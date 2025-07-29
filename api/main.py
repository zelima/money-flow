from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Optional
import pandas as pd
import requests
import io
from datetime import datetime
import logging

from models import (
    BudgetRecord, BudgetSummary, DepartmentTrend, 
    YearSummary, APIResponse, ErrorResponse
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
    redoc_url="/redoc"
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
budget_data: pd.DataFrame = None


def load_budget_data():
    """Load budget data from GitHub repository (latest pipeline data)"""
    global budget_data
    
    # GitHub raw file URLs for the pipeline-generated data
    GITHUB_REPO = "https://raw.githubusercontent.com/zelima/money-flow/main"
    CSV_URL = f"{GITHUB_REPO}/data/processed/georgian_budget.csv"
    DATAPACKAGE_URL = f"{GITHUB_REPO}/data/processed/datapackage.json"
    
    try:
        logger.info("🌐 Fetching latest budget data from GitHub repository...")
        
        # Fetch CSV data from GitHub
        response = requests.get(CSV_URL, timeout=30)
        response.raise_for_status()
        
        # Read CSV data directly from the response
        budget_data = pd.read_csv(io.StringIO(response.text))
        budget_data['budget'] = pd.to_numeric(budget_data['budget'], errors='coerce')
        budget_data['year'] = pd.to_numeric(budget_data['year'], errors='coerce')
        budget_data = budget_data.dropna()
        
        # Get data statistics
        years_range = f"{budget_data['year'].min():.0f}-{budget_data['year'].max():.0f}"
        departments_count = budget_data['name'].nunique()
        total_budget = budget_data['budget'].sum()
        
        # Try to get metadata from datapackage.json
        try:
            meta_response = requests.get(DATAPACKAGE_URL, timeout=10)
            if meta_response.status_code == 200:
                import json
                metadata = json.loads(meta_response.text)
                last_update = metadata.get('updated', 'Unknown')
                logger.info(f"📊 Data last updated: {last_update}")
        except:
            logger.warning("Could not fetch metadata from datapackage.json")
        
        logger.info(f"✅ Loaded {len(budget_data)} budget records from GitHub pipeline data")
        logger.info(f"📅 Years: {years_range} | 🏛️ Departments: {departments_count} | 💰 Total: {total_budget:,.1f}M ₾")
        logger.info(f"🌐 Data source: {CSV_URL}")
        
    except requests.exceptions.RequestException as e:
        logger.error(f"❌ Network error fetching data from GitHub: {e}")
        raise HTTPException(status_code=503, detail="Unable to fetch data from GitHub repository")
    except pd.errors.EmptyDataError:
        logger.error("❌ Empty or invalid CSV data received from GitHub")
        raise HTTPException(status_code=503, detail="Invalid data format received from GitHub")
    except Exception as e:
        logger.error(f"❌ Error loading budget data from GitHub: {e}")
        raise HTTPException(status_code=503, detail=f"Data loading error: {str(e)}")


# Load data on startup
@app.on_event("startup")
async def startup_event():
    load_budget_data()


@app.get("/", response_model=APIResponse)
async def root():
    """Root endpoint with API information"""
    # Get real-time data stats
    data_stats = {}
    if budget_data is not None:
        data_stats = {
            "records": len(budget_data),
            "years": f"{budget_data['year'].min():.0f}-{budget_data['year'].max():.0f}",
            "departments": budget_data['name'].nunique(),
            "total_budget_millions": f"{budget_data['budget'].sum():,.1f}M ₾",
            "data_source": "🌐 Fetched from GitHub repository",
            "github_repo": "https://github.com/zelima/money-flow"
        }
    
    return APIResponse(
        data={
            "message": "🇬🇪 Georgian Budget Data API",
            "version": "1.0.0",
            "description": "Serving real Georgian government budget data processed by automated quarterly pipeline",
            "data_statistics": data_stats,
            "endpoints": [
                "/docs - API documentation",
                "/health - Health check",
                "/budget - Get budget data",
                "/summary - Data summary",
                "/departments - List departments",
                "/trends/{department} - Department trends",
                "/years/{year} - Year summary",
                "/search - Search departments"
            ]
        }
    )


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    global budget_data
    return {
        "status": "healthy",
        "data_loaded": budget_data is not None,
        "records_count": len(budget_data) if budget_data is not None else 0
    }


@app.get("/budget", response_model=List[BudgetRecord])
async def get_budget_data(
    year: Optional[int] = Query(None, description="Filter by year"),
    department: Optional[str] = Query(None, description="Filter by department name (partial match)"),
    min_budget: Optional[float] = Query(None, description="Minimum budget amount"),
    max_budget: Optional[float] = Query(None, description="Maximum budget amount"),
    limit: int = Query(100, le=1000, description="Limit number of results"),
    offset: int = Query(0, ge=0, description="Offset for pagination")
):
    """Get budget data with optional filters"""
    global budget_data
    
    if budget_data is None:
        raise HTTPException(status_code=500, detail="Budget data not loaded")
    
    # Apply filters
    filtered_data = budget_data.copy()
    
    if year:
        filtered_data = filtered_data[filtered_data['year'] == year]
    
    if department:
        filtered_data = filtered_data[
            filtered_data['name'].str.contains(department, case=False, na=False)
        ]
    
    if min_budget is not None:
        filtered_data = filtered_data[filtered_data['budget'] >= min_budget]
    
    if max_budget is not None:
        filtered_data = filtered_data[filtered_data['budget'] <= max_budget]
    
    # Apply pagination
    total_records = len(filtered_data)
    filtered_data = filtered_data.iloc[offset:offset + limit]
    
    # Convert to list of BudgetRecord objects
    records = []
    for _, row in filtered_data.iterrows():
        records.append(BudgetRecord(
            year=int(row['year']),
            budget=float(row['budget']),
            name=str(row['name'])
        ))
    
    return records


@app.get("/summary", response_model=BudgetSummary)
async def get_summary():
    """Get overall budget data summary"""
    global budget_data
    
    if budget_data is None:
        raise HTTPException(status_code=500, detail="Budget data not loaded")
    
    return BudgetSummary(
        total_records=len(budget_data),
        year_range=(int(budget_data['year'].min()), int(budget_data['year'].max())),
        total_budget=float(budget_data['budget'].sum()),
        departments_count=budget_data['name'].nunique()
    )


@app.get("/departments", response_model=List[str])
async def get_departments():
    """Get list of all departments"""
    global budget_data
    
    if budget_data is None:
        raise HTTPException(status_code=500, detail="Budget data not loaded")
    
    return sorted(budget_data['name'].unique().tolist())


@app.get("/trends/{department}", response_model=DepartmentTrend)
async def get_department_trend(department: str):
    """Get budget trend for a specific department"""
    global budget_data
    
    if budget_data is None:
        raise HTTPException(status_code=500, detail="Budget data not loaded")
    
    # Find department (partial match)
    dept_data = budget_data[
        budget_data['name'].str.contains(department, case=False, na=False)
    ].copy()
    
    if dept_data.empty:
        raise HTTPException(status_code=404, detail=f"Department '{department}' not found")
    
    # Sort by year
    dept_data = dept_data.sort_values('year')
    
    # Calculate growth rate (if we have more than one year)
    growth_rate = None
    if len(dept_data) > 1:
        first_budget = dept_data.iloc[0]['budget']
        last_budget = dept_data.iloc[-1]['budget']
        years_span = dept_data.iloc[-1]['year'] - dept_data.iloc[0]['year']
        if first_budget > 0 and years_span > 0:
            growth_rate = ((last_budget / first_budget) ** (1/years_span) - 1) * 100
    
    return DepartmentTrend(
        department=dept_data.iloc[0]['name'],
        years=dept_data['year'].tolist(),
        budgets=dept_data['budget'].tolist(),
        total_budget=float(dept_data['budget'].sum()),
        avg_budget=float(dept_data['budget'].mean()),
        growth_rate=growth_rate
    )


@app.get("/years/{year}", response_model=YearSummary)
async def get_year_summary(year: int):
    """Get budget summary for a specific year"""
    global budget_data
    
    if budget_data is None:
        raise HTTPException(status_code=500, detail="Budget data not loaded")
    
    year_data = budget_data[budget_data['year'] == year].copy()
    
    if year_data.empty:
        raise HTTPException(status_code=404, detail=f"No data found for year {year}")
    
    # Sort by budget descending
    year_data = year_data.sort_values('budget', ascending=False)
    
    departments = []
    for _, row in year_data.iterrows():
        departments.append({
            "name": row['name'],
            "budget": row['budget']
        })
    
    return YearSummary(
        year=year,
        total_budget=float(year_data['budget'].sum()),
        departments=departments,
        top_departments=departments[:10]  # Top 10 departments
    )


@app.get("/search")
async def search_departments(
    q: str = Query(..., min_length=2, description="Search query for department names"),
    limit: int = Query(10, le=50, description="Limit number of results")
):
    """Search departments by name"""
    global budget_data
    
    if budget_data is None:
        raise HTTPException(status_code=500, detail="Budget data not loaded")
    
    # Search in department names
    matching_depts = budget_data[
        budget_data['name'].str.contains(q, case=False, na=False)
    ]['name'].unique()
    
    return {
        "query": q,
        "results": matching_depts[:limit].tolist(),
        "total_found": len(matching_depts)
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 