#!/usr/bin/env python3
"""Fail when FORM-controlled config or docs drift from the approved version lock."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LOCK = json.loads((ROOT / "docs/reference/form-version-lock.json").read_text())
SOFTWARE = json.loads((ROOT / "docs/reference/software-inventory.json").read_text())
DATABASES = json.loads((ROOT / "docs/reference/database-inventory.json").read_text())

errors: list[str] = []


def expect(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)


def contains(path: str, value: str) -> None:
    expect(value in (ROOT / path).read_text(), f"{path} does not contain locked value: {value}")


source = SOFTWARE["source_context"]["biobakery-containers"]
expect(source["repository"] == LOCK["source_repository"], "software inventory source repository drifted")
expect(source["head"] == LOCK["source_commit"], "software inventory Hugemiler commit drifted")

images = SOFTWARE["images"]
for name in ("kneaddata", "metaphlan", "humann", "baqlava"):
    expect(
        LOCK[name]["image"] in images[name]["repo_digests"],
        f"{name} image digest differs from the FORM lock",
    )

expect(
    images["kneaddata"]["conda_packages"]["kneaddata"]["version"]
    == LOCK["kneaddata"]["conda_package"],
    "KneadData package version drifted",
)
expect(
    images["kneaddata"]["conda_packages"]["bowtie2"]["version"]
    == LOCK["kneaddata"]["bowtie2"],
    "KneadData Bowtie2 version drifted",
)
expect(
    images["metaphlan"]["python_distributions"]["metaphlan"]
    == LOCK["metaphlan"]["software"],
    "MetaPhlAn software version drifted",
)
expect(
    images["humann"]["python_distributions"]["humann"]
    == LOCK["humann"]["python_distribution"],
    "HUMAnN distribution version drifted",
)
expect(
    images["baqlava"]["python_distributions"]["baqlava"]
    == LOCK["baqlava"]["python_distribution"],
    "BAQLaVa distribution version drifted",
)
expect(
    images["metaphlan"]["strainphlan_version_output"].split()[2]
    == LOCK["strainphlan"]["software"],
    "StrainPhlAn version drifted",
)

artifacts = {item["id"]: item for item in DATABASES["artifacts"]}
metaphlan_db = artifacts["metaphlan-markers"]
expect(metaphlan_db["version"] == LOCK["metaphlan"]["index"], "MetaPhlAn index drifted")
expect(metaphlan_db["source"] == LOCK["metaphlan"]["archive"], "MetaPhlAn URL drifted")
expect(metaphlan_db["md5"] == LOCK["metaphlan"]["archive_md5"], "MetaPhlAn MD5 drifted")
expect(
    metaphlan_db["bowtie2_index_source"] == LOCK["metaphlan"]["bowtie2_index_archive"],
    "MetaPhlAn Bowtie2 index URL drifted",
)
expect(
    metaphlan_db["bowtie2_index_md5"] == LOCK["metaphlan"]["bowtie2_index_archive_md5"],
    "MetaPhlAn Bowtie2 index MD5 drifted",
)
expect(
    artifacts["strainphlan-markers"]["version"] == LOCK["strainphlan"]["index"],
    "StrainPhlAn marker index drifted",
)

for path in ("conf/params.config", "conf/profiles/form_docker.config", "README.md"):
    contains(path, LOCK["metaphlan"]["index"])
for path in ("conf/profiles/form_docker.config", "README.md"):
    for name in ("kneaddata", "metaphlan", "humann"):
        contains(path, LOCK[name]["image"])

for path in (
    "README.md",
    "docs/reference/versions.md",
    "docs/reference/databases.md",
    "docs/stages/03-metaphlan.md",
    "docs/stages/06-strainphlan.md",
):
    contains(path, LOCK["metaphlan"]["index"])

contains("docs/reference/databases.md", LOCK["metaphlan"]["bowtie2_index_archive"])
contains("docs/stages/03-metaphlan.md", LOCK["metaphlan"]["bowtie2_index_archive"])
for path in ("docs/reference/databases.md", "docs/stages/03-metaphlan.md"):
    contains(path, LOCK["metaphlan"]["bowtie2_index_archive_md5"])
    contains(path, LOCK["metaphlan"]["archive_md5"])
# The README builds the URL from a base variable, so require its path and file.
for fragment in ("metaphlan_databases", "bowtie2_indexes", "_bt2.tar", "_bt2.md5"):
    contains("README.md", fragment)

for path in [ROOT / "README.md", *ROOT.joinpath("docs").rglob("*.md")]:
    expect(
        "mpa_vJun23_CHOCOPhlAnSGB_202307" not in path.read_text(),
        f"user-facing documentation selects or repeats the non-FORM vJun23 index: {path.relative_to(ROOT)}",
    )

if errors:
    raise SystemExit("FORM version lock check failed:\n- " + "\n- ".join(errors))

print("FORM version lock: OK")
