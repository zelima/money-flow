import pytest
from pydantic import ValidationError
from models import (
    BudgetRecord, BudgetSummary, DepartmentTrend, 
    YearSummary, APIResponse, ErrorResponse,
    SubDepartment, DepartmentDetail, BudgetDrillDown, DrillDownSummary
)

@pytest.mark.api
class TestBudgetRecord:
    """Test BudgetRecord model validation"""
    
    def test_valid_budget_record(self):
        """Test creating a valid budget record"""
        data = {
            "year": 2020,
            "name": "Test Department",
            "budget": 1000000.0
        }
        record = BudgetRecord(**data)
        assert record.year == 2020
        assert record.name == "Test Department"
        assert record.budget == 1000000.0
    
    def test_budget_record_invalid_year(self):
        """Test validation of year field"""
        data = {
            "year": "invalid",
            "name": "Test Department",
            "budget": 1000000.0
        }
        with pytest.raises(ValidationError):
            BudgetRecord(**data)
    
    def test_budget_record_invalid_budget(self):
        """Test validation of budget field"""
        data = {
            "year": 2020,
            "name": "Test Department",
            "budget": "invalid"
        }
        with pytest.raises(ValidationError):
            BudgetRecord(**data)
    
    def test_budget_record_empty_name(self):
        """Test validation of name field"""
        data = {
            "year": 2020,
            "name": "",
            "budget": 1000000.0
        }
        # Empty string should be valid for Pydantic
        record = BudgetRecord(**data)
        assert record.name == ""

@pytest.mark.api
class TestBudgetSummary:
    """Test BudgetSummary model validation"""
    
    def test_valid_budget_summary(self):
        """Test creating a valid budget summary"""
        data = {
            "total_records": 100,
            "year_range": (2019, 2021),
            "total_budget": 5000000.0,
            "departments_count": 5
        }
        summary = BudgetSummary(**data)
        assert summary.total_records == 100
        assert summary.year_range == (2019, 2021)
        assert summary.total_budget == 5000000.0
        assert summary.departments_count == 5
    
    def test_budget_summary_missing_fields(self):
        """Test budget summary with missing required fields"""
        data = {
            "total_records": 0,
            "total_budget": 0.0
        }
        with pytest.raises(ValidationError):
            BudgetSummary(**data)

@pytest.mark.api
class TestDepartmentTrend:
    """Test DepartmentTrend model validation"""
    
    def test_valid_department_trend(self):
        """Test creating a valid department trend"""
        data = {
            "department": "Test Department",
            "years": [2019, 2020, 2021],
            "budgets": [1000000.0, 1200000.0, 1500000.0],
            "total_budget": 3700000.0,
            "avg_budget": 1233333.33
        }
        trend = DepartmentTrend(**data)
        assert trend.department == "Test Department"
        assert trend.years == [2019, 2020, 2021]
        assert trend.budgets == [1000000.0, 1200000.0, 1500000.0]
        assert trend.total_budget == 3700000.0
        assert trend.avg_budget == 1233333.33
    
    def test_department_trend_with_growth_rate(self):
        """Test department trend with optional growth rate"""
        data = {
            "department": "Test Department",
            "years": [2019, 2020],
            "budgets": [1000000.0, 1200000.0],
            "total_budget": 2200000.0,
            "avg_budget": 1100000.0,
            "growth_rate": 20.0
        }
        trend = DepartmentTrend(**data)
        assert trend.growth_rate == 20.0

@pytest.mark.api
class TestYearSummary:
    """Test YearSummary model validation"""
    
    def test_valid_year_summary(self):
        """Test creating a valid year summary"""
        data = {
            "year": 2020,
            "total_budget": 5000000.0,
            "departments": [
                {"name": "Dept A", "budget": 2000000.0},
                {"name": "Dept B", "budget": 3000000.0}
            ],
            "top_departments": [
                {"name": "Dept B", "budget": 3000000.0},
                {"name": "Dept A", "budget": 2000000.0}
            ]
        }
        summary = YearSummary(**data)
        assert summary.year == 2020
        assert summary.total_budget == 5000000.0
        assert len(summary.departments) == 2
        assert len(summary.top_departments) == 2

@pytest.mark.api
class TestAPIResponse:
    """Test APIResponse model validation"""
    
    def test_valid_api_response(self):
        """Test creating a valid API response"""
        data = {
            "success": True,
            "data": {"test": "value"},
            "message": "Data retrieved successfully"
        }
        response = APIResponse(**data)
        assert response.success is True
        assert response.data == {"test": "value"}
        assert response.message == "Data retrieved successfully"
    
    def test_api_response_without_data(self):
        """Test API response without data field"""
        data = {
            "success": True,
            "message": "Operation completed"
        }
        response = APIResponse(**data)
        assert response.data is None
    
    def test_api_response_default_values(self):
        """Test API response with default values"""
        response = APIResponse()
        assert response.success is True
        assert response.message == "Success"
        assert response.data is None
        assert response.timestamp is not None

@pytest.mark.api
class TestErrorResponse:
    """Test ErrorResponse model validation"""
    
    def test_valid_error_response(self):
        """Test creating a valid error response"""
        data = {
            "success": False,
            "error": "Something went wrong"
        }
        response = ErrorResponse(**data)
        assert response.success is False
        assert response.error == "Something went wrong"
    
    def test_error_response_default_timestamp(self):
        """Test error response with default timestamp"""
        data = {
            "success": False,
            "error": "Something went wrong"
        }
        response = ErrorResponse(**data)
        assert response.timestamp is not None

@pytest.mark.api
class TestSubDepartment:
    """Test SubDepartment model validation"""
    
    def test_valid_sub_department(self):
        """Test creating a valid sub department"""
        data = {
            "id": 1,
            "name_english": "Test Sub Department",
            "allocation_percentage": 25.5,
            "employee_count": 50,
            "projects_count": 10
        }
        sub_dept = SubDepartment(**data)
        assert sub_dept.id == 1
        assert sub_dept.name_english == "Test Sub Department"
        assert sub_dept.allocation_percentage == 25.5
        assert sub_dept.employee_count == 50
        assert sub_dept.projects_count == 10
    
    def test_sub_department_with_optional_fields(self):
        """Test sub department with optional fields"""
        data = {
            "id": 1,
            "name_english": "Test Sub Department",
            "name_georgian": "ტესტი ქვედეპარტამენტი",
            "allocation_percentage": 25.5,
            "employee_count": 50,
            "projects_count": 10,
            "budget_amount": 500000.0,
            "notes": "Test notes"
        }
        sub_dept = SubDepartment(**data)
        assert sub_dept.name_georgian == "ტესტი ქვედეპარტამენტი"
        assert sub_dept.budget_amount == 500000.0
        assert sub_dept.notes == "Test notes"

@pytest.mark.api
class TestDepartmentDetail:
    """Test DepartmentDetail model validation"""
    
    def test_valid_department_detail(self):
        """Test creating a valid department detail"""
        data = {
            "id": 1,
            "name_english": "Test Department",
            "sub_departments": [
                {
                    "id": 1,
                    "name_english": "Sub A",
                    "allocation_percentage": 50.0,
                    "employee_count": 25,
                    "projects_count": 5
                },
                {
                    "id": 2,
                    "name_english": "Sub B",
                    "allocation_percentage": 50.0,
                    "employee_count": 25,
                    "projects_count": 5
                }
            ]
        }
        detail = DepartmentDetail(**data)
        assert detail.id == 1
        assert detail.name_english == "Test Department"
        assert len(detail.sub_departments) == 2
    
    def test_department_detail_with_optional_fields(self):
        """Test department detail with optional fields"""
        data = {
            "id": 1,
            "name_english": "Test Department",
            "name_georgian": "ტესტი დეპარტამენტი",
            "description": "Test department description",
            "total_budget": 1000000.0,
            "sub_departments": []
        }
        detail = DepartmentDetail(**data)
        assert detail.name_georgian == "ტესტი დეპარტამენტი"
        assert detail.description == "Test department description"
        assert detail.total_budget == 1000000.0

@pytest.mark.api
class TestBudgetDrillDown:
    """Test BudgetDrillDown model validation"""
    
    def test_valid_budget_drill_down(self):
        """Test creating a valid budget drill down"""
        data = {
            "department_name": "Test Department",
            "sub_department_name": "Test Sub Department",
            "allocation_percentage": 25.5,
            "employee_count": 50,
            "projects_count": 10
        }
        drill_down = BudgetDrillDown(**data)
        assert drill_down.department_name == "Test Department"
        assert drill_down.sub_department_name == "Test Sub Department"
        assert drill_down.allocation_percentage == 25.5
        assert drill_down.employee_count == 50
        assert drill_down.projects_count == 10
    
    def test_budget_drill_down_with_optional_fields(self):
        """Test budget drill down with optional fields"""
        data = {
            "department_name": "Test Department",
            "department_name_georgian": "ტესტი დეპარტამენტი",
            "sub_department_name": "Test Sub Department",
            "sub_department_name_georgian": "ტესტი ქვედეპარტამენტი",
            "allocation_percentage": 25.5,
            "employee_count": 50,
            "projects_count": 10,
            "year": 2020,
            "budget_amount": 500000.0,
            "notes": "Test notes"
        }
        drill_down = BudgetDrillDown(**data)
        assert drill_down.department_name_georgian == "ტესტი დეპარტამენტი"
        assert drill_down.sub_department_name_georgian == "ტესტი ქვედეპარტამენტი"
        assert drill_down.year == 2020
        assert drill_down.budget_amount == 500000.0
        assert drill_down.notes == "Test notes"

@pytest.mark.api
class TestDrillDownSummary:
    """Test DrillDownSummary model validation"""
    
    def test_valid_drill_down_summary(self):
        """Test creating a valid drill down summary"""
        data = {
            "department": "Test Department",
            "year": 2020,
            "total_department_budget": 1000000.0,
            "sub_departments_count": 2,
            "total_sub_budget": 800000.0,
            "coverage_percentage": 80.0,
            "sub_departments": [
                {
                    "id": 1,
                    "name_english": "Sub A",
                    "allocation_percentage": 50.0,
                    "employee_count": 25,
                    "projects_count": 5
                }
            ]
        }
        summary = DrillDownSummary(**data)
        assert summary.department == "Test Department"
        assert summary.year == 2020
        assert summary.total_department_budget == 1000000.0
        assert summary.sub_departments_count == 2
        assert summary.total_sub_budget == 800000.0
        assert summary.coverage_percentage == 80.0
        assert len(summary.sub_departments) == 1

if __name__ == "__main__":
    pytest.main([__file__])
