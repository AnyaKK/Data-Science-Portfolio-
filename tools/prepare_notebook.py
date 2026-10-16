"""Create a reviewable notebook copy without changing the archived original.

The script removes saved outputs and execution counters, drops transient notebook
metadata, and replaces absolute Windows user-home prefixes. It intentionally does
not rewrite course attribution or analytical code.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


WINDOWS_HOME = re.compile(r"(?i)[a-z]:[\\/]users[\\/][^\\/\"'\s]+")


def prepare_notebook(source: Path, destination: Path) -> None:
    notebook = json.loads(source.read_text(encoding="utf-8"))

    for cell in notebook.get("cells", []):
        source_lines = cell.get("source", [])
        if isinstance(source_lines, str):
            source_lines = [source_lines]
        cell["source"] = [WINDOWS_HOME.sub("${USER_HOME}", line) for line in source_lines]

        if cell.get("cell_type") == "code":
            cell["execution_count"] = None
            cell["outputs"] = []

        metadata = cell.get("metadata")
        if isinstance(metadata, dict):
            for key in ("collapsed", "execution", "jupyter", "scrolled", "trusted"):
                metadata.pop(key, None)

    metadata = notebook.get("metadata", {})
    cleaned_metadata = {
        key: metadata[key]
        for key in ("kernelspec", "language_info")
        if key in metadata
    }
    notebook["metadata"] = cleaned_metadata

    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(
        json.dumps(notebook, ensure_ascii=False, indent=1) + "\n",
        encoding="utf-8",
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("destination", type=Path)
    args = parser.parse_args()
    prepare_notebook(args.source, args.destination)


if __name__ == "__main__":
    main()
