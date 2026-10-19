# Data availability and handling

No source or case-level dataset is distributed in this project.

The analysis requires authorized access to the original AER directory. At render time, pass that directory as `SOURCE_ROOT` or set `AER_SOURCE_ROOT`. The code expects the selected QCA pack beneath that root and fails if any required file or column is absent.

This design is intentional:

- supplied CSVs, notebooks, HTML reports, PDFs, and the manuscript may be private, copyrighted, or unlicensed for redistribution;
- calibrated city records, exclusion lists, and cases-by-path remain case-level derived data and are excluded from the public portfolio;
- SHA-256 fingerprints provide provenance without copying source contents;
- the public report contains aggregate model diagnostics and truth-table configurations with case labels removed.

To reproduce the private audit, use the original authorized files in place. Do not copy them into this folder. See `docs/WORKFLOW.md` for expected logical source roles and verification steps.
