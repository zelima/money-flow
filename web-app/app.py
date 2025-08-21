from flask import Flask, render_template, jsonify, request, send_from_directory
import requests
import json
import os
from datetime import datetime

app = Flask(__name__, static_folder='static')

# API Configuration
API_BASE_URL = os.environ.get('API_BASE_URL', 'http://localhost:8000')

def fetch_api_data(endpoint):
    """Fetch data from the API"""
    try:
        response = requests.get(f"{API_BASE_URL}{endpoint}", timeout=30)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching data from API: {e}")
        return None

@app.route('/')
def dashboard():
    """Main dashboard page"""
    return render_template('dashboard.html')

@app.route('/static/<path:filename>')
def static_files(filename):
    """Serve static files"""
    return send_from_directory(app.static_folder, filename)

@app.route('/health')
def health_check():
    """Health check endpoint for Cloud Run"""
    return jsonify({
        "status": "healthy",
        "service": "georgian-budget-frontend",
        "environment": os.environ.get('ENVIRONMENT', 'local'),
        "api_base_url": API_BASE_URL
    })

@app.route('/api/health')
def api_health():
    """Check API health"""
    health_data = fetch_api_data("/health")
    return jsonify(health_data or {"status": "error", "message": "API not available"})

@app.route('/api/summary')
def api_summary():
    """Get budget summary"""
    summary_data = fetch_api_data("/summary")
    return jsonify(summary_data or {"error": "Failed to fetch summary"})

@app.route('/api/budget')
def api_budget():
    """Get budget data with filters"""
    year = request.args.get('year')
    department = request.args.get('department')
    limit = request.args.get('limit', 100)
    
    params = []
    if year:
        params.append(f"year={year}")
    if department:
        params.append(f"department={department}")
    params.append(f"limit={limit}")
    
    endpoint = f"/budget?{'&'.join(params)}"
    budget_data = fetch_api_data(endpoint)
    return jsonify(budget_data or [])

@app.route('/api/departments')
def api_departments():
    """Get list of departments"""
    departments_data = fetch_api_data("/departments")
    return jsonify(departments_data or [])

@app.route('/api/trends/<department>')
def api_trends(department):
    """Get trends for a specific department"""
    trend_data = fetch_api_data(f"/trends/{department}")
    return jsonify(trend_data or {"error": "Department not found"})

@app.route('/api/year/<int:year>')
def api_year(year):
    """Get year summary"""
    year_data = fetch_api_data(f"/years/{year}")
    return jsonify(year_data or {"error": "Year not found"})

# New drill-down endpoints
@app.route('/api/drill-down/<department>')
def api_drill_down(department):
    """Get sub-department breakdown for a specific department"""
    year = request.args.get('year')
    
    endpoint = f"/drill-down/{department}"
    if year:
        endpoint += f"?year={year}"
    
    drill_down_data = fetch_api_data(endpoint)
    return jsonify(drill_down_data or {"error": "Department not found"})

@app.route('/api/drill-down/analysis/<department>/<int:year>')
def api_drill_down_analysis(department, year):
    """Get comprehensive drill-down analysis for a department and year"""
    analysis_data = fetch_api_data(f"/drill-down/analysis/{department}/{year}")
    return jsonify(analysis_data or {"error": "Analysis not available"})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000) 