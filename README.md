# Data Science Portfolio

## About

This public portfolio brings together 11 documented project folders, 66 R/Python learning notebooks and a standalone R visualisation script completed or adapted during data-science study. It demonstrates data collection, wrangling, visualisation, statistical analysis, machine learning, spatial analysis and reproducible workflows, with selected SQL, Excel, Power BI and Bash work. Each project folder explains its question, evidence, methods, data and reproducibility limits.

Many notebooks began as IBM Skills Network or Coursera labs and peer-graded assignments. Their original attribution and course material remain in the notebooks. The summaries below describe the work that is present in this repository; they do not claim results beyond the saved files.

The public repository is a curated, privacy-aware selection from a larger local study archive. Raw private data, account details, institution-facing records, third-party course packs and duplicate checkpoints remain outside version control.

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
| [Heart-disease GA/PSO feature selection](projects/heart-disease-feature-selection/) | Reproducible comparison of all features, genetic-algorithm selection and particle-swarm selection across five classifiers | Python, scikit-learn, XGBoost, PyGAD, PySwarms |
| [Starbucks offer-response analysis](projects/starbucks-offer-analysis/) | Event reconstruction, feature engineering, exploratory analysis and a logistic-regression pipeline on simulated rewards data | Python, pandas, scikit-learn |
| [Loan-repayment classification assessment](projects/loan-classification-assessment/) | KNN, decision-tree, SVM and logistic-regression comparison with classification metrics | Python, pandas, scikit-learn |
| [Spatial digital-infrastructure analysis](projects/spatial-infrastructure-r/) | Audited local-authority joins, spatial mapping, OLS diagnostics and decision-support outputs | R, Quarto, sf, tidyverse |

## Learning exercises

| Collection | Focus |
| --- | --- |
| [Python foundations](exercises/python-foundations/) | 17 notebooks covering core syntax, data structures, control flow, functions, classes, files, NumPy and APIs |
| [Python data analysis](exercises/python-data-analysis/) | Data wrangling, exploratory analysis, model development and evaluation |
| [Python visualisation](exercises/python-visualisation/) | Matplotlib, statistical charts, word clouds, maps and Plotly |
| [Python machine learning](exercises/python-machine-learning/) | Regression, classification, clustering and recommendation systems |
| [Statistics with Python](exercises/python-statistics/) | Descriptive statistics, probability, hypothesis tests, regression and visualisation |
| [Python data engineering](exercises/python-data-engineering/) | API extraction, web scraping and ETL practice |
| [R foundations and analysis](exercises/r-foundations-and-analysis/) | R data structures, web data, charting, tidyverse analysis and modelling |
| [R data import and visualisation](exercises/r-basic-visualisation/) | Tab-delimited data import, exploratory plots, grouped comparisons and an optional violin plot |
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
│   ├── epidemiology-ml-methods/
│   ├── heart-disease-feature-selection/
│   ├── starbucks-offer-analysis/
│   ├── loan-classification-assessment/
│   └── spatial-infrastructure-r/
└── exercises/
    ├── python-foundations/
    ├── python-data-analysis/
    ├── python-visualisation/
    ├── python-machine-learning/
    ├── python-statistics/
    ├── python-data-engineering/
    ├── r-foundations-and-analysis/
    ├── r-basic-visualisation/
    ├── weather-api-r/
    └── bash-backup/
```

## Research-role evidence

For a concise cross-project map of inspectable competencies — including Git/GitHub workflow use, pandas, scikit-learn, regression, classification, clustering, time-series modelling, probabilistic count modelling, visualisation, SQL and reproducibility — see [`SKILLS_EVIDENCE.md`](SKILLS_EVIDENCE.md).

For the local source review, inclusion decisions and privacy/size exclusions recorded during the October 2026 portfolio update, see [`docs/LOCAL_SOURCE_AUDIT.md`](docs/LOCAL_SOURCE_AUDIT.md).

The repository uses short-lived branches and pull requests for maintenance so that portfolio changes can be reviewed before they reach `main`.

## Using the repository

1. Open a project folder and read its `README.md` first.
2. Run notebooks in Jupyter with the language and packages listed in that project guide.
3. Expect network access to be required: several notebooks download IBM-hosted snapshots or query public websites and APIs.
4. Treat saved notebook outputs as a record of the original run. Live sources and package versions can change, so a new run may differ.
5. Learning notebooks retain their course attribution. They are evidence of completed or adapted practice, not a claim of authorship over supplied prompts or datasets.

## Credentials

No credential is required to browse the saved work. Exercises that call OpenWeather, Exchange Rates, IBM Speech to Text, IBM Language Translator or Db2 read their settings from environment variables when those cells are run; the required variable names are listed in [`.env.example`](.env.example). Keep keys, service URLs and connection strings out of notebooks and version control.
