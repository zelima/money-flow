from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime


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