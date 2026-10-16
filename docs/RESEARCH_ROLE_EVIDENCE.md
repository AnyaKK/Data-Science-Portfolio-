# Research-role evidence crosswalk

This page maps common machine-learning, health-data and research-assistant criteria to **inspectable evidence already present in this repository**. It is intended to help recruiters and collaborators find supporting work quickly without overstating professional experience.

## Technical evidence

| Competency | Repository evidence | What can be supported |
| --- | --- | --- |
| Python data analysis | [SpaceX data wrangling](../projects/spacex-falcon9-landing/03-data-wrangling.ipynb), [King County regression](../projects/king-county-house-prices/house-price-regression.ipynb), [heart-disease feature selection](../projects/heart-disease-feature-selection/) | pandas-based loading, cleaning, transformation, feature preparation and analysis |
| scikit-learn | [SpaceX model comparison](../projects/spacex-falcon9-landing/06-model-comparison.ipynb), [loan classification](../projects/loan-classification-assessment/), [heart-disease feature selection](../projects/heart-disease-feature-selection/) | pipelines, scaling, classification, regression, model comparison and tuning |
| Regression | [King County regression](../projects/king-county-house-prices/), [Boston housing statistics](../projects/boston-housing-statistics/) | linear, polynomial, Ridge and statsmodels-based regression |
| Classification | [SpaceX model comparison](../projects/spacex-falcon9-landing/06-model-comparison.ipynb), [loan classification](../projects/loan-classification-assessment/), [heart-disease feature selection](../projects/heart-disease-feature-selection/) | logistic regression, SVM, decision tree, KNN, random forest and XGBoost comparisons |
| Hyperparameter tuning | [SpaceX model comparison](../projects/spacex-falcon9-landing/06-model-comparison.ipynb), [heart-disease feature selection](../projects/heart-disease-feature-selection/) | GridSearchCV and nested/fold-aware model-selection workflows |
| Feature selection / optimisation | [Heart-disease feature selection](../projects/heart-disease-feature-selection/) | genetic-algorithm and particle-swarm feature selection with stability and paired comparisons |
| Clustering | [Epidemiology ML methods](../projects/epidemiology-ml-methods/) | KMeans with standardisation and silhouette evaluation |
| Time-series validation | [Epidemiology ML methods](../projects/epidemiology-ml-methods/) | chronological validation using TimeSeriesSplit |
| Time-series modelling | [Epidemiology ML methods](../projects/epidemiology-ml-methods/) | AutoReg forecasting on synthetic weekly infection counts |
| Probabilistic count modelling | [Epidemiology ML methods](../projects/epidemiology-ml-methods/) | Poisson GLM for count outcomes |
| Model evaluation | [Heart-disease feature selection](../projects/heart-disease-feature-selection/), [epidemiology ML methods](../projects/epidemiology-ml-methods/) | ROC AUC, calibration, sensitivity/specificity, stability, MAE, silhouette score and time-aware evaluation |
| Data visualisation | [Boston housing statistics](../projects/boston-housing-statistics/), [SpaceX EDA](../projects/spacex-falcon9-landing/04-exploratory-data-analysis.ipynb), [stock/revenue visualisation](../projects/stock-revenue-analysis/) | matplotlib, seaborn, Plotly and exploratory/statistical visualisation |
| SQL | [SpaceX SQL analysis](../projects/spacex-falcon9-landing/05-sql-analysis.ipynb) | SQL exploration within an end-to-end analytics workflow |
| R | [Global COVID-19 analysis](../projects/covid19-r-analysis/), [spatial infrastructure analysis](../projects/spatial-infrastructure-r/) | data cleaning, web extraction, modelling, mapping and public-health-oriented analysis |
| Reproducibility | [Epidemiology ML methods](../projects/epidemiology-ml-methods/), [heart-disease feature selection](../projects/heart-disease-feature-selection/), [Portfolio CI](../.github/workflows/portfolio-ci.yml) | explicit dependencies, fixed seeds, saved results/provenance, tests and CI |
| Git / GitHub | [PR #2](https://github.com/AnyaKK/Data-Science-Portfolio-/pull/2), [PR #3](https://github.com/AnyaKK/Data-Science-Portfolio-/pull/3), [PR #4](https://github.com/AnyaKK/Data-Science-Portfolio-/pull/4), [PR #7](https://github.com/AnyaKK/Data-Science-Portfolio-/pull/7) | branch-based changes, pull requests, merges, conflict handling, repository maintenance and CI-backed review |

## Health-data and research context

| Area | Evidence | Scope |
| --- | --- | --- |
| Public-health data | [Global COVID-19 analysis in R](../projects/covid19-r-analysis/) | public-source COVID-19 data extraction, cleaning and comparison |
| Predictive health modelling | [Heart-disease feature selection](../projects/heart-disease-feature-selection/) | benchmark heart-disease classification with leakage-aware validation and feature-selection comparison |
| Epidemiology-relevant methods | [Epidemiology ML methods](../projects/epidemiology-ml-methods/) | synthetic infection-count workflow for clustering, surge classification, chronological validation, forecasting and Poisson modelling |
| Research limitations / non-clinical use | [Heart-disease README](../projects/heart-disease-feature-selection/README.md), [epidemiology model card](../projects/epidemiology-ml-methods/MODEL_CARD.md) | explicit statements about benchmark/synthetic data, non-clinical use, limitations and generalisability |
| Data governance awareness | [Epidemiology data-governance note](../projects/epidemiology-ml-methods/DATA_GOVERNANCE.md), [local source audit](LOCAL_SOURCE_AUDIT.md) | privacy-aware publication decisions, exclusion of sensitive/private data, credential handling and governance considerations for future real health-data work |

## Safe CV wording supported by this repository

The repository supports wording such as:

- "Python data analysis using pandas and scikit-learn"
- "classification and regression model development and evaluation"
- "GridSearchCV and cross-validation"
- "KMeans clustering and silhouette evaluation"
- "chronological validation with TimeSeriesSplit"
- "time-series modelling with statsmodels AutoReg"
- "Poisson GLM count modelling"
- "Git/GitHub workflows using branches, pull requests and merges"
- "reproducible analytical workflows with explicit dependencies, automated tests and GitHub Actions"
- "privacy-aware portfolio curation and documented data-governance considerations"

## Claims this repository does **not** establish

This portfolio does not by itself establish:

- professional epidemiologist employment;
- deployed outbreak-prediction systems;
- access to identifiable patient records for the published projects;
- professional PyTorch or JAX experience;
- NHS-specific information-governance certification;
- enterprise-scale DevOps or MLOps experience.

Those boundaries are intentional. The purpose of this portfolio is to provide transparent, inspectable evidence for methods that are actually visible in the code and documentation.
