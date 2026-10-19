# AER crisp-set QCA reanalysis

This project reconstructs the submitted six-condition energy model, diagnoses whether it supports the manuscript, and runs a corrected five-condition crisp-set QCA. The corrected primary analysis treats the outcome as **presence of the course-defined plan category**, not plan stringency or implementation. The population-derived energy measure is retained only as a sensitivity analysis.

The workflow is intentionally fail-fast and fully annotated. The visible code in `AER_QCA_reanalysis.qmd`, the reusable functions in `scripts/`, and `docs/CODE_WALKTHROUGH.md` explain the syntax, sequence, analytical decisions, and privacy actions. No package is installed, no source is downloaded, and no source file is modified during a run.

## Provenance verdict

The strongest generating provenance is the energy-notebook/rendered-report branch. Its stored calibrated matrix is reproduced exactly, including the effects of a non-unique national-population join. The reconstruction yields 709 complete cases, 42 observed six-condition configurations, 22 logical remainders, and an `ENERGY_CONSUMPTION` necessity consistency below the conventional 0.90 threshold.

The corrected primary model uses 726 complete cases and five conditions. It has 30 observed configurations, 2 logical remainders, no individually necessary condition or negation at 0.90, and five complex/parsimonious paths. Its overall solution consistency is approximately 0.8701 and coverage approximately 0.4012.

## Project structure

```text
AER_QCA_reanalysis.qmd        Executable, annotated Quarto report
scripts/
  qca_helpers.R               Assertions, calibration, QCA, and export helpers
  analysis_pipeline.R         Ordered reconstruction and corrected analysis
  render_analysis.R           Commented command-line render wrapper
  build_portfolio_manifest.R  Commented inclusion/exclusion hash manifest
analysis_outputs/             Private audit outputs after a local private run
docs/
  CODE_WALKTHROUGH.md         Function-, syntax-, decision-, and action-level notes
  WORKFLOW.md                 Reproduction and verification protocol
  portfolio_copy_manifest.csv Included, regenerated, sanitized, and excluded artifacts
data/
  README.md                   Data-access and non-redistribution statement
results/                      Public-mode report, figures, and aggregate tables
```

## Requirements

- R 4.4 or a compatible recent R release
- R packages `QCA`, `digest`, and `knitr`
- Quarto
- Authorized access to the original AER source directory

Package installation is deliberately outside the analytical script. Record and review versions before running; the report exports its observed R and package versions.

## Run the private audit

From the project root in PowerShell:

```powershell
Rscript scripts/render_analysis.R "C:/path/to/authorized/AER" analysis_outputs private
```

This mode writes aggregate results plus case-level audit files such as calibrated cases, exclusions, and cases-by-path. Those files are private and must not be committed to a public portfolio.

## Run the public-safe portfolio build

```powershell
Rscript scripts/render_analysis.R "C:/path/to/authorized/AER" results/tables portfolio results/report
```

Portfolio mode suppresses case names in truth tables, redacts local source paths, and does not write calibrated case data, exclusions, or cases-by-path. It is a disclosure control, not a substitute for reviewing the resulting Git diff.

## Interpretation guardrails

- `OUTCOME` means plan-category presence only.
- `SUPPORTED` is a national enabling-context score assigned to cities; it is not a city-level CCPI score.
- `AUTONOMOUS` is the country-level Local Autonomy Index; it is not a measure of participatory governance.
- `BENEFIT` is city PM2.5 and therefore needs an explicit co-benefits argument in the literature review.
- `ENERGY_CONSUMPTION` is a national total allocated by population share. It is not measured city consumption and is strongly entangled with `POP`.
- Complex, parsimonious, and intermediate solutions must be labelled separately. No corrected intermediate solution is claimed without a defensible directional-expectation vector.
- Logical remainders are never converted to observed/sufficient rows by numeric truth-table position.

## Verification

After rendering, check that:

1. the submitted calibrated-data reconstruction reports an exact match;
2. the corrected truth table has 32 rows and the submitted table has 64;
3. the corrected model reports 726 cases and 2 remainders;
4. no individual corrected literal passes necessity consistency 0.90;
5. the HTML report and CSV outputs agree on solution consistency and coverage; and
6. a portfolio build contains no local paths, personal identifiers, source documents, or case-level rows.

See `docs/WORKFLOW.md` for the complete action log and `docs/CODE_WALKTHROUGH.md` for line-by-line conceptual annotations.
