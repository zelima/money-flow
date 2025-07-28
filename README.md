# Georgian Budget Data Analysis - Money Flow

A comprehensive system for analyzing Georgian government budget data, making public spending transparent and accessible.

## Overview

This project fetches, processes, and visualizes Georgian government budget data from official sources like geostat.ge. It uses datapackage-pipelines for data transformation and provides a web interface for exploring budget allocations and spending patterns.

## Features

- 📊 **Data Pipeline**: Automated fetching and processing of Georgian budget Excel files
- 🌐 **Web Visualization**: Interactive charts and tables for budget analysis
- 🔄 **Real-time Updates**: Automated data refresh from government sources
- 🇬🇪 **Georgian Language Support**: Proper handling of Georgian text and translations
- 📱 **Responsive Design**: Works on desktop and mobile devices

## Project Structure

```
money-flow/
├── data-pipeline/          # Data processing pipelines
│   ├── processors/         # Custom data processors
│   ├── pipeline-spec.yaml  # Pipeline configuration
│   └── translations/       # Georgian-English mappings
├── api/                    # Backend API
├── web-app/               # Frontend application
├── data/                  # Processed data storage
│   ├── raw/              # Raw downloaded files
│   ├── processed/        # Cleaned and structured data
│   └── translations/     # Translation files
└── docs/                 # Documentation
```

## Quick Start

### Prerequisites

- Python 3.8+
- Node.js 16+
- datapackage-pipelines

### Installation

1. Clone the repository:
```bash
git clone https://github.com/olmait/money-flow.git
cd money-flow
```

2. Set up the data pipeline:
```bash
cd data-pipeline
pip install -r requirements.txt
```

3. Set up the web application:
```bash
cd web-app
npm install
```

### Running the Pipeline

```bash
cd data-pipeline
dpp run georgian-budget-pipeline
```

### Running the Web App

```bash
cd web-app
npm run dev
```

## Data Sources

- **Primary**: [geostat.ge](https://geostat.ge) - Georgian National Statistics Office
- **Secondary**: [mof.ge](https://mof.ge) - Ministry of Finance
- **Format**: Excel spreadsheets with functional budget classifications

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contact

For questions about Georgian budget data or this project, please open an issue.
