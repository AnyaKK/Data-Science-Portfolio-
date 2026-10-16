# Tesla and GameStop stock and revenue visualisation

This course notebook combines historical share-price data with quarterly revenue data for Tesla and GameStop, then displays each company in a two-panel Plotly figure.

## Workflow

- Downloads maximum-period TSLA and GME price histories with `yfinance`.
- Requests company revenue pages from Macrotrends and parses tables with Beautiful Soup.
- Removes currency symbols and thousands separators from revenue fields.
- Plots historical share price and revenue in paired Plotly charts.

The saved price outputs begin on 29 June 2010 for Tesla and 13 February 2002 for GameStop. The notebook is an extraction and visualisation exercise; it does not contain a predictive model or an investment recommendation.

## File

- [stock-revenue-dashboard.ipynb](stock-revenue-dashboard.ipynb)

## Run locally

```bash
python -m pip install jupyter yfinance pandas requests beautifulsoup4 html5lib plotly
jupyter notebook stock-revenue-dashboard.ipynb
```

Network access is required. Live market-data and website responses may differ from the saved output or block automated requests.

## Compatibility notes

The notebook uses the removed `DataFrame.append` method and contains a malformed date cutoff in its graph helper. It may need small updates for current pandas versions before a full rerun.

