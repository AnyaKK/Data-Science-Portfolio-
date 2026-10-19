# Render the AER QCA report from an authorized source directory.
#
# This script is a thin, deliberately explicit command-line wrapper around
# Quarto. It does not duplicate the analytical logic in analysis_pipeline.R;
# instead, it configures the environment that the visible Quarto setup chunk
# reads and then asks Quarto to execute that document. Keeping configuration
# here and analysis in the pipeline prevents two subtly different workflows.
#
# Command-line syntax
# -------------------
# Rscript scripts/render_analysis.R SOURCE_ROOT [OUTPUT_DIRECTORY] [MODE] [REPORT_OUTPUT_DIRECTORY]
#
# SOURCE_ROOT:
#   Directory containing AER_main/8. QCA & R/QCA pack/QCA pack. This argument
#   is mandatory because the source material is intentionally not bundled.
# OUTPUT_DIRECTORY:
#   Directory for machine-readable tables; defaults to analysis_outputs.
# MODE:
#   Either "private" (case-level audit files allowed) or "portfolio"
#   (aggregate/public-safe outputs only). The default is private.
# REPORT_OUTPUT_DIRECTORY:
#   Optional directory for the HTML artifact. When omitted, Quarto writes the
#   report in the project root. The portfolio convention is results/report.
#
# Example (PowerShell):
# & Rscript scripts/render_analysis.R "D:/authorized/AER" analysis_outputs private

# `commandArgs(trailingOnly = TRUE)` returns only values supplied after the
# script name. It excludes R's own executable flags.
arguments <- commandArgs(trailingOnly = TRUE)

# Fail before doing any work when the required source root was omitted. A
# guessed machine-specific path would undermine reproducibility and privacy.
if (length(arguments) < 1L || !nzchar(arguments[[1L]])) {
  stop(
    paste(
      "Usage: Rscript scripts/render_analysis.R SOURCE_ROOT",
      "[OUTPUT_DIRECTORY] [private|portfolio] [REPORT_OUTPUT_DIRECTORY]"
    ),
    call. = FALSE
  )
}

# Resolve the three user-facing arguments. `if (...) ... else ...` chooses a
# supplied optional value or the documented default. `tolower()` makes the
# mode comparison case-insensitive without allowing ambiguous abbreviations.
source_root <- arguments[[1L]]
output_dir <- if (length(arguments) >= 2L && nzchar(arguments[[2L]])) {
  arguments[[2L]]
} else {
  "analysis_outputs"
}
mode <- if (length(arguments) >= 3L && nzchar(arguments[[3L]])) {
  tolower(arguments[[3L]])
} else {
  "private"
}
# An empty value means Quarto's default (the project root). The path remains
# relative to the project root unless the caller explicitly supplies an
# absolute path.
report_output_dir <- if (length(arguments) >= 4L && nzchar(arguments[[4L]])) {
  arguments[[4L]]
} else {
  ""
}

# Only two modes are valid. Stopping on a misspelling is safer than silently
# producing case-level files when the user intended a public portfolio build.
if (!mode %in% c("private", "portfolio")) {
  stop("MODE must be exactly 'private' or 'portfolio'.", call. = FALSE)
}

# Locate the project root from the current working directory. The runner is
# designed to be launched from the project root, which is also how Quarto
# resolves the document's relative script and output paths.
project_root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
qmd_path <- file.path(project_root, "AER_QCA_reanalysis.qmd")
if (!file.exists(qmd_path)) {
  stop(
    "AER_QCA_reanalysis.qmd was not found in the current working directory. ",
    "Run this command from the project root.",
    call. = FALSE
  )
}

# Verify that the supplied root exists now, rather than letting a deeper CSV
# read fail with a less useful error. `normalizePath()` also removes accidental
# relative-path ambiguity while preserving the path only in process memory.
source_root <- normalizePath(source_root, winslash = "/", mustWork = TRUE)

# Prefer an explicit QUARTO_PATH when supplied; otherwise use the executable on
# PATH. No software is downloaded or installed silently by this script.
quarto <- Sys.getenv("QUARTO_PATH", unset = "")
if (!nzchar(quarto)) {
  quarto <- Sys.which("quarto")
}
if (!nzchar(quarto) || !file.exists(quarto)) {
  stop(
    "Quarto was not found. Install Quarto or set QUARTO_PATH to its executable.",
    call. = FALSE
  )
}

# Environment variables are the documented interface between this wrapper and
# the visible setup chunk in the QMD. `Sys.setenv()` affects only this R process
# and child processes; it does not permanently alter the user's machine.
Sys.setenv(
  AER_SOURCE_ROOT = source_root,
  AER_OUTPUT_DIR = output_dir,
  AER_FIGURE_DIR = file.path(output_dir, "figures"),
  AER_PORTFOLIO_MODE = if (identical(mode, "portfolio")) "true" else "false"
)

# Build the argument vector as separate elements. `system2()` then quotes each
# platform argument safely and returns Quarto's integer exit status.
quarto_arguments <- c(
  "render",
  qmd_path,
  "--to", "html"
)
if (nzchar(report_output_dir)) {
  quarto_arguments <- c(quarto_arguments, "--output-dir", report_output_dir)
}

# Run the render with the project root as the working directory. `on.exit()`
# guarantees that the caller's working directory is restored even if rendering
# fails, which makes this wrapper safe to source from an interactive R session.
old_working_directory <- getwd()
on.exit(setwd(old_working_directory), add = TRUE)
setwd(project_root)
status <- system2(quarto, args = quarto_arguments)

# A non-zero status means the report was not verified. Converting that status
# into an R error prevents downstream automation from treating a partial HTML
# file as a successful analysis.
if (!identical(status, 0L)) {
  stop("Quarto render failed with exit status ", status, ".", call. = FALSE)
}

# Confirm the expected artifact exists after Quarto reports success. The final
# message is intentionally compact so CI logs show the exact verified output.
html_path <- if (nzchar(report_output_dir)) {
  file.path(project_root, report_output_dir, "AER_QCA_reanalysis.html")
} else {
  file.path(project_root, "AER_QCA_reanalysis.html")
}
if (!file.exists(html_path)) {
  stop("Quarto returned success but the expected HTML report is missing.", call. = FALSE)
}
message("Rendered: ", normalizePath(html_path, winslash = "/", mustWork = TRUE))
