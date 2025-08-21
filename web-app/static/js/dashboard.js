let currentData = [];
let allDepartments = [];
let yearChart, departmentChart;
let latestYear = null; // Store the latest available year

// Initialize dashboard
async function init() {
    await checkApiHealth();
    await loadSummary();
    await loadDepartments();
    setupCharts(); // Setup charts first
    await loadInitialData(); // Then load data
}

async function checkApiHealth() {
    try {
        const response = await fetch('/api/health');
        const health = await response.json();

        if (health.status !== 'healthy') {
            throw new Error('API not healthy');
        }
        // API is healthy - continue silently
    } catch (error) {
        console.error('❌ Cannot connect to API. Make sure the FastAPI server is running on port 8000.');
        throw error;
    }
}

async function loadSummary() {
    try {
        const response = await fetch('/api/summary');
        const summary = await response.json();

        document.getElementById('year-range').textContent = summary.year_range ? `${summary.year_range[0]}-${summary.year_range[1]}` : '-';
        document.getElementById('total-budget').textContent = summary.total_budget ? summary.total_budget.toLocaleString(undefined, {maximumFractionDigits: 1}) + 'M ₾' : '-';
        document.getElementById('departments-count').textContent = summary.departments_count || '-';

        // Populate year filter and store latest year
        if (summary.year_range) {
            const yearFilter = document.getElementById('year-filter');
            latestYear = summary.year_range[1]; // Store the latest year
            for (let year = summary.year_range[0]; year <= summary.year_range[1]; year++) {
                const option = document.createElement('option');
                option.value = year;
                option.textContent = year;
                yearFilter.appendChild(option);
            }
        }

        document.getElementById('metrics').style.display = 'grid';
    } catch (error) {
        console.error('Error loading summary:', error);
    }
}

async function loadDepartments() {
    try {
        const response = await fetch('/api/departments');
        allDepartments = await response.json();

        const departmentFilter = document.getElementById('department-filter');
        allDepartments.forEach(dept => {
            const option = document.createElement('option');
            option.value = dept;
            option.textContent = dept.length > 50 ? dept.substring(0, 50) + '...' : dept;
            departmentFilter.appendChild(option);
        });

        document.getElementById('controls').style.display = 'block';
    } catch (error) {
        console.error('Error loading departments:', error);
    }
}

async function loadInitialData() {
    // Load data with no filters (all years, all departments)
    await updateCharts();
    // Initialize metrics cards with default values (all years, all departments)
    await updateMetricsCards('', '');

    // Show the charts and data sections by default
    document.getElementById('charts').style.display = 'grid';
    document.getElementById('data-section').style.display = 'block';
}

async function updateCharts() {
    const year = document.getElementById('year-filter').value;
    const department = document.getElementById('department-filter').value;

    console.log('🔍 updateCharts called with:', { year, department });

    try {
        let url = '/api/budget?limit=1000';
        if (year) url += `&year=${year}`;
        if (department) url += `&department=${encodeURIComponent(department)}`;

        console.log('🌐 Fetching data from:', url);

        const response = await fetch(url);
        currentData = await response.json();

        console.log('📊 Data received:', {
            count: currentData.length,
            sample: currentData.slice(0, 3)
        });

        // Update metrics cards based on current filters
        await updateMetricsCards(year, department);

        updateYearChart();
        await updateDepartmentChart(); // Make this async to fetch drill-down data
        await updateDataTable(); // Make this async for sub-department data

        document.getElementById('charts').style.display = 'grid';
        document.getElementById('data-section').style.display = 'block';
    } catch (error) {
        console.error('Error updating charts:', error);
    }
}

async function updateMetricsCards(year, department) {
    try {
        // Update Years Covered
        if (year) {
            // Single year selected
            document.getElementById('year-range').textContent = year;
        } else {
            // All years selected - get from summary
            const response = await fetch('/api/summary');
            const summary = await response.json();
            if (summary.year_range) {
                document.getElementById('year-range').textContent = `${summary.year_range[0]}-${summary.year_range[1]}`;
            }
        }

        // Update Total Budget
        if (year && department) {
            // Specific year and department selected
            const yearData = currentData.filter(record => record.year == year && record.name === department);
            if (yearData.length > 0) {
                const totalBudget = yearData.reduce((sum, record) => sum + record.budget, 0);
                document.getElementById('total-budget').textContent = totalBudget.toLocaleString(undefined, {maximumFractionDigits: 1}) + 'M ₾';
            }
        } else if (year) {
            // Specific year, all departments
            const yearData = currentData.filter(record => record.year == year);
            if (yearData.length > 0) {
                const totalBudget = yearData.reduce((sum, record) => sum + record.budget, 0);
                document.getElementById('total-budget').textContent = totalBudget.toLocaleString(undefined, {maximumFractionDigits: 1}) + 'M ₾';
            }
        } else if (department) {
            // Specific department, all years
            const deptData = currentData.filter(record => record.name === department);
            if (deptData.length > 0) {
                const totalBudget = deptData.reduce((sum, record) => sum + record.budget, 0);
                document.getElementById('total-budget').textContent = totalBudget.toLocaleString(undefined, {maximumFractionDigits: 1}) + 'M ₾';
            }
        } else {
            // All years and all departments - get from summary
            const response = await fetch('/api/summary');
            const summary = await response.json();
            if (summary.total_budget) {
                document.getElementById('total-budget').textContent = summary.total_budget.toLocaleString(undefined, {maximumFractionDigits: 1}) + 'M ₾';
            }
        }

        // Update Departments Count
        if (department) {
            // Specific department selected - get sub-departments count
            try {
                const year = document.getElementById('year-filter').value;
                const effectiveYear = year || latestYear;

                let drillDownUrl = `/api/drill-down/${encodeURIComponent(department)}`;
                if (effectiveYear) drillDownUrl += `?year=${effectiveYear}`;

                const response = await fetch(drillDownUrl);
                const drillDownData = await response.json();

                if (drillDownData.sub_departments && drillDownData.sub_departments.length > 0) {
                    document.getElementById('departments-count').textContent = drillDownData.sub_departments.length;
                } else {
                    document.getElementById('departments-count').textContent = '1';
                }
            } catch (error) {
                // If drill-down fails, show 1 for the main department
                document.getElementById('departments-count').textContent = '1';
            }
        } else {
            // All departments selected - get total departments count from summary
            const response = await fetch('/api/summary');
            const summary = await response.json();
            if (summary.departments_count) {
                document.getElementById('departments-count').textContent = summary.departments_count;
            }
        }

    } catch (error) {
        console.error('Error updating metrics cards:', error);
    }
}

function setupCharts() {
    const yearCtx = document.getElementById('yearChart').getContext('2d');
    const departmentCtx = document.getElementById('departmentChart').getContext('2d');

    yearChart = new Chart(yearCtx, {
        type: 'line',
        data: { labels: [], datasets: [] },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: { display: true, text: 'Budget Trends Over Time' }
            },
            scales: {
                y: { beginAtZero: true, title: { display: true, text: 'Budget (Million ₾)' } },
                x: {
                    beginAtZero: false,
                    ticks: {
                        maxRotation: 45,
                        minRotation: 0
                    }
                }
            }
        }
    });

    departmentChart = new Chart(departmentCtx, {
        type: 'doughnut',
        data: { labels: [], datasets: [] },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: { display: true, text: 'Budget Distribution by Department' },
                legend: { position: 'bottom' }
            }
        }
    });
}

function updateYearChart() {
    const year = document.getElementById('year-filter').value;
    const department = document.getElementById('department-filter').value;

    console.log('🔍 updateYearChart called with:', { year, department });
    console.log('📊 currentData available:', currentData ? currentData.length : 'undefined');

    if (year) {
        // Year selected - show year comparison
        if (department && department.trim() !== '') {
            // Year + Department selected - show sub-departments year comparison
            console.log('📊 Showing sub-departments year comparison for:', department, year);
            updateSubDepartmentYearComparison(department, year);
        } else {
            // Year only selected - show main departments year comparison
            console.log('📈 Showing main departments year comparison for year:', year);
            updateYearComparisonChart(year);
        }
    } else {
        // No year selected - show time series (regardless of department selection)
        if (department && department.trim() !== '') {
            // Department only selected - show department time series
            console.log('📊 Showing department time series for:', department);
            updateDepartmentTimeSeriesChart(department);
        } else {
            // No filters - show overall time series
            console.log('📊 Showing overall time series for all years');
            updateTimeSeriesChart();
        }
    }
}

function updateTimeSeriesChart() {
    console.log('🔍 updateTimeSeriesChart called with currentData:', {
        length: currentData ? currentData.length : 'undefined',
        sample: currentData ? currentData.slice(0, 3) : 'undefined'
    });

    const yearData = {};
    currentData.forEach(record => {
        yearData[record.year] = (yearData[record.year] || 0) + record.budget;
    });

    console.log('📊 Processed yearData:', yearData);

    const years = Object.keys(yearData).sort();
    const budgets = years.map(year => yearData[year]);

    console.log('📊 Final chart data:', { years, budgets });

    // Update chart type and options for time series
    yearChart.config.type = 'line';
    yearChart.options.plugins.title.text = 'Budget Trends Over Time (All Departments)';
    yearChart.options.scales.y.title.text = 'Budget (Million ₾)';

    yearChart.data.labels = years;
    yearChart.data.datasets = [{
        label: 'Total Budget',
        data: budgets,
        borderColor: '#45b089',
        backgroundColor: 'rgba(69, 176, 137, 0.1)',
        fill: true,
        tension: 0.1
    }];

    // Hide summary info for time series
    document.getElementById('year-chart-info').style.display = 'none';

    yearChart.update();

    console.log('🔍 Overall time series chart updated');
}

function updateDepartmentTimeSeriesChart(department) {
    console.log('🔍 updateDepartmentTimeSeriesChart called with:', { department, currentData: currentData ? currentData.length : 'undefined' });

    // Filter data for the specific department
    const departmentData = currentData.filter(record => record.name === department);

    if (departmentData.length === 0) {
        console.log('⚠️ No data found for department:', department);
        updateTimeSeriesChart(); // Fall back to overall time series
        return;
    }

    // Group by year and sum budgets for the department
    const yearData = {};
    departmentData.forEach(record => {
        yearData[record.year] = (yearData[record.year] || 0) + record.budget;
    });

    console.log('📊 Processed department yearData:', yearData);

    const years = Object.keys(yearData).sort();
    const budgets = years.map(year => yearData[year]);

    console.log('📊 Final department chart data:', { years, budgets });

    // Update chart type and options for department time series
    yearChart.config.type = 'line';
    yearChart.options.plugins.title.text = `Budget Trends Over Time - ${department}`;
    yearChart.options.scales.y.title.text = 'Budget (Million ₾)';

    yearChart.data.labels = years;
    yearChart.data.datasets = [{
        label: department,
        data: budgets,
        borderColor: '#FF6B6B',
        backgroundColor: 'rgba(255, 107, 107, 0.1)',
        fill: true,
        tension: 0.1
    }];

    // Hide summary info for time series
    document.getElementById('year-chart-info').style.display = 'none';

    yearChart.update();

    console.log('🔍 Department time series chart updated');
}

async function updateYearComparisonChart(selectedYear) {
    try {
        // Fetch data for the selected year and previous year
        const previousYear = parseInt(selectedYear) - 1;

        // Get data for both years
        let currentYearUrl = `/api/budget?year=${selectedYear}&limit=1000`;
        let previousYearUrl = `/api/budget?year=${previousYear}&limit=1000`;

        const [currentResponse, previousResponse] = await Promise.all([
            fetch(currentYearUrl),
            fetch(previousYearUrl)
        ]);

        const currentYearData = await currentResponse.json();
        const previousYearData = await previousResponse.json();

        // Create department comparison data
        const comparisonData = {};

        // Process current year data
        currentYearData.forEach(record => {
            comparisonData[record.name] = {
                current: record.budget,
                previous: 0
            };
        });

        // Process previous year data
        previousYearData.forEach(record => {
            if (comparisonData[record.name]) {
                comparisonData[record.name].previous = record.budget;
            } else {
                comparisonData[record.name] = {
                    current: 0,
                    previous: record.budget
                };
            }
        });

        // Convert to chart format and sort by current year budget
        const departments = Object.keys(comparisonData);
        const sortedDepartments = departments.sort((a, b) => comparisonData[b].current - comparisonData[a].current);

        const currentBudgets = sortedDepartments.map(dept => comparisonData[dept].current);
        const previousBudgets = sortedDepartments.map(dept => comparisonData[dept].previous);

        // Calculate percentage changes for tooltip
        const percentageChanges = sortedDepartments.map(dept => {
            const current = comparisonData[dept].current;
            const previous = comparisonData[dept].previous;
            if (previous === 0) return current > 0 ? '+∞%' : '0%';
            const change = ((current - previous) / previous) * 100;
            return change >= 0 ? `+${change.toFixed(1)}%` : `${change.toFixed(1)}%`;
        });

        // Update chart type and options for comparison
        // Destroy and recreate chart to ensure proper bar chart rendering
        yearChart.destroy();

        const yearCtx = document.getElementById('yearChart').getContext('2d');
        yearChart = new Chart(yearCtx, {
            type: 'bar',
            data: { labels: [], datasets: [] },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: {
                        display: true,
                        text: `Budget Comparison: ${selectedYear} vs ${previousYear}`
                    },
                    legend: {
                        display: true,
                        position: 'top'
                    },
                    tooltip: {
                        callbacks: {
                            afterBody: function(context) {
                                const dataIndex = context[0].dataIndex;
                                return `Change: ${percentageChanges[dataIndex]}`;
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        type: 'category',
                        ticks: { maxRotation: 45 }
                    },
                    y: {
                        type: 'linear',
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Budget (Million ₾)'
                        }
                    }
                }
            }
        });

        yearChart.data.labels = sortedDepartments;
        yearChart.data.datasets = [
            {
                label: selectedYear,
                data: currentBudgets,
                backgroundColor: '#45b089',
                borderColor: '#45b089',
                borderWidth: 1,
                categoryPercentage: 0.8,
                barPercentage: 0.9
            },
            {
                label: previousYear,
                data: previousBudgets,
                backgroundColor: '#FF6B6B',
                borderColor: '#FF6B6B',
                borderWidth: 1,
                categoryPercentage: 0.8,
                barPercentage: 0.9
            }
        ];

        // Show summary info
        const totalCurrent = currentBudgets.reduce((sum, budget) => sum + budget, 0);
        const totalPrevious = previousBudgets.reduce((sum, budget) => sum + budget, 0);
        const totalChange = totalPrevious > 0 ? ((totalCurrent - totalPrevious) / totalPrevious) * 100 : 0;
        const changeText = totalChange >= 0 ? `+${totalChange.toFixed(1)}%` : `${totalChange.toFixed(1)}%`;
        const changeColor = totalChange >= 0 ? '#45b089' : '#FF6B6B';

        document.getElementById('year-comparison-summary').innerHTML =
            `<strong>Total Budget:</strong> ${selectedYear}: ${totalCurrent.toLocaleString()}M ₾ | ${previousYear}: ${totalPrevious.toLocaleString()}M ₾ | <span style="color: ${changeColor};">Change: ${changeText}</span>`;
        document.getElementById('year-chart-info').style.display = 'block';

        // Force chart update
        yearChart.update('none');

        // Additional debugging
        console.log('🔍 Main departments chart updated with:', {
            type: yearChart.config.type,
            labelsCount: yearChart.data.labels.length,
            datasetsCount: yearChart.data.datasets.length,
            totalDataPoints: yearChart.data.datasets.reduce((sum, dataset) => sum + dataset.data.length, 0)
        });

    } catch (error) {
        console.error('Error updating year comparison chart:', error);
        // Fall back to time series if comparison fails
        updateTimeSeriesChart();
    }
}

async function updateSubDepartmentBreakdown(department) {
    try {
        // Use latest year as default for breakdown
        const effectiveYear = latestYear;

        console.log('🔍 updateSubDepartmentBreakdown called with:', { department, effectiveYear });

        // Fetch drill-down data for the selected department
        let drillDownUrl = `/api/drill-down/${encodeURIComponent(department)}`;
        if (effectiveYear) drillDownUrl += `?year=${effectiveYear}`;

        console.log('🌐 Fetching drill-down data from:', drillDownUrl);

        const response = await fetch(drillDownUrl);
        const drillDownData = await response.json();

        console.log('📊 Drill-down data received:', drillDownData);

        if (drillDownData.error || !drillDownData.sub_departments) {
            // Fall back to time series if drill-down fails
            console.log('⚠️ Drill-down failed, falling back to time series');
            updateTimeSeriesChart();
            return;
        }

        const subDepts = drillDownData.sub_departments;

        // Sort sub-departments by budget amount
        const sortedSubDepts = subDepts.sort((a, b) => (b.budget_amount || 0) - (a.budget_amount || 0));

        const labels = sortedSubDepts.map(sub => {
            const name = sub.name_english.length > 25 ? sub.name_english.substring(0, 25) + '...' : sub.name_english;
            return name;
        });

        const data = sortedSubDepts.map(sub => sub.budget_amount || 0);
        const percentages = sortedSubDepts.map(sub => sub.allocation_percentage);

        // Update chart type and options for sub-departments
        yearChart.config.type = 'bar';
        yearChart.options.plugins.title.text = `🔍 ${department} Sub-Departments${effectiveYear ? ` (${effectiveYear})` : ''}`;
        yearChart.options.scales.y.title.text = 'Budget (Million ₾)';
        yearChart.options.scales.x.ticks.maxRotation = 45;

        yearChart.data.labels = labels;
        yearChart.data.datasets = [{
            label: 'Budget Amount',
            data: data,
            backgroundColor: '#45b089',
            borderColor: '#45b089',
            borderWidth: 1
        }];

        // Add tooltip with allocation percentage
        yearChart.options.plugins.tooltip = {
            callbacks: {
                afterBody: function(context) {
                    const dataIndex = context[0].dataIndex;
                    return `Allocation: ${percentages[dataIndex]}%`;
                }
            }
        };

        // Ensure legend is visible
        yearChart.options.plugins.legend = {
            display: true,
            position: 'top'
        };

        // Show summary info
        const totalBudget = drillDownData.total_budget || data.reduce((sum, budget) => sum + budget, 0);
        const subDeptCount = subDepts.length;

        document.getElementById('year-comparison-summary').innerHTML =
            `<strong>${department}</strong> | Total Budget: ${totalBudget.toLocaleString()}M ₾ | Sub-Departments: ${subDeptCount}${effectiveYear ? ` | Year: ${effectiveYear}` : ''}`;
        document.getElementById('year-chart-info').style.display = 'block';

        yearChart.update();

    } catch (error) {
        console.error('Error updating sub-department year chart:', error);
        // Fall back to time series if drill-down fails
        updateTimeSeriesChart();
    }
}

async function updateSubDepartmentYearComparison(department, selectedYear) {
    try {
        const previousYear = parseInt(selectedYear) - 1;

        console.log('🔍 updateSubDepartmentYearComparison called with:', { department, selectedYear, previousYear });

        // Fetch drill-down data for both years
        const [currentResponse, previousResponse] = await Promise.all([
            fetch(`/api/drill-down/${encodeURIComponent(department)}?year=${selectedYear}`),
            fetch(`/api/drill-down/${encodeURIComponent(department)}?year=${previousYear}`)
        ]);

        const currentYearData = await currentResponse.json();
        const previousYearData = await previousResponse.json();

        console.log('📊 Current year data:', currentYearData);
        console.log('📊 Previous year data:', previousYearData);
        console.log('📊 Current year sub-departments:', currentYearData.sub_departments);
        console.log('📊 Previous year sub-departments:', previousYearData.sub_departments);

        if (currentYearData.error || !currentYearData.sub_departments) {
            console.log('⚠️ Current year drill-down failed, falling back to main department comparison');
            updateYearComparisonChart(selectedYear);
            return;
        }

        const currentSubDepts = currentYearData.sub_departments || [];
        const previousSubDepts = previousYearData.sub_departments || [];

        // Create comparison data for sub-departments
        const comparisonData = {};

        // First, collect all unique sub-department names from both years
        const allSubDeptNames = new Set();
        currentSubDepts.forEach(sub => allSubDeptNames.add(sub.name_english));
        previousSubDepts.forEach(sub => allSubDeptNames.add(sub.name_english));

        console.log('🔍 All unique sub-department names:', Array.from(allSubDeptNames));

        // Initialize all sub-departments with 0 values
        allSubDeptNames.forEach(name => {
            comparisonData[name] = {
                current: 0,
                previous: 0,
                allocation: 0
            };
        });

        // Process current year sub-departments
        currentSubDepts.forEach(sub => {
            if (comparisonData[sub.name_english]) {
                comparisonData[sub.name_english].current = sub.budget_amount || 0;
                comparisonData[sub.name_english].allocation = sub.allocation_percentage;
            }
        });

        // Process previous year sub-departments
        previousSubDepts.forEach(sub => {
            if (comparisonData[sub.name_english]) {
                comparisonData[sub.name_english].previous = sub.budget_amount || 0;
                // Keep the current year allocation if we have it, otherwise use previous year
                if (!comparisonData[sub.name_english].allocation) {
                    comparisonData[sub.name_english].allocation = sub.allocation_percentage;
                }
            }
        });

        console.log('📊 Comparison data after processing:', comparisonData);

        // Sort by current year budget
        const subDeptNames = Object.keys(comparisonData);
        const sortedSubDepts = subDeptNames.sort((a, b) => comparisonData[b].current - comparisonData[a].current);

        const currentBudgets = sortedSubDepts.map(name => comparisonData[name].current);
        const previousBudgets = sortedSubDepts.map(name => comparisonData[name].previous);

        // Calculate percentage changes
        const percentageChanges = sortedSubDepts.map(name => {
            const current = comparisonData[name].current;
            const previous = comparisonData[name].previous;
            if (previous === 0) return current > 0 ? '+∞%' : '0%';
            const change = ((current - previous) / previous) * 100;
            return change >= 0 ? `+${change.toFixed(1)}%` : `${change.toFixed(1)}%`;
        });

        // Update chart for sub-department comparison
        // Destroy and recreate chart to ensure proper bar chart rendering
        yearChart.destroy();

        const yearCtx = document.getElementById('yearChart').getContext('2d');
        yearChart = new Chart(yearCtx, {
            type: 'bar',
            data: { labels: [], datasets: [] },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: {
                        display: true,
                        text: `🔍 ${department} Sub-Departments: ${selectedYear} vs ${previousYear}`
                    },
                    legend: {
                        display: true,
                        position: 'top'
                    }
                },
                scales: {
                    x: {
                        type: 'category',
                        ticks: { maxRotation: 45 }
                    },
                    y: {
                        type: 'linear',
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Budget (Million ₾)'
                        }
                    }
                }
            }
        });

        yearChart.data.labels = sortedSubDepts;
        yearChart.data.datasets = [
            {
                label: selectedYear,
                data: currentBudgets,
                backgroundColor: '#45b089',
                borderColor: '#45b089',
                borderWidth: 1,
                categoryPercentage: 0.8,
                barPercentage: 0.9
            },
            {
                label: previousYear,
                data: previousBudgets,
                backgroundColor: '#FF6B6B',
                borderColor: '#FF6B6B',
                borderWidth: 1,
                categoryPercentage: 0.8,
                barPercentage: 0.9
            }
        ];

        console.log('📊 Final chart data:', {
            labels: sortedSubDepts,
            currentBudgets: currentBudgets,
            previousBudgets: previousBudgets,
            totalBars: sortedSubDepts.length * 2
        });

        // Add tooltip with percentage change and allocation
        yearChart.options.plugins.tooltip = {
            callbacks: {
                afterBody: function(context) {
                    const dataIndex = context[0].dataIndex;
                    const subDeptName = sortedSubDepts[dataIndex];
                    const allocation = comparisonData[subDeptName].allocation;
                    return `Change: ${percentageChanges[dataIndex]} | Allocation: ${allocation}%`;
                }
            }
        };

        // Ensure legend is visible
        yearChart.options.plugins.legend = {
            display: true,
            position: 'top'
        };

        // Show summary info
        const totalCurrent = currentYearData.total_budget || currentBudgets.reduce((sum, budget) => sum + budget, 0);
        const totalPrevious = previousYearData.total_budget || previousBudgets.reduce((sum, budget) => sum + budget, 0);
        const totalChange = totalPrevious > 0 ? ((totalCurrent - totalPrevious) / totalPrevious) * 100 : 0;
        const changeText = totalChange >= 0 ? `+${totalChange.toFixed(1)}%` : `${totalChange.toFixed(1)}%`;
        const changeColor = totalChange >= 0 ? '#45b089' : '#FF6B6B';

        document.getElementById('year-comparison-summary').innerHTML =
            `<strong>${department}</strong> | ${selectedYear}: ${totalCurrent.toLocaleString()}M ₾ | ${previousYear}: ${totalPrevious.toLocaleString()}M ₾ | <span style="color: ${changeColor};">Change: ${changeText}</span>`;
        document.getElementById('year-chart-info').style.display = 'block';

        // Force chart update
        yearChart.update('none');

        // Additional debugging
        console.log('🔍 Chart updated with:', {
            type: yearChart.config.type,
            labelsCount: yearChart.data.labels.length,
            datasetsCount: yearChart.data.datasets.length,
            totalDataPoints: yearChart.data.datasets.reduce((sum, dataset) => sum + dataset.data.length, 0)
        });

    } catch (error) {
        console.error('Error updating sub-department year comparison:', error);
        // Fall back to main department comparison if sub-department comparison fails
        updateYearComparisonChart(selectedYear);
    }
}

async function updateDepartmentChart() {
    const year = document.getElementById('year-filter').value;
    const department = document.getElementById('department-filter').value;

    console.log('🔍 updateDepartmentChart called with:', { year, department });
    console.log('📊 currentData available for department chart:', currentData ? currentData.length : 'undefined');

    // If a single department is selected, show sub-departments
    if (department && department.trim() !== '') {
        await updateSubDepartmentChart(department, year);
    } else {
        // Show regular department breakdown
        console.log('🏛️ Showing main department breakdown');
        updateMainDepartmentChart();
    }
}

function updateMainDepartmentChart() {
    console.log('🔍 updateMainDepartmentChart called with currentData:', {
        length: currentData ? currentData.length : 'undefined',
        sample: currentData ? currentData.slice(0, 3) : 'undefined'
    });

    const deptData = {};
    currentData.forEach(record => {
        const shortName = record.name.length > 30 ? record.name.substring(0, 30) + '...' : record.name;
        deptData[shortName] = (deptData[shortName] || 0) + record.budget;
    });

    console.log('📊 Processed deptData:', deptData);

    const sortedDepts = Object.entries(deptData)
        .sort((a, b) => b[1] - a[1])
        .slice(0, 8); // Show top 8 departments

    const labels = sortedDepts.map(d => d[0]);
    const data = sortedDepts.map(d => d[1]);

    console.log('📊 Final department chart data:', { labels, data });

    // Update chart title
    departmentChart.options.plugins.title.text = '🏛️ Budget Distribution by Department';

    departmentChart.data.labels = labels;
    departmentChart.data.datasets = [{
        data: data,
        backgroundColor: [
            '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0',
            '#9966FF', '#FF9F40', '#FF6384', '#C9CBCF'
        ]
    }];
    departmentChart.update();

    console.log('🔍 Department chart updated');
}

async function updateSubDepartmentChart(department, year) {
    try {
        // Use latest year as default if no year is selected
        const effectiveYear = year || latestYear;

        // Fetch drill-down data for the selected department
        let drillDownUrl = `/api/drill-down/${encodeURIComponent(department)}`;
        if (effectiveYear) drillDownUrl += `?year=${effectiveYear}`;

        const response = await fetch(drillDownUrl);
        const drillDownData = await response.json();

        // Debug: Log the drill-down data (remove in production)
        // console.log('🔍 Chart drill-down data received:', drillDownData);

        if (drillDownData.error || !drillDownData.sub_departments) {
            // Fall back to regular department chart if drill-down fails
            updateMainDepartmentChart();
            return;
        }

        // Extract sub-department data
        const subDepts = drillDownData.sub_departments;
        const labels = subDepts.map(sub => {
            const name = sub.name_english.length > 25 ? sub.name_english.substring(0, 25) + '...' : sub.name_english;
            return name;
        });

        const data = subDepts.map(sub => sub.budget_amount || 0);
        const percentages = subDepts.map(sub => sub.allocation_percentage);

        // Create enhanced labels with percentages and employee counts
        const enhancedLabels = subDepts.map(sub => {
            const name = sub.name_english.length > 20 ? sub.name_english.substring(0, 20) + '...' : sub.name_english;
            return `${name} (${sub.allocation_percentage}%)`;
        });

        // Update chart title to show it's sub-departments
        const totalBudget = drillDownData.total_budget;
        const budgetText = totalBudget ? ` - ${totalBudget.toLocaleString()}M ₾` : '';
        const yearText = effectiveYear ? ` (${effectiveYear})` : '';
        const defaultYearIndicator = (!year && effectiveYear) ? ' 📅' : ''; // Show calendar icon when using default year
        departmentChart.options.plugins.title.text = `🔍 ${department} Sub-Departments${budgetText}${yearText}${defaultYearIndicator}`;

        // Use different colors for sub-departments
        const subDeptColors = [
            '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7',
            '#DDA0DD', '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E9'
        ];

        departmentChart.data.labels = enhancedLabels;
        departmentChart.data.datasets = [{
            data: data,
            backgroundColor: subDeptColors.slice(0, data.length)
        }];

        departmentChart.update();

    } catch (error) {
        console.error('Error fetching drill-down data:', error);
        // Fall back to regular department chart
        updateMainDepartmentChart();
    }
}

async function updateDataTable() {
    const container = document.getElementById('table-container');
    const department = document.getElementById('department-filter').value;
    const year = document.getElementById('year-filter').value;

    // If a single department is selected, show sub-department table
    if (department && department.trim() !== '') {
        await updateSubDepartmentTable(department, year, container);
    } else {
        updateMainDataTable(container);
    }
}

function updateMainDataTable(container) {
    if (currentData.length === 0) {
        container.innerHTML = '<p>No data available for the selected filters.</p>';
        return;
    }

    // Sort by year desc, then budget desc
    const sortedData = [...currentData].sort((a, b) => {
        if (a.year !== b.year) return b.year - a.year;
        return b.budget - a.budget;
    });

    const table = `
        <table>
            <thead>
                <tr>
                    <th>Year</th>
                    <th>Department</th>
                    <th>Budget (Million ₾)</th>
                </tr>
            </thead>
            <tbody>
                ${sortedData.slice(0, 50).map(record => `
                    <tr>
                        <td>${record.year}</td>
                        <td>${record.name}</td>
                        <td>${record.budget.toLocaleString(undefined, {maximumFractionDigits: 1})}</td>
                    </tr>
                `).join('')}
            </tbody>
        </table>
        ${sortedData.length > 50 ? `<p><em>Showing first 50 of ${sortedData.length} records</em></p>` : ''}
    `;

    container.innerHTML = table;
}

async function updateSubDepartmentTable(department, year, container) {
    try {
        // Use latest year as default if no year is selected
        const effectiveYear = year || latestYear;

        // Fetch drill-down data
        let drillDownUrl = `/api/drill-down/${encodeURIComponent(department)}`;
        if (effectiveYear) drillDownUrl += `?year=${effectiveYear}`;

        const response = await fetch(drillDownUrl);
        const drillDownData = await response.json();

        // Debug: Log the drill-down data (remove in production)
        // console.log('🔍 Table drill-down data received:', drillDownData);

        if (drillDownData.error || !drillDownData.sub_departments) {
            updateMainDataTable(container);
            return;
        }

        const subDepts = drillDownData.sub_departments;
        const totalBudget = drillDownData.total_budget;

        const table = `
            <div style="margin-bottom: 15px; padding: 10px; background: #f8f9fa; border-radius: 5px;">
                <h4>🔍 ${department} - Sub-Department Breakdown</h4>
                ${totalBudget ? `<p><strong>Total Department Budget:</strong> ${totalBudget.toLocaleString()}M ₾ (${effectiveYear})${(!year && effectiveYear) ? ' 📅 Using latest year' : ''}</p>` : ''}
                <p><strong>Sub-Departments:</strong> ${subDepts.length}</p>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>Sub-Department</th>
                        <th>Allocation %</th>
                        <th>Budget (Million ₾)</th>
                        <th>Employees</th>
                        <th>Projects</th>
                    </tr>
                </thead>
                <tbody>
                    ${subDepts.map(sub => `
                        <tr>
                            <td>${sub.name_english}</td>
                            <td>${sub.allocation_percentage}%</td>
                            <td>${sub.budget_amount ? sub.budget_amount.toLocaleString(undefined, {maximumFractionDigits: 1}) : 'N/A'}</td>
                            <td>${sub.employee_count.toLocaleString()}</td>
                            <td>${sub.projects_count}</td>
                        </tr>
                    `).join('')}
                </tbody>
            </table>
            <div style="margin-top: 10px; font-size: 0.9em; color: #666;">
                <p><em>💡 Tip: Select "All Departments" to see the overview again</em></p>
            </div>
        `;

        container.innerHTML = table;

    } catch (error) {
        console.error('Error fetching sub-department table data:', error);
        updateMainDataTable(container);
    }
}

function downloadData() {
    if (currentData.length === 0) {
        alert('No data to download');
        return;
    }

    const csv = [
        ['Year', 'Department', 'Budget (Million ₾)'],
        ...currentData.map(record => [record.year, record.name, record.budget])
    ].map(row => row.map(cell => `"${cell}"`).join(',')).join('\n');

    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `budget_data_${new Date().toISOString().split('T')[0]}.csv`;
    a.click();
    window.URL.revokeObjectURL(url);
}

// Initialize dashboard when page loads
document.addEventListener('DOMContentLoaded', init);
