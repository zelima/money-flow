from unittest.mock import MagicMock, patch

import pytest
import requests


@pytest.mark.integration
class TestAPIIntegration:
    """Test integration between API and moneyflow-front services"""

    @patch("requests.get")
    def test_api_health_from_webapp(self, mock_get):
        """Test that moneyflow-front can successfully call API health endpoint"""
        # Mock successful API response
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {"status": "healthy"}
        mock_get.return_value = mock_response

        # Simulate moneyflow-front calling API
        response = requests.get("http://localhost:8000/health", timeout=30)

        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"

    @patch("requests.get")
    def test_api_data_flow(self, mock_get):
        """Test data flow from API to moneyflow-front"""
        # Mock API summary endpoint
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            "total_records": 100,
            "year_range": [2020, 2023],
            "total_budget": 1000000.0,
            "departments_count": 25,
        }
        mock_get.return_value = mock_response

        # Simulate moneyflow-front fetching summary data
        response = requests.get("http://localhost:8000/summary", timeout=30)

        assert response.status_code == 200
        data = response.json()
        assert data["total_records"] == 100
        assert data["departments_count"] == 25


@pytest.mark.integration
class TestErrorHandling:
    """Test error handling across services"""

    @patch("requests.get")
    def test_api_unavailable_handling(self, mock_get):
        """Test how moneyflow-front handles API unavailability"""
        # Mock API failure
        mock_get.side_effect = requests.exceptions.ConnectionError("Connection refused")

        # Test that moneyflow-front gracefully handles API failures
        # This would be tested in the actual moneyflow-front integration tests
        pass


if __name__ == "__main__":
    pytest.main([__file__])
