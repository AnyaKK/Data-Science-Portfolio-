# Spatial digital-infrastructure analysis in R

This R and Quarto assessment assembles an England local-authority dataset from model-based unemployment, deprivation and mobile-coverage sources. It focuses on reproducible data integration, join auditing, spatial visualisation, regression diagnostics and decision-support summaries.

## What is included

- `spatial-infrastructure-analysis.qmd` — the sanitized, executable Quarto source.
- `results/figures/` — eight stable-name maps from the latest recorded run.
- `results/tables/` — selected descriptive, correlation, regression and multi-criteria outputs.

The Git-ready source removes the personal author field and course-module identifier. The unchanged original and all raw inputs remain in the ignored local archive.

## Methods demonstrated

The source validates packages and project folders, standardises geography codes, profiles missingness, checks unique join keys, records unmatched keys, joins Nomis, IoD/IMD 2025 and Ofcom data, creates choropleths, estimates ordinary least-squares models with diagnostics and produces a multi-criteria ranking table.

## Input files

The source expects the following public-source files under `data/raw/` (the exact names are also declared in the Quarto document):

- Ofcom Connected Nations mobile-coverage CSV;
- IoD 2025 index and domain workbooks;
- three Nomis exports;
- a 2024 local-authority boundary file; and
- a 2024-to-2025 local-authority lookup.

They are excluded from Git because the boundary and source workbooks are large and independently downloadable. The document's source descriptions should be checked before a new run because public datasets can be revised.

## Run locally

Install Quarto, R and the packages declared in the setup chunk, add the raw files, then run:

```bash
quarto render spatial-infrastructure-analysis.qmd
```

## Limitations

This is an ecological local-authority analysis. Associations and rankings do not establish individual-level or causal effects, and boundary/version changes can affect joins and comparisons.
