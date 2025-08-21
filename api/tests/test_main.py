import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock
import json
import os
from main import app

client = TestClient(app)

@pytest.mark.api
class TestHealthEndpoints:
    """Test health check endpoints"""
    
    def test_health_endpoint(self):
        """Test the health check endpoint"""
        response = client.get("/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert "environment" in data
        assert "data_loaded" in data
        assert "database" in data
    
    def test_docs_endpoint(self):
        """Test that docs endpoint is accessible"""
        response = client.get("/docs")
        assert response.status_code == 200

@pytest.mark.api
class TestBudgetEndpoints:
    """Test budget data endpoints"""
    
    @patch('main.budget_data')
    def test_summary_endpoint_with_data(self, mock_budget_data):
        """Test summary endpoint when budget data is available"""
        mock_budget_data = [
            {"year": 2020, "name": "Test Dept", "budget": 100.0},
            {"year": 2020, "name": "Test Dept 2", "budget": 200.0}
        ]
        
        with patch('main.budget_data', mock_budget_data):
            response = client.get("/summary")
            assert response.status_code == 200
            data = response.json()
            assert "total_records" in data
            assert "year_range" in data
            assert "departments_count" in data
            assert "total_budget" in data
    
    @patch('main.budget_data')
    def test_summary_endpoint_no_data(self, mock_budget_data):
        """Test summary endpoint when no budget data is available"""
        mock_budget_data = None
        
        with patch('main.budget_data', mock_budget_data):
            response = client.get("/summary")
            assert response.status_code == 500
            data = response.json()
            assert "detail" in data
            assert "Budget data not loaded" in data["detail"]
    
    @patch('main.budget_data')
    def test_budget_endpoint_with_filters(self, mock_budget_data):
        """Test budget endpoint with year and department filters"""
        mock_budget_data = [
            {"year": 2020, "name": "Test Dept", "budget": 100.0},
            {"year": 2021, "name": "Test Dept", "budget": 150.0}
        ]
        
        with patch('main.budget_data', mock_budget_data):
            response = client.get("/budget?year=2020&department=Test Dept")
            assert response.status_code == 200
            data = response.json()
            assert len(data) == 1
            assert data[0]["year"] == 2020
            assert data[0]["name"] == "Test Dept"
    
    @patch('main.budget_data')
    def test_budget_endpoint_limit(self, mock_budget_data):
        """Test budget endpoint with limit parameter"""
        mock_budget_data = [
            {"year": 2020, "name": f"Dept {i}", "budget": 100.0 + i}
            for i in range(10)
        ]
        
        with patch('main.budget_data', mock_budget_data):
            response = client.get("/budget?limit=5")
            assert response.status_code == 200
            data = response.json()
            assert len(data) == 5
    
    @patch('main.budget_data')
    def test_departments_endpoint(self, mock_budget_data):
        """Test departments endpoint"""
        mock_budget_data = [
            {"year": 2020, "name": "Dept A", "budget": 100.0},
            {"year": 2020, "name": "Dept B", "budget": 200.0},
            {"year": 2021, "name": "Dept A", "budget": 150.0}
        ]
        
        with patch('main.budget_data', mock_budget_data):
            response = client.get("/departments")
            assert response.status_code == 200
            data = response.json()
            assert "Dept A" in data
            assert "Dept B" in data
            assert len(data) == 2  # Unique departments only

@pytest.mark.api
class TestTrendsEndpoints:
    """Test trends analysis endpoints"""
    
    @patch('main.budget_data')
    def test_trends_endpoint(self, mock_budget_data):
        """Test trends endpoint for a specific department"""
        mock_budget_data = [
            {"year": 2019, "name": "Test Dept", "budget": 100.0},
            {"year": 2020, "name": "Test Dept", "budget": 120.0},
            {"year": 2021, "name": "Test Dept", "budget": 150.0}
        ]
        
        with patch('main.budget_data', mock_budget_data):
            response = client.get("/trends/Test Dept")
            assert response.status_code == 200
            data = response.json()
            assert "department" in data
            assert "years" in data
            assert "budgets" in data
            assert "total_budget" in data
            assert "avg_budget" in data
            assert len(data["years"]) == 3
    
    @patch('main.budget_data')
    def test_trends_endpoint_department_not_found(self, mock_budget_data):
        """Test trends endpoint for non-existent department"""
        mock_budget_data = [
            {"year": 2020, "name": "Other Dept", "budget": 100.0}
        ]
        
        with patch('main.budget_data', mock_budget_data):
            response = client.get("/trends/NonExistent")
            assert response.status_code == 404
            data = response.json()
            assert "detail" in data
            assert "Department 'NonExistent' not found" in data["detail"]

@pytest.mark.api
class TestYearEndpoints:
    """Test year-specific endpoints"""
    
    @patch('main.budget_data')
    def test_year_endpoint(self, mock_budget_data):
        """Test year endpoint for a specific year"""
        mock_budget_data = [
            {"year": 2020, "name": "Dept A", "budget": 100.0},
            {"year": 2020, "name": "Dept B", "budget": 200.0},
            {"year": 2021, "name": "Dept A", "budget": 150.0}
        ]
        
        with patch('main.budget_data', mock_budget_data):
            response = client.get("/years/2020")
            assert response.status_code == 200
            data = response.json()
            assert data["year"] == 2020
            assert "total_budget" in data
            assert "departments" in data
            assert "top_departments" in data
            assert len(data["departments"]) == 2
    
    @patch('main.budget_data')
    def test_year_endpoint_year_not_found(self, mock_budget_data):
        """Test year endpoint for non-existent year"""
        mock_budget_data = [
            {"year": 2020, "name": "Test Dept", "budget": 100.0}
        ]
        
        with patch('main.budget_data', mock_budget_data):
            response = client.get("/years/2025")
            assert response.status_code == 404
            data = response.json()
            assert "detail" in data
            assert "No data found for year 2025" in data["detail"]


@pytest.mark.api
class TestErrorHandling:
    """Test error handling scenarios"""
    
    def test_invalid_year_parameter(self):
        """Test handling of invalid year parameter"""
        response = client.get("/budget?year=invalid")
        assert response.status_code == 422  # FastAPI validation error
    
    @patch('main.budget_data')
    def test_invalid_limit_parameter(self, mock_budget_data):
        """Test handling of invalid limit parameter"""
        # Mock budget data to avoid 500 error from missing data
        mock_budget_data = [
            {"year": 2020, "name": "Test Dept", "budget": 100.0}
        ]
        
        with patch('main.budget_data', mock_budget_data):
            response = client.get("/budget?limit=-1")
            # The limit parameter should be valid according to FastAPI validation
            # but might cause issues in business logic
            assert response.status_code in [200, 422, 400]
    
    def test_missing_endpoint(self):
        """Test 404 for non-existent endpoints"""
        response = client.get("/nonexistent")
        assert response.status_code == 404

@pytest.mark.api
class TestSearchEndpoints:
    """Test search functionality"""
    
    @patch('main.budget_data')
    def test_search_departments(self, mock_budget_data):
        """Test department search endpoint"""
        mock_budget_data = [
            {"year": 2020, "name": "Test Department A", "budget": 100.0},
            {"year": 2020, "name": "Test Department B", "budget": 200.0},
            {"year": 2020, "name": "Other Dept", "budget": 300.0}
        ]
        
        with patch('main.budget_data', mock_budget_data):
            response = client.get("/search?q=Test")
            assert response.status_code == 200
            data = response.json()
            assert "query" in data
            assert "results" in data
            assert "total_found" in data
            assert len(data["results"]) == 2
            assert "Test Department A" in data["results"]
            assert "Test Department B" in data["results"]
    
    def test_search_query_too_short(self):
        """Test search with query that's too short"""
        response = client.get("/search?q=a")
        assert response.status_code == 422  # FastAPI validation error

if __name__ == "__main__":
    pytest.main([__file__])
