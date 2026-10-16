# Heart-disease feature selection with GA and PSO

This Python capstone compares genetic-algorithm (GA) and particle-swarm-optimisation (PSO) feature selection for heart-disease classification. It uses the processed Cleveland benchmark data and evaluates logistic regression, decision tree, random forest, support-vector machine and XGBoost classifiers against an all-feature baseline.

## What is included

- `heart-disease-ga-pso.ipynb` — the reviewable workflow, with saved outputs and machine-specific paths removed.
- `data/processed.cleveland.data` — the 303-row benchmark input used by the notebook.
- `results/` — selected tables from the saved final run, including out-of-fold performance, calibration, feature counts, stability and paired bootstrap comparisons.
- `requirements.txt` — the main Python dependencies imported by the notebook.

An unchanged copy of the working notebook remains in the ignored local archive. The portfolio copy retains the analytical code while avoiding embedded local paths and multi-megabyte output cells.

## Workflow demonstrated

The notebook records data acquisition and integrity checks, focused exploratory analysis, fold-local preprocessing, frozen outer and inner splits, model tuning, GA and PSO optimisation, out-of-fold prediction, calibration assessment, bootstrap comparisons and feature-selection stability analysis. Fixed random seeds and saved run manifests support repeatability.

## Evidence from the saved run

The saved class table contains 164 records labelled no disease and 139 labelled disease. In the saved out-of-fold summary, logistic regression with all 13 features has ROC AUC 0.914; its GA and PSO variants have ROC AUC 0.908 and 0.906 while selecting means of 8.1 and 8.0 features. These are results of this recorded run, not clinical-performance claims.

See [`results/display_aggregated_performance_rounded.csv`](results/display_aggregated_performance_rounded.csv) and [`results/selected_feature_counts.csv`](results/selected_feature_counts.csv) for the underlying values.

## Run locally

```bash
python -m venv .venv
python -m pip install -r requirements.txt
jupyter lab heart-disease-ga-pso.ipynb
```

The full optimisation is computationally expensive. Use the notebook's fast configuration first when validating an environment.

## Data and limitations

The notebook identifies the processed Cleveland heart-disease data as its benchmark source and includes provenance and verification steps. The dataset is small and historic, and missing-value handling, split choices and optimiser settings affect estimates. This work is a methods demonstration and must not be used for diagnosis or clinical decisions.
