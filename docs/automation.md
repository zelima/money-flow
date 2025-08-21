# 🤖 Georgian Budget Data Automation

## 📅 **Quarterly Schedule**

The pipeline runs automatically **4 times per year**:
- **March 15** - Q1 update (post-budget approval)
- **June 15** - Q2 update (mid-year adjustments)
- **September 15** - Q3 update (budget revisions)
- **December 15** - Q4 update (final year data)

**Time**: 6:00 AM UTC (9:00 AM Georgia time)

## 🧠 **Smart Automation Features**

### 1. **Intelligent Data Checking**
- ✅ Only runs if data hasn't been updated in the last 60 days
- ✅ Checks source availability before processing
- ✅ Skips unnecessary runs to save resources

### 2. **Manual Controls**
You can manually trigger the pipeline with options:

#### Quick Manual Run
```bash
# Go to GitHub Actions → "Georgian Budget Data Pipeline" → "Run workflow"
```

#### Manual Trigger Options:
- **Year**: Specify which year to process (default: current year)
- **Force Download**: Force re-download even if data is recent
- **Check Only**: Only check if new data is available (don't process)

### 3. **Data Quality & Validation**
- 📊 Validates record counts and data structure
- 🔍 Checks year ranges and budget totals
- ✅ Updates metadata with processing timestamps
- 📈 Generates data quality reports

## 🏷️ **Automatic Releases**

Each successful pipeline run creates a **quarterly release**:

```
🇬🇪 Georgian Budget Data 2024 Q2
├── 📊 Data Statistics:
│   ├── Records: 225
│   ├── Year range: 2002-2024
│   ├── Departments: 10
│   ├── Total budget: 211,224.7M ₾
│   └── Last updated: 2024-06-15
└── 📁 Files:
    ├── georgian_budget.csv
    ├── georgian_budget.json
    └── datapackage.json
```

## 🔍 **Pipeline Steps**

### 1. **Data Availability Check**
```bash
# Checks if new data is available
# Compares with last update timestamp
# Decides whether to proceed
```

### 2. **Data Processing** (if needed)
```bash
cd data-pipeline
dpp run georgian-budget-pipeline
```

### 3. **Quality Validation**
```bash
# Validates data structure
# Counts records and checks ranges
# Updates metadata
```

### 4. **Git Commit & Push**
```bash
git commit -m "🇬🇪 Update Georgian budget data (225 records) - 2024-06-15"
git push
```

### 5. **Release Creation**
```bash
# Creates GitHub release with data statistics
# Tags: data-2024-Q2-20240615
```

## ⚡ **Usage Examples**

### Check if New Data is Available
```yaml
# Manual trigger with "Check Only: true"
# Will check but not process data
```

### Force Update (Emergency)
```yaml
# Manual trigger with "Force Download: true"
# Will process regardless of last update
```

### Process Specific Year
```yaml
# Manual trigger with "Year: 2023"
# Will process 2023 data specifically
```

## 📊 **Monitoring & Notifications**

### Pipeline Status
- ✅ **Success**: Data updated, release created
- ⏭️ **Skipped**: Recent data available, no update needed
- ❌ **Failed**: Error in processing (check logs)

### Artifacts
- 📋 **Pipeline logs**: Kept for 90 days
- 📊 **Raw data files**: Excel files from geostat.ge
- 📄 **Datapackage**: Metadata and validation info

### GitHub Notifications
- 🏷️ **New Release**: When quarterly data is published
- 📝 **Commit**: When data files are updated
- 🚨 **Failure**: When pipeline encounters errors

## 🔧 **Troubleshooting**

### Pipeline Skipped?
```bash
# Reason: Data updated within last 60 days
# Solution: Use "Force Download: true" if needed
```

### Pipeline Failed?
```bash
# Check: GitHub Actions logs
# Common issues:
# - Source URL not accessible
# - Data format changed
# - Processing errors
```

### Missing Data?
```bash
# Check: data/processed/ directory
# Files should include:
# - georgian_budget.csv
# - georgian_budget.json
# - datapackage.json
```

## 🎯 **Benefits**

### For Users
- 📊 **Always Fresh**: Quarterly updates ensure current data
- 🚀 **No Maintenance**: Fully automated pipeline
- 📈 **Quality Assured**: Validated data with error checking

### For System
- ⚡ **Efficient**: Only processes when needed
- 💾 **Reliable**: Comprehensive error handling
- 📦 **Traceable**: Full audit trail with releases

### For Georgian Citizens
- 🇬🇪 **Transparent**: Regular government budget updates
- 📊 **Accessible**: Data available in multiple formats
- 🔍 **Analyzable**: Ready for research and analysis

---

**🤖 This automation ensures Georgian budget data stays current without manual intervention, while being resource-efficient and providing high-quality, validated datasets for transparency and analysis.**
