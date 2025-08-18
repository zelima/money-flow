"""
Georgian Budget Data Pipeline - Cloud Function
Migrated from GitHub Actions to GCP Cloud Functions

This function processes Georgian budget data using the existing data-pipeline directory
and datapackage-pipelines framework, exactly as it works in GitHub Actions.
"""

import os
import json
import shutil
import requests
from datetime import datetime, timezone
from google.cloud import storage
from google.cloud import logging as cloud_logging

# Simple JSON response helper (replaces Flask jsonify)
def jsonify(data, status_code=200):
    """Simple JSON response helper"""
    import json
    return json.dumps(data), status_code, {'Content-Type': 'application/json'}
# Cloud Functions 2nd gen imports
import base64
import tempfile
import subprocess
import sys

# Setup Cloud Logging
client = cloud_logging.Client()
client.setup_logging()

import logging
logger = logging.getLogger(__name__)

# Configuration from environment variables
DATA_BUCKET_NAME = os.environ.get('DATA_BUCKET_NAME')
PROJECT_ID = os.environ.get('PROJECT_ID')
ENVIRONMENT = os.environ.get('ENVIRONMENT', 'prod')
GEOSTAT_URL = os.environ.get('GEOSTAT_URL', 'https://geostat.ge/media/72030/saxelmwifo-biujeti-funqcionalur-chrilshi.xlsx')


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
            logger.info(f"📁 Copying pipeline from {source_pipeline_dir} to {pipeline_dir}")
            shutil.copytree(source_pipeline_dir, pipeline_dir, dirs_exist_ok=True)
        else:
            logger.error(f"❌ Pipeline source directory not found: {source_pipeline_dir}")
            raise FileNotFoundError(f"data-pipeline directory not found at {source_pipeline_dir}")
        
        # Install data-pipeline requirements
        requirements_file = os.path.join(pipeline_dir, "requirements.txt")
        if os.path.exists(requirements_file):
            logger.info("📦 Installing data-pipeline requirements...")
            subprocess.check_call([
                sys.executable, "-m", "pip", "install", "-r", requirements_file
            ])
        
        logger.info(f"✅ Pipeline environment ready at {pipeline_dir}")
        return pipeline_dir, data_dir
        
    except Exception as e:
        logger.error(f"❌ Failed to setup pipeline environment: {e}")
        raise


def run_datapackage_pipeline(pipeline_dir: str, work_dir: str) -> tuple:
    """Run the datapackage-pipelines exactly as in GitHub Actions"""
    logger.info("🇬🇪 Running Georgian budget data pipeline with datapackage-pipelines...")
    
    try:
        # Change to the data-pipeline directory
        original_cwd = os.getcwd()
        os.chdir(pipeline_dir)
        
        # Set environment variables for pipeline execution
        env = os.environ.copy()
        env.update({
            'PYTHONPATH': pipeline_dir,
            'DPP_PROCESSOR_PATH': os.path.join(pipeline_dir, 'processors')
        })
        
        # Run the pipeline exactly as in GitHub Actions
        logger.info("🚀 Executing: dpp run all --verbose")
        result = subprocess.run(
            ["dpp", "run", "all", "--verbose"],
            cwd=pipeline_dir,
            env=env,
            capture_output=True,
            text=True,
            timeout=480  # 8 minutes timeout
        )
        
        # Log the output
        if result.stdout:
            logger.info(f"📊 Pipeline stdout:\n{result.stdout}")
        if result.stderr:
            logger.warning(f"⚠️ Pipeline stderr:\n{result.stderr}")
        
        # Check if pipeline succeeded
        if result.returncode != 0:
            logger.error(f"❌ Pipeline failed with return code {result.returncode}")
            raise subprocess.CalledProcessError(result.returncode, "dpp run all")
        
        logger.info("✅ Pipeline completed successfully")
        
        # Return to original directory
        os.chdir(original_cwd)
        
        # Find the generated files in the data/processed directory
        processed_dir = os.path.join(work_dir, "data", "processed")
        csv_path = os.path.join(processed_dir, "georgian_budget.csv")
        json_path = os.path.join(processed_dir, "georgian_budget.json")
        datapackage_path = os.path.join(processed_dir, "datapackage.json")
        
        # Verify files exist
        files_found = []
        for file_path, name in [(csv_path, "CSV"), (json_path, "JSON"), (datapackage_path, "datapackage")]:
            if os.path.exists(file_path):
                files_found.append(file_path)
                logger.info(f"✅ Found {name} file: {file_path}")
            else:
                logger.warning(f"⚠️ {name} file not found: {file_path}")
        
        if not files_found:
            raise FileNotFoundError("No processed files found after pipeline execution")
        
        return csv_path, json_path, datapackage_path
        
    except subprocess.TimeoutExpired:
        logger.error("❌ Pipeline execution timed out")
        raise
    except Exception as e:
        logger.error(f"❌ Pipeline execution failed: {e}")
        raise
    finally:
        # Always return to original directory
        os.chdir(original_cwd)


def upload_to_storage(files: list, bucket_name: str):
    """Upload processed files to Cloud Storage"""
    logger.info(f"☁️ Uploading files to Cloud Storage bucket: {bucket_name}")
    
    try:
        storage_client = storage.Client()
        bucket = storage_client.bucket(bucket_name)
        
        uploaded_files = []
        for local_path in files:
            filename = os.path.basename(local_path)
            blob_name = f"processed/{filename}"
            
            blob = bucket.blob(blob_name)
            blob.upload_from_filename(local_path)
            
            logger.info(f"✅ Uploaded {filename} to {blob_name}")
            uploaded_files.append(blob_name)
        
        return uploaded_files
        
    except Exception as e:
        logger.error(f"❌ Error uploading to storage: {e}")
        raise


def process_budget_data(cloud_event):
    """
    Main Cloud Function entry point triggered by Pub/Sub
    Processes Georgian budget data and stores results in Cloud Storage
    """
    logger.info("🇬🇪 Starting Georgian Budget Data Pipeline")
    
    # Parse the Pub/Sub message
    try:
        if cloud_event.data:
            message_data = base64.b64decode(cloud_event.data['message']['data']).decode('utf-8')
            trigger_data = json.loads(message_data)
        else:
            trigger_data = {"trigger_type": "manual"}
            
        logger.info(f"🔄 Trigger data: {trigger_data}")
        
    except Exception as e:
        logger.warning(f"⚠️ Could not parse trigger data: {e}, using defaults")
        trigger_data = {"trigger_type": "unknown"}
    
    # Check if this is just a data availability check
    if trigger_data.get('check_only', False):
        logger.info("🔍 Performing data availability check only")
        try:
            response = requests.head(GEOSTAT_URL, timeout=30)
            if response.status_code == 200:
                logger.info("✅ Data source is available")
                return {"status": "available", "url": GEOSTAT_URL}
            else:
                logger.warning(f"⚠️ Data source returned status {response.status_code}")
                return {"status": "unavailable", "status_code": response.status_code}
        except Exception as e:
            logger.error(f"❌ Data availability check failed: {e}")
            return {"status": "error", "error": str(e)}
    
    # Main processing
    with tempfile.TemporaryDirectory() as work_dir:
        try:
            # Set up the data-pipeline environment (copy from function source)
            pipeline_dir, data_dir = setup_pipeline_environment(work_dir)
            
            # Run the datapackage-pipelines exactly as in GitHub Actions
            csv_path, json_path, datapackage_path = run_datapackage_pipeline(pipeline_dir, work_dir)
            
            # Upload to Cloud Storage
            files_to_upload = [f for f in [csv_path, json_path, datapackage_path] if os.path.exists(f)]
            uploaded_files = upload_to_storage(files_to_upload, DATA_BUCKET_NAME)
            
            # Create response
            result = {
                "status": "success",
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "trigger_type": trigger_data.get('trigger_type', 'unknown'),
                "uploaded_files": uploaded_files,
                "bucket": DATA_BUCKET_NAME,
                "urls": {
                    "csv": f"gs://{DATA_BUCKET_NAME}/processed/georgian_budget.csv",
                    "json": f"gs://{DATA_BUCKET_NAME}/processed/georgian_budget.json",
                    "datapackage": f"gs://{DATA_BUCKET_NAME}/processed/datapackage.json"
                }
            }
            
            logger.info(f"🎉 Pipeline completed successfully: {result}")
            return result
            
        except Exception as e:
            logger.error(f"❌ Pipeline failed: {e}")
            error_result = {
                "status": "error",
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "trigger_type": trigger_data.get('trigger_type', 'unknown'),
                "error": str(e)
            }
            return error_result





def health_check():
    """Health check endpoint"""
    return jsonify({
        "name": "Georgian Budget Data Pipeline",
        "status": "healthy",
        "version": "1.0.0",
        "environment": ENVIRONMENT,
        "bucket": DATA_BUCKET_NAME,
        "trigger_type": "event_triggered",
        "endpoints": {
            "health": "GET / - This health check endpoint",
            "manual_trigger": "POST /trigger - Manual pipeline trigger",
            "event_trigger": "process_budget_data function for Pub/Sub"
        }
    })


def test_endpoint():
    """Simple test endpoint"""
    return jsonify({
        "message": "Function is working!",
        "timestamp": datetime.now(timezone.utc).isoformat()
    })


def manual_trigger():
    """Manual trigger endpoint"""
    try:
        # Get request data
        request_json = request.get_json(silent=True) or {}
        
        # Create trigger message
        trigger_message = {
            "trigger_type": "manual_http",
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "year": request_json.get("year", "current"),
            "force_download": request_json.get("force_download", True),
            "check_only": request_json.get("check_only", False)
        }
        
        logger.info(f"🚀 Direct HTTP trigger: {trigger_message}")
        
        # Check if this is just a data availability check
        if trigger_message.get('check_only', False):
            logger.info("🔍 Performing data availability check only")
            try:
                response = requests.head(GEOSTAT_URL, timeout=30)
                if response.status_code == 200:
                    logger.info("✅ Data source is available")
                    return jsonify({"status": "available", "url": GEOSTAT_URL})
                else:
                    logger.warning(f"⚠️ Data source returned status {response.status_code}")
                    return jsonify({"status": "unavailable", "status_code": response.status_code})
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
                csv_path, json_path, datapackage_path = run_datapackage_pipeline(pipeline_dir, work_dir)
                
                # Upload to Cloud Storage
                files_to_upload = [f for f in [csv_path, json_path, datapackage_path] if os.path.exists(f)]
                uploaded_files = upload_to_storage(files_to_upload, DATA_BUCKET_NAME)
                
                # Create response
                result = {
                    "status": "success",
                    "timestamp": datetime.now(timezone.utc).isoformat(),
                    "trigger_type": trigger_message.get('trigger_type', 'unknown'),
                    "uploaded_files": uploaded_files,
                    "bucket": DATA_BUCKET_NAME,
                    "urls": {
                        "csv": f"gs://{DATA_BUCKET_NAME}/processed/georgian_budget.csv",
                        "datapackage": f"gs://{DATA_BUCKET_NAME}/processed/datapackage.json"
                    }
                }
                
                logger.info(f"🎉 Pipeline completed successfully via HTTP: {result}")
                return jsonify(result)
                
            except Exception as e:
                logger.error(f"❌ Pipeline failed via HTTP: {e}")
                error_result = {
                    "status": "error",
                    "timestamp": datetime.now(timezone.utc).isoformat(),
                    "trigger_type": trigger_message.get('trigger_type', 'unknown'),
                    "error": str(e)
                }
                return jsonify(error_result)
        
    except Exception as e:
        logger.error(f"❌ Failed to trigger pipeline: {e}")
        return jsonify({"status": "error", "error": str(e)}), 500


# Cloud Functions 2nd gen entry point
def http_handler(request):
    """HTTP handler for Cloud Functions 2nd gen"""
    # Handle different HTTP methods
    if request.method == 'GET':
        if request.path == '/':
            return health_check()
        elif request.path == '/test':
            return test_endpoint()
        else:
            return jsonify({"error": "Endpoint not found"}), 404
    
    elif request.method == 'POST':
        if request.path == '/':
            return manual_trigger()
        elif request.path == '/trigger':
            return manual_trigger()
        else:
            return jsonify({"error": "Endpoint not found"}), 404
    
    else:
        return jsonify({"error": "Method not allowed"}), 405


# Event trigger entry point
def process_budget_data_event(cloud_event):
    """Event trigger entry point for Cloud Functions 2nd gen"""
    return process_budget_data(cloud_event)