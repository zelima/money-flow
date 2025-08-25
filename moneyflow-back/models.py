from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, Field


class BudgetRecord(BaseModel):
    """Single budget record"""

    year: int = Field(..., description="Budget year")
    budget: float = Field(..., description="Budget amount in millions GEL")
    name: str = Field(..., description="Department/ministry name")


class BudgetSummary(BaseModel):
    """Summary statistics for budget data"""

    total_records: int
    year_range: tuple[int, int]
    total_budget: float
    departments_count: int


class DepartmentTrend(BaseModel):
    """Budget trend for a specific department"""

    department: str
    years: List[int]
    budgets: List[float]
    total_budget: float
    avg_budget: float
    growth_rate: Optional[float] = None


class YearSummary(BaseModel):
    """Budget summary for a specific year"""

    year: int
    total_budget: float
    departments: List[dict]
    top_departments: List[dict]


class APIResponse(BaseModel):
    """Standard API response wrapper"""

    success: bool = True
    data: Optional[dict] = None
    message: str = "Success"
    timestamp: datetime = Field(default_factory=datetime.now)


class ErrorResponse(BaseModel):
    """Error response model"""

    success: bool = False
    error: str
    timestamp: datetime = Field(default_factory=datetime.now)


# New models for PostgreSQL drill-down functionality
class SubDepartment(BaseModel):
    """Sub-department model for drill-down analysis"""

    id: int
    name_english: str
    name_georgian: Optional[str] = None
    allocation_percentage: float
    employee_count: int
    projects_count: int
    budget_amount: Optional[float] = None
    notes: Optional[str] = None

    class Config:
        from_attributes = True


class DepartmentDetail(BaseModel):
    """Department with sub-departments for drill-down"""

    id: int
    name_english: str
    name_georgian: Optional[str] = None
    description: Optional[str] = None
    total_budget: Optional[float] = None
    sub_departments: List[SubDepartment]

    class Config:
        from_attributes = True


class BudgetDrillDown(BaseModel):
    """Drill-down budget data combining GitHub and PostgreSQL sources"""

    department_name: str
    department_name_georgian: Optional[str] = None
    sub_department_name: str
    sub_department_name_georgian: Optional[str] = None
    allocation_percentage: float
    employee_count: int
    projects_count: int
    year: Optional[int] = None
    budget_amount: Optional[float] = None
    notes: Optional[str] = None

    class Config:
        from_attributes = True


class DrillDownSummary(BaseModel):
    """Summary of drill-down analysis for a department"""

    department: str
    year: int
    total_department_budget: float
    sub_departments_count: int
    total_sub_budget: float
    coverage_percentage: float
    sub_departments: List[SubDepartment]
