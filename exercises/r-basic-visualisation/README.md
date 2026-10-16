# Flower data import and visualisation in R

## About

This compact exercise demonstrates importing a tab-delimited dataset and exploring it with base R graphics. It was recovered during the final local-source audit and is presented separately from the larger notebook collections so that the original scope remains clear.

The data has 96 observations and eight variables describing petunia treatment, nitrogen level, experimental block, plant measurements and flower count. The local file matches the publicly downloadable companion dataset documented in the [*An Introduction to R* importing-data chapter](https://intro2r.com/importing-data.html). The cleaned script retains the analyses present in the local source while using a repository-relative data path.

## What the script demonstrates

- inspecting a data frame with `str()` and `summary()`;
- line, point, histogram, density and dot-chart displays;
- comparing plant weight with shoot area;
- ordered nitrogen-factor levels for grouped boxplots; and
- an optional violin plot when the `vioplot` package is installed.

## Files

| File | Purpose |
| --- | --- |
| `flower-visualisation.R` | Reproducible plotting exercise |
| `data/flower.csv` | Tab-delimited companion data used by the script |
| `data/README.md` | Dataset structure, provenance and attribution note |

## Run

From this directory, run:

```r
source("flower-visualisation.R")
```

Base R is sufficient for every plot except the optional violin plot. Install `vioplot` only if that final comparison is required. Running the script in a non-interactive session may create `Rplots.pdf`; that generated file is ignored by Git.

The unchanged local source script, RStudio project file and both source data variants are preserved in the ignored `local-only/originals/standalone-r-visualisation/` archive. Generated R session state and history files remain only in the source folder.
