# Data governance and privacy note

## Current project

The published epidemiology methods project uses only **synthetic data generated in code**. No identifiable, pseudonymised or anonymised patient records are included.

This design allows the methods to be demonstrated publicly without exposing health information.

## Repository-level privacy controls

The wider portfolio applies several controls that are relevant to responsible data handling:

- private and participant-level data remain outside version control;
- credentials and service settings are supplied through environment variables rather than committed secrets;
- machine-specific and personal paths are removed from public copies where appropriate;
- public project READMEs distinguish supplied/course datasets from personal analytical contributions; and
- the repository records publication/exclusion decisions in [the local source audit](../../docs/LOCAL_SOURCE_AUDIT.md).

These controls demonstrate privacy-aware portfolio practice. They do **not** amount to NHS information-governance certification.

## Governance considerations for real epidemiological data

If this workflow were adapted to real health data, the analysis plan would need to address, as applicable:

1. **Lawful basis and approvals** — confirm research or operational authority, ethics requirements, contracts and data-sharing permissions before access.
2. **Data minimisation** — use only variables required for the research question and avoid collecting unnecessary identifiers.
3. **De-identification** — prefer anonymised or appropriately pseudonymised data where identifiable information is not necessary.
4. **Access control** — restrict data to authorised users and approved environments.
5. **Secure storage and transfer** — use institutionally approved systems rather than public repositories or personal cloud storage.
6. **Retention and deletion** — follow the approved retention schedule and remove data when no longer required.
7. **Provenance and auditability** — document source, extraction date, transformations, exclusions, quality checks and analysis versions.
8. **Temporal leakage prevention** — for forecasting tasks, ensure future information does not enter training data or feature engineering.
9. **Disclosure control** — review small cells, rare conditions, geography and free text before releasing tables or figures.
10. **Subgroup evaluation** — assess whether model performance differs across clinically or demographically important groups where lawful and scientifically justified.
11. **Clinical or public-health review** — involve domain experts when selecting outcomes, thresholds and interpretations.
12. **Reproducible separation** — keep code and configuration under version control while keeping confidential data outside public Git history.

## Evidence boundary

This note documents **awareness of governance requirements and privacy-aware analytical practice**. It should not be used to claim formal NHS data-governance certification, experience as a Caldicott Guardian or Data Protection Officer, authorised access to NHS patient-identifiable datasets, or completed ethics approval for this synthetic demonstration.
