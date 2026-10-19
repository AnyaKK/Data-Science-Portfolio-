# Build a public-safe manifest of the working-to-portfolio transfer.
#
# Usage:
# Rscript scripts/build_portfolio_manifest.R WORKING_PROJECT_ROOT PORTFOLIO_PROJECT_ROOT
#
# The script records relative/logical paths only. Absolute paths are used in
# memory to read file metadata, but are never written to either manifest. It
# does not copy or delete anything; it documents the already authorized copy.

arguments <- commandArgs(trailingOnly = TRUE)
if (length(arguments) != 2L) {
  stop(
    "Usage: Rscript scripts/build_portfolio_manifest.R WORKING_PROJECT_ROOT PORTFOLIO_PROJECT_ROOT",
    call. = FALSE
  )
}

# Canonical roots make every later existence/hash check unambiguous. `mustWork`
# prevents a typo from producing an apparently valid manifest full of blanks.
working_root <- normalizePath(arguments[[1L]], winslash = "/", mustWork = TRUE)
portfolio_root <- normalizePath(arguments[[2L]], winslash = "/", mustWork = TRUE)

if (!requireNamespace("digest", quietly = TRUE)) {
  stop("The digest package is required to build SHA-256 entries.", call. = FALSE)
}

# Hash raw bytes rather than an R object serialization. This is the same method
# used by the analytical pipeline and is robust to Windows path punctuation.
sha256_file <- function(path) {
  size <- file.info(path)$size
  connection <- file(path, open = "rb")
  on.exit(close(connection), add = TRUE)
  bytes <- readBin(connection, what = "raw", n = size)
  unname(digest::digest(bytes, algo = "sha256", serialize = FALSE))
}

# Return size/hash together. Missing files are represented explicitly as NA so
# a missing expected artifact remains detectable in the CSV.
file_fingerprint <- function(root, relative_path) {
  path <- file.path(root, relative_path)
  if (!file.exists(path)) return(list(size = NA_real_, sha256 = NA_character_))
  list(size = unname(file.info(path)$size), sha256 = sha256_file(path))
}

# Files copied byte-for-byte from the private working project into the public
# project. The two intentionally renamed public documents are listed with their
# destination names and sanitization transformation.
copied <- data.frame(
  source_artifact = c(
    ".gitignore", "README.md", "AER_QCA_reanalysis.qmd", "literature_evidence.csv",
    "scripts/qca_helpers.R", "scripts/analysis_pipeline.R", "scripts/render_analysis.R",
    "scripts/build_portfolio_manifest.R", "docs/CODE_WALKTHROUGH.md", "docs/WORKFLOW.md",
    "docs/source_selection_log_public.md", "docs/analysis_lineage_public.csv", "data/README.md"
  ),
  destination_relative_path = c(
    ".gitignore", "README.md", "AER_QCA_reanalysis.qmd", "literature_evidence.csv",
    "scripts/qca_helpers.R", "scripts/analysis_pipeline.R", "scripts/render_analysis.R",
    "scripts/build_portfolio_manifest.R", "docs/CODE_WALKTHROUGH.md", "docs/WORKFLOW.md",
    "docs/source_selection_log.md", "docs/analysis_lineage.csv", "data/README.md"
  ),
  decision = "included",
  reason = c(
    "Public/private ignore controls", "Project documentation", "Executable annotated report",
    "Short source-claim evidence table; no source text reproduced",
    "Reusable annotated QCA helpers", "Annotated end-to-end analysis",
    "Annotated render wrapper", "Annotated manifest generator",
    "Syntax/function/action commentary", "Reproduction and decision protocol",
    "Public-safe logical source selection record", "Public-safe output lineage", "Data-governance notice"
  ),
  transformation = c(
    rep("byte-identical copy", 10),
    "sanitized logical-source version renamed for the public project",
    "sanitized aggregate lineage renamed for the public project",
    "byte-identical copy"
  ),
  stringsAsFactors = FALSE
)

# Aggregate tables are rerun in portfolio mode rather than copied. This removes
# private case labels and redacts paths at the calculation/export boundary.
table_names <- c(
  "analysis_settings.csv", "case_flow.csv", "condition_associations.csv",
  "data_dictionary.csv", "energy_proxy_diagnostics.csv", "individual_sufficiency.csv",
  "intermediate_solution_decision.csv", "join_audit.csv", "logical_remainders_used.csv",
  "model_comparison.csv", "necessity.csv", "selected_input_hashes.csv",
  "sensitivity_comparison.csv", "session_versions.csv", "set_balance.csv",
  "solutions_and_fit.csv", "submitted_model_comparison.csv",
  "submitted_row_mutation_audit.csv", "threshold_diagnostics.csv",
  "truth_table_complete.csv", "truth_table_submitted_complete.csv"
)
regenerated_tables <- data.frame(
  source_artifact = file.path("analysis_outputs", table_names),
  destination_relative_path = file.path("results", "tables", table_names),
  decision = "regenerated",
  reason = "Aggregate model evidence allowed in the public portfolio",
  transformation = "rerun in portfolio mode; local paths and case labels redacted where applicable",
  stringsAsFactors = FALSE
)

# The figure is deterministic and the report is a distinct public-mode render.
rendered <- data.frame(
  source_artifact = c(
    "analysis_outputs/figures/set_balance_corrected.png",
    "AER_QCA_reanalysis.html"
  ),
  destination_relative_path = c(
    "results/figures/set_balance_corrected.png",
    "results/report/AER_QCA_reanalysis.html"
  ),
  decision = c("regenerated", "regenerated"),
  reason = c("Aggregate set-balance visualization", "Self-contained public analytical report"),
  transformation = c(
    "rerun from the portfolio-mode calibrated aggregate object",
    "portfolio-mode render omitting the private manuscript crosswalk and case labels"
  ),
  stringsAsFactors = FALSE
)

# Explicit exclusions make absence intentional and reviewable. Logical external
# descriptions avoid disclosing source-tree paths or personal document names.
excluded <- data.frame(
  source_artifact = c(
    "source_manifest.csv", "source_selection_log.md", "analysis_lineage.csv",
    "model_manuscript_crosswalk.csv", "analysis_outputs/calibrated_data_corrected.csv",
    "analysis_outputs/cases_by_path.csv", "analysis_outputs/case_exclusions_corrected.csv",
    "analysis_outputs/case_exclusions_submitted.csv", "[authorized source CSVs]",
    "[supplied notebooks and rendered HTML]", "[private manuscript and feedback]",
    "[supplied PDFs and course literature]"
  ),
  destination_relative_path = "",
  decision = "excluded",
  reason = c(
    "Private recursive inventory contains source names/locations",
    "Replaced by a sanitized logical-source record",
    "Replaced by sanitized aggregate lineage",
    "Private manuscript-specific locators and replacement wording",
    "Case-level derived data", "Case-level path membership", "Case-level exclusions",
    "Case-level exclusions", "Raw data; redistribution rights not established",
    "Source code/reports may be private or third-party material",
    "Personal and assessment material", "Copyright/licensing not established"
  ),
  transformation = "not copied",
  stringsAsFactors = FALSE
)

# Combine decisions, then fingerprint both sides for included/regenerated rows.
# The loop is explicit so source and destination metadata stay aligned by row.
manifest <- rbind(copied, regenerated_tables, rendered, excluded)
source_size <- destination_size <- rep(NA_real_, nrow(manifest))
source_sha256 <- destination_sha256 <- rep(NA_character_, nrow(manifest))
for (i in seq_len(nrow(manifest))) {
  if (manifest$decision[i] != "excluded") {
    source <- file_fingerprint(working_root, manifest$source_artifact[i])
    destination <- file_fingerprint(portfolio_root, manifest$destination_relative_path[i])
    source_size[i] <- source$size
    source_sha256[i] <- source$sha256
    destination_size[i] <- destination$size
    destination_sha256[i] <- destination$sha256
  }
}
manifest$source_size_bytes <- source_size
manifest$destination_size_bytes <- destination_size
manifest$source_sha256 <- source_sha256
manifest$destination_sha256 <- destination_sha256

# Record the manifest itself without attempting a self-referential hash: writing
# a hash into the file would necessarily change that file's hash.
self_row <- data.frame(
  source_artifact = "portfolio_copy_manifest.csv",
  destination_relative_path = "docs/portfolio_copy_manifest.csv",
  decision = "generated",
  reason = "Records all inclusion, regeneration, sanitization, and exclusion decisions",
  transformation = "same generated decision table written to private and public projects; self-hash intentionally blank",
  source_size_bytes = NA_real_, destination_size_bytes = NA_real_,
  source_sha256 = NA_character_, destination_sha256 = NA_character_,
  stringsAsFactors = FALSE
)
manifest <- rbind(manifest, self_row)

# Sort by decision and destination for stable diffs, then write the same
# relative-path-only record to both locations.
manifest <- manifest[order(manifest$decision, manifest$destination_relative_path, manifest$source_artifact), ]
row.names(manifest) <- NULL
private_manifest <- file.path(working_root, "portfolio_copy_manifest.csv")
public_manifest <- file.path(portfolio_root, "docs", "portfolio_copy_manifest.csv")
utils::write.csv(manifest, private_manifest, row.names = FALSE, na = "", fileEncoding = "UTF-8")
utils::write.csv(manifest, public_manifest, row.names = FALSE, na = "", fileEncoding = "UTF-8")
message("Wrote ", nrow(manifest), " manifest decisions to both project roots.")
