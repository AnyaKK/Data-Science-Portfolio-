from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np
import pandas as pd
import statsmodels.api as sm
from sklearn.cluster import KMeans
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (
    accuracy_score,
    mean_absolute_error,
    roc_auc_score,
    silhouette_score,
)
from sklearn.model_selection import TimeSeriesSplit
from sklearn.preprocessing import StandardScaler
from statsmodels.tsa.ar_model import AutoReg


def generate_weekly_data(n_weeks: int = 180, seed: int = 42) -> pd.DataFrame:
    """Generate synthetic weekly infection-count data for a methods demonstration.

    The data are deliberately synthetic: they are not patient records and must not
    be interpreted as a real epidemiological study.
    """
    rng = np.random.default_rng(seed)
    week = np.arange(n_weeks)
    seasonal = np.sin(2 * np.pi * week / 52)
    temperature = 11 - 6 * seasonal + rng.normal(0, 1.8, size=n_weeks)
    school_term = ((week % 52 >= 4) & (week % 52 <= 38)).astype(int)

    counts = np.zeros(n_weeks, dtype=int)
    counts[0] = 16
    for t in range(1, n_weeks):
        log_mu = (
            2.15
            + 0.32 * seasonal[t]
            - 0.018 * temperature[t]
            + 0.18 * school_term[t]
            + 0.018 * counts[t - 1]
        )
        mu = float(np.exp(np.clip(log_mu, 1.0, 4.5)))
        counts[t] = rng.poisson(mu)

    df = pd.DataFrame(
        {
            "week": week,
            "cases": counts,
            "temperature_c": temperature,
            "school_term": school_term,
            "season_sin": seasonal,
            "season_cos": np.cos(2 * np.pi * week / 52),
        }
    )
    df["lag_1_cases"] = df["cases"].shift(1)
    df["rolling_4_cases"] = df["cases"].shift(1).rolling(4, min_periods=1).mean()
    threshold = float(df["cases"].quantile(0.70))
    df["surge_next_week"] = (df["cases"].shift(-1) >= threshold).astype("Int64")
    return df.dropna().reset_index(drop=True)


def clustering_summary(df: pd.DataFrame) -> dict:
    features = df[["cases", "temperature_c", "lag_1_cases", "rolling_4_cases"]]
    scaled = StandardScaler().fit_transform(features)
    model = KMeans(n_clusters=3, n_init=20, random_state=42)
    labels = model.fit_predict(scaled)
    return {
        "n_clusters": 3,
        "silhouette_score": round(float(silhouette_score(scaled, labels)), 4),
        "cluster_counts": {
            str(k): int(v)
            for k, v in pd.Series(labels).value_counts().sort_index().items()
        },
    }


def classification_summary(df: pd.DataFrame) -> dict:
    feature_cols = [
        "lag_1_cases",
        "rolling_4_cases",
        "temperature_c",
        "school_term",
        "season_sin",
        "season_cos",
    ]
    X = df[feature_cols]
    y = df["surge_next_week"].astype(int)

    splitter = TimeSeriesSplit(n_splits=5)
    aucs = []
    accuracies = []
    valid_folds = 0

    for train_idx, test_idx in splitter.split(X):
        X_train, X_test = X.iloc[train_idx], X.iloc[test_idx]
        y_train, y_test = y.iloc[train_idx], y.iloc[test_idx]

        if y_train.nunique() < 2 or y_test.nunique() < 2:
            continue

        scaler = StandardScaler()
        X_train_scaled = scaler.fit_transform(X_train)
        X_test_scaled = scaler.transform(X_test)

        model = LogisticRegression(max_iter=1000, random_state=42)
        model.fit(X_train_scaled, y_train)

        prob = model.predict_proba(X_test_scaled)[:, 1]
        pred = (prob >= 0.5).astype(int)

        aucs.append(roc_auc_score(y_test, prob))
        accuracies.append(accuracy_score(y_test, pred))
        valid_folds += 1

    if not aucs:
        raise RuntimeError("No valid time-series folds contained both outcome classes.")

    return {
        "time_series_cv_folds": valid_folds,
        "mean_roc_auc": round(float(np.mean(aucs)), 4),
        "mean_accuracy": round(float(np.mean(accuracies)), 4),
    }


def autoreg_summary(df: pd.DataFrame) -> dict:
    series = df["cases"].astype(float)
    split = int(len(series) * 0.8)
    train = series.iloc[:split]
    test = series.iloc[split:]

    model = AutoReg(train, lags=4, old_names=False, trend="ct").fit()
    forecast = model.predict(start=split, end=len(series) - 1, dynamic=False)
    mae = mean_absolute_error(test.to_numpy(), np.asarray(forecast))
    return {
        "model": "AutoReg(lags=4)",
        "holdout_weeks": int(len(test)),
        "mae": round(float(mae), 4),
    }


def poisson_glm_summary(df: pd.DataFrame) -> dict:
    cols = [
        "lag_1_cases",
        "rolling_4_cases",
        "temperature_c",
        "school_term",
        "season_sin",
        "season_cos",
    ]
    X = sm.add_constant(df[cols].astype(float), has_constant="add")
    y = df["cases"].astype(float)
    model = sm.GLM(y, X, family=sm.families.Poisson()).fit()
    return {
        "model": "Poisson GLM",
        "aic": round(float(model.aic), 4),
        "deviance": round(float(model.deviance), 4),
        "n_observations": int(model.nobs),
    }


def run_demo() -> dict:
    df = generate_weekly_data()
    return {
        "data": {
            "n_weeks": int(len(df)),
            "synthetic": True,
        },
        "clustering": clustering_summary(df),
        "classification": classification_summary(df),
        "time_series": autoreg_summary(df),
        "probabilistic_count_model": poisson_glm_summary(df),
    }


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Synthetic epidemiology ML methods demonstration."
    )
    parser.add_argument(
        "--output", type=Path, default=None, help="Optional JSON output path."
    )
    args = parser.parse_args()

    results = run_demo()
    rendered = json.dumps(results, indent=2)
    print(rendered)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
