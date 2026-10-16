# SpaceX Falcon 9 landing analysis

This folder contains a sequence of course notebooks about Falcon 9 first-stage landing outcomes. Together they cover acquisition, preparation, exploration and model comparison. The notebooks retain their original IBM Skills Network/Coursera attribution.

## Notebook guide

| Order | Notebook | Purpose |
| --- | --- | --- |
| 1 | [API data collection](01-api-data-collection.ipynb) | Loads a saved SpaceX API response, resolves related API identifiers, keeps Falcon 9 launches and fills missing payload mass. |
| 2 | [Wikipedia web scraping](02-wikipedia-web-scraping.ipynb) | Parses launch tables from a fixed Wikipedia revision as a parallel acquisition exercise. |
| 3 | [Data wrangling](03-data-wrangling.ipynb) | Profiles launch data and derives a binary landing-success label. |
| 4 | [Exploratory data analysis](04-exploratory-data-analysis.ipynb) | Compares landing outcomes by flight number, payload, launch site, orbit and year, then prepares categorical features. |
| 5 | [SQL analysis](05-sql-analysis.ipynb) | Uses SQL queries to answer launch-site, payload, booster and landing-outcome questions. |
| 6 | [Model comparison](06-model-comparison.ipynb) | Tunes logistic regression, SVM, decision-tree and K-nearest-neighbour classifiers with grid search. |

The API and wrangling notebooks save intermediate CSV names, but those generated files are not committed here. Later stages load IBM-hosted snapshots instead, so this repository is a set of related notebook exercises rather than a single end-to-end local pipeline.

## Saved outputs

- The API notebook's saved result contains 90 Falcon 9 launch records after filtering; payload mass is mean-imputed, while missing landing-pad values remain.
- The wrangling notebook labels two thirds of its 90 rows as successful landings.
- The model notebook uses 72 training rows and 18 held-out rows. Its saved 10-fold cross-validation scores are about 0.822 for logistic regression, 0.822 for SVM, 0.867 for the decision tree and 0.844 for K-nearest neighbours.

These values describe saved notebook outputs, not independently reproduced benchmarks.

## Running the notebooks

Python notebooks use packages including:

```bash
python -m pip install jupyter pandas numpy requests beautifulsoup4 html5lib matplotlib seaborn scikit-learn
```

The SQL notebook additionally uses Jupyter SQL magic, `ibm_db`, `ibm_db_sa` and SQLAlchemy. Set a valid SQLAlchemy Db2 connection URI before running its connection cell:

```bash
export DB2_CONNECTION='ibm_db_sa://user:password@host:port/database?security=SSL'
```

Use the equivalent environment-variable command for your shell. Network access is required for the external snapshots, APIs and web pages.

## Reproducibility notes

- The Wikipedia scraper is a coursework implementation. Two assignments in its row parser place the wrong extracted values into the launch-site and booster-landing columns, so validate its dataframe before reuse.
- The exploratory notebook creates categorical dummy columns but does not include the intended numeric features in the saved `features_one_hot` object, and its export cell is not run.
- The model notebook fits the scaler before the train/test split. Cells described as test accuracy score the full 90-row dataset, so the README reports the cross-validation results instead.
- The SQL notebook expects an external Db2 instance and table. Several exercise queries differ from their written questions, so treat their saved results as coursework evidence rather than a production analysis.

