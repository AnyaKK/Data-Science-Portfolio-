"""Verify published evidence bytes without running notebook cells or fitting models."""
from pathlib import Path
import hashlib
import json

root = Path(__file__).resolve().parents[1] / "electronic_records"
manifest = json.loads((root / "SHA256_MANIFEST.json").read_text(encoding="utf-8"))
for name, expected in manifest["files"].items():
    path = root / name
    assert path.stat().st_size == expected["bytes"], f"Size mismatch: {name}"
    assert hashlib.sha256(path.read_bytes()).hexdigest() == expected["sha256"], f"Hash mismatch: {name}"
notebook = json.loads((root / "Heart_Disease_GA_PSO_Analysis_Workflow_v3_Monitored-IR.ipynb").read_text(encoding="utf-8-sig"))
assert notebook["nbformat"] == 4
assert all(cell["cell_type"] in {"code", "markdown", "raw"} for cell in notebook["cells"])
assert not any(output.get("output_type") == "error" for cell in notebook["cells"] for output in cell.get("outputs", [])), "Saved notebook error output found"
print(f"PASS: {len(manifest['files'])} evidence files match; notebook JSON is readable; no saved error outputs. No cells were executed.")
