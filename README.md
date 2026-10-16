# Data Science Portfolio

This repository collects data analysis, statistics, machine-learning and business-intelligence coursework. The projects use Python, R, SQL, Excel, Power BI and Bash. Each project folder has a short guide to its question, data, methods, saved outputs and reproducibility notes.

Many notebooks began as IBM Skills Network or Coursera labs and peer-graded assignments. Their original attribution and course material remain in the notebooks. The summaries below describe the work that is present in this repository; they do not claim results beyond the saved files.

## Projects

| Project | What it demonstrates | Main tools |
| --- | --- | --- |
| [SpaceX Falcon 9 landing analysis](projects/spacex-falcon9-landing/) | API collection, web scraping, data wrangling, SQL exploration, visual analysis and classification-model comparison | Python, pandas, scikit-learn, Beautiful Soup, SQL |
| [King County house-price regression](projects/king-county-house-prices/) | Data cleaning, exploratory analysis, linear and polynomial regression, and Ridge evaluation | Python, pandas, seaborn, scikit-learn |
| [Boston housing statistics](projects/boston-housing-statistics/) | Visualisation, hypothesis tests and ordinary least-squares models | Python, SciPy, statsmodels, seaborn |
| [Global COVID-19 analysis in R](projects/covid19-r-analysis/) | HTML-table extraction, data cleaning, ratios, filtering and country comparisons | R, httr, rvest |
| [Stock and revenue visualisation](projects/stock-revenue-analysis/) | Tesla and GameStop market-data extraction, revenue scraping and Plotly charts | Python, yfinance, Beautiful Soup, Plotly |
| [Business-intelligence exercises](projects/business-intelligence/) | Excel pivot analysis, Power BI report design and static dashboard outputs | Excel, Power BI |
| [Epidemiology ML methods demonstration](projects/epidemiology-ml-methods/) | Synthetic epidemiology-style workflow for clustering, chronological validation, time-series forecasting, probabilistic count modelling, tests and CI | Python, pandas, scikit-learn, statsmodels, pytest |

## Smaller exercises

| Exercise | Focus |
| --- | --- |
| [OpenWeather API in R](exercises/weather-api-r/) | A coursework draft for collecting five-day forecasts with `httr` |
| [Bash backup script](exercises/bash-backup/) | A coursework draft for creating a timestamped archive from recently modified files |

## Repository layout

```text
.
├── README.md
├── SKILLS_EVIDENCE.md
├── .github/
│   └── workflows/
│       └── portfolio-ci.yml
├── projects/
│   ├── spacex-falcon9-landing/
│   ├── king-county-house-prices/
│   ├── boston-housing-statistics/
│   ├── covid19-r-analysis/
│   ├── stock-revenue-analysis/
│   ├── business-intelligence/
│   └── epidemiology-ml-methods/
└── exercises/
    ├── weather-api-r/
    └── bash-backup/
```

## Research-role evidence

For a concise cross-project map of inspectable competencies — including Git/GitHub workflow use, pandas, scikit-learn, regression, classification, clustering, time-series modelling, probabilistic count modelling, visualisation, SQL and reproducibility — see [`SKILLS_EVIDENCE.md`](SKILLS_EVIDENCE.md).

The repository uses branch-based pull requests for larger maintenance changes. Recent examples include [PR #2](../../pull/2), which reorganised the portfolio, documented projects and removed hard-coded credentials from current files.

## Using the repository

1. Open a project folder and read its `README.md` first.
2. Run notebooks in Jupyter with the language and packages listed in that project guide.
3. Expect network access to be required: several notebooks download IBM-hosted snapshots or query public websites and APIs.
4. Treat saved notebook outputs as a record of the original run. Live sources and package versions can change, so a new run may differ.

## Credentials

No credential is required to browse the saved work. The weather exercise reads `OPENWEATHER_API_KEY`, and the Db2 notebook reads `DB2_CONNECTION`, from environment variables when those cells are run. Keep keys and connection strings out of notebooks and version control.
