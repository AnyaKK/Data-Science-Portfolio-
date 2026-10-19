# End-to-end data and QCA pipeline used by AER_QCA_reanalysis.qmd.
#
# The functions are ordered in the same sequence as the audit: construct the
# corrected city base, calibrate the primary model, reconstruct the submitted
# error branch, build a corrected energy sensitivity, summarize/plot results,
# and finally orchestrate exports in run_analysis(). Detailed syntax and every
# numbered orchestration action are explained in docs/CODE_WALKTHROUGH.md.

# Source the helper layer only when it is not already loaded by the QMD. This
# guard supports both direct sourcing and Quarto execution without double work.
if (!exists("run_qca_model", mode = "function")) {
  source(file.path("scripts", "qca_helpers.R"), local = FALSE)
}

# Build one-row-per-city corrected raw data. Inputs are a named path list;
# output contains the joined/derived city data and a machine-readable join audit.
# Unique-key assertions make row multiplication impossible in this branch.
make_corrected_city_data <- function(paths) {
  main <- read_source_csv(paths$main)
  lai <- read_source_csv(paths$lai)
  population <- read_source_csv(paths$population)

  main_required <- c(
    "city_name", "city_name_original", "city_code", "country_name", "geoname_id",
    "gpcX2013", "gpcX2014", "gpcX2015",
    "National.Climate.Policy._.2013", "National.Climate.Policy._.2014",
    "National.Climate.Policy._.2015", "af", "pm25", "latitude", "longitude"
  )
  assert_columns(main, main_required, "main_dataset.csv")
  assert_columns(lai, c("country_name", "D_LAI_2010", "D_LAI_2014"), "lai_dataset.csv")
  assert_columns(population, c("city_name", "X2013", "X2014", "X2015"), "population_data.csv")

  assert_unique_key(main, "city_code", "main_dataset.csv")
  assert_unique_key(population, "city_name", "population_data.csv")

  main$country_name <- normalize_country(main$country_name)
  lai$country_name <- normalize_country(lai$country_name)
  assert_unique_key(lai, "country_name", "lai_dataset.csv after country normalization")

  country_index <- match(main$country_name, lai$country_name)
  city_index <- match(main$city_name, population$city_name)

  data <- main[, main_required, drop = FALSE]
  data$D_LAI_2010 <- lai$D_LAI_2010[country_index]
  data$D_LAI_2014 <- lai$D_LAI_2014[country_index]
  data$X2013 <- population$X2013[city_index]
  data$X2014 <- population$X2014[city_index]
  data$X2015 <- population$X2015[city_index]
  data$GDPpc <- row_mean_available(data, c("gpcX2013", "gpcX2014", "gpcX2015"))
  data$NCP <- row_mean_available(data, c(
    "National.Climate.Policy._.2013", "National.Climate.Policy._.2014",
    "National.Climate.Policy._.2015"
  ))
  data$LAI <- row_mean_available(data, c("D_LAI_2010", "D_LAI_2014"))
  data$POP <- row_mean_available(data, c("X2013", "X2014", "X2015"))
  data$OUTCOME_RAW <- suppressWarnings(as.integer(data$af))

  join_audit <- data.frame(
    check = c(
      "main_rows", "unique_main_city_codes", "population_rows", "unique_population_city_names",
      "lai_rows", "unique_lai_countries_after_normalization", "unmatched_main_countries_to_lai",
      "unmatched_main_cities_to_population"
    ),
    value = c(
      nrow(main), length(unique(main$city_code)), nrow(population), length(unique(population$city_name)),
      nrow(lai), length(unique(lai$country_name)), sum(is.na(country_index)), sum(is.na(city_index))
    ),
    stringsAsFactors = FALSE
  )

  list(data = data, join_audit = join_audit)
}

# Calibrate the five primary conditions and outcome, apply one complete-case
# rule, and return both analysed cases and explicit private exclusion reasons.
make_five_condition_cdm <- function(city, thresholds = c(
  LARGE = 100000, AFFLUENT = 30000, BENEFIT = 12.5, AUTONOMOUS = 55, SUPPORTED = 0.45
)) {
  raw_map <- c(LARGE = "POP", AFFLUENT = "GDPpc", BENEFIT = "pm25", AUTONOMOUS = "LAI", SUPPORTED = "NCP")
  cdm <- data.frame(row.names = city$city_code, check.names = FALSE)
  for (condition in names(raw_map)) {
    cdm[[condition]] <- crisp_above(city[[raw_map[[condition]]]], thresholds[[condition]])
  }
  cdm$OUTCOME <- city$OUTCOME_RAW
  complete <- stats::complete.cases(cdm)
  missing_fields <- apply(cdm, 1, function(x) paste(names(x)[is.na(x)], collapse = ";"))
  exclusions <- data.frame(
    case_id = city$city_code[!complete],
    case_name = city$city_name_original[!complete],
    country_name = city$country_name[!complete],
    missing_or_invalid_fields = missing_fields[!complete],
    stringsAsFactors = FALSE
  )
  list(
    cdm = cdm[complete, , drop = FALSE],
    complete = complete,
    exclusions = exclusions,
    case_lookup = data.frame(
      case_id = city$city_code[complete],
      case_name = city$city_name_original[complete],
      stringsAsFactors = FALSE
    )
  )
}

# Reproduce the submitted city-energy processing, defects included. This branch
# deliberately keeps the duplicated Finland key and saved Cyprus mismatch so
# the historical output can be identified; it must not feed the corrected model.
reconstruct_submitted_city_data <- function(city, paths) {
  energy <- read_source_csv(paths$energy)
  national <- read_source_csv(paths$national_filtered)
  assert_columns(energy, c("country_name", "X2020", "X2021", "X2022", "X2023"), "Energy_consumption.csv")
  assert_columns(national, c("country_name", "population_2022", "population_2023"), "dated national population file")

  numeric_clean <- function(x) suppressWarnings(as.numeric(gsub("[^0-9.-]", "", as.character(x))))
  energy[c("X2020", "X2021", "X2022", "X2023")] <- lapply(
    energy[c("X2020", "X2021", "X2022", "X2023")], numeric_clean
  )
  national[c("population_2022", "population_2023")] <- lapply(
    national[c("population_2022", "population_2023")], numeric_clean
  )

  energy$country_name <- normalize_country(energy$country_name)
  national_original_country <- trimws(as.character(national$country_name))
  national$country_name <- normalize_country(national_original_country)
  # Preserve the saved branch's uncorrected "Cypruss" typo: the notebook only
  # attempted to repair "Cyprusr", so Cyprus remained unmatched in its output.
  national$country_name[national_original_country == "Cypruss"] <- "Cypruss"
  national_duplicate_rows <- duplicated(national$country_name) | duplicated(national$country_name, fromLast = TRUE)

  energy_national <- merge(
    energy,
    national[, c("country_name", "population_2022", "population_2023")],
    by = "country_name",
    all.x = TRUE,
    sort = TRUE
  )
  # The duplicated Finland key is deliberately retained in this audit-only branch.
  submitted <- merge(city, energy_national, by = "country_name", all.x = TRUE, sort = TRUE)
  submitted$FE_Consumption <- row_mean_available(
    transform(
      submitted,
      X2020_TJ = X2020 * 41.868,
      X2021_TJ = X2021 * 41.868,
      X2022_TJ = X2022 * 41.868,
      X2023_TJ = X2023 * 41.868
    ),
    c("X2020_TJ", "X2021_TJ", "X2022_TJ", "X2023_TJ")
  )
  submitted$NATL_POP <- row_mean_available(submitted, c("population_2022", "population_2023"))
  submitted$FE_Consumption_Proxy <- submitted$FE_Consumption * submitted$POP / submitted$NATL_POP

  list(
    data = submitted,
    national_duplicate_keys = unique(national$country_name[national_duplicate_rows]),
    extra_rows_from_duplicate_join = nrow(submitted) - nrow(city)
  )
}

# Calibrate the saved six-condition submitted data, compare it with the stored
# matrix, and verify that the independent reconstruction has the same proxy
# signature. Duplicate city rows receive audit-only occurrence identifiers.
make_submitted_model <- function(paths, rebuilt_submitted) {
  saved_city <- read_source_csv(paths$submitted_city)
  assert_columns(saved_city, c(
    "country_name", "city_name_original", "city_code", "GDPpc", "pm25", "LAI", "NCP",
    "POP", "FE_Consumption_Proxy", "af"
  ), "Cities_By_EC_2025-01-31.csv")

  saved_city$audit_case_id <- paste0(saved_city$city_code, "::", ave(
    seq_len(nrow(saved_city)), saved_city$city_code, FUN = seq_along
  ))
  raw <- data.frame(
    LARGE = crisp_above(saved_city$POP, 100000),
    AFFLUENT = crisp_above(saved_city$GDPpc, 30000),
    BENEFIT = crisp_above(saved_city$pm25, 12.5),
    AUTONOMOUS = crisp_above(saved_city$LAI, 55),
    SUPPORTED = crisp_above(saved_city$NCP, 0.45),
    ENERGY_CONSUMPTION = crisp_above(saved_city$FE_Consumption_Proxy, 8190),
    OUTCOME = suppressWarnings(as.integer(saved_city$af)),
    row.names = saved_city$audit_case_id,
    check.names = FALSE
  )
  complete <- stats::complete.cases(raw)
  missing_fields <- apply(raw, 1, function(x) paste(names(x)[is.na(x)], collapse = ";"))
  exclusions <- data.frame(
    audit_case_id = saved_city$audit_case_id[!complete],
    city_code = saved_city$city_code[!complete],
    case_name = saved_city$city_name_original[!complete],
    country_name = saved_city$country_name[!complete],
    missing_or_invalid_fields = missing_fields[!complete],
    stringsAsFactors = FALSE
  )
  cdm <- raw[complete, , drop = FALSE]
  lookup <- data.frame(
    case_id = saved_city$audit_case_id[complete],
    case_name = saved_city$city_name_original[complete],
    stringsAsFactors = FALSE
  )

  stored <- read_source_csv(paths$submitted_cdm)
  stored_conditions <- c(
    "LARGE", "AFFLUENT", "BENEFIT", "AUTONOMOUS", "SUPPORTED", "ENERGY_CONSUMPTION", "OUTCOME"
  )
  assert_columns(stored, stored_conditions, "stored submitted calibrated data matrix")
  stored_matrix <- as.matrix(stored[, stored_conditions, drop = FALSE])
  storage.mode(stored_matrix) <- "integer"
  reconstructed_matrix <- as.matrix(cdm[, stored_conditions, drop = FALSE])
  storage.mode(reconstructed_matrix) <- "integer"
  exact_cdm_match <- identical(dim(stored_matrix), dim(reconstructed_matrix)) &&
    identical(unname(stored_matrix), unname(reconstructed_matrix))

  rebuilt <- rebuilt_submitted$data
  saved_signature <- sort(paste(saved_city$city_code, sprintf("%.6f", saved_city$FE_Consumption_Proxy), sep = "::"))
  rebuilt_signature <- sort(paste(rebuilt$city_code, sprintf("%.6f", rebuilt$FE_Consumption_Proxy), sep = "::"))
  rebuilt_proxy_match <- identical(saved_signature, rebuilt_signature)

  duplicate_codes <- names(which(table(saved_city$city_code) > 1))
  comparison <- data.frame(
    check = c(
      "saved_precalibration_rows", "rebuilt_precalibration_rows", "unique_saved_city_codes",
      "extra_rows_from_nonunique_national_population_join", "duplicated_city_codes",
      "submitted_complete_case_rows", "stored_cdm_rows", "stored_cdm_exact_membership_match",
      "rebuilt_city_proxy_signature_match", "energy_set_members", "energy_set_member_share"
    ),
    value = c(
      nrow(saved_city), nrow(rebuilt), length(unique(saved_city$city_code)),
      rebuilt_submitted$extra_rows_from_duplicate_join, length(duplicate_codes),
      nrow(cdm), nrow(stored_matrix), exact_cdm_match, rebuilt_proxy_match,
      sum(cdm$ENERGY_CONSUMPTION), mean(cdm$ENERGY_CONSUMPTION)
    ),
    stringsAsFactors = FALSE
  )

  list(
    saved_city = saved_city,
    cdm = cdm,
    case_lookup = lookup,
    exclusions = exclusions,
    comparison = comparison,
    duplicate_city_codes = duplicate_codes,
    exact_cdm_match = exact_cdm_match,
    rebuilt_proxy_match = rebuilt_proxy_match
  )
}

# Construct a corrected population-allocated energy proxy: enforce unique
# country keys, freeze energy to 2020-2022 and population to 2022, and retain
# unmatched counts. The proxy remains a sensitivity variable, not primary data.
make_corrected_energy <- function(city, paths) {
  energy <- read_source_csv(paths$energy)
  national <- read_source_csv(paths$national_raw)
  assert_columns(energy, c("country_name", "X2020", "X2021", "X2022"), "Energy_consumption.csv")
  assert_columns(national, c("country_name", "population_2022"), "national_pop.csv")
  numeric_clean <- function(x) suppressWarnings(as.numeric(gsub("[^0-9.-]", "", as.character(x))))
  energy[c("X2020", "X2021", "X2022")] <- lapply(
    energy[c("X2020", "X2021", "X2022")], numeric_clean
  )
  national$population_2022 <- numeric_clean(national$population_2022)
  energy$country_name <- normalize_country(energy$country_name)
  national$country_name <- normalize_country(national$country_name)
  assert_unique_key(energy, "country_name", "Energy_consumption.csv after normalization")
  assert_unique_key(national, "country_name", "national_pop.csv after normalization")

  energy$FE_Consumption_2020_2022_TJ <- row_mean_available(energy, c("X2020", "X2021", "X2022")) * 41.868
  national_index <- match(energy$country_name, national$country_name)
  energy$NATL_POP_2022 <- suppressWarnings(as.numeric(national$population_2022[national_index]))
  assert_unique_key(energy, "country_name", "corrected national energy-population table")

  energy_index <- match(city$country_name, energy$country_name)
  out <- city
  out$FE_Consumption_2020_2022_TJ <- energy$FE_Consumption_2020_2022_TJ[energy_index]
  out$NATL_POP_2022 <- energy$NATL_POP_2022[energy_index]
  out$FE_Consumption_Proxy_2020_2022 <-
    out$FE_Consumption_2020_2022_TJ * out$POP / out$NATL_POP_2022

  list(
    data = out,
    unmatched_energy_countries_to_population = sum(is.na(national_index)),
    unmatched_city_countries_to_energy = sum(is.na(energy_index))
  )
}

# Add one energy set to the calibrated five-condition matrix at a supplied
# threshold. Complete cases are determined anew because energy may be missing.
make_energy_cdm <- function(energy_city, energy_threshold, base_thresholds = c(
  LARGE = 100000, AFFLUENT = 30000, BENEFIT = 12.5, AUTONOMOUS = 55, SUPPORTED = 0.45
)) {
  # Recalibrate all six columns from the same raw rows. Doing this explicitly
  # avoids relying on row positions from a separately filtered five-set matrix.
  energy_set <- crisp_above(energy_city$FE_Consumption_Proxy_2020_2022, energy_threshold)
  raw <- data.frame(
    LARGE = crisp_above(energy_city$POP, base_thresholds[["LARGE"]]),
    AFFLUENT = crisp_above(energy_city$GDPpc, base_thresholds[["AFFLUENT"]]),
    BENEFIT = crisp_above(energy_city$pm25, base_thresholds[["BENEFIT"]]),
    AUTONOMOUS = crisp_above(energy_city$LAI, base_thresholds[["AUTONOMOUS"]]),
    SUPPORTED = crisp_above(energy_city$NCP, base_thresholds[["SUPPORTED"]]),
    ENERGY_CONSUMPTION = energy_set,
    OUTCOME = energy_city$OUTCOME_RAW,
    row.names = energy_city$city_code,
    check.names = FALSE
  )
  complete <- stats::complete.cases(raw)
  list(
    cdm = raw[complete, , drop = FALSE],
    complete = complete,
    case_lookup = data.frame(
      case_id = energy_city$city_code[complete],
      case_name = energy_city$city_name_original[complete],
      stringsAsFactors = FALSE
    )
  )
}

# Reduce a full model result to one comparable sensitivity row containing
# settings, formulas, fit, and overlap with the main model's complex paths.
summarize_qca_result <- function(result, specification, description, main_paths = NULL) {
  complex_paths <- subset(result$solutions, solution_type == "complex" & row_type == "path")
  complex_overall <- subset(result$solutions, solution_type == "complex" & row_type == "overall_solution")
  pars_paths <- subset(result$solutions, solution_type == "parsimonious" & row_type == "path")
  pars_overall <- subset(result$solutions, solution_type == "parsimonious" & row_type == "overall_solution")
  paths <- complex_paths$expression
  shared <- if (is.null(main_paths)) NA_integer_ else sum(paths %in% main_paths)
  union_n <- if (is.null(main_paths)) NA_integer_ else length(union(paths, main_paths))
  data.frame(
    specification = specification,
    description = description,
    cases = result$settings$cases,
    conditions = result$settings$conditions,
    incl_cut = result$settings$incl_cut,
    n_cut = result$settings$n_cut,
    observed_configurations = result$settings$observed_configurations,
    logical_remainders = result$settings$logical_remainders,
    sufficient_observed_configurations = result$settings$sufficient_observed_configurations,
    complex_path_count = nrow(complex_paths),
    complex_formula = complex_overall$expression[1],
    complex_consistency = complex_overall$consistency[1],
    complex_PRI = complex_overall$PRI[1],
    complex_coverage = complex_overall$raw_coverage[1],
    parsimonious_path_count = nrow(pars_paths),
    parsimonious_formula = pars_overall$expression[1],
    parsimonious_consistency = pars_overall$consistency[1],
    parsimonious_coverage = pars_overall$raw_coverage[1],
    paths_shared_with_main = shared,
    path_jaccard_with_main = if (is.na(union_n) || union_n == 0) NA_real_ else shared / union_n,
    stringsAsFactors = FALSE
  )
}

# Produce the only static figure: membership share by corrected set. Reference
# lines at 0.15, 0.50, and 0.85 make highly unbalanced sets visually apparent.
make_set_balance_figure <- function(set_balance, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  grDevices::png(path, width = 1200, height = 760, res = 140)
  old <- graphics::par(mar = c(8, 5, 3, 1))
  on.exit({ graphics::par(old); grDevices::dev.off() }, add = TRUE)
  colours <- ifelse(set_balance$set == "OUTCOME", "#9C3D54", "#2B6F8A")
  graphics::barplot(
    set_balance$member_share,
    names.arg = set_balance$set,
    las = 2,
    ylim = c(0, 1),
    col = colours,
    border = NA,
    ylab = "Share of analysed cases in set",
    main = "Corrected five-condition model: set balance"
  )
  graphics::abline(h = c(0.15, 0.5, 0.85), lty = c(3, 2, 3), col = "grey55")
  invisible(path)
}

# Master orchestration function. It performs all source checks, reconstruction,
# primary/sensitivity models, diagnostics, disclosure-controlled exports, and
# returns the structured object used by the report. `portfolio_mode = TRUE`
# removes case columns/exports and redacts local source paths.
run_analysis <- function(source_root, output_dir = "analysis_outputs", figure_dir = NULL,
                         portfolio_mode = FALSE) {
  # ----- Execution preconditions and deterministic configuration -----
  assert_packages(c("QCA", "digest"))
  # Current calculations are deterministic. The seed future-proofs the report
  # against stochastic diagnostics without changing today's results.
  set.seed(20261019)

  # Normalize roots once so hashing, error messages, and exports reference one
  # unambiguous location. Only derived-output directories are created.
  source_root <- normalizePath(source_root, winslash = "/", mustWork = TRUE)
  qca_pack <- file.path(source_root, "AER_main", "8. QCA & R", "QCA pack", "QCA pack")
  qca_pack <- normalizePath(qca_pack, winslash = "/", mustWork = TRUE)
  output_dir <- normalizePath(output_dir, winslash = "/", mustWork = FALSE)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  if (is.null(figure_dir)) figure_dir <- file.path(output_dir, "figures")
  dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

  # ----- Source resolution and provenance fingerprints -----
  # The list includes computational CSV inputs and provenance-only artifacts.
  # The notebook, rendered HTML, saved truth table, and course script are
  # asserted and hashed to identify the branch; this pipeline never executes
  # supplied notebooks/HTML/scripts and does not take results from their prose.
  paths <- list(
    main = file.path(qca_pack, "main_dataset.csv"),
    lai = file.path(qca_pack, "lai_dataset.csv"),
    population = file.path(qca_pack, "population_data.csv"),
    energy = file.path(qca_pack, "Energy_consumption.csv"),
    national_raw = file.path(qca_pack, "national_pop.csv"),
    national_filtered = file.path(qca_pack, "national_pop_filtered - 2025-01-31.csv"),
    submitted_city = file.path(qca_pack, "Cities_By_EC_2025-01-31.csv"),
    submitted_cdm = file.path(qca_pack, "Calibrated Data Matrix - 2025-01-31.csv"),
    submitted_truth = file.path(qca_pack, "QCA_Results_TruthTable.csv"),
    energy_notebook = file.path(qca_pack, "AER_Looped_Energy_Consumption.ipynb"),
    energy_html = file.path(qca_pack, "AER_Looped_Energy_Consumption.html"),
    course_script = file.path(qca_pack, "script v03.03 mr 2024-03-15.R")
  )
  assert_files(unlist(paths, use.names = FALSE))

  # Logical IDs remain stable when private paths are redacted in portfolio mode.
  logical_ids <- names(paths)
  selected_hashes <- data.frame(
    source_id = logical_ids,
    relative_path = vapply(paths, function(x) {
      sub(paste0("^", gsub("([][{}()+*^$|\\?.])", "\\\\\\1", source_root), "/?"), "", x)
    }, character(1)),
    size_bytes = vapply(paths, function(x) file.info(x)$size, numeric(1)),
    sha256 = vapply(paths, sha256_file, character(1)),
    stringsAsFactors = FALSE
  )
  selected_hashes_export <- selected_hashes
  if (portfolio_mode) {
    # Preserve reproducibility fingerprints without exposing local/source names.
    selected_hashes_export$relative_path <- paste0("[authorized external input]/", selected_hashes_export$source_id)
  }

  # ----- Corrected five-condition primary analysis -----
  # Corrected joins enforce unique keys, then a single declared calibration and
  # complete-case rule produces the 726-case primary matrix.
  corrected <- make_corrected_city_data(paths)
  corrected_city <- corrected$data
  thresholds <- c(LARGE = 100000, AFFLUENT = 30000, BENEFIT = 12.5, AUTONOMOUS = 55, SUPPORTED = 0.45)
  corrected_cdm_parts <- make_five_condition_cdm(corrected_city, thresholds)
  corrected_result <- run_qca_model(
    corrected_cdm_parts$cdm,
    conditions = names(thresholds),
    model_id = "corrected_primary_five_condition",
    incl_cut = 0.80,
    n_cut = 1,
    pri_cut = 0,
    case_lookup = corrected_cdm_parts$case_lookup
  )

  # ----- Forensic reconstruction of the submitted six-condition branch -----
  # This branch retains the known join/spelling defects only long enough to
  # prove which artifact chain generated the submitted results.
  submitted_rebuilt <- reconstruct_submitted_city_data(corrected_city, paths)
  submitted <- make_submitted_model(paths, submitted_rebuilt)
  submitted_result <- run_qca_model(
    submitted$cdm,
    conditions = c(names(thresholds), "ENERGY_CONSUMPTION"),
    model_id = "submitted_six_condition_reconstruction",
    incl_cut = 0.80,
    n_cut = 1,
    pri_cut = 0,
    case_lookup = submitted$case_lookup
  )
  # Forensic branch only: reproduce numeric truth-table overwrites 3 and 15.
  # The result is relabelled below so it cannot be mistaken for a valid,
  # theory-directed intermediate solution.
  submitted_mutation <- run_qca_model(
    submitted$cdm,
    conditions = c(names(thresholds), "ENERGY_CONSUMPTION"),
    model_id = "submitted_row_mutation_audit",
    incl_cut = 0.80,
    n_cut = 1,
    pri_cut = 0,
    case_lookup = submitted$case_lookup,
    mutate_rows = c(3L, 15L)
  )

  alleged_solutions <- subset(
    submitted_mutation$solutions,
    solution_type == "complex"
  )
  alleged_solutions$solution_type <- "alleged_intermediate_row_mutation"
  alleged_cases <- subset(submitted_mutation$cases_by_path, solution_type == "complex")
  alleged_cases$solution_type <- "alleged_intermediate_row_mutation"

  # ----- Corrected energy-proxy sensitivity analyses -----
  # Both six-condition checks remain secondary because the proxy is derived
  # from population, temporally misaligned, and not observed city consumption.
  energy_corrected <- make_corrected_energy(corrected_city, paths)
  energy_available <- is.finite(energy_corrected$data$FE_Consumption_Proxy_2020_2022)
  energy_median <- stats::median(
    energy_corrected$data$FE_Consumption_Proxy_2020_2022[energy_available], na.rm = TRUE
  )
  energy_8190_parts <- make_energy_cdm(energy_corrected$data, 8190, thresholds)
  energy_median_parts <- make_energy_cdm(energy_corrected$data, energy_median, thresholds)
  energy_8190_result <- run_qca_model(
    energy_8190_parts$cdm,
    conditions = c(names(thresholds), "ENERGY_CONSUMPTION"),
    model_id = "corrected_energy_sensitivity_threshold_8190",
    incl_cut = 0.80,
    n_cut = 1,
    case_lookup = energy_8190_parts$case_lookup
  )
  energy_median_result <- run_qca_model(
    energy_median_parts$cdm,
    conditions = c(names(thresholds), "ENERGY_CONSUMPTION"),
    model_id = "corrected_energy_sensitivity_median_threshold",
    incl_cut = 0.80,
    n_cut = 1,
    case_lookup = energy_median_parts$case_lookup
  )

  # ----- Specification and calibration sensitivity analyses -----
  # Extract the main formula's individual paths once; later specifications are
  # compared with these exact strings as a transparent stability diagnostic.
  main_paths <- subset(
    corrected_result$solutions,
    solution_type == "complex" & row_type == "path"
  )$expression
  sensitivity_rows <- list(
    summarize_qca_result(
      corrected_result, "main", "Five-condition corrected model; incl.cut 0.80; n.cut 1", main_paths
    ),
    summarize_qca_result(
      submitted_result, "submitted_error", "Six-condition reconstruction retaining duplicated Finland join and 2020-2023 energy proxy", main_paths
    ),
    summarize_qca_result(
      energy_8190_result, "energy_corrected_8190", "Six-condition sensitivity; corrected join; frozen 2020-2022 population-allocated energy proxy; threshold 8190", main_paths
    ),
    summarize_qca_result(
      energy_median_result, "energy_corrected_median", paste0("Six-condition sensitivity; corrected join; energy threshold at sample median ", round(energy_median, 2)), main_paths
    )
  )

  run_sensitivity <- function(specification, description, thresholds_used = thresholds, incl_cut = 0.80, n_cut = 1) {
    parts <- make_five_condition_cdm(corrected_city, thresholds_used)
    result <- run_qca_model(
      parts$cdm,
      conditions = names(thresholds),
      model_id = paste0("sensitivity_", specification),
      incl_cut = incl_cut,
      n_cut = n_cut,
      case_lookup = parts$case_lookup
    )
    summarize_qca_result(result, specification, description, main_paths)
  }

  sensitivity_rows[[length(sensitivity_rows) + 1L]] <- run_sensitivity(
    "incl_cut_0_75", "Five-condition model with sufficiency inclusion threshold 0.75", incl_cut = 0.75
  )
  sensitivity_rows[[length(sensitivity_rows) + 1L]] <- run_sensitivity(
    "n_cut_2", "Five-condition model requiring at least two cases per configuration", n_cut = 2
  )
  variants <- list(
    pop_75000 = c(LARGE = 75000), pop_125000 = c(LARGE = 125000),
    gdp_25000 = c(AFFLUENT = 25000), gdp_35000 = c(AFFLUENT = 35000),
    pm25_10 = c(BENEFIT = 10), pm25_15 = c(BENEFIT = 15),
    lai_50 = c(AUTONOMOUS = 50), lai_60 = c(AUTONOMOUS = 60),
    ncp_0_40 = c(SUPPORTED = 0.40), ncp_0_50 = c(SUPPORTED = 0.50)
  )
  for (variant in names(variants)) {
    changed <- variants[[variant]]
    variant_thresholds <- thresholds
    variant_thresholds[names(changed)] <- changed
    description <- paste0("Five-condition model with ", names(changed), " threshold ", unname(changed))
    sensitivity_rows[[length(sensitivity_rows) + 1L]] <- run_sensitivity(
      variant, description, thresholds_used = variant_thresholds
    )
  }
  sensitivity <- do.call(rbind, sensitivity_rows)

  # ----- Diagnostics and machine-readable audit tables -----
  # Build case-level material only in memory here; the export boundary later
  # decides whether disclosure is permitted.
  corrected_complete <- corrected_city[corrected_cdm_parts$complete, , drop = FALSE]
  calibrated_corrected <- cbind(
    data.frame(
      case_id = corrected_complete$city_code,
      case_name = corrected_complete$city_name_original,
      country_name = corrected_complete$country_name,
      POP = corrected_complete$POP,
      GDPpc = corrected_complete$GDPpc,
      pm25 = corrected_complete$pm25,
      LAI = corrected_complete$LAI,
      NCP = corrected_complete$NCP,
      stringsAsFactors = FALSE
    ),
    corrected_cdm_parts$cdm
  )
  set_balance <- data.frame(
    set = names(corrected_cdm_parts$cdm),
    members = colSums(corrected_cdm_parts$cdm),
    nonmembers = nrow(corrected_cdm_parts$cdm) - colSums(corrected_cdm_parts$cdm),
    member_share = colMeans(corrected_cdm_parts$cdm),
    stringsAsFactors = FALSE
  )
  associations <- pairwise_binary_associations(corrected_cdm_parts$cdm, names(thresholds))
  threshold_specs <- data.frame(
    condition = names(thresholds),
    raw_variable = c("POP", "GDPpc", "pm25", "LAI", "NCP"),
    threshold = unname(thresholds),
    stringsAsFactors = FALSE
  )
  threshold_diag <- threshold_diagnostics(corrected_city, threshold_specs)

  proxy_complete <- stats::complete.cases(
    energy_corrected$data[, c("POP", "FE_Consumption_Proxy_2020_2022"), drop = FALSE]
  )
  energy_proxy_diag <- data.frame(
    diagnostic = c(
      "formula", "energy_years", "national_population_year", "unit_conversion_ktoe_to_TJ",
      "available_city_rows", "pearson_correlation_proxy_with_POP", "calibrated_phi_with_LARGE_at_8190",
      "membership_share_at_8190", "membership_share_at_median", "median_threshold",
      "unmatched_energy_countries_to_population", "unmatched_city_countries_to_energy"
    ),
    value = c(
      "national mean final energy consumption * 41.868 * city POP / national population",
      "2020-2022", "2022", "41.868", sum(proxy_complete),
      stats::cor(
        energy_corrected$data$POP[proxy_complete],
        energy_corrected$data$FE_Consumption_Proxy_2020_2022[proxy_complete]
      ),
      stats::cor(
        energy_8190_result$cdm$LARGE,
        energy_8190_result$cdm$ENERGY_CONSUMPTION
      ),
      mean(energy_8190_result$cdm$ENERGY_CONSUMPTION),
      mean(energy_median_result$cdm$ENERGY_CONSUMPTION),
      energy_median,
      energy_corrected$unmatched_energy_countries_to_population,
      energy_corrected$unmatched_city_countries_to_energy
    ),
    stringsAsFactors = FALSE
  )

  case_flow <- data.frame(
    branch = c(
      "corrected", "corrected", "corrected", "corrected", "submitted", "submitted", "submitted"
    ),
    stage = c(
      "main city records imported", "after one-to-one/many-to-one joins", "complete five-condition cases",
      "excluded from five-condition complete-case model", "saved city-energy records after erroneous join",
      "complete submitted six-condition cases", "excluded from submitted complete-case model"
    ),
    records = c(
      nrow(corrected_city), nrow(corrected_city), nrow(corrected_cdm_parts$cdm),
      nrow(corrected_cdm_parts$exclusions), nrow(submitted$saved_city), nrow(submitted$cdm), nrow(submitted$exclusions)
    ),
    explanation = c(
      "One row per city_code in main_dataset.csv",
      "Joins preserve main rows; unmatched data remain missing and are audited",
      "No missing values in five conditions or OUTCOME",
      "One row per excluded city with missing fields is saved privately",
      "Nine extra Finnish rows result from two Finland national-population records",
      "Notebook thresholds and complete-case rule reproduced",
      "One row per excluded submitted record with missing fields is saved privately"
    ),
    stringsAsFactors = FALSE
  )

  # ----- Consolidate model outputs without erasing solution labels -----
  # Each row retains model_id and solution_type so manuscript statements cannot
  # mix complex, parsimonious, and alleged/intermediate formulas.
  all_solutions <- rbind(
    submitted_result$solutions,
    alleged_solutions,
    corrected_result$solutions,
    energy_8190_result$solutions,
    energy_median_result$solutions
  )
  all_cases <- rbind(
    submitted_result$cases_by_path,
    alleged_cases,
    corrected_result$cases_by_path,
    energy_8190_result$cases_by_path,
    energy_median_result$cases_by_path
  )
  simplifying_assumptions <- rbind_fill(list(
    submitted_result$simplifying_assumptions,
    corrected_result$simplifying_assumptions,
    energy_8190_result$simplifying_assumptions,
    energy_median_result$simplifying_assumptions
  ))
  if (!nrow(simplifying_assumptions)) {
    simplifying_assumptions <- data.frame(
      model_id = character(), solution_type = character(), model_number = integer(),
      configuration = character(), stringsAsFactors = FALSE
    )
  }

  submitted_energy_nec <- subset(
    submitted_result$necessity, literal == "ENERGY_CONSUMPTION"
  )$consistency[1]
  # Compact headline checks support the report prose. Values are generated from
  # live model objects, not manually transcribed from old HTML.
  model_comparison <- data.frame(
    check = c(
      "likely_generating_branch", "submitted_cdm_cases", "submitted_truth_rows",
      "submitted_observed_configurations", "submitted_logical_remainders",
      "submitted_energy_necessity_consistency", "submitted_energy_necessary_at_0_90",
      "corrected_primary_cases", "corrected_truth_rows", "corrected_logical_remainders",
      "corrected_individually_necessary_conditions", "corrected_complex_paths",
      "corrected_complex_solution_consistency", "corrected_complex_solution_coverage",
      "intermediate_solution_reported_for_corrected_model"
    ),
    value = c(
      "AER_Looped_Energy_Consumption.ipynb and rendered HTML",
      nrow(submitted_result$cdm), nrow(submitted_result$truth_table),
      submitted_result$settings$observed_configurations, submitted_result$settings$logical_remainders,
      submitted_energy_nec, submitted_energy_nec >= 0.90,
      nrow(corrected_result$cdm), nrow(corrected_result$truth_table),
      corrected_result$settings$logical_remainders,
      sum(corrected_result$necessity$necessary_at_0_90),
      sum(corrected_result$solutions$solution_type == "complex" & corrected_result$solutions$row_type == "path"),
      subset(corrected_result$solutions, solution_type == "complex" & row_type == "overall_solution")$consistency[1],
      subset(corrected_result$solutions, solution_type == "complex" & row_type == "overall_solution")$raw_coverage[1],
      FALSE
    ),
    stringsAsFactors = FALSE
  )
  if (portfolio_mode) {
    model_comparison$value[model_comparison$check == "likely_generating_branch"] <-
      "energy-notebook and rendered-report branch"
  }

  data_dictionary <- data.frame(
    construct = c("OUTCOME", "LARGE", "AFFLUENT", "BENEFIT", "AUTONOMOUS", "SUPPORTED", "ENERGY_CONSUMPTION"),
    raw_measure = c(
      "af: presence of the course-defined A-level/A1 plan category",
      "Mean city population, 2013-2015", "Mean city GDP per capita, 2013-2015",
      "City PM2.5 concentration", "Country Local Autonomy Index mean, 2010 and 2014",
      "Country national-climate-policy score mean, 2013-2015",
      "National final energy mean 2020-2022 allocated by city share of national population"
    ),
    data_level = c("city", "city", "city", "city", "country assigned to city", "country assigned to city", "country allocated to city by POP"),
    main_cutoff = c("af == 1", "> 100000", "> 30000", "> 12.5", "> 55", "> 0.45", "> 8190 (sensitivity only)"),
    boundary_rule = c("coded binary", rep("strictly greater than", 6)),
    analytical_status = c(
      "corrected outcome: plan presence, not stringency or implementation",
      "primary mandatory condition", "primary mandatory condition",
      "primary external/co-benefit condition; requires theory in manuscript",
      "primary institutional condition; not participatory governance",
      "primary national enabling context; not city-level CCPI",
      "excluded from primary model; retained only as sensitivity because it is population-derived and temporally misaligned"
    ),
    stringsAsFactors = FALSE
  )

  intermediate_decision <- data.frame(
    model = c("submitted row-mutation audit", "corrected primary model"),
    decision = c("reproduced for diagnosis only; not a valid intermediate solution", "no intermediate solution reported"),
    reason = c(
      "Rows 3 and 15 were overwritten by numeric position without documented directional expectations; row 3 was already sufficient.",
      "The supplied literature does not justify a complete directional-expectation vector or named easy counterfactuals for this model."
    ),
    stringsAsFactors = FALSE
  )

  analysis_settings <- rbind(
    submitted_result$settings,
    corrected_result$settings,
    energy_8190_result$settings,
    energy_median_result$settings
  )
  analysis_settings$calibration_rule <- ">"
  analysis_settings$necessity_cut <- 0.90
  analysis_settings$show_cases <- TRUE
  analysis_settings$intermediate_solution <- c("invalid row-mutation audit only", "not reported", "not reported", "not reported")

  # ----- Figure generation -----
  set_balance_figure <- file.path(figure_dir, "set_balance_corrected.png")
  make_set_balance_figure(set_balance, set_balance_figure)

  # ----- Disclosure-controlled exports -----
  # Aggregate/public-safe outputs are always written. Portfolio-mode truth
  # tables lose their case-label column before export.
  write_utf8_csv(selected_hashes_export, file.path(output_dir, "selected_input_hashes.csv"))
  write_utf8_csv(corrected$join_audit, file.path(output_dir, "join_audit.csv"))
  write_utf8_csv(case_flow, file.path(output_dir, "case_flow.csv"))
  write_utf8_csv(data_dictionary, file.path(output_dir, "data_dictionary.csv"))
  write_utf8_csv(threshold_diag, file.path(output_dir, "threshold_diagnostics.csv"))
  write_utf8_csv(set_balance, file.path(output_dir, "set_balance.csv"))
  write_utf8_csv(associations, file.path(output_dir, "condition_associations.csv"))
  write_utf8_csv(energy_proxy_diag, file.path(output_dir, "energy_proxy_diagnostics.csv"))
  write_utf8_csv(submitted$comparison, file.path(output_dir, "submitted_model_comparison.csv"))
  write_utf8_csv(model_comparison, file.path(output_dir, "model_comparison.csv"))
  write_utf8_csv(analysis_settings, file.path(output_dir, "analysis_settings.csv"))
  write_utf8_csv(intermediate_decision, file.path(output_dir, "intermediate_solution_decision.csv"))
  write_utf8_csv(corrected_result$necessity, file.path(output_dir, "necessity.csv"))
  write_utf8_csv(corrected_result$individual_sufficiency, file.path(output_dir, "individual_sufficiency.csv"))

  corrected_truth_public <- corrected_result$truth_table
  submitted_truth_public <- submitted_result$truth_table
  if (portfolio_mode) {
    corrected_truth_public$cases <- NULL
    submitted_truth_public$cases <- NULL
  }
  write_utf8_csv(corrected_truth_public, file.path(output_dir, "truth_table_complete.csv"))
  write_utf8_csv(submitted_truth_public, file.path(output_dir, "truth_table_submitted_complete.csv"))
  write_utf8_csv(all_solutions, file.path(output_dir, "solutions_and_fit.csv"))
  write_utf8_csv(sensitivity, file.path(output_dir, "sensitivity_comparison.csv"))
  write_utf8_csv(simplifying_assumptions, file.path(output_dir, "logical_remainders_used.csv"))
  write_utf8_csv(submitted_mutation$row_mutation_audit, file.path(output_dir, "submitted_row_mutation_audit.csv"))
  write_utf8_csv(session_table(), file.path(output_dir, "session_versions.csv"))

  # Privacy boundary: calibrated cases, path memberships, and exclusion rows
  # are available for the private audit only and are never written publicly.
  if (!portfolio_mode) {
    write_utf8_csv(calibrated_corrected, file.path(output_dir, "calibrated_data_corrected.csv"))
    write_utf8_csv(all_cases, file.path(output_dir, "cases_by_path.csv"))
    write_utf8_csv(corrected_cdm_parts$exclusions, file.path(output_dir, "case_exclusions_corrected.csv"))
    write_utf8_csv(submitted$exclusions, file.path(output_dir, "case_exclusions_submitted.csv"))
  }

  # ----- Returned analysis contract -----
  # Return the same in-memory objects used to produce the files so Quarto never
  # has to re-read derived CSVs or maintain a second calculation pathway.
  list(
    source_root = if (portfolio_mode) "[external authorized source root]" else source_root,
    qca_pack = if (portfolio_mode) "[external authorized QCA pack]" else qca_pack,
    paths = paths,
    selected_hashes = selected_hashes_export,
    corrected_city = corrected_city,
    corrected_cdm = corrected_cdm_parts$cdm,
    corrected = corrected_result,
    submitted = submitted_result,
    submitted_audit = submitted,
    alleged_intermediate = list(solutions = alleged_solutions, row_audit = submitted_mutation$row_mutation_audit),
    energy_8190 = energy_8190_result,
    energy_median = energy_median_result,
    energy_proxy_diagnostics = energy_proxy_diag,
    case_flow = case_flow,
    data_dictionary = data_dictionary,
    threshold_diagnostics = threshold_diag,
    set_balance = set_balance,
    associations = associations,
    sensitivity = sensitivity,
    solutions = all_solutions,
    simplifying_assumptions = simplifying_assumptions,
    model_comparison = model_comparison,
    intermediate_decision = intermediate_decision,
    output_dir = output_dir,
    portfolio_mode = portfolio_mode,
    files = list(set_balance_figure = set_balance_figure)
  )
}
