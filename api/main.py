import json
import logging
import os
from typing import List, Optional

from fastapi import Depends, FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from google.cloud import storage
from models import (
    APIResponse,
    BudgetDrillDown,
    BudgetRecord,
    BudgetSummary,
    DepartmentDetail,
    DepartmentTrend,
    DrillDownSummary,
    SubDepartment,
    YearSummary,
)
from sqlalchemy.orm import Session

from database import (
    get_budget_drill_down,
    get_db,
    get_department_by_name,
    get_sub_departments_by_department,
    test_connection,
)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="Georgian Budget Data API",
    description="API for analyzing Georgian government budget data from 2002-2020",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global variable to store budget data
budget_data: List[dict] = None

# Environment configuration
ENVIRONMENT = os.getenv("ENVIRONMENT", "local")
CLOUD_STORAGE_BUCKET = os.getenv("CLOUD_STORAGE_BUCKET", "")
CLOUD_STORAGE_PREFIX = os.getenv("CLOUD_STORAGE_PREFIX", "data/processed")


def load_budget_data_from_cloud_storage():
    """Load budget data from Google Cloud Storage"""
    global budget_data

    try:
        logger.info("☁️ Fetching budget data from Cloud Storage...")

        # Initialize Cloud Storage client
        storage_client = storage.Client()
        bucket = storage_client.bucket(CLOUD_STORAGE_BUCKET)

        # Get JSON file from Cloud Storage (preferred over CSV)
        json_blob = bucket.blob(f"{CLOUD_STORAGE_PREFIX}/georgian_budget.json")
        if not json_blob.exists():
            raise Exception(
                f"""
                JSON file not found in bucket:
                    {CLOUD_STORAGE_BUCKET}/{CLOUD_STORAGE_PREFIX}/georgian_budget.json
                """
            )

        # Download and read JSON data
        json_content = json_blob.download_as_text()
        budget_data = json.loads(json_content)

        # Validate data structure
        if not isinstance(budget_data, list) or len(budget_data) == 0:
            raise Exception("Invalid JSON data structure - expected non-empty list")

        # Get data statistics
        years = [record.get("year") for record in budget_data if record.get("year")]
        departments = [
            record.get("name") for record in budget_data if record.get("name")
        ]
        budgets = [record.get("budget") or 0.0 for record in budget_data]

        if years and departments and budgets:
            years_range = f"{min(years)}-{max(years)}"
            departments_count = len(set(departments))
            total_budget = sum(budgets)

            logger.info(
                f"✅ Loaded {len(budget_data)} budget records from Cloud Storage"
            )
            logger.info(
                f"""
                📅 Years: {years_range}
                🏛️ Departments: {departments_count}
                💰 Total: {total_budget:,.1f}M ₾
                """
            )
            logger.info(f"☁️ Data source: Cloud Storage bucket {CLOUD_STORAGE_BUCKET}")
        else:
            logger.warning("⚠️ Some budget records missing required fields")

        # Try to get metadata from datapackage.json
        try:
            meta_blob = bucket.blob(f"{CLOUD_STORAGE_PREFIX}/datapackage.json")
            if meta_blob.exists():
                metadata = json.loads(meta_blob.download_as_text())
                last_update = metadata.get("updated", "Unknown")
                logger.info(f"📊 Data last updated: {last_update}")
        except Exception as e:
            logger.warning(f"Could not fetch metadata from datapackage.json: {e}")

    except Exception as e:
        logger.error(f"❌ Error loading budget data from Cloud Storage: {e}")
        raise HTTPException(
            status_code=503, detail=f"Unable to fetch data from Cloud Storage: {str(e)}"
        )


def load_budget_data():
    """Load budget data from Cloud Storage"""
    if not CLOUD_STORAGE_BUCKET:
        raise HTTPException(
            status_code=500, detail="Cloud Storage bucket not configured"
        )

    load_budget_data_from_cloud_storage()


# Load data on startup
@app.on_event("startup")
async def startup_event():
    # Test PostgreSQL connection
    db_connected = test_connection()
    if db_connected:
        logger.info("🐘 PostgreSQL connection verified")
    else:
        logger.warning("⚠️ PostgreSQL connection failed - drill-down features disabled")

    # Load budget data from Cloud Storage
    load_budget_data()


@app.get("/", response_model=APIResponse)
async def root():
    """Root endpoint with API information"""
    # Get real-time data stats
    data_stats = {}
    if budget_data is not None:
        years = [record.get("year") for record in budget_data if record.get("year")]
        departments = [
            record.get("name") for record in budget_data if record.get("name")
        ]
        budgets = [record.get("budget") or 0.0 for record in budget_data]

        if years and departments and budgets:
            data_stats = {
                "records": len(budget_data),
                "years": f"{min(years)}-{max(years)}",
                "departments": len(set(departments)),
                "total_budget_millions": f"{sum(budgets):,.1f}M ₾",
                "data_source": "☁️ Cloud Storage",
                "environment": ENVIRONMENT,
                "drill_down_enabled": "🐘 PostgreSQL sub-departments available"
                if test_connection()
                else "⚠️ PostgreSQL not available",
            }

    return APIResponse(
        data={
            "message": "Budget Data API",
            "version": "1.0.0",
            "description": "Government budget data processed by automated pipeline",
            "data_statistics": data_stats,
            "endpoints": [
                "/docs - API documentation",
                "/health - Health check",
                "/budget - Get budget data",
                "/summary - Data summary",
                "/departments - List departments",
                "/trends/{department} - Department trends",
                "/years/{year} - Year summary",
                "/search - Search departments",
                "/drill-down/{department} - Sub-department breakdown",
                "/drill-down/analysis/{department}/{year} - drill-down analysis",
            ],
        }
    )


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    global budget_data

    # Check database connection
    db_status = "connected" if test_connection() else "disconnected"

    return {
        "status": "healthy",
        "environment": ENVIRONMENT,
        "data_loaded": budget_data is not None,
        "records_count": len(budget_data) if budget_data is not None else 0,
        "database": db_status,
        "data_source": "cloud_storage",
        "cloud_storage_bucket": CLOUD_STORAGE_BUCKET,
    }


@app.get("/budget", response_model=List[BudgetRecord])
async def get_budget_data(
    year: Optional[int] = Query(None, description="Filter by year"),
    department: Optional[str] = Query(
        None, description="Filter by department name (partial match)"
    ),
    min_budget: Optional[float] = Query(None, description="Minimum budget amount"),
    max_budget: Optional[float] = Query(None, description="Maximum budget amount"),
    limit: int = Query(100, le=1000, description="Limit number of results"),
    offset: int = Query(0, ge=0, description="Offset for pagination"),
):
    """Get budget data with optional filters"""
    global budget_data

    if budget_data is None:
        raise HTTPException(status_code=500, detail="Budget data not loaded")

    # Apply filters
    filtered_data = budget_data.copy()

    if year:
        filtered_data = [
            record for record in filtered_data if record.get("year") == float(year)
        ]

    if department:
        filtered_data = [
            record
            for record in filtered_data
            if record.get("name")
            and department.lower() in record.get("name", "").lower()
        ]

    if min_budget is not None:
        filtered_data = [
            record
            for record in filtered_data
            if (record.get("budget") or 0.0) >= min_budget
        ]

    if max_budget is not None:
        filtered_data = [
            record
            for record in filtered_data
            if (record.get("budget") or 0.0) <= max_budget
        ]

    # Apply pagination
    filtered_data = filtered_data[offset : offset + limit]

    # Convert to list of BudgetRecord objects
    records = []
    for record in filtered_data:
        # Handle null budget values by converting them to 0
        budget_value = record.get("budget")
        if budget_value is None:
            budget_value = 0.0
        else:
            budget_value = float(budget_value)

        records.append(
            BudgetRecord(
                year=int(float(record.get("year", 0))),
                budget=budget_value,
                name=str(record.get("name", "")),
            )
        )

    return records


@app.get("/summary", response_model=BudgetSummary)
async def get_summary():
    """Get overall budget data summary"""
    global budget_data

    if budget_data is None:
        raise HTTPException(status_code=500, detail="Budget data not loaded")

    years = [record.get("year") for record in budget_data if record.get("year")]
    budgets = [record.get("budget") or 0.0 for record in budget_data]
    departments = [record.get("name") for record in budget_data if record.get("name")]

    if not years or not budgets or not departments:
        raise HTTPException(status_code=500, detail="Invalid data structure")

    return BudgetSummary(
        total_records=len(budget_data),
        year_range=(min(years), max(years)),
        total_budget=sum(budgets),
        departments_count=len(set(departments)),
    )


@app.get("/departments", response_model=List[str])
async def get_departments():
    """Get list of all departments"""
    global budget_data

    if budget_data is None:
        raise HTTPException(status_code=500, detail="Budget data not loaded")

    departments = [record.get("name") for record in budget_data if record.get("name")]
    return sorted(list(set(departments)))


@app.get("/trends/{department}", response_model=DepartmentTrend)
async def get_department_trend(department: str):
    """Get budget trend for a specific department"""
    global budget_data

    if budget_data is None:
        raise HTTPException(status_code=500, detail="Budget data not loaded")

    # Find department records (partial match)
    dept_data = [
        record
        for record in budget_data
        if record.get("name") and department.lower() in record.get("name", "").lower()
    ]

    if not dept_data:
        raise HTTPException(
            status_code=404, detail=f"Department '{department}' not found"
        )

    # Sort by year
    dept_data = sorted(dept_data, key=lambda x: x.get("year", 0))

    # Calculate growth rate (if we have more than one year)
    growth_rate = None
    if len(dept_data) > 1:
        first_budget = dept_data[0].get("budget") or 0.0
        last_budget = dept_data[-1].get("budget") or 0.0
        years_span = dept_data[-1].get("year", 0) - dept_data[0].get("year", 0)
        if first_budget > 0 and years_span > 0:
            growth_rate = ((last_budget / first_budget) ** (1 / years_span) - 1) * 100

    return DepartmentTrend(
        department=dept_data[0].get("name", ""),
        years=[int(float(record.get("year", 0))) for record in dept_data],
        budgets=[record.get("budget") or 0.0 for record in dept_data],
        total_budget=sum(record.get("budget") or 0.0 for record in dept_data),
        avg_budget=sum(record.get("budget") or 0.0 for record in dept_data)
        / len(dept_data),
        growth_rate=growth_rate,
    )


@app.get("/years/{year}", response_model=YearSummary)
async def get_year_summary(year: int):
    """Get budget summary for a specific year"""
    global budget_data

    if budget_data is None:
        raise HTTPException(status_code=500, detail="Budget data not loaded")

    year_data = [record for record in budget_data if record.get("year") == float(year)]

    if not year_data:
        raise HTTPException(status_code=404, detail=f"No data found for year {year}")

    # Sort by budget descending
    year_data = sorted(year_data, key=lambda x: x.get("budget") or 0.0, reverse=True)

    departments = []
    for record in year_data:
        departments.append(
            {"name": record.get("name", ""), "budget": record.get("budget") or 0.0}
        )

    return YearSummary(
        year=year,
        total_budget=sum(record.get("budget") or 0.0 for record in year_data),
        departments=departments,
        top_departments=departments[:10],  # Top 10 departments
    )


@app.get("/search")
async def search_departments(
    q: str = Query(..., min_length=2, description="Search query for department names"),
    limit: int = Query(10, le=50, description="Limit number of results"),
):
    """Search departments by name"""
    global budget_data

    if budget_data is None:
        raise HTTPException(status_code=500, detail="Budget data not loaded")

    # Search in department names
    matching_depts = [
        record.get("name")
        for record in budget_data
        if record.get("name") and q.lower() in record.get("name", "").lower()
    ]

    unique_depts = list(set(matching_depts))

    return {
        "query": q,
        "results": unique_depts[:limit],
        "total_found": len(unique_depts),
    }


# New PostgreSQL drill-down endpoints
@app.get("/drill-down/{department}", response_model=DepartmentDetail)
async def get_department_drill_down(
    department: str,
    year: Optional[int] = Query(None, description="Year for budget data"),
    db: Session = Depends(get_db),
):
    """
    Get sub-department breakdown for a specific department
    Combines PostgreSQL sub-department data with Cloud Storage main department data
    """
    # Check if database is available
    if db is None:
        raise HTTPException(
            status_code=503,
            detail="database not available. Please start the database.",
        )

    # Find department in PostgreSQL
    dept = get_department_by_name(db, department)
    if not dept:
        raise HTTPException(
            status_code=404,
            detail=f"Department '{department}' not found in drill-down database",
        )

    # Get sub-departments with optional budget data
    sub_depts = get_sub_departments_by_department(db, dept.id, year)

    # Get main department budget from Cloud Storage data (if available)
    main_budget = None
    if budget_data is not None and year:
        dept_records = [
            record
            for record in budget_data
            if record.get("name") == department and record.get("year") == float(year)
        ]
        if dept_records:
            budget_value = dept_records[0].get("budget")
            main_budget = float(budget_value) if budget_value is not None else 0.0

    # Convert to response models
    sub_dept_models = []
    for sub_dept in sub_depts:
        budget_amount = None
        notes = None

        # Always calculate from allocation percentage when we have main budget data
        if main_budget:
            # Calculate from allocation percentage (this is the correct approach)
            budget_amount = main_budget * float(sub_dept.allocation_percentage) / 100.0
            # Try to get notes from stored budget allocations
            if hasattr(sub_dept, "budget_allocations") and sub_dept.budget_allocations:
                for budget in sub_dept.budget_allocations:
                    if budget.year == year:
                        notes = budget.notes  # Keep notes but calculate amount
                        break

        sub_dept_models.append(
            SubDepartment(
                id=sub_dept.id,
                name_english=sub_dept.name_english,
                name_georgian=sub_dept.name_georgian,
                allocation_percentage=float(sub_dept.allocation_percentage),
                employee_count=sub_dept.employee_count,
                projects_count=sub_dept.projects_count,
                budget_amount=budget_amount,
                notes=notes,
            )
        )

    return DepartmentDetail(
        id=dept.id,
        name_english=dept.name_english,
        name_georgian=dept.name_georgian,
        description=dept.description,
        total_budget=main_budget,
        sub_departments=sub_dept_models,
    )


@app.get("/drill-down/analysis/{department}/{year}", response_model=DrillDownSummary)
async def get_drill_down_analysis(
    department: str, year: int, db: Session = Depends(get_db)
):
    """
    Get comprehensive drill-down analysis for a department and year
    Shows how the main department budget is allocated across sub-departments
    """
    # Check if database is available
    if db is None:
        raise HTTPException(
            status_code=503,
            detail="Database not available. Please start the database.",
        )

    # Get main department budget from Cloud Storage data
    if budget_data is None:
        raise HTTPException(
            status_code=503, detail="Cloud Storage budget data not available"
        )

    dept_records = [
        record
        for record in budget_data
        if record.get("name") == department and record.get("year") == float(year)
    ]
    if not dept_records:
        raise HTTPException(
            status_code=404, detail=f"No budget data found for {department} in {year}"
        )

    budget_value = dept_records[0].get("budget")
    main_budget = float(budget_value) if budget_value is not None else 0.0

    # Get drill-down data from PostgreSQL
    drill_down_data = get_budget_drill_down(db, department, year, limit=50)

    # Convert to sub-department models and calculate totals
    sub_departments = []
    total_sub_budget = 0.0

    for item in drill_down_data:
        # Calculate budget amount from allocation percentage and main budget
        budget_amount = main_budget * float(item.allocation_percentage) / 100.0
        total_sub_budget += budget_amount

        sub_departments.append(
            SubDepartment(
                id=0,  # Not needed for this view
                name_english=item.sub_department_name,
                name_georgian=item.sub_department_name_georgian,
                allocation_percentage=float(item.allocation_percentage),
                employee_count=item.employee_count,
                projects_count=item.projects_count,
                budget_amount=budget_amount,
                notes=item.notes,
            )
        )

    # Calculate coverage percentage
    coverage_percentage = (
        (total_sub_budget / main_budget * 100.0) if main_budget > 0 else 0.0
    )

    return DrillDownSummary(
        department=department,
        year=year,
        total_department_budget=main_budget,
        sub_departments_count=len(sub_departments),
        total_sub_budget=total_sub_budget,
        coverage_percentage=coverage_percentage,
        sub_departments=sub_departments,
    )


@app.get("/drill-down/explore", response_model=List[BudgetDrillDown])
async def explore_drill_down_data(
    department: Optional[str] = Query(None, description="Filter by department name"),
    year: Optional[int] = Query(None, description="Filter by year"),
    limit: int = Query(100, description="Maximum number of records"),
    db: Session = Depends(get_db),
):
    """
    Explore drill-down data across departments and years
    This is the "BigQuery-style" analytics endpoint for complex queries
    """
    # Check if database is available
    if db is None:
        raise HTTPException(
            status_code=503,
            detail="Database not available. Please start the database.",
        )

    drill_down_data = get_budget_drill_down(db, department, year, limit)

    return [
        BudgetDrillDown(
            department_name=item.department_name,
            department_name_georgian=item.department_name_georgian,
            sub_department_name=item.sub_department_name,
            sub_department_name_georgian=item.sub_department_name_georgian,
            allocation_percentage=float(item.allocation_percentage),
            employee_count=item.employee_count,
            projects_count=item.projects_count,
            year=item.year,
            budget_amount=float(item.budget_amount) if item.budget_amount else None,
            notes=item.notes,
        )
        for item in drill_down_data
    ]


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
