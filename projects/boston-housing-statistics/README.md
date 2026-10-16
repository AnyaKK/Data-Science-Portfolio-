# Boston housing statistical analysis

This course notebook uses the Boston housing dataset to practise visualisation, hypothesis testing and regression. It examines median home value alongside Charles River proximity, building age, nitric-oxide concentration, non-retail business acreage, pupil-teacher ratio and distance to employment centres.

## Methods

- Box plots, histograms and scatter plots with pandas, seaborn and matplotlib.
- Levene tests and an independent-samples t-test for Charles River groups.
- One-way ANOVA across three age bands.
- Ordinary least-squares models for nitric oxide versus non-retail acreage and distance versus median value.

The saved notebook output includes 506 observations. It reports a Charles River group t-test p-value of about 0.0036, an age-band ANOVA p-value of about 1.7e-15, an OLS R² of 0.583 for nitric oxide versus non-retail acreage, and an R² of 0.062 for distance versus median value. These figures describe the stored run and should be interpreted with the notebook's assumptions and course framing.

## File

- [boston-housing-analysis.ipynb](boston-housing-analysis.ipynb)

## Run locally

```bash
python -m pip install jupyter pandas numpy scipy statsmodels matplotlib seaborn
jupyter notebook boston-housing-analysis.ipynb
```

The notebook downloads its CSV from IBM Cloud Object Storage.

## Interpretation note

One section is labelled as Pearson correlation but implements OLS and derives a correlation value from R². The README therefore describes the saved model directly rather than treating it as a separately calculated Pearson test.

