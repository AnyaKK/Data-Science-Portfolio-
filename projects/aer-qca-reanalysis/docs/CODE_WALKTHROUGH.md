# Annotated code and action walkthrough

This guide explains the workflow at three levels: what each R syntax pattern means, what every function does, and why each analytical or file-handling decision was made. The executable source remains authoritative; this document is an annotation layer, not a substitute for running the code.

## 1. Core R syntax used throughout

| Syntax | Meaning in this project |
|---|---|
| `<-` | Assign the value on the right to the named object on the left. |
| `$name` | Select a named column from a data frame or a named element from a list. |
| `x[i]` | Select one or more positions; a logical vector retains positions that are `TRUE`. |
| `x[, columns, drop = FALSE]` | Select data-frame columns while guaranteeing that the result remains a data frame. |
| `function(arguments) { ... }` | Define reusable code with explicit inputs. |
| `package::function()` | Call a function from a named package without relying on search-path order. |
| `...` | Forward optional arguments to another function. |
| `!` | Logical NOT; for example, `!file.exists(path)` means the path is absent. |
| `&` / `|` | Element-wise logical AND / OR. |
| `%in%` | Test whether each left-hand value occurs in the right-hand set. |
| `==` | Equality test. It does not assign a value. |
| `>` | Strict boundary rule used for all five primary crisp sets. Exact cutoff values are non-members. |
| `~CONDITION` | QCA notation for absence of a crisp condition. In R data, absence is calculated as `1 - CONDITION`. |
| `*` in a QCA formula | Boolean conjunction, meaning logical AND. It is not an arithmetic multiplication in the displayed solution string. |
| `+` in a QCA formula | Boolean disjunction, meaning logical OR. |
| `NA` | Missing value. Missing raw data stay missing through calibration and are removed only by the documented complete-case step. |
| `TRUE` / `FALSE` | Logical values used by assertions, status fields, and portfolio mode. |
| `stop()` | Abort immediately with an explanatory error when a required invariant fails. |
| `stopifnot()` | Compact assertion used in the report for fixed truth-table row counts. |
| `invisible()` | Return a value without printing it automatically. |
| `lapply(x, f)` | Apply `f` to every element and return a list; used when output types may differ. |
| `vapply(x, f, template)` | Apply `f` while enforcing the declared output type and length; a mismatch is an error. |
| `apply(x, 1, f)` | Apply `f` across rows (`1`) of a matrix/data frame; used for configuration strings and path unions. |
| `do.call(rbind, rows)` | Call `rbind` with a list of accumulated tables after their schemas have been aligned. |
| `subset(data, condition)` | Select rows satisfying a readable logical expression while retaining a data-frame result. |
| `match(x, table)` | Return one position per `x`; used after unique-key checks to prevent an expanding many-to-many join. |
| `merge(x, y, ...)` | Join tables by key; retained only where reconstructing the submitted branch's row-expansion defect. |
| `ave(sequence, group, FUN = seq_along)` | Number repeated records within each group so duplicate audit rows receive stable occurrence IDs. |
| `seq_len(n)` / `seq_along(x)` | Generate safe index sequences even when `n` or `x` is empty. |
| `drop = FALSE` | Keep a one-column data-frame selection as a data frame rather than silently simplifying it to a vector. |
| `stringsAsFactors = FALSE` | Keep text as character data, avoiding version-dependent automatic factor conversion. |
| `check.names = FALSE` | Preserve deliberate labels such as `~CONDITION` instead of converting them to syntactic R names. |
| `row.names = ...` | Assign stable case identifiers used by QCA and path membership; never exported as an accidental CSV column. |
| `on.exit(action, add = TRUE)` | Guarantee cleanup such as closing a binary file/device or restoring a directory even after an error. |
| `normalizePath()` / `file.path()` | Resolve one canonical path and construct child paths with platform-appropriate separators. |
| `unname(x)` | Remove source vector names when values, not labels, are required. |
| `sprintf()` | Format reconstructed proxy values to fixed precision for order-independent signature comparison. |
| `gsub()` / `sub()` | Apply explicit regular-expression replacements; used for numeric cleaning, path redaction, and negation parsing. |
| `ifelse(test, yes, no)` | Select a value for every element; used for vectorized labels rather than control flow. |
| `pmin()` | Row-wise minimum; for crisp literals it is Boolean intersection/AND. |
| `union(x, y)` | Return unique members of both path sets for the Jaccard denominator. |
| `is.finite(x)` | Accept only observed numeric values, excluding `NA`, `NaN`, and infinities. |
| `suppressWarnings()` | Silence only expected conversion warnings while subsequent missingness checks still audit failed values. |

## Execution contract

- **Reads:** twelve asserted frozen inputs. Only named CSV fields enter calculations; notebooks, rendered reports, and the course script are fingerprinted as provenance evidence but never executed.
- **Writes:** generated CSV and PNG outputs under the configured derived-output directories, plus Quarto's rendered HTML.
- **Private-only writes:** calibrated cases, path memberships, and exclusion rows. The manuscript crosswalk is read/displayed only in private report mode.
- **Never does:** install packages, modify supplied files, download data, execute supplied notebooks, or stage/commit/push Git.
- **Stops when:** required packages, files, columns, unique corrected keys, binary set invariants, case identifiers, or complete truth-table dimensions fail.

## 2. `scripts/qca_helpers.R`

### `assert_packages(packages)`

1. `vapply(..., requireNamespace, logical(1), quietly = TRUE)` checks every required package and guarantees one logical result per package.
2. Missing names are collected rather than failing at the first package.
3. `stop()` explains that packages must be installed beforehand.
4. The function never calls `install.packages()`. Silent installation would make the run stateful and could change package versions without review.

### `assert_files(paths)`

1. `file.exists()` checks every required frozen input.
2. All missing paths are printed in one error so the user can repair configuration in one pass.
3. No fallback download or live scrape occurs.

### `assert_columns(data, required, label)`

1. `setdiff(required, names(data))` identifies schema violations.
2. The labelled error identifies both the input and missing fields.
3. This prevents downstream code from silently reading the wrong version or a similarly named file.

### `assert_unique_key(data, key, label, allow_missing)`

1. The requested key column is checked first.
2. Missing key values are identified independently from duplicates.
3. `duplicated(..., fromLast = TRUE)` marks every member of a duplicate group, not only later occurrences.
4. The function prints example duplicate values and stops before a join.
5. This assertion is the direct safeguard against the submitted Finland duplication.

### `read_source_csv(path, ...)`

1. `read.csv()` supplies a stable base-R importer and converts syntactically awkward source headers into valid names.
2. Empty strings, `NA`, and `NaN` are treated as missing.
3. The host-native decoder is used because forcing either UTF-8 or Latin-1 truncates the mixed-encoding supplied files.
4. Analytical joins use `city_code`, ASCII country keys, and verified city keys; display-name encoding is never the key safeguard.
5. Under a C locale, a UTF-8 byte-order mark can appear as `X...` in the first header. A single header ending in `country_name` is normalized to that exact name.

### `write_utf8_csv(data, path)`

1. The destination parent is created when absent.
2. Row names are never written as an undocumented extra field.
3. Missing values are written as empty cells.
4. Outputs use UTF-8 so derived files have one documented encoding even though source encodings are mixed.

### `rbind_fill(frames)`

1. Empty inputs are removed.
2. The union of column names is calculated.
3. Missing columns are added as `NA` before row binding.
4. This is needed because five- and six-condition simplifying-assumption tables do not naturally have identical schemas.

### `sha256_file(path)`

1. File size is read from metadata.
2. A binary connection reads exactly that many raw bytes.
3. `digest(..., algo = "sha256", serialize = FALSE)` hashes the bytes rather than an R serialization.
4. Reading bytes explicitly avoids a Windows `file.access()` defect for paths containing an ampersand.
5. The resulting hash remains a standard SHA-256 fingerprint and matched the independent PowerShell inventory hashes.

### `row_mean_available(data, columns)`

1. Required year columns are asserted.
2. Values are converted to a numeric matrix.
3. `rowMeans(..., na.rm = TRUE)` averages available years.
4. A row with no usable value becomes `NaN`; the function converts non-finite results to `NA`.
5. This reproduces the course/notebook available-year logic while making all-missing rows explicit.

### `crisp_above(x, threshold)`

1. The output starts as missing for every case.
2. Only finite observations are eligible for calibration.
3. `as.integer(x > threshold)` converts membership to 1 and non-membership to 0.
4. Exact boundary values are 0 because the operator is strict `>`.

### `normalize_country(x)`

1. Surrounding whitespace is removed.
2. A fixed, visible lookup maps supplied aliases to one analytical spelling.
3. The function never performs approximate matching; every change is inspectable.
4. The submitted-error reconstruction deliberately overrides one normalization so the saved `Cypruss` mismatch is faithfully reproduced.

### `make_literal_matrix(cdm, conditions)`

1. Positive condition columns are retained.
2. Negations are calculated as `1 - condition` for binary sets.
3. Negated columns receive `~` labels.
4. The combined matrix ensures necessity and individual sufficiency test every condition and its negation.

### `literal_fit_tables(cdm, conditions, outcome, necessity_cut)`

1. `QCA::pof(..., relation = "necessity")` calculates necessity consistency, coverage, and relevance of necessity.
2. A condition is flagged necessary only when consistency is at least 0.90.
3. A separate `QCA::pof(..., relation = "sufficiency")` call calculates sufficiency consistency, PRI, raw coverage, and unique coverage.
4. Separate tables prevent the manuscript's interchange of consistency and coverage.

### `truth_table_frame(tt, conditions)`

1. The QCA truth-table object is converted to a normal data frame.
2. Printed `-` values for unobserved rows become numeric missing values.
3. A stable sequential row and explicit Boolean configuration string are added.
4. Each row is classified as a logical remainder, sufficient observed row, contradictory observed row below the cutoff, or purely negative observed row.
5. Case identifiers are retained in private mode and removed from portfolio exports.

### `path_membership(term, cdm)`

1. Display parentheses are removed.
2. The term is split at `*`, yielding conjunctive literals.
3. A `~` prefix changes a condition from `x` to `1 - x`.
4. `pmin()` takes the set intersection across literals. For crisp sets this equals logical AND.
5. An unknown condition name stops the run instead of returning a false path.

### `extract_solution(solution, cdm, conditions, model_id, solution_type, case_lookup, outcome)`

1. Every alternative solution model returned by QCA is processed; alternatives are never discarded silently.
2. Each path string is converted back into case-level path membership with `path_membership()`.
3. `QCA::pof()` calculates path consistency, PRI, raw coverage, and unique coverage.
4. `apply(..., max)` constructs union membership across paths for overall solution fit. For crisp sets this is logical OR.
5. For every path, member counts, outcome-member counts, and deviant-consistency counts are calculated.
6. Private case rows receive a stable ID, display name, outcome, and role.
7. QCA simplifying assumptions are extracted by model number for the remainder audit.

### `run_qca_model(cdm, conditions, model_id, incl_cut, n_cut, pri_cut, case_lookup, mutate_rows)`

1. Required set columns and the outcome are asserted.
2. Complete cases are selected explicitly.
3. Unique row names are required because QCA uses them to display cases.
4. Every membership is checked to be binary.
5. `QCA::truthTable()` is called with all settings named: outcome, conditions, inclusion cutoff, frequency cutoff, PRI cutoff, complete table, and case display.
6. The table must contain exactly `2^k` rows.
7. `mutate_rows` is used only for the forensic submitted-row audit. Original and replacement values are recorded before mutation.
8. `QCA::minimize()` without `include` yields the complex solution.
9. `QCA::minimize(include = "?")` yields parsimonious alternatives.
10. Necessity, individual sufficiency, solutions, cases, simplifying assumptions, settings, and original QCA objects are returned together.

### Diagnostic helpers

- `overall_solution_row()` selects the one aggregate row for a requested solution type without ambiguous non-standard evaluation.
- `pairwise_binary_associations()` calculates each binary pair's Pearson/phi correlation as a redundancy diagnostic.
- `threshold_diagnostics()` reports availability, missingness, boundary cases, in/out counts, member shares, and raw range for each cutoff.
- `session_table()` records R, platform, QCA, digest, knitr, and rmarkdown versions.

## 3. `scripts/analysis_pipeline.R`

### `make_corrected_city_data(paths)`

1. Imports the three shared city, LAI, and population sources.
2. Checks every field used downstream.
3. Requires unique `city_code`, population `city_name`, and normalized LAI `country_name` keys.
4. Normalizes country aliases on both sides of the country match.
5. Uses `match()` to append LAI and population values while preserving all 885 main rows and their order.
6. Derives GDP per capita and national-policy means for 2013-2015, LAI mean for 2010/2014, and population mean for 2013-2015.
7. Converts `af` to the raw binary outcome without changing its construct label.
8. Returns both the case data and join-audit counts.

Decision: the corrected code maps the Czech country label on both sides. An earlier probe normalized only one side and incorrectly dropped 26 Czech cases; the final pipeline retains them and yields 726 complete cases.

### `make_five_condition_cdm(city, thresholds)`

1. Maps each condition to its raw measure.
2. Applies the strict cutoff through `crisp_above()`.
3. Uses `city_code` as the row identity.
4. Calculates complete cases across all five conditions and `OUTCOME`.
5. Writes a private exclusion reason for every omitted city.
6. Returns the CDM, selection vector, exclusions, and aligned case lookup.

### `reconstruct_submitted_city_data(city, paths)`

1. Imports national energy and the dated filtered national-population output.
2. Converts non-numeric characters in year fields before arithmetic.
3. Normalizes country names but deliberately preserves the saved `Cypruss` error.
4. Detects the duplicate Finland national key.
5. Merges national energy with the defective population table, then merges to cities.
6. Converts 2020-2023 ktoe values to TJ with factor 41.868 and averages them.
7. Averages 2022-2023 national population.
8. Calculates the submitted population-allocated proxy.
9. Returns the 894 rows and the nine-row expansion count.

Decision: retaining defects here is not an endorsement. It is necessary to identify which branch generated the manuscript and to distinguish reproduction from correction.

### `make_submitted_model(paths, rebuilt_submitted)`

1. Imports the saved 894-row city-energy file.
2. Creates a unique audit ID by combining `city_code` with occurrence number because nine city codes occur twice.
3. Applies the six submitted thresholds.
4. Records all 185 complete-case exclusions.
5. Imports the stored 709-row CDM and compares the seven binary columns exactly.
6. Compares sorted city-code/proxy signatures between the raw-input reconstruction and saved derived file.
7. Reports row counts, duplicate counts, exact matches, and energy-set balance.

### `make_corrected_energy(city, paths)`

1. Imports the frozen national energy file and the unique raw national-population file.
2. Requires unique normalized country keys on both sides.
3. Averages 2020-2022 energy only, because supplied source documentation ends in 2022.
4. Converts ktoe to TJ.
5. Uses 2022 national population rather than averaging a later 2023 value.
6. Allocates the national total by each city's population share.
7. Counts any unmatched countries.

Decision: the resulting field remains a sensitivity proxy. Repairing the join and year choice does not turn national allocation into measured city consumption.

### `make_energy_cdm(energy_city, energy_threshold, base_thresholds)`

1. Recalibrates the same five base conditions.
2. Adds the corrected energy proxy at a supplied threshold.
3. Selects complete six-condition cases.
4. Returns an aligned lookup for QCA case reporting.

### `summarize_qca_result(result, specification, description, main_paths)`

1. Separates complex paths, complex overall fit, parsimonious paths, and parsimonious overall fit.
2. Records table diversity and all QCA settings.
3. Stores full formulas rather than manually typed abbreviations.
4. Counts exact shared paths with the main model.
5. Computes a Jaccard similarity across complex-path sets.

### `make_set_balance_figure(set_balance, path)`

1. Creates a fixed-size PNG through base R.
2. Uses one color for conditions and another for the outcome.
3. Adds 0.15, 0.50, and 0.85 visual reference lines.
4. Closes the graphics device through `on.exit()` even if later code fails.

## 4. `run_analysis()` action sequence

The orchestrator performs these actions in order:

1. Checks `QCA` and `digest` without installing anything.
2. Sets a seed for deterministic behaviour, even though current operations are deterministic.
3. Resolves the configured source root and QCA-pack subdirectory.
4. Resolves output and figure directories outside the source tree.
5. Names all twelve required inputs and stops if any is missing.
6. Calculates source-relative paths, sizes, and SHA-256 hashes.
7. Redacts source filenames in portfolio mode while preserving logical IDs, sizes, and hashes.
8. Builds the corrected one-row-per-city base.
9. Calibrates and runs the corrected five-condition model at `incl.cut = 0.80`, `n.cut = 1`, and `pri.cut = 0`.
10. Reconstructs the erroneous submitted city join from inputs.
11. Calibrates and runs the submitted six-condition model.
12. Repeats rows 3 and 15 as a forensic mutation and relabels the output as an invalid audit artifact.
13. Builds the corrected 2020-2022 energy proxy.
14. Runs energy sensitivities at 8,190 and the empirical median.
15. Runs a main five-condition 0.75 inclusion sensitivity.
16. Runs `n.cut = 2`.
17. Runs lower and higher cutoffs for population, GDP, PM2.5, LAI, and NCP.
18. Compares every complex-path set with the main solution.
19. Builds the full private corrected calibrated dataset.
20. Calculates set balance, binary associations, threshold diagnostics, and energy redundancy diagnostics.
21. Constructs the case-flow table.
22. Combines submitted, invalid-audit, corrected, and energy-sensitivity solution tables.
23. Combines private path cases.
24. Combines simplifying assumptions while preserving five- and six-condition schemas.
25. Builds concise submitted-versus-corrected model checks.
26. Builds the construct/data-level dictionary.
27. Records why no corrected intermediate solution is reported.
28. Generates the set-balance figure.
29. Writes aggregate outputs in both private and portfolio modes.
30. Writes case-level calibrated data, path cases, and exclusions only in private mode.
31. Returns all major objects to Quarto so displayed results and saved CSVs come from the same run.

## 5. Quarto document annotations

### YAML execution and HTML settings

1. `toc: true`, `toc-depth: 3`, and `number-sections: true` make the long audit navigable and give stable section labels without pretending they are manuscript page numbers.
2. `code-fold: false` keeps the analytical code visible by default; `code-tools: true` lets a reader inspect or copy it from the HTML interface.
3. `embed-resources: true` creates a self-contained HTML artifact rather than a report that breaks when its support directory is omitted.
4. `df-print: paged` prevents large complete truth tables from overwhelming the initial page while retaining all rows.
5. `echo: true` and `warning: true` expose code and warnings; `message: false` suppresses package-startup noise only.
6. `error: false` makes any chunk error abort the render. A partially rendered report must never be mistaken for verified analysis.
7. `params.source_root` and `params.output_dir` are portable defaults/overrides; environment variables let the same source render privately or in portfolio mode without editing the QMD.

### Report-local helpers

`show_table(x, digits, caption)` identifies numeric columns with `vapply`, rounds only a display copy, escapes HTML, and delegates formatting to `knitr::kable`. The full-precision CSV remains unchanged.

`metric(name)` performs a named lookup in `model_comparison`; `[1]` makes the scalar contract explicit. `numeric_metric(name)` converts a known numeric text value, and `diagnostic_value(table, name)` retrieves heterogeneous diagnostics by label rather than unstable row number.

`AER_QCA_reanalysis.qmd` is deliberately configured with `code-fold: false` and `echo: true` so analytical code remains visible. Each chunk explains its inputs and why it exists. The setup chunk:

1. reads portfolio mode;
2. resolves `source_root` from a parameter or environment variable;
3. resolves output locations;
4. sources both scripts;
5. executes `run_analysis()`; and
6. defines display-only rounding helpers.

All reported numerical claims are drawn from the returned `analysis` object. Rounding occurs only in HTML display; CSVs retain full precision. Truth-table row-count assertions make a truncated table impossible to render as complete.

Warnings remain enabled. Package startup messages are suppressed because they are not analytical diagnostics. A warning caused by data or model code therefore remains visible and must be resolved or explained.

## 6. Methodological decision register

| Decision | Reason | Consequence |
|---|---|---|
| Outcome means plan-category presence | `af` is the executed outcome field; no quality/implementation variable is present. | Remove stringency, ambition, implementation, and effectiveness claims. |
| Primary model has five conditions | Energy is population-derived, highly correlated with POP, temporally late, and highly imbalanced. | Energy remains a sensitivity, not a primary cause. |
| Main `incl.cut` is 0.80 | This matches the course/notebook workflow and stated method. | The 0.75 run is labelled sensitivity only. |
| Necessity benchmark is 0.90 | Declared in the manuscript and supported by QCA reporting practice. | 0.8735 cannot be called necessary. |
| Stable city key is `city_code` | Display names are not guaranteed unique and have encoding variants. | Case joins and QCA row labels are auditable. |
| Correct country keys before joining | The submitted Kosovo-to-Finland mapping caused case duplication. | Corrected city base stays at 885 rows. |
| No corrected intermediate solution | No complete, source-backed directional expectations or named easy counterfactuals are available. | Complex and parsimonious solutions are reported; invalid row mutation is removed. |
| Interpret the complex solution | It rests on observed sufficient rows; here it equals the parsimonious formula. | No substantive claim depends on unobserved configurations. |
| Avoid mechanism-rich path labels | Commitment, participation, leadership, and implementation are unmeasured. | Interpret Boolean expressions only. |
| Keep case-level files private | Redistribution rights are not established. | Portfolio contains aggregate tables and code, not raw/case-level data. |

## 7. File and portfolio actions

1. The original AER source tree is read only.
2. A temporary working mirror was used for verification because the managed Windows sandbox allowed PowerShell reads but denied child R file access to the external source path. Hashes confirm byte identity; this workaround is not embedded in the delivered workflow.
3. The working project retains private manuscript crosswalk and case-level outputs.
4. The portfolio project receives code, explanatory documentation, aggregate tables, a public-mode rendered report, and a public-safe copy manifest.
5. The portfolio copy excludes the manuscript, feedback, names/emails, copyrighted/course PDFs, original notebooks/reports, raw data, case-level calibrated data, case lists, local paths, and caches.
6. Root portfolio documentation is updated in the existing style.

### Artifact action log

| Action | Artifact class | Reason |
|---|---|---|
| Read | Selected source CSVs | Reconstruct and correct the analytical data. |
| Hash but do not execute | Notebook, rendered HTML, course script, saved output | Establish generating provenance without trusting embedded instructions. |
| Write in both modes | Aggregate diagnostics, truth tables, solutions, sensitivity tables, figure | These support the result and can be made public without case labels. |
| Write in private mode only | Calibrated rows, cases-by-path, exclusion records | Required for internal traceability but contains case-level data. |
| Read/display in private mode only | Manuscript crosswalk | Contains manuscript-specific locators and replacement language. |
| Exclude from portfolio | Manuscript, feedback, PDFs, raw data, notebooks, original HTML, case-level derivatives | Privacy, copyright/licensing, and data-governance boundaries. |

### Exact render interface

From the project root, run:

```powershell
Rscript scripts/render_analysis.R "C:/path/to/authorized/AER" analysis_outputs private
```

The wrapper sets `AER_SOURCE_ROOT`, `AER_OUTPUT_DIR`, `AER_FIGURE_DIR`, and `AER_PORTFOLIO_MODE` only for the current process, invokes `quarto render AER_QCA_reanalysis.qmd --to html`, optionally adds `--output-dir`, checks the exit status, and confirms the HTML exists. Use `results/tables portfolio results/report` for the public build.
7. `git status --short` and `git diff --check` are review-only commands.
8. No `git add`, commit, push, branch change, or history rewrite is performed.

## 8. Reading the outputs

- `model_comparison.csv` is the shortest numerical verdict.
- `submitted_model_comparison.csv` proves the generating branch and defective join reproduction.
- `necessity.csv` and `individual_sufficiency.csv` contain corrected literal diagnostics.
- `truth_table_complete.csv` contains all corrected configurations.
- `truth_table_submitted_complete.csv` preserves the full reconstruction audit.
- `solutions_and_fit.csv` labels every path and overall formula by branch and solution type.
- `cases_by_path.csv` is private and supports case-level verification.
- `sensitivity_comparison.csv` shows which findings survive design alternatives.
- `model_manuscript_crosswalk.csv` translates numerical/model findings into precise manuscript actions.
- `analysis_lineage.csv` traces claims from source field to R object, file, and manuscript location.
- `portfolio_copy_manifest.csv` records every inclusion, exclusion, hash, and sanitization transformation.
