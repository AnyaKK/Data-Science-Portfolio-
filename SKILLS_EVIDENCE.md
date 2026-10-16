# Skills Evidence Map

This page points recruiters and collaborators to **inspectable evidence** in the repository. It separates existing coursework/project evidence from newer portfolio-method demonstrations and avoids claiming methods that are not visible in the code.

| Competency | Inspectable evidence | What the evidence shows |
| --- | --- | --- |
| **Git / GitHub version control** | [PR #2 – Organise portfolio and add project documentation](../../pull/2) and [PR #1](../../pull/1) | Branch-based changes, pull requests, merges and repository maintenance. |
| **Repository security / secrets handling** | [`.gitignore`](.gitignore), [`.env.example`](.env.example), and PR #2 | Environment-variable handling and removal of hard-coded credentials from current files. This is repository-security evidence, not a substitute for formal health-data governance training. |
| **Python / pandas** | [SpaceX data wrangling](projects/spacex-falcon9-landing/03-data-wrangling.ipynb), [SpaceX model comparison](projects/spacex-falcon9-landing/06-model-comparison.ipynb), [King County regression](projects/king-county-house-prices/house-price-regression.ipynb) | Data loading, transformation, feature preparation and analytical workflows using pandas. |
| **scikit-learn** | [SpaceX model comparison](projects/spacex-falcon9-landing/06-model-comparison.ipynb), [King County regression](projects/king-county-house-prices/house-price-regression.ipynb) | `GridSearchCV`, logistic regression, SVM, decision tree, KNN, pipelines, scaling, Ridge regression and train/test workflows. |
| **Regression** | [King County regression](projects/king-county-house-prices/house-price-regression.ipynb) and [Boston housing statistics](projects/boston-housing-statistics/boston-housing-analysis.ipynb) | Linear/polynomial/Ridge regression and statsmodels-based statistical modelling. |
| **Classification** | [SpaceX model comparison](projects/spacex-falcon9-landing/06-model-comparison.ipynb) | Logistic regression, SVM, decision tree and KNN model comparison with cross-validation/tuning. |
| **Clustering** | [Epidemiology ML methods](projects/epidemiology-ml-methods/) | KMeans clustering with standardisation and silhouette evaluation on synthetic epidemiology-style data. |
| **Time-series modelling** | [Epidemiology ML methods](projects/epidemiology-ml-methods/) | Forward-only validation and `AutoReg` forecasting on synthetic weekly infection counts. |
| **Probabilistic count modelling** | [Epidemiology ML methods](projects/epidemiology-ml-methods/) | Poisson GLM for weekly count outcomes. |
| **Health / epidemiology context** | [Global COVID-19 analysis in R](projects/covid19-r-analysis/) and [Epidemiology ML methods](projects/epidemiology-ml-methods/) | Public-health-oriented data cleaning/comparison plus a clearly labelled synthetic epidemiology-method demonstration. |
| **Data visualisation** | [Boston housing statistics](projects/boston-housing-statistics/), [Stock and revenue analysis](projects/stock-revenue-analysis/), [SpaceX exploratory analysis](projects/spacex-falcon9-landing/04-exploratory-data-analysis.ipynb) | Matplotlib/seaborn/Plotly visualisation and exploratory analysis. |
| **Reproducibility / testing / CI** | [Epidemiology ML methods](projects/epidemiology-ml-methods/), [GitHub Actions workflow](.github/workflows/portfolio-ci.yml) | Fixed random seed, explicit requirements, automated tests and CI. |
| **R** | [Global COVID-19 analysis](projects/covid19-r-analysis/) and [OpenWeather API exercise](exercises/weather-api-r/) | Web-data extraction, cleaning, filtering and API-oriented R workflows. |
| **SQL** | [SpaceX SQL analysis](projects/spacex-falcon9-landing/05-sql-analysis.ipynb) | SQL-based exploration in the wider analytics workflow. |

## Evidence boundaries

- The epidemiology methods project uses **synthetic data** and is a portfolio skills demonstration, not a clinical or deployed outbreak-prediction system.
- This repository currently demonstrates **pandas** and **scikit-learn** directly in code.
- It does **not** currently establish professional PyTorch or JAX experience.
- The GitHub history and pull requests demonstrate practical Git/GitHub workflow use; they do not by themselves imply enterprise-scale DevOps experience.
