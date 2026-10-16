# Local R and Python source audit

This audit records how the local study folders were reviewed for the October 2026 portfolio update. It is deliberately written without personal document names, student identifiers, account details or confidential data fields.

## Scope reviewed

The review covered the main `UEL_DS` folder and its nested data-science `Projects` folder. It examined filenames, notebook metadata and source code for R, R Markdown, Quarto, Python and Jupyter files. Notebook checkpoints, virtual environments and Git internals were treated as generated material rather than separate projects.

## Inventory outcome

| Outcome | Material |
| --- | --- |
| Already represented | SpaceX capstone, King County regression, Boston statistics, global COVID-19 analysis in R, stock/revenue visualisation, business-intelligence work, epidemiology methods, weather API practice and Bash practice |
| Added as project folders | Heart-disease GA/PSO feature selection, Starbucks offer-response analysis, loan classification assessment and spatial digital-infrastructure analysis in R |
| Added as learning collections | Python foundations, data analysis, visualisation, machine learning, statistics and data engineering; R foundations, data analysis, data import and visualisation |
| Preserved locally only | Exact source notebooks/scripts, raw private or large data, course packs, reports, binaries and duplicate checkpoints |

Sixty-nine sanitized notebooks were prepared during the original organisation work: three project notebooks and 66 learning notebooks. A fourth project is supplied as an R/Quarto source document. The final audit added one previously missed R data-import and visualisation script with its 96-row teaching dataset.

## Unchanged local archive

Before sanitising any notebook, 311 R/Python source files were copied byte-for-byte into `local-only/originals/`; source and archive SHA-256 checksums matched. The final audit located one additional R script and raised the verified code-copy count to 312. Supporting source data for the Starbucks and R visualisation work is also retained there. The entire `local-only/` tree is excluded by `.gitignore` and is not part of the pull request.

The archive groups files by their source area:

| Source group | Code files |
| --- | ---: |
| Organised IBM coursework | 120 |
| Python projects dump | 143 |
| R projects dump | 26 |
| Spatial R work | 13 |
| Data-ecology R work | 5 |
| Dissertation notebooks | 2 |
| Separate R analysis | 2 |
| Standalone R visualisation | 1 |

These counts include duplicates and alternate versions because the archive's purpose is preservation, not presentation.

## What was identified

### Python

- foundations exercises in language syntax, collections, control flow, functions, classes, files, NumPy and APIs;
- data-analysis exercises covering wrangling, exploratory analysis, regression and model evaluation;
- visualisation exercises using Matplotlib, Plotly, word clouds and maps;
- machine-learning exercises spanning regression, classification, clustering and recommender systems;
- statistics exercises covering distributions, hypothesis tests, regression and visualisation;
- API, scraping and ETL exercises and assessments;
- SpaceX, stock/revenue, house-price, statistics, loan, Starbucks and heart-disease capstone/assessment work; and
- additional clinical, survey, focus-group and web-scraping notebooks that require privacy, provenance or completeness review before publication.

### R

- R foundations, data-import, data-frame, HTTP, scraping, charting and tidyverse exercises;
- data-analysis/model-development review notebooks;
- a standalone flower-data import and base-graphics exercise;
- the global COVID-19 and OpenWeather work already represented in the repository;
- a spatial digital-infrastructure assessment built in Quarto;
- survey-analysis scripts whose respondent data is sensitive; and
- QCA and other supplied exercise-pack notebooks that need clearer authorship/provenance separation before publication.

## Publication decisions

The following material remains local-only:

- participant-level survey, clinical, focus-group and health records;
- transcripts, contracts, tutor records, assessment briefs and institution-facing reports;
- documents containing student or candidate identifiers;
- raw notebooks that contain account-connection or API credential cells;
- large raw archives and datasets, including airline and movie data;
- SPSS, installer, video, subtitle and other non-R/Python course assets;
- duplicate notebook checkpoints and the earlier incomplete Windows checkout; and
- third-party tutorials or course packs where a completed personal contribution cannot be separated confidently from the supplied material.

One substantial predictive-web-analytics notebook was also kept local-only because it still contains a machine-specific input path, lacks clear dataset provenance and licensing, and is accompanied by reports containing personal identifiers. It requires a separate reproducibility and privacy review before publication.

Git-ready notebooks retain visible course attribution. Newly prepared or sanitised copies have unnecessary output cells and transient metadata removed where needed, and machine-specific user-home prefixes are replaced. Earlier project notebooks may intentionally retain saved results; the final cleanup removed only the largest raw HTML/table payloads. The unchanged originals remain available locally for comparison.

## Clone and CI findings

The old checkout inside the projects dump failed on a historical filename containing a Windows-invalid colon. It was preserved untouched. A fresh clone of current `main` into a new Windows directory succeeded, confirming that the repository history now checks out on Windows.

The screenshot's `AutoReg(..., old_names=False)` failure refers to an earlier revision. Current `main` no longer passes `old_names`, and the epidemiology test suite passes locally (`3 passed`). The repository now pins Ubuntu 24.04 and uses the current Node-24-based major versions of the checkout and Python setup actions, addressing the separate runner deprecation warning shown in the screenshot.
