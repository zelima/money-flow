# Getting Started with Georgian Budget Data Analysis

This guide will help you set up and run the Georgian budget data analysis system locally.

## Prerequisites

Make sure you have the following installed:

- **Python 3.8+** (for data pipeline)
- **Node.js 16+** (for API and web app)
- **Git** (for version control)

## Quick Setup

### 1. Clone the Repository

```bash
git clone https://github.com/olmait/money-flow.git
cd money-flow
```

### 2. Set Up Data Pipeline

```bash
cd data-pipeline
pip install -r requirements.txt
cd ..
```

### 3. Set Up API Server

```bash
cd api
npm install
cd ..
```

### 4. Set Up Web Application

```bash
cd moneyflow-front
npm install
cd ..
```

## Running the System

### Step 1: Run the Data Pipeline

First, let's fetch and process the Georgian budget data:

```bash
cd data-pipeline
dpp run georgian-budget-pipeline
```

This will:
- Download the latest Georgian budget Excel file from geostat.ge
- Clean and normalize the data
- Translate Georgian headers to English
- Generate processed CSV and JSON files

### Step 2: Start the API Server

```bash
cd api
npm run dev
```

The API will be available at: `http://localhost:3001`

### Step 3: Start the Web Application

```bash
cd moneyflow-front
npm run dev
```

The web app will be available at: `http://localhost:5173`

## API Endpoints

Once the API is running, you can access these endpoints:

- `GET /api/health` - Health check
- `GET /api/metadata` - Data metadata and schema
- `GET /api/budget` - Budget data with filtering
- `GET /api/budget/summary/departments` - Department summaries
- `GET /api/budget/trends` - Budget trends over time
- `GET /api/departments` - Available departments
- `GET /api/search` - Search budget data

### Example API Calls

```bash
# Get health status
curl http://localhost:3001/api/health

# Get all departments
curl http://localhost:3001/api/departments

# Get budget data for 2024
curl "http://localhost:3001/api/budget?year=2024&limit=10"

# Search for education-related budget items
curl "http://localhost:3001/api/search?q=education"
```

## Data Processing

The data pipeline processes Georgian budget files through these stages:

1. **Download**: Fetches Excel files from geostat.ge
2. **Structure Detection**: Analyzes Excel layout to find headers and data
3. **Data Cleaning**: Removes empty rows, standardizes column names
4. **Translation**: Converts Georgian text to English using mapping files
5. **Normalization**: Standardizes department codes and amounts
6. **Export**: Saves as CSV and JSON for API consumption

## Configuration

### Environment Variables

Create a `.env` file in the API directory:

```env
NODE_ENV=development
PORT=3001
FRONTEND_URL=http://localhost:5173
```

### Data Pipeline Configuration

Edit `data-pipeline/pipeline-spec.yaml` to customize:

- Source URLs
- Processing parameters
- Output formats
- Translation mappings

## Development

### Running Tests

```bash
# API tests
cd api
npm test

# Web app tests
cd moneyflow-front
npm test
```

### Code Quality

```bash
# Lint API code
cd api
npm run lint

# Lint web app code
cd moneyflow-front
npm run lint
```

## Deployment

### GitHub Actions

The repository includes automated workflows:

1. **Data Pipeline**: Runs weekly to fetch new budget data
2. **API Deployment**: Deploys to cloud providers on push
3. **Web App Build**: Builds and deploys frontend

### Manual Deployment

1. **API Server** (Node.js/Express):
   - Deploy to Heroku, Railway, or Vercel
   - Set environment variables
   - Configure data directory

2. **Web App** (React/Vite):
   - Build: `npm run build`
   - Deploy to Vercel, Netlify, or GitHub Pages

3. **Data Pipeline**:
   - Use GitHub Actions for automation
   - Or run manually on schedule

## Troubleshooting

### Common Issues

1. **Excel File Not Found**:
   - Check if geostat.ge URL has changed
   - Update file IDs in `fetch_georgian_budget.py`
   - Try manual download and place in `data/raw/`

2. **Georgian Text Encoding**:
   - Ensure UTF-8 encoding is used
   - Update translation mappings if needed

3. **API Data Not Loading**:
   - Check if processed data exists in `moneyflow-back/data/`
   - Run data pipeline first
   - Check API logs for errors

### Getting Help

- Open an issue on GitHub
- Check the documentation in `docs/`
- Review example data in `examples/`

## Next Steps

1. **Customize Visualizations**: Modify the web app to add new charts
2. **Add New Data Sources**: Extend pipeline to include other datasets
3. **Enhance Translations**: Improve Georgian-English mappings
4. **Add Alerts**: Set up notifications for data updates

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and add tests
4. Submit a pull request

See `CONTRIBUTING.md` for detailed guidelines.
