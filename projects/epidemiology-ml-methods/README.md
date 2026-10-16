# Epidemiology ML Methods Demonstration

This project is a **methods demonstration using synthetic weekly infection-count data**. It was created to make specific machine-learning and epidemiological-data skills easy to inspect in a public portfolio.

It is **not** a real outbreak-forecasting study, does not contain patient data, and should not be interpreted as evidence of clinical deployment or prospective surveillance.

## What it demonstrates

- **Python data preparation with pandas and NumPy**
- **scikit-learn workflows** for preprocessing, KMeans clustering and logistic regression
- **Chronological validation** with `TimeSeriesSplit`
- **Time-series modelling** with `statsmodels` `AutoReg`
- **Probabilistic count modelling** with a Poisson GLM
- **Model evaluation** using ROC-AUC, accuracy, silhouette score and MAE
- **Reproducibility** through a fixed random seed, explicit project requirements, automated tests and GitHub Actions

## Epidemiology-style workflow

The script generates synthetic weekly infection counts with seasonal structure, temperature, school-term status and lagged case features. It then runs four compact analyses:

1. **Clustering** — KMeans groups weeks with similar case, temperature and lagged-count profiles.
2. **Surge classification** — logistic regression predicts whether the next week reaches a synthetic surge threshold, evaluated with forward-only `TimeSeriesSplit`.
3. **Time-series forecasting** — `AutoReg` forecasts a chronological holdout period from lagged weekly counts.
4. **Probabilistic count modelling** — a Poisson GLM models weekly counts from lagged cases, rolling counts, temperature, school-term status and seasonal terms.

## Repository files

```text
epidemiology-ml-methods/
├── README.md
├── epidemiology_methods.py
├── requirements.txt
├── results.json
└── tests/
    └── test_epidemiology_methods.py
```

## Run locally

```bash
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
python -m pip install -r requirements.txt
python epidemiology_methods.py --output results.json
python -m pytest -q tests
```

## Reproducibility notes

The synthetic dataset is generated with a fixed seed. The committed `results.json` records one verified run of the current code. GitHub Actions runs the tests on pull requests and pushes to `main`.

Because the data are synthetic, the reported metrics are **method checks rather than scientific performance claims**.

## Why this project is in the portfolio

My existing portfolio already contains regression, classification, pandas and scikit-learn work. This compact extension makes additional research-assistant competencies directly inspectable: clustering, chronological validation, time-series modelling, probabilistic count modelling, testing and CI.

For a cross-project evidence map, see [`../../SKILLS_EVIDENCE.md`](../../SKILLS_EVIDENCE.md).
