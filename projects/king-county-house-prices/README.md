# King County house-price regression

This project explores house sales in King County, Washington, including Seattle, and builds regression models for sale price. The notebook is a completed data-analysis course assignment and retains its original course attribution.

## What the notebook does

- Downloads an IBM-hosted copy of the King County house-sales dataset.
- Removes identifier columns and mean-imputes missing bedroom and bathroom values.
- Uses descriptive statistics, a waterfront box plot, a living-area regression plot and feature correlations for exploration.
- Fits single-feature and multi-feature linear regression models.
- Builds a scaling and second-degree polynomial pipeline.
- Evaluates Ridge regression on an 85/15 train/test split.

The saved dataset has 21,613 rows. Saved outputs report an in-sample R² of about 0.493 for living area alone, 0.658 for the 11-feature linear model and 0.751 for the polynomial pipeline. The final degree-two Ridge model reports a held-out R² of about 0.700. These are the notebook's stored results, not newly reproduced benchmarks.

## File

- [house-price-regression.ipynb](house-price-regression.ipynb)

## Run locally

```bash
python -m pip install jupyter pandas numpy matplotlib seaborn scikit-learn
jupyter notebook house-price-regression.ipynb
```

The notebook downloads its CSV from IBM Cloud Object Storage, so it requires network access.

## Reproducibility note

The assignment prose asks for one Ridge setting while the implemented cells use `alpha=1`. The results above follow the code that is actually saved in the notebook. Most earlier R² values are training-set scores; the final Ridge values use the held-out split.

