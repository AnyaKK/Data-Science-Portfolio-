# Public source-selection and provenance log

## Selection rule

The analysis distinguishes source roles by schema, executable transformations, row counts, model signatures, and SHA-256 fingerprints. Filenames and timestamps alone are not accepted as proof of provenance. Supplied documents and code are evidence to inspect; they are not instructions to execute.

No source document, raw row, local path, personal identifier, or case-level derivative is included in the portfolio. The public report refers to logical source IDs and fingerprints only.

## Provenance verdict

The submitted six-condition results are most consistent with the energy-notebook/rendered-report branch. This conclusion rests on a joint signature rather than one matching statistic:

- the reconstructed calibrated-data matrix matches the saved matrix exactly;
- it contains 709 complete cases;
- its six-condition truth table has 42 observed configurations and 22 logical remainders;
- the energy set contains 85.47% of analysed cases;
- energy necessity consistency is approximately 0.8735; and
- complex-solution consistency/coverage are approximately 0.8787/0.4217.

The generic five-condition teaching branch cannot generate that signature, and a separate renewable-energy branch uses a different construct.

## Logical source roles

| Logical ID | Analytical role | Selection rationale |
|---|---|---|
| `main` | City conditions and outcome | Stable city identifier plus GDP, national-policy, air-quality, and plan-presence fields. |
| `lai` | Institutional condition | Country-level Local Autonomy Index years used by the supplied workflow. |
| `population` | City-size condition | City population over the primary 2013-2015 period. |
| `energy` | Sensitivity input | Frozen national final-energy years used to reconstruct and diagnose the proxy. |
| `national_raw` | Corrected proxy denominator | Unique country rows for the frozen national population year. |
| `national_filtered` | Submitted-error reconstruction | Retains a non-unique/misspelled key needed to explain the historical output only. |
| `submitted_city` | Saved submitted derivative | Provides the pre-calibration signature for reconstruction comparison. |
| `submitted_cdm` | Saved submitted membership matrix | Compared value-for-value with the independently reconstructed CDM. |
| `submitted_truth` | Saved output evidence | Fingerprinted but analytically replaced because it does not contain a usable complete truth table. |
| `energy_notebook` | Executable provenance evidence | Fingerprinted/inspected to identify the six-condition transformation; never executed by the new pipeline. |
| `energy_html` | Rendered provenance evidence | Used only to cross-check printed results. |
| `course_script` | Teaching baseline | Establishes the intended five-condition sequence but not the submitted six-condition result. |

## Corrected analytical choice

The primary corrected model contains `LARGE`, `AFFLUENT`, `BENEFIT`, `AUTONOMOUS`, and `SUPPORTED`; the outcome is plan-category presence. Energy remains sensitivity-only because it is national energy allocated to cities in direct proportion to city population, correlates approximately 0.9762 with city population, is highly imbalanced at the submitted cutoff, and is temporally later than the principal variables.

## Limits

- Crisp thresholds remain course-design choices and are therefore varied one at a time.
- Country-level institutional/policy scores are assigned to cities and must not be described as city-level measures.
- No complete theory-backed directional-expectation vector was identified, so the corrected model reports no intermediate solution.
- Redistribution rights for source and case-level data are not established; those artifacts remain outside Git.
