# Global COVID-19 data analysis in R

This R course notebook retrieves a Wikipedia table of COVID-19 testing by country, cleans it and performs ratio, filtering, sorting and country-comparison exercises.

## Workflow

1. Request the Wikipedia testing-by-country page with `httr`.
2. Extract the first HTML table with `rvest`.
3. Rename and convert fields, remove aggregate or unused columns, and write a local `covid.csv` during execution.
4. Calculate confirmed-to-tested and confirmed-to-population ratios.
5. Filter country names with regular expressions and compare selected countries.

The saved output reports an overall confirmed-to-tested ratio of 0.1 for the extracted table. It also contains example name-pattern, country-comparison and low-ratio queries. Because the source page can change, these values are a record of the original run.

## File

- [covid19-analysis.ipynb](covid19-analysis.ipynb)

## Run locally

Use a Jupyter environment with an R kernel, then install the required packages in R:

```r
install.packages(c("httr", "rvest"))
```

Network access and permission to write `covid.csv` are required.

## Reproducibility notes

- The pre-processing function keeps a hard-coded row range, so a changed Wikipedia table may require adjustment.
- The generated CSV is not committed to this repository.
- One saved comparison emits an R length warning because it compares multi-column rows. Review that cell before reusing the comparison logic.

