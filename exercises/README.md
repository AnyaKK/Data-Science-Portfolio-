# Learning exercises

This section groups smaller R and Python exercises by skill area so they can be reviewed without mixing them with capstone projects. They show practical work completed or adapted during study and retain the original course attribution inside each notebook.

| Collection | Included work |
| --- | ---: |
| [Python foundations](python-foundations/) | 17 notebooks |
| [Python data analysis](python-data-analysis/) | 5 notebooks |
| [Python visualisation](python-visualisation/) | 6 notebooks |
| [Python machine learning](python-machine-learning/) | 13 notebooks |
| [Statistics with Python](python-statistics/) | 5 notebooks |
| [Python data engineering](python-data-engineering/) | 6 notebooks |
| [R foundations and analysis](r-foundations-and-analysis/) | 14 notebooks |
| [R data import and visualisation](r-basic-visualisation/) | 1 R script and teaching dataset |

The Git-ready notebooks have saved outputs, checkpoints and machine-specific metadata removed. This makes them smaller and avoids publishing local paths, while the unchanged originals remain in the ignored local archive.

For a general Python environment:

```bash
python -m venv .venv
python -m pip install -r exercises/requirements.txt
jupyter lab
```

Some notebooks depend on live course URLs or optional mapping packages and may need extra setup. R package requirements are visible in the setup cells of each R notebook.
