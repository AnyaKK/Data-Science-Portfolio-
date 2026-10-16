# Starbucks offer-response analysis

This Python capstone explores a simulated rewards-program dataset containing customer profiles, offer definitions and event transcripts. The notebook prepares a customer-offer table, derives an offer-success indicator, explores demographic and offer patterns, and builds a logistic-regression pipeline.

## What the notebook demonstrates

- assessment and cleaning of the profile, portfolio and transcript tables;
- date, age, income, gender, channel and offer-type feature engineering;
- reconstruction of offer received, viewed and completed events;
- exploratory charts for customer and offer behaviour;
- a 70/30 train-test split, min-max scaling and logistic regression; and
- ten-fold cross-validation for accuracy, precision and recall plus a confusion matrix.

The portfolio copy uses relative data paths and scikit-learn's built-in confusion-matrix display. Saved outputs were removed to avoid retaining local paths; the analytical cells and markdown remain.

## Data

The raw course dataset is not committed. Place these files in `data/` before running the notebook:

```text
data/
├── portfolio.csv
├── profile.csv
└── transcript.csv
```

The source folder labels these as the Starbucks capstone dataset. The customer identifiers are simulated/anonymised, but the raw event table is large and remains in the ignored local archive rather than Git history.

## Run locally

```bash
python -m venv .venv
python -m pip install -r requirements.txt
jupyter lab starbucks-offer-analysis.ipynb
```

The notebook began as capstone coursework. Its original scenario and attribution remain in the notebook; this README describes the work evidenced by the saved cells without claiming authorship of the supplied prompt or data.

## Limitations

The success label is an engineered interpretation of event sequences, and the resulting associations are not causal. Re-running may also require small compatibility changes if pandas or scikit-learn behaviour changes.
