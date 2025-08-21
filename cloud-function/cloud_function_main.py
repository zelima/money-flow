"""
Georgian Budget Data Pipeline - Cloud Function
Migrated from GitHub Actions to GCP Cloud Functions

This function processes Georgian budget data using the existing data-pipeline directory
and datapackage-pipelines framework, exactly as it works in GitHub Actions.
"""

import json
import logging
import os
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime, timezone

import requests
from google.cloud import logging as cloud_logging
from google.cloud import storage

# Setup Cloud Logging
client = cloud_logging.Client()
client.setup_logging()

logger = logging.getLogger(__name__)

# Configuration from environment variables
DATA_BUCKET_NAME = os.environ.get("DATA_BUCKET_NAME")
PROJECT_ID = os.environ.get("PROJECT_ID")
ENVIRONMENT = os.environ.get("ENVIRONMENT", "prod")
GEOSTAT_URL = os.environ.get(
    "GEOSTAT_URL",
    "https://geostat.ge/media/72030/saxelmwifo-biujeti-funqcionalur-chrilshi.xlsx",
)


# Simple JSON response helper (replaces Flask jsonify)
def jsonify(data, status_code=200):
    """Simple JSON response helper"""
    return json.dumps(data), status_code, {"Content-Type": "application/json"}


def setup_pipeline_environment(work_dir: str):
    """Set up the data-pipeline directory structure and install dependencies"""
    logger.info("🔧 Setting up data-pipeline environment...")

    try:
        # Create directory structure exactly as in the repository
        data_dir = os.path.join(work_dir, "data")
        os.makedirs(os.path.join(data_dir, "raw"), exist_ok=True)
        os.makedirs(os.path.join(data_dir, "processed"), exist_ok=True)

        pipeline_dir = os.path.join(work_dir, "data-pipeline")
        os.makedirs(pipeline_dir, exist_ok=True)

        # Copy the data-pipeline directory from the function source
        # The data-pipeline directory should be included in the function deployment
        source_pipeline_dir = "/workspace/data-pipeline"
        if os.path.exists(source_pipeline_dir):
            logger.info(
                f"📁 Copying pipeline from {source_pipeline_dir} to {pipeline_dir}"
            )
            shutil.copytree(source_pipeline_dir, pipeline_dir, dirs_exist_ok=True)
        else:
            logger.error(
                f"❌ Pipeline source directory not found: {source_pipeline_dir}"
            )
            raise FileNotFoundError(
                f"data-pipeline directory not found at {source_pipeline_dir}"
            )

        # Install data-pipeline requirements
        requirements_file = os.path.join(pipeline_dir, "requirements.txt")
        if os.path.exists(requirements_file):
            logger.info("📦 Installing data-pipeline requirements...")
            subprocess.check_call(
                [sys.executable, "-m", "pip", "install", "-r", requirements_file]
            )

        logger.info("✅ Pipeline environment ready at {}".format(pipeline_dir))
        return pipeline_dir, data_dir

    except Exception as e:
        logger.error(f"❌ Failed to setup pipeline environment: {e}")
        raise


def run_datapackage_pipeline(pipeline_dir: str, work_dir: str) -> tuple:
    """Run the datapackage-pipelines exactly as in GitHub Actions"""
    logger.info(
        "🇬🇪 Running Georgian budget data pipeline with datapackage-pipelines..."
    )

    try:
        # Change to the data-pipeline directory
        original_cwd = os.getcwd()
        os.chdir(pipeline_dir)

        # Set environment variables for pipeline execution
        env = os.environ.copy()
        env.update(
            {
                "PYTHONPATH": pipeline_dir,
                "DPP_PROCESSOR_PATH": os.path.join(pipeline_dir, "processors"),
            }
        )

        # Run the pipeline exactly as in GitHub Actions
        logger.info("🚀 Executing: dpp run all --verbose")
        result = subprocess.run(
            ["dpp", "run", "all", "--verbose"],
            cwd=pipeline_dir,
            env=env,
            capture_output=True,
            text=True,
            timeout=480,  # 8 minutes timeout
        )

        # Restore original working directory
        os.chdir(original_cwd)

        if result.returncode != 0:
            logger.error(f"❌ Pipeline failed with return code {result.returncode}")
            logger.error(f"stdout: {result.stdout}")
            logger.error(f"stderr: {result.stderr}")
            raise RuntimeError(f"Pipeline failed: {result.stderr}")

        logger.info("✅ Pipeline completed successfully")

        # Find output files
        csv_path = os.path.join(work_dir, "data", "processed", "georgian_budget.csv")
        json_path = os.path.join(work_dir, "data", "processed", "georgian_budget.json")
        datapackage_path = os.path.join(
            work_dir, "data", "processed", "datapackage.json"
        )

        # Verify files exist
        if not os.path.exists(csv_path):
            raise FileNotFoundError(f"CSV output not found: {csv_path}")
        if not os.path.exists(json_path):
            raise FileNotFoundError(f"JSON output not found: {json_path}")
        if not os.path.exists(datapackage_path):
            raise FileNotFoundError(f"Datapackage output not found: {datapackage_path}")

        logger.info("📁 Output files generated:")
        logger.info(f"  CSV: {csv_path}")
        logger.info(f"  JSON: {json_path}")
        logger.info(f"  Datapackage: {datapackage_path}")

        return csv_path, json_path, datapackage_path

    except Exception as e:
        logger.error(f"❌ Pipeline execution failed: {e}")
        raise


def upload_to_storage(files: list, bucket_name: str) -> list:
    """Upload processed files to Cloud Storage"""
    logger.info(f"☁️ Uploading {len(files)} files to Cloud Storage...")

    try:
        storage_client = storage.Client()
        bucket = storage_client.bucket(bucket_name)

        uploaded_files = []
        for file_path in files:
            if os.path.exists(file_path):
                # Determine destination path in storage
                filename = os.path.basename(file_path)
                destination_blob_name = f"processed/{filename}"

                # Upload file
                blob = bucket.blob(destination_blob_name)
                blob.upload_from_filename(file_path)

                logger.info(f"✅ Uploaded {filename} to {destination_blob_name}")
                uploaded_files.append(destination_blob_name)
            else:
                logger.warning(f"⚠️ File not found: {file_path}")

        return uploaded_files

    except Exception as e:
        logger.error(f"❌ Failed to upload files to storage: {e}")
        raise


def process_budget_data(trigger_data: dict) -> dict:
    """Main processing function for both event and HTTP triggers"""
    logger.info("🚀 Starting Georgian Budget Data Pipeline")

    try:
        # Create temporary working directory
        with tempfile.TemporaryDirectory() as work_dir:
            logger.info(f"📁 Working directory: {work_dir}")

            # Set up the data-pipeline environment
            pipeline_dir, data_dir = setup_pipeline_environment(work_dir)

            # Run the datapackage-pipelines
            csv_path, json_path, datapackage_path = run_datapackage_pipeline(
                pipeline_dir, work_dir
            )

            # Upload to Cloud Storage
            files_to_upload = [csv_path, json_path, datapackage_path]
            uploaded_files = upload_to_storage(files_to_upload, DATA_BUCKET_NAME)

            # Create success result
            result = {
                "status": "success",
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "trigger_type": trigger_data.get("trigger_type", "unknown"),
                "uploaded_files": uploaded_files,
                "bucket": DATA_BUCKET_NAME,
                "urls": {
                    "csv": f"gs://{DATA_BUCKET_NAME}/processed/georgian_budget.csv",
                    "json": f"gs://{DATA_BUCKET_NAME}/processed/georgian_budget.json",
                    "datapackage": (
                        f"gs://{DATA_BUCKET_NAME}/processed/datapackage.json"
                    ),
                },
            }

            logger.info("🎉 Pipeline completed successfully: {}".format(result))
            return result

    except Exception as e:
        logger.error(f"❌ Pipeline failed: {e}")
        error_result = {
            "status": "error",
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "trigger_type": trigger_data.get("trigger_type", "unknown"),
            "error": str(e),
        }
        return error_result


def health_check():
    """Health check endpoint"""
    return jsonify(
        {
            "name": "Georgian Budget Data Pipeline",
            "status": "healthy",
            "version": "1.0.0",
            "environment": ENVIRONMENT,
            "bucket": DATA_BUCKET_NAME,
            "trigger_type": "event_triggered",
            "endpoints": {
                "health": "GET / - This health check endpoint",
                "manual_trigger": "POST /trigger - Manual pipeline trigger",
                "event_trigger": "process_budget_data function for Pub/Sub",
            },
        }
    )


def test_endpoint():
    """Simple test endpoint"""
    return jsonify(
        {
            "message": "Function is working!",
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
    )


def manual_trigger(request_data):
    """Manual trigger endpoint"""
    try:
        # Get request data
        request_json = request_data.get_json(silent=True) or {}

        # Create trigger message
        trigger_message = {
            "trigger_type": "manual_http",
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "year": request_json.get("year", "current"),
            "force_download": request_json.get("force_download", True),
            "check_only": request_json.get("check_only", False),
        }

        logger.info("🚀 Direct HTTP trigger: {}".format(trigger_message))

        # Check if this is just a data availability check
        if trigger_message.get("check_only", False):
            logger.info("🔍 Performing data availability check only")
            try:
                response = requests.head(GEOSTAT_URL, timeout=30)
                if response.status_code == 200:
                    logger.info("✅ Data source is available")
                    return jsonify({"status": "available", "url": GEOSTAT_URL})
                else:
                    logger.warning(
                        f"⚠️ Data source returned status {response.status_code}"
                    )
                    return jsonify(
                        {"status": "unavailable", "status_code": response.status_code}
                    )
            except Exception as e:
                logger.error(f"❌ Data availability check failed: {e}")
                return jsonify({"status": "error", "error": str(e)})

        # Execute the pipeline directly
        logger.info("🇬🇪 Starting Georgian Budget Data Pipeline via HTTP")

        # Main processing
        with tempfile.TemporaryDirectory() as work_dir:
            try:
                # Set up the data-pipeline environment (copy from function source)
                pipeline_dir, data_dir = setup_pipeline_environment(work_dir)

                # Run the datapackage-pipelines exactly as in GitHub Actions
                csv_path, json_path, datapackage_path = run_datapackage_pipeline(
                    pipeline_dir, work_dir
                )

                # Upload to Cloud Storage
                files_to_upload = [
                    f
                    for f in [csv_path, json_path, datapackage_path]
                    if os.path.exists(f)
                ]
                uploaded_files = upload_to_storage(files_to_upload, DATA_BUCKET_NAME)

                # Create response
                result = {
                    "status": "success",
                    "timestamp": datetime.now(timezone.utc).isoformat(),
                    "trigger_type": trigger_message.get("trigger_type", "unknown"),
                    "uploaded_files": uploaded_files,
                    "bucket": DATA_BUCKET_NAME,
                    "urls": {
                        "csv": f"gs://{DATA_BUCKET_NAME}/processed/georgian_budget.csv",
                        "json": (
                            f"gs://{DATA_BUCKET_NAME}/processed/georgian_budget.json"
                        ),
                        "datapackage": (
                            f"gs://{DATA_BUCKET_NAME}/processed/datapackage.json"
                        ),
                    },
                }

                logger.info(
                    "🎉 Pipeline completed successfully via HTTP: {}".format(result)
                )
                return jsonify(result)

            except Exception as e:
                logger.error(f"❌ Pipeline failed via HTTP: {e}")
                error_result = {
                    "status": "error",
                    "timestamp": datetime.now(timezone.utc).isoformat(),
                    "trigger_type": trigger_message.get("trigger_type", "unknown"),
                    "error": str(e),
                }
                return jsonify(error_result)

    except Exception as e:
        logger.error(f"❌ Failed to trigger pipeline: {e}")
        return jsonify({"status": "error", "error": str(e)}), 500


# Cloud Functions 2nd gen entry point
def http_handler(request):
    """HTTP handler for Cloud Functions 2nd gen"""
    # Handle different HTTP methods
    if request.method == "GET":
        if request.path == "/":
            return health_check()
        elif request.path == "/test":
            return test_endpoint()
        else:
            return jsonify({"error": "Endpoint not found"}), 404

    elif request.method == "POST":
        if request.path == "/":
            return manual_trigger(request)
        elif request.path == "/trigger":
            return manual_trigger(request)
        else:
            return jsonify({"error": "Endpoint not found"}), 404

    else:
        return jsonify({"error": "Method not allowed"}), 405


# Event trigger entry point
def process_budget_data_event(cloud_event):
    """Event trigger entry point for Cloud Functions 2nd gen"""
    return process_budget_data(cloud_event)
