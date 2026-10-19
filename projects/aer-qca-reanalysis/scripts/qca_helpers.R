# Reusable helpers for the AER crisp-set QCA audit.
# This file deliberately uses only base R, QCA, and digest.
#
# Reading convention
# ------------------
# Every public helper below starts with a comment that states its inputs,
# action, and output. The longer rationale and a glossary of R/QCA syntax are
# in docs/CODE_WALKTHROUGH.md. Keeping both layers makes the source readable
# during execution without turning every expression into duplicated prose.

# Dependency assertion: receive character package names, check them without
# attaching them, and return invisibly on success. Missing packages are an
# error because automatic installation would make the analysis non-reproducible.
assert_packages <- function(packages) {
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) {
    stop(
      "Missing required R package(s): ", paste(missing, collapse = ", "),
      ". Install them before rendering; this workflow never installs packages silently.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

# Input assertion: verify every required path before any analytical step. The
# vectorized check lets one error list all missing inputs rather than failing
# piecemeal during later imports.
assert_files <- function(paths) {
  missing <- paths[!file.exists(paths)]
  if (length(missing)) {
    stop("Required input file(s) not found:\n- ", paste(missing, collapse = "\n- "), call. = FALSE)
  }
  invisible(TRUE)
}

# Schema assertion: compare required field names with a data frame's actual
# names and stop with a labelled diagnostic when a version is incompatible.
assert_columns <- function(data, required, label = deparse(substitute(data))) {
  missing <- setdiff(required, names(data))
  if (length(missing)) {
    stop(label, " is missing expected column(s): ", paste(missing, collapse = ", "), call. = FALSE)
  }
  invisible(TRUE)
}

# Key assertion: reject missing or duplicated join keys before a corrected
# join. `allow_missing` exists for deliberate audits but defaults to FALSE.
assert_unique_key <- function(data, key, label = deparse(substitute(data)), allow_missing = FALSE) {
  assert_columns(data, key, label)
  value <- data[[key]]
  missing <- is.na(value) | trimws(as.character(value)) == ""
  if (!allow_missing && any(missing)) {
    stop(label, " has ", sum(missing), " missing value(s) in key ", key, call. = FALSE)
  }
  duplicate <- duplicated(value) | duplicated(value, fromLast = TRUE)
  duplicate[missing] <- FALSE
  if (any(duplicate)) {
    examples <- unique(as.character(value[duplicate]))
    stop(
      label, " violates key uniqueness for ", key, ". Example duplicate(s): ",
      paste(utils::head(examples, 10), collapse = ", "), call. = FALSE
    )
  }
  invisible(TRUE)
}

# Source import: read a supplied CSV without rewriting it, preserve character
# values, recognize the supplied missing tokens, and repair only a BOM-damaged
# first header. No analytical value is changed here.
read_source_csv <- function(path, ...) {
  # The supplied files contain mixed legacy encodings. Let R use the host's
  # native decoder; analytical joins use stable ASCII codes/keys rather than
  # display labels. Forcing UTF-8 or Latin-1 truncates some supplied files.
  out <- utils::read.csv(
    path,
    stringsAsFactors = FALSE,
    check.names = TRUE,
    na.strings = c("", "NA", "NaN"),
    ...
  )
  # R under a C locale can expose a UTF-8 BOM as the syntactic prefix X....
  if (!"country_name" %in% names(out)) {
    candidate <- grep("country_name$", names(out), value = TRUE)
    if (length(candidate) == 1L) names(out)[names(out) == candidate] <- "country_name"
  }
  out
}

# Derived-output export: create the parent directory and write one explicit
# UTF-8 CSV without row-name side effects.
write_utf8_csv <- function(data, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  utils::write.csv(data, path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
  invisible(path)
}

# Heterogeneous-row binder: align data-frame schemas by column name before
# combining them. This is used for simplifying-assumption records from models
# with different numbers of conditions.
rbind_fill <- function(frames) {
  frames <- Filter(function(x) is.data.frame(x) && nrow(x) > 0, frames)
  if (!length(frames)) return(data.frame())
  columns <- unique(unlist(lapply(frames, names), use.names = FALSE))
  frames <- lapply(frames, function(x) {
    missing <- setdiff(columns, names(x))
    for (name in missing) x[[name]] <- NA
    x[, columns, drop = FALSE]
  })
  do.call(rbind, frames)
}

# Provenance fingerprint: hash the exact file bytes with SHA-256. Explicit raw
# reads avoid a Windows path-handling defect in digest's file shortcut.
sha256_file <- function(path) {
  # digest(file = TRUE) relies on file.access(), which is unreliable for some
  # Windows paths containing an ampersand. Reading bytes explicitly avoids that
  # platform defect while producing the same SHA-256 value.
  size <- file.info(path)$size
  connection <- file(path, open = "rb")
  on.exit(close(connection), add = TRUE)
  bytes <- readBin(connection, what = "raw", n = size)
  unname(digest::digest(bytes, algo = "sha256", serialize = FALSE))
}

# Available-year mean: average the named numeric columns by row while keeping a
# row with no finite value missing rather than converting it to a number.
row_mean_available <- function(data, columns) {
  assert_columns(data, columns)
  values <- as.matrix(data[, columns, drop = FALSE])
  storage.mode(values) <- "numeric"
  result <- rowMeans(values, na.rm = TRUE)
  result[!is.finite(result)] <- NA_real_
  result
}

# Crisp-set calibration: finite raw values strictly above the anchor become 1;
# finite values at or below it become 0; missing/non-finite values remain NA.
crisp_above <- function(x, threshold) {
  out <- rep(NA_integer_, length(x))
  keep <- !is.na(x) & is.finite(x)
  out[keep] <- as.integer(x[keep] > threshold)
  out
}

# Country-key normalization: apply a finite, inspectable alias dictionary. No
# approximate/fuzzy matching is allowed because it could hide a wrong join.
normalize_country <- function(x) {
  x <- trimws(as.character(x))
  mapping <- c(
    "Espana" = "Spain",
    "Estland" = "Estonia",
    "Great Britain" = "United Kingdom",
    "Luxemburg" = "Luxembourg",
    "Slovak Republic" = "Slovakia",
    "Czech Republic" = "Czechia",
    "Macedonia" = "North Macedonia",
    "Turkey" = "Turkiye",
    "TÃ¼rkiye" = "Turkiye",
    "Türkiye" = "Turkiye",
    "Cyprusr" = "Cyprus",
    "Cypruss" = "Cyprus"
  )
  hit <- x %in% names(mapping)
  x[hit] <- unname(mapping[x[hit]])
  x
}

# Literal expansion: return every positive condition and its Boolean negation,
# labelled with QCA's `~` notation, for symmetrical necessity/sufficiency tests.
make_literal_matrix <- function(cdm, conditions) {
  positive <- cdm[, conditions, drop = FALSE]
  negative <- 1 - positive
  names(negative) <- paste0("~", conditions)
  cbind(positive, negative)
}

# Literal-fit calculation: use QCA::pof for necessity and sufficiency, then add
# explicit Boolean pass/fail flags at the declared 0.90 and 0.80 conventions.
literal_fit_tables <- function(cdm, conditions, outcome = "OUTCOME", necessity_cut = 0.90) {
  # Create a 2k-column literal matrix (`k` positive plus `k` negated sets) and
  # keep the binary outcome separate because QCA::pof expects X and Y objects.
  literals <- make_literal_matrix(cdm, conditions)
  y <- cdm[[outcome]]

  # `inclN`, `covN`, and `RoN` are QCA's necessity consistency, coverage, and
  # relevance of necessity. Row names carry the literal labels, so copy them to
  # an ordinary column before clearing row names for a stable CSV schema.
  nec <- QCA::pof(literals, y, relation = "necessity")$incl.cov
  nec <- data.frame(
    literal = row.names(nec),
    consistency = as.numeric(nec$inclN),
    coverage = as.numeric(nec$covN),
    relevance_of_necessity = as.numeric(nec$RoN),
    necessary_at_0_90 = as.numeric(nec$inclN) >= necessity_cut,
    row.names = NULL,
    check.names = FALSE
  )

  # The same literals are tested as individually sufficient conditions. These
  # values are descriptive diagnostics; the minimized configurations below are
  # the configurational result and should not be confused with these literals.
  suf <- QCA::pof(literals, y, relation = "sufficiency")$incl.cov
  suf <- data.frame(
    literal = row.names(suf),
    consistency = as.numeric(suf$inclS),
    PRI = as.numeric(suf$PRI),
    coverage = as.numeric(suf$covS),
    unique_coverage = as.numeric(suf$covU),
    row.names = NULL,
    check.names = FALSE
  )
  list(necessity = nec, sufficiency = suf)
}

# Truth-table normalization: convert QCA's truthTable object to a complete,
# consistently typed data frame that retains every observed and remainder row.
truth_table_frame <- function(tt, conditions) {
  # QCA stores the computed table inside `$tt`. Coerce printed/factor fields to
  # numeric values before comparisons so ordering and row labels cannot affect
  # the classification.
  out <- tt$tt
  as_number <- function(x) suppressWarnings(as.numeric(as.character(x)))
  out$incl <- as_number(out$incl)
  out$PRI <- as_number(out$PRI)
  out$row <- seq_len(nrow(out))
  # `apply(..., 1, ...)` works row-wise; concatenating 0/1 memberships yields a
  # compact configuration identifier in the declared condition order.
  out$configuration <- apply(out[, conditions, drop = FALSE], 1, paste0, collapse = "")
  # Remainders have n=0. Among observed rows, OUT=1 means the configured
  # inclusion/frequency rules classify the row as sufficient. Remaining rows
  # are labelled descriptively without silently deleting contradictions.
  out$row_type <- ifelse(
    out$n == 0,
    "logical_remainder",
    ifelse(
      out$OUT == "1",
      "sufficient_observed",
      ifelse(out$incl > 0 & out$incl < 1, "contradictory_observed_below_cut", "negative_observed")
    )
  )
  out[, c("row", "configuration", conditions, "OUT", "n", "incl", "PRI", "row_type", "cases"), drop = FALSE]
}

# Boolean path evaluator: parse a minimized term such as A*~B and calculate its
# 0/1 membership for each calibrated case. `*` means logical AND in this text.
path_membership <- function(term, cdm) {
  # Remove parentheses used only for printed grouping, split conjunctions on
  # `*`, and begin with universal membership. Every literal can only retain or
  # lower that membership in the loop.
  term <- gsub("[()]", "", term)
  literals <- strsplit(term, "\\*", fixed = FALSE)[[1]]
  literals <- trimws(literals)
  membership <- rep(1, nrow(cdm))
  for (literal in literals) {
    negated <- startsWith(literal, "~")
    condition <- sub("^~", "", literal)
    if (!condition %in% names(cdm)) {
      stop("Solution term refers to absent condition: ", condition, call. = FALSE)
    }
    value <- cdm[[condition]]
    if (negated) value <- 1 - value
    # Row-wise minimum is crisp/fuzzy intersection. With binary data it is 1
    # only when every literal in the conjunction is satisfied.
    membership <- pmin(membership, value)
  }
  membership
}

# Solution extractor: turn QCA's possibly multi-model solution object into
# tidy path, overall-fit, case-membership, and simplifying-assumption tables.
# Metrics are recomputed from explicit Boolean memberships to make each number
# auditable rather than relying only on a formatted print method.
extract_solution <- function(solution, cdm, conditions, model_id, solution_type,
                             case_lookup = NULL, outcome = "OUTCOME") {
  # `solution$solution` is QCA's list of minimized alternatives. Absence of an
  # alternative is a failed analytical result, not an empty table to ignore.
  if (!length(solution$solution)) {
    stop("QCA minimization returned no solution for ", model_id, " / ", solution_type, call. = FALSE)
  }
  if (is.null(case_lookup)) {
    case_lookup <- data.frame(case_id = row.names(cdm), case_name = row.names(cdm), stringsAsFactors = FALSE)
  }
  if (nrow(case_lookup) != nrow(cdm)) stop("case_lookup and CDM row counts differ", call. = FALSE)

  # Accumulate lists because repeatedly appending rows to a data frame is slow
  # and can change types. They are bound once after every alternative model.
  fit_rows <- list()
  case_rows <- list()
  assumption_rows <- list()

  for (model_number in seq_along(solution$solution)) {
    # Each alternative contains one or more conjunctive terms. `vapply()`
    # enforces one numeric case-membership vector per term.
    terms <- as.character(solution$solution[[model_number]])
    membership <- vapply(terms, path_membership, numeric(nrow(cdm)), cdm = cdm)
    if (is.null(dim(membership))) membership <- matrix(membership, ncol = 1)
    colnames(membership) <- terms
    row.names(membership) <- row.names(cdm)

    path_fit <- QCA::pof(as.data.frame(membership), cdm[[outcome]], relation = "sufficiency")$incl.cov
    if (ncol(membership) == 1 && is.na(path_fit$covU[1])) path_fit$covU[1] <- path_fit$covS[1]
    # A solution is the OR/union of its paths, so row-wise maximum gives
    # membership in at least one path. QCA fit is then calculated for paths and
    # their union using the same outcome vector.
    solution_membership <- apply(membership, 1, max)
    solution_fit <- QCA::pof(data.frame(SOLUTION = solution_membership), cdm[[outcome]], relation = "sufficiency")$incl.cov

    for (i in seq_along(terms)) {
      # Separate consistent path members (outcome=1) from deviant-consistency
      # members (outcome=0), then retain exact counts in the fit table.
      member <- membership[, i] == 1
      consistent <- member & cdm[[outcome]] == 1
      fit_rows[[length(fit_rows) + 1L]] <- data.frame(
        model_id = model_id,
        solution_type = solution_type,
        model_number = model_number,
        row_type = "path",
        path_number = i,
        expression = terms[i],
        consistency = as.numeric(path_fit$inclS[i]),
        PRI = as.numeric(path_fit$PRI[i]),
        raw_coverage = as.numeric(path_fit$covS[i]),
        unique_coverage = as.numeric(path_fit$covU[i]),
        member_cases = sum(member),
        outcome_member_cases = sum(consistent),
        deviant_consistency_cases = sum(member & cdm[[outcome]] == 0),
        stringsAsFactors = FALSE
      )
      if (any(member)) {
        selected <- case_lookup[member, , drop = FALSE]
        selected$model_id <- model_id
        selected$solution_type <- solution_type
        selected$model_number <- model_number
        selected$path_number <- i
        selected$path_expression <- terms[i]
        selected$outcome <- cdm[[outcome]][member]
        selected$case_role <- ifelse(selected$outcome == 1, "consistent_path_member", "deviant_consistency_case")
        case_rows[[length(case_rows) + 1L]] <- selected[, c(
          "model_id", "solution_type", "model_number", "path_number", "path_expression",
          "case_id", "case_name", "outcome", "case_role"
        )]
      }
    }

    fit_rows[[length(fit_rows) + 1L]] <- data.frame(
      model_id = model_id,
      solution_type = solution_type,
      model_number = model_number,
      row_type = "overall_solution",
      path_number = NA_integer_,
      expression = paste(terms, collapse = " + "),
      consistency = as.numeric(solution_fit$inclS[1]),
      PRI = as.numeric(solution_fit$PRI[1]),
      raw_coverage = as.numeric(solution_fit$covS[1]),
      unique_coverage = NA_real_,
      member_cases = sum(solution_membership == 1),
      outcome_member_cases = sum(solution_membership == 1 & cdm[[outcome]] == 1),
      deviant_consistency_cases = sum(solution_membership == 1 & cdm[[outcome]] == 0),
      stringsAsFactors = FALSE
    )

    # QCA stores simplifying assumptions for alternative model j under `M<j>`.
    # These are the logical remainders used by parsimonious minimization. They
    # are exported explicitly so counterfactual use is never left implicit.
    sa_name <- paste0("M", model_number)
    sa <- solution$SA[[sa_name]]
    if (!is.null(sa) && nrow(sa)) {
      sa <- as.data.frame(sa, stringsAsFactors = FALSE)
      if (ncol(sa) == length(conditions)) names(sa) <- conditions
      sa$model_id <- model_id
      sa$solution_type <- solution_type
      sa$model_number <- model_number
      sa$configuration <- apply(sa[, conditions, drop = FALSE], 1, paste0, collapse = "")
      assumption_rows[[length(assumption_rows) + 1L]] <- sa[, c(
        "model_id", "solution_type", "model_number", "configuration", conditions
      )]
    }
  }

  list(
    fit = do.call(rbind, fit_rows),
    cases = if (length(case_rows)) do.call(rbind, case_rows) else data.frame(),
    simplifying_assumptions = if (length(assumption_rows)) do.call(rbind, assumption_rows) else data.frame()
  )
}

# Model runner: validate binary input, build one complete truth table, optionally
# reproduce the submitted row mutation for diagnosis, and calculate labelled
# complex and parsimonious solutions plus fit and case diagnostics.
run_qca_model <- function(cdm, conditions, model_id, incl_cut = 0.80, n_cut = 1,
                          pri_cut = 0, case_lookup = NULL, mutate_rows = integer()) {
  # Restrict the matrix to the declared conditions/outcome after checking its
  # schema. Any residual incomplete row is removed consistently at this boundary.
  required <- c(conditions, "OUTCOME")
  assert_columns(cdm, required, paste0("CDM for ", model_id))
  cdm <- cdm[stats::complete.cases(cdm[, required, drop = FALSE]), required, drop = FALSE]
  if (!nrow(cdm)) stop("No complete cases for model ", model_id, call. = FALSE)
  if (is.null(row.names(cdm)) || anyDuplicated(row.names(cdm))) {
    stop("CDM row names must be stable unique case identifiers for ", model_id, call. = FALSE)
  }
  non_binary <- vapply(cdm, function(x) any(!x %in% c(0, 1)), logical(1))
  if (any(non_binary)) stop("Non-binary set(s) in ", model_id, ": ", paste(names(cdm)[non_binary], collapse = ", "), call. = FALSE)

  # `complete = TRUE` materializes all 2^k configurations, including logical
  # remainders; `show.cases = TRUE` preserves private audit traceability.
  tt <- QCA::truthTable(
    cdm,
    outcome = "OUTCOME",
    conditions = conditions,
    incl.cut = incl_cut,
    n.cut = n_cut,
    pri.cut = pri_cut,
    complete = TRUE,
    show.cases = TRUE
  )
  if (nrow(tt$tt) != 2^length(conditions)) {
    stop("Truth-table invariant failed for ", model_id, ": expected ", 2^length(conditions),
         " rows, got ", nrow(tt$tt), call. = FALSE)
  }

  # Substantive models leave `mutate_rows` empty. The optional branch exists
  # only to reproduce the submitted notebook's positional overwrite, and the
  # before/after values are captured so the action is visible.
  tt_used <- tt
  changed_rows <- data.frame()
  if (length(mutate_rows)) {
    if (any(mutate_rows < 1 | mutate_rows > nrow(tt$tt))) stop("Invalid audit-only truth-table row mutation", call. = FALSE)
    before <- tt_used$tt$OUT[mutate_rows]
    tt_used$tt$OUT[mutate_rows] <- "1"
    changed_rows <- data.frame(
      row = mutate_rows,
      configuration = apply(tt_used$tt[mutate_rows, conditions, drop = FALSE], 1, paste0, collapse = ""),
      before = before,
      after = tt_used$tt$OUT[mutate_rows],
      stringsAsFactors = FALSE
    )
  }

  # Omitting remainders produces the complex solution. `include = "?"` permits
  # all remainders and produces the parsimonious solution. No intermediate
  # minimization is attempted without defensible directional expectations.
  complex <- QCA::minimize(tt_used, details = TRUE, show.cases = TRUE)
  parsimonious <- QCA::minimize(tt_used, include = "?", details = TRUE, show.cases = TRUE)
  complex_extract <- extract_solution(complex, cdm, conditions, model_id, "complex", case_lookup)
  pars_extract <- extract_solution(parsimonious, cdm, conditions, model_id, "parsimonious", case_lookup)
  fits <- literal_fit_tables(cdm, conditions)
  tt_frame <- truth_table_frame(tt, conditions)

  # Return tidy tables for reports/CSVs plus the original QCA objects for an
  # expert who needs to inspect package-specific internals in the same session.
  list(
    cdm = cdm,
    conditions = conditions,
    settings = data.frame(
      model_id = model_id,
      cases = nrow(cdm),
      conditions = length(conditions),
      truth_table_rows = nrow(tt_frame),
      observed_configurations = sum(tt_frame$n > 0),
      logical_remainders = sum(tt_frame$n == 0),
      sufficient_observed_configurations = sum(tt_frame$row_type == "sufficient_observed"),
      contradictory_observed_below_cut = sum(tt_frame$row_type == "contradictory_observed_below_cut"),
      incl_cut = incl_cut,
      n_cut = n_cut,
      pri_cut = pri_cut,
      stringsAsFactors = FALSE
    ),
    truth_table = tt_frame,
    necessity = fits$necessity,
    individual_sufficiency = fits$sufficiency,
    solutions = rbind(complex_extract$fit, pars_extract$fit),
    cases_by_path = rbind(complex_extract$cases, pars_extract$cases),
    simplifying_assumptions = rbind(complex_extract$simplifying_assumptions, pars_extract$simplifying_assumptions),
    row_mutation_audit = changed_rows,
    objects = list(truth_table = tt, truth_table_used = tt_used, complex = complex, parsimonious = parsimonious)
  )
}

# Overall-row selector: return the one aggregate solution row used by comparison
# tables while preserving the requested solution type label.
overall_solution_row <- function(model_result, solution_type = "complex") {
  keep <- model_result$solutions$solution_type == solution_type &
    model_result$solutions$row_type == "overall_solution"
  model_result$solutions[keep, , drop = FALSE]
}

# Binary-association diagnostic: compute the Pearson/phi association for every
# pair of crisp conditions so mechanically redundant sets are easy to detect.
pairwise_binary_associations <- function(cdm, conditions) {
  combinations <- utils::combn(conditions, 2, simplify = FALSE)
  do.call(rbind, lapply(combinations, function(pair) {
    value <- stats::cor(cdm[[pair[1]]], cdm[[pair[2]]], use = "complete.obs", method = "pearson")
    data.frame(condition_1 = pair[1], condition_2 = pair[2], phi_correlation = value, stringsAsFactors = FALSE)
  }))
}

# Calibration diagnostic: describe values around every strict cutoff, including
# equality counts, missingness, and membership share. This exposes boundary
# behavior that a single threshold number would conceal.
threshold_diagnostics <- function(raw, specifications) {
  # Iterate over the explicit condition-to-raw-variable specification rather
  # than relying on column order. Each output row documents one calibration.
  rows <- list()
  for (i in seq_len(nrow(specifications))) {
    variable <- specifications$raw_variable[i]
    threshold <- specifications$threshold[i]
    value <- raw[[variable]]
    available <- is.finite(value)
    rows[[i]] <- data.frame(
      condition = specifications$condition[i],
      raw_variable = variable,
      threshold = threshold,
      boundary_rule = ">",
      available_cases = sum(available),
      missing_cases = sum(!available),
      exact_boundary_cases = sum(value == threshold, na.rm = TRUE),
      members = sum(value > threshold, na.rm = TRUE),
      nonmembers = sum(value <= threshold, na.rm = TRUE),
      member_share = mean(value[available] > threshold),
      minimum = min(value[available]),
      median = stats::median(value[available]),
      maximum = max(value[available]),
      stringsAsFactors = FALSE
    )
  }
  do.call(rbind, rows)
}

# Session provenance: return the R and key package versions observed during the
# run so a future rerun can distinguish code changes from dependency changes.
session_table <- function() {
  info <- utils::sessionInfo()
  packages <- c("QCA", "digest", "knitr", "rmarkdown")
  data.frame(
    component = c("R", "platform", packages),
    version = c(
      paste(info$R.version$major, info$R.version$minor, sep = "."),
      info$platform,
      vapply(packages, function(x) {
        if (requireNamespace(x, quietly = TRUE)) as.character(utils::packageVersion(x)) else NA_character_
      }, character(1))
    ),
    stringsAsFactors = FALSE
  )
}
