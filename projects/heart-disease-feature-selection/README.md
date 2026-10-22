# Heart-disease feature selection with GA and PSO

This dissertation compared genetic algorithm (GA) and particle swarm optimisation (PSO) feature selection with all-feature models on the processed Cleveland benchmark. The current grading record is the executed v3 reviewed notebook linked below. The earlier compact notebook remains available as a historical portfolio copy.

## Abstract

Feature selection may reduce predictor sets without improving prediction. This study compared genetic algorithm (GA) and particle swarm optimisation (PSO) feature selection against all-feature models for heart-disease classification using the processed Cleveland dataset.

The analysis included 303 observations and 13 predictors. Logistic regression, decision tree, random forest, support vector machine and extreme gradient boosting were evaluated using five-fold stratified outer validation repeated twice. Training-local preprocessing, classifier-specific selection and condition-specific tuning produced 15 conditions. Area under the receiver operating characteristic curve (ROC-AUC) was primary; complementary metrics, calibration, parsimony, stability and computation were examined. Paired fold-mean differences were distinguished from differences calculated using averaged repeated out-of-fold probabilities. Bootstrap intervals conditioned on realised predictions without repeating model development.

All-feature logistic regression achieved aggregated ROC-AUC .914, Matthews correlation coefficient .708, sensitivity .799 and specificity .902. Only decision-tree PSO minus all-feature performance had a positive paired fold-mean ROC-AUC difference (+0.0044). Its aggregated-prediction difference was +0.0100, with conditional 95% bootstrap confidence interval [−0.0166, 0.0363]. All aggregated ROC-AUC contrast intervals spanned zero. Mean selected-feature counts ranged from 5.00 to 8.80 for GA and 6.20 to 8.40 for PSO. Selection stability varied, and calibration remained secondary. PSO recorded shorter mean runtimes, qualified by shared-cache execution order.

Neither selector consistently improved discrimination across classifiers. Smaller subsets did not establish clinical benefit. The historical sample, dependent folds, reused inner partitions and conditional uncertainty limited interpretation. The findings supported classifier-specific internal comparisons; contemporary independent evaluation was needed before broader application.

## Grading notebook and project note

[Heart_Disease_GA_PSO_Analysis_Workflow_v3_Monitored-IR.ipynb](electronic_records/Heart_Disease_GA_PSO_Analysis_Workflow_v3_Monitored-IR.ipynb) is an unchanged copy of the supplied reviewed notebook, including saved outputs and personal details, provided at the author's explicit request for grading. Its SHA-256 is recorded in the [export-copy manifest](electronic_records/SHA256_MANIFEST.json). No notebook cells, personal details or outputs were removed or redacted for this copy. The `IR` filename does not establish human independent review or prove leakage impossible; the saved review fields and qualifications remain as recorded.

## Repository structure

```text
heart-disease-feature-selection/
├── README.md
├── heart-disease-ga-pso.ipynb          # Earlier compact portfolio copy
├── requirements.txt                  # General package requirements
├── requirements-v3-recorded.txt      # Versions recorded by the executed run
├── data/processed.cleveland.data
├── electronic_records/              # Current v3 evidence and exact reviewed notebook
│   ├── Heart_Disease_GA_PSO_Analysis_Workflow_v3_Monitored-IR.ipynb
│   ├── SHA256_MANIFEST.json
│   └── ...                          # Tables, predictions, masks, run/configuration records
├── results/                         # Existing convenient table copies refreshed from v3
├── docs/
│   ├── PROJECT_NOTE.md
│   └── PUBLICATION_CHANGELOG.md
└── scripts/verify_records.py         # File-identity checks only; no fitting
```

## Evidence and interpretation

The electronic records accompany Appendices A–H. `analysis_estimands.json` documents two different quantities: the equal-weight mean of paired outer-fold ROC-AUC differences and differences calculated from averaged repeated out-of-fold predictions. Conditional bootstrap intervals apply only to the latter realised predictions, not to fold means or the later post-analysis joint proposition. Repeated folds are dependent. Smaller feature sets and recurring predictors did not establish clinical benefit or causal importance. Runtime comparisons were affected by shared-cache execution order. See the saved tables and recorded statuses rather than interpreting rounded ties as exact equality.

The export-copy manifest checks file identity. The original run manifest covers only its listed analytical artifacts; it does not retrospectively cover the reviewed notebook or new repository documentation. Neither hashes nor assertion PASS rows prove the absence of leakage.

## Run locally

```bash
python -m venv .venv
# Activate .venv using the command appropriate for your operating system.
python -m pip install -r requirements-v3-recorded.txt
python -m pip install jupyterlab ipykernel
python scripts/verify_records.py
jupyter lab electronic_records/Heart_Disease_GA_PSO_Analysis_Workflow_v3_Monitored-IR.ipynb
```

Open the notebook's run-control cell before execution. Set `PROJECT_DIR` to a local working folder containing `data/processed.cleveland.data`. Begin in smoke mode; a full run requires the notebook's explicit final-run settings. Restart the kernel and run all after changing controls. Use a separate output directory for a new run. The saved outputs are evidence of the recorded execution; publishing this copy did not rerun analysis. The recorded runtime was Python 3.13.2 on Windows; package versions and system differences may affect a fresh run. Windows-specific monitoring is platform dependent.

## Data and use limits

Data source: [UCI Heart Disease](https://doi.org/10.24432/C52P4X), processed Cleveland member. Preserve the dataset's attribution and applicable source terms. This small historical internal benchmark did not establish contemporary or external clinical performance and must not be used for diagnosis or clinical decisions. Third-party papers, course packs, credentials, local caches and temporary files are not part of this project publication.
