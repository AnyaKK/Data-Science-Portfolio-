# Model card: synthetic epidemiology ML methods demonstration

## Purpose

This project is a **methods demonstration** for machine-learning and statistical techniques relevant to epidemiological research. It uses synthetic weekly infection-count data so that the workflow can be inspected publicly without exposing personal or clinical information.

It is not intended for diagnosis, public-health decision-making, outbreak declaration or deployment.

## Data

The dataset is generated programmatically with a fixed random seed. It contains synthetic weekly infection counts, temperature, school-term status, seasonal terms, lagged case counts and rolling case summaries.

No patient records, names, addresses, identifiers or real clinical events are used.

## Methods demonstrated

### KMeans clustering

Standardised weekly features are grouped into three clusters and evaluated using silhouette score. This demonstrates an unsupervised-learning workflow, not clinically meaningful epidemiological phenotypes.

### Surge classification

Logistic regression predicts whether the following week crosses a synthetic surge threshold. Evaluation uses forward-only TimeSeriesSplit rather than random shuffling so later observations are not used to train models evaluated on earlier time periods.

### Time-series forecasting

statsmodels AutoReg is fit on a chronological training period and evaluated on a later holdout period using mean absolute error.

### Probabilistic count modelling

A Poisson GLM models weekly counts from lagged counts, rolling counts, temperature, school-term status and seasonal terms.

## Evaluation

The project reports method-level metrics including ROC AUC, accuracy, silhouette score, mean absolute error, AIC and model deviance.

These metrics confirm that the workflow executes and provides inspectable evaluation. They are **not clinical validation results**.

## Generalisability limitations

The synthetic generator is much simpler than a real infectious-disease system. Real outbreak data can include changes in testing behaviour, reporting delays, interventions, changing population structure, missingness, geographical dependence, strain variation, non-stationarity, case-definition changes and uncertainty in labels and denominators.

Performance on this synthetic dataset therefore says nothing about expected performance on real Strep A, influenza, COVID-19 or other disease surveillance data.

## Bias and fairness

The synthetic data contain no protected demographic attributes. As a result, the project cannot assess subgroup bias or fairness. A real health-data model would require subgroup performance checks, careful review of proxy variables and clinically meaningful error analysis.

## Reproducibility

The project uses a fixed random seed, explicit dependencies, a command-line script, automated tests, saved JSON output and GitHub Actions CI.

## Appropriate interpretation

A recruiter or collaborator can treat this project as evidence that the author has implemented pandas/NumPy data preparation, scikit-learn preprocessing and classification, KMeans clustering, time-aware validation, statsmodels AutoReg, Poisson GLM, model evaluation, pytest tests and CI-backed reproducibility.

It should not be interpreted as evidence of deployed clinical AI, real-world outbreak forecasting or professional epidemiologist practice.
