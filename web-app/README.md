# Georgian Budget Analysis Dashboard

A simple and elegant Streamlit frontend for visualizing Georgian government budget data.

## Features

- 🇬🇪 **Georgian Budget Overview** - Key statistics and metrics
- 📊 **Interactive Charts** - Budget trends and department comparisons  
- 🔍 **Data Filtering** - Filter by year and department
- 📈 **Trend Analysis** - Department growth rates and patterns
- 📋 **Raw Data Access** - Search and download budget data
- 🎨 **Beautiful UI** - Clean, responsive design

## Quick Start

### 1. Install Dependencies

```bash
cd web-app
pip install -r requirements.txt
```

### 2. Start the FastAPI Backend

Make sure your FastAPI server is running first:

```bash
cd ../api
python main.py
```

The API should be running at http://localhost:8000

### 3. Launch the Dashboard

```bash
cd ../web-app
streamlit run app.py
```

The dashboard will open in your browser at http://localhost:8501

## Dashboard Sections

### 📊 Budget Overview
- Total budget records and coverage years
- Sum of all budgets across departments
- Quick metrics dashboard

### 🔍 Data Explorer
- **Year Filter**: View specific years or all years
- **Department Filter**: Focus on specific ministries
- **Real-time Filtering**: Instant chart updates

### 📈 Visualizations

#### 1. Budget by Year
- **Single Department**: Line chart showing budget trends over time
- **All Departments**: Stacked bar chart by year

#### 2. Departments  
- **Single Year**: Horizontal bar chart comparing departments
- **All Years**: Pie chart showing total budget share

#### 3. Trends
- **Growth Rate Analysis**: Annual growth rates for departments
- **Detailed Metrics**: Total, average, and growth statistics

#### 4. Raw Data
- **Searchable Table**: Find specific departments
- **Download CSV**: Export filtered data

## API Integration

The dashboard connects to your FastAPI backend and uses these endpoints:

- `/health` - API status check
- `/summary` - Overall budget statistics  
- `/budget` - Filtered budget data
- `/departments` - List of all departments
- `/trends/{department}` - Department trend analysis

## Customization

### Adding New Charts

```python
# Example: Add a new visualization
fig = px.scatter(df, x='year', y='budget', color='name')
st.plotly_chart(fig, use_container_width=True)
```

### Modifying Filters

```python
# Example: Add budget range filter
min_budget = st.slider("Minimum Budget", 0, 5000, 0)
max_budget = st.slider("Maximum Budget", 0, 5000, 5000)
```

## Performance

- **Caching**: API calls are cached for 5 minutes
- **Efficient Loading**: Only fetches data when filters change
- **Responsive Design**: Works on desktop and mobile

## Troubleshooting

### Dashboard won't load
- Ensure FastAPI server is running on port 8000
- Check API health at http://localhost:8000/health

### Charts not displaying  
- Verify data is loaded (check the overview metrics)
- Try refreshing the page or clearing cache

### Performance issues
- Reduce the number of records by using filters
- The app caches data automatically to improve speed

## Technology Stack

- **Frontend**: Streamlit
- **Charts**: Plotly Express  
- **Data**: Pandas
- **API Client**: Requests
- **Backend**: FastAPI (separate service) 