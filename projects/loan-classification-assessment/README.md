# Loan-repayment classification assessment

This completed Python machine-learning assessment compares classifiers for predicting whether a loan will be paid off or enter collection. It is retained as a compact example of an end-to-end supervised-learning exercise.

## Evidence in the notebook

The notebook loads training and test data, converts dates, explores class patterns, engineers day-of-week and categorical features, normalises inputs and trains:

- k-nearest neighbours;
- a decision tree;
- a support-vector machine; and
- logistic regression.

Evaluation cells use Jaccard score, F1 score and log loss where applicable. The Git-ready copy has outputs and local execution metadata removed, so this README does not assert a particular winning score.

## Run locally

```bash
python -m venv .venv
python -m pip install -r requirements.txt
jupyter lab loan-classification.ipynb
```

The notebook references course-hosted CSV files and therefore requires network access. It began as an IBM Skills Network/Coursera assessment; the supplied instructions and attribution remain in the notebook.
