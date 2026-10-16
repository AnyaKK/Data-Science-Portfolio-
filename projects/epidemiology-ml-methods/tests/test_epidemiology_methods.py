from pathlib import Path
import sys

PROJECT_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_DIR))

from epidemiology_methods import (
    autoreg_summary,
    classification_summary,
    clustering_summary,
    generate_weekly_data,
    poisson_glm_summary,
)


def test_generate_weekly_data_has_expected_columns():
    df = generate_weekly_data(n_weeks=120, seed=7)
    expected = {
        "week",
        "cases",
        "temperature_c",
        "school_term",
        "season_sin",
        "season_cos",
        "lag_1_cases",
        "rolling_4_cases",
        "surge_next_week",
    }
    assert expected.issubset(df.columns)
    assert len(df) > 100
    assert df.isna().sum().sum() == 0


def test_machine_learning_summaries_are_well_formed():
    df = generate_weekly_data()
    cluster = clustering_summary(df)
    classifier = classification_summary(df)

    assert cluster["n_clusters"] == 3
    assert 0 <= cluster["silhouette_score"] <= 1
    assert classifier["time_series_cv_folds"] >= 1
    assert 0 <= classifier["mean_roc_auc"] <= 1
    assert 0 <= classifier["mean_accuracy"] <= 1


def test_time_series_and_probabilistic_models_run():
    df = generate_weekly_data()
    ts = autoreg_summary(df)
    glm = poisson_glm_summary(df)

    assert ts["holdout_weeks"] > 0
    assert ts["mae"] >= 0
    assert glm["n_observations"] == len(df)
    assert glm["aic"] > 0
