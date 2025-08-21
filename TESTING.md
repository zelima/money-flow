# Testing Guide for Georgian Budget Application

This document provides comprehensive information about running tests for the Georgian Budget application, which consists of two main services:

- **API Service** (FastAPI)
- **Web App Service** (Flask)

## 🚀 Quick Start

### Run All Tests
```bash
make test
```

### Run Tests for Specific Service
```bash
# API tests only
make test-api

# Web app tests only
make test-web-app
```

### Install Test Dependencies
```bash
make test-install
```

## 📋 Prerequisites

Before running tests, ensure you have:

1. **Python 3.11+** installed
2. **pip** package manager
3. **Test dependencies** installed (see below)

## 🔧 Setup

### 1. Install Test Dependencies

```bash
# Install test dependencies for all services
make test-install

# Or install individually:
cd api && pip install -r requirements-test.txt
cd web-app && pip install -r requirements-test.txt
```

### 2. Verify Installation

```bash
# Check if pytest is available
python -m pytest --version

# Check if coverage tools are available
python -m coverage --version
```

## 🧪 Running Tests

### Command Line Options

#### Basic Test Execution
```bash
# Run all tests in a service
cd api && python -m pytest

# Run with verbose output
cd api && python -m pytest -v

# Run specific test file
cd api && python -m pytest tests/test_main.py

# Run specific test class
cd api && python -m pytest tests/test_main.py::TestHealthEndpoints

# Run specific test method
cd api && python -m pytest tests/test_main.py::TestHealthEndpoints::test_health_endpoint
```

#### Coverage Reports
```bash
# Run tests with coverage
cd api && python -m pytest --cov=. --cov-report=term-missing

# Generate HTML coverage report
cd api && python -m pytest --cov=. --cov-report=html

# Generate XML coverage report (for CI/CD)
cd api && python -m pytest --cov=. --cov-report=xml
```

#### Test Filtering
```bash
# Run only unit tests
python -m pytest -m unit

# Run only integration tests
python -m pytest -m integration

# Skip slow tests
python -m pytest -m "not slow"

# Run tests matching a pattern
python -m pytest -k "health"
```

### Makefile Commands

The project includes convenient Makefile targets for testing:

```bash
# Run all tests
make test

# Run tests for specific service
make test-api
make test-web-app

# Run tests with coverage reports
make test-coverage

# Install test dependencies
make test-install
```

## 📊 Test Structure

### API Service Tests (`api/tests/`)

- **`test_main.py`** - Tests for FastAPI endpoints and application logic
- **`test_models.py`** - Tests for Pydantic data models
- **`test_database.py`** - Tests for database operations and connections

### Web App Tests (`web-app/tests/`)

- **`test_app.py`** - Tests for Flask routes and application logic
- **API proxy endpoint tests**
- **Static file serving tests**



## 🔍 Test Categories

### Unit Tests
- Test individual functions and methods in isolation
- Use mocking to isolate dependencies
- Fast execution, high reliability

### Integration Tests
- Test interactions between components
- May require external services (database, APIs)
- Slower execution, more comprehensive

### End-to-End Tests
- Test complete user workflows
- Require full application stack
- Slowest execution, most realistic

## 🎯 Test Coverage

The testing setup includes coverage reporting to help identify untested code:

```bash
# Generate coverage report
make test-coverage

# View coverage in terminal
cd api && python -m pytest --cov=. --cov-report=term-missing

# Open HTML coverage report
cd api && open htmlcov/index.html
```

### Coverage Targets
- **Minimum coverage**: 80%
- **Target coverage**: 90%+
- **Critical paths**: 100%

## 🚨 Common Issues and Solutions

### Import Errors
```bash
# Ensure you're in the correct directory
cd api
python -m pytest tests/

# Check Python path
export PYTHONPATH="${PYTHONPATH}:$(pwd)"
```

### Missing Dependencies
```bash
# Install missing packages
pip install -r requirements-test.txt

# Check if package is installed
python -c "import pytest; print('pytest available')"
```

### Database Connection Issues
- Tests use mocked database connections by default
- Ensure database service is running for integration tests
- Check environment variables for database configuration

### Permission Issues
```bash
# Make sure you have write permissions
chmod +w tests/
chmod +w .pytest_cache/
```

## 🔄 Continuous Integration

Tests are automatically run in GitHub Actions when:

- **API Tests**: When `api/` directory, `pytest.ini`, or `requirements*.txt` files are modified
- **Web App Tests**: When `web-app/` directory, `pytest.ini`, or `requirements*.txt` files are modified
- **Integration Tests**: When both `api/` and `web-app/` directories are modified

### CI Workflow Structure
- **`.github/workflows/api-tests.yml`**: Backend tests (triggers on API changes only)
- **`.github/workflows/web-app-tests.yml`**: Frontend tests (triggers on web-app changes only)
- **`.github/workflows/integration-tests.yml`**: Cross-service tests (triggers on both services)

### CI Test Matrix
- **API Tests**: Ubuntu, Python 3.11 (Backend only)
- **Web App Tests**: Ubuntu, Python 3.11 (Frontend only)
- **Integration Tests**: Ubuntu, Python 3.11 (Both services)

### CI Coverage Reports
- Coverage reports are uploaded to Codecov with service-specific flags
- Separate coverage tracking for each service
- Combined coverage for integration tests

## 📝 Writing New Tests

### Test Naming Convention
```python
# Test files: test_*.py
test_main.py

# Test classes: Test*
class TestHealthEndpoints:

# Test methods: test_*
def test_health_endpoint(self):
```

### Test Structure
```python
import pytest
from unittest.mock import patch, MagicMock

class TestExample:
    """Test class description"""
    
    def test_success_case(self):
        """Test successful scenario"""
        # Arrange
        expected = "success"
        
        # Act
        result = function_under_test()
        
        # Assert
        assert result == expected
    
    @patch('module.function_to_mock')
    def test_with_mocking(self, mock_function):
        """Test with mocked dependencies"""
        mock_function.return_value = "mocked"
        # ... test logic
```

### Best Practices
1. **One assertion per test** when possible
2. **Descriptive test names** that explain the scenario
3. **Use fixtures** for common setup
4. **Mock external dependencies** for unit tests
5. **Test both success and failure cases**
6. **Test edge cases and error conditions**

## 🧹 Cleanup

### Remove Test Artifacts
```bash
# Clean up test cache and coverage files
make clean-deps

# Or manually:
find . -name ".pytest_cache" -type d -exec rm -rf {} +
find . -name ".coverage" -delete
find . -name "htmlcov" -type d -exec rm -rf {} +
find . -name "coverage.xml" -delete
```

### Reset Test Environment
```bash
# Clean and reinstall dependencies
make clean-deps
make test-install
```

## 📚 Additional Resources

- [pytest Documentation](https://docs.pytest.org/)
- [pytest-cov Documentation](https://pytest-cov.readthedocs.io/)
- [unittest.mock Documentation](https://docs.python.org/3/library/unittest.mock.html)
- [FastAPI Testing Guide](https://fastapi.tiangolo.com/tutorial/testing/)
- [Flask Testing Guide](https://flask.palletsprojects.com/en/2.3.x/testing/)

## 🤝 Contributing

When adding new features or fixing bugs:

1. **Write tests first** (TDD approach)
2. **Ensure all tests pass** before submitting PR
3. **Maintain or improve test coverage**
4. **Update this documentation** if needed

## 📞 Support

If you encounter issues with testing:

1. Check this documentation
2. Review the test logs and error messages
3. Ensure all dependencies are installed
4. Check the GitHub Actions logs for CI issues
5. Create an issue with detailed error information
