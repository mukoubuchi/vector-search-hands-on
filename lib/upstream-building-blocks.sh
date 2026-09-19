#!/bin/bash
# shellcheck shell=bash
# This file only records values; every reader sources it.
# shellcheck disable=SC2034
# Provenance of the Building Blocks assets shipped in setup/participant/.bob
#
# The mode and the skill come from the upstream IBM Building Blocks repository
# and are shipped unmodified, with one documented exception recorded below.
# check_upstream_building_blocks.sh re-downloads these blobs and compares them
# with the shipped copies.

UPSTREAM_REPO="ibm-self-serve-assets/building-blocks"
UPSTREAM_REF="4a2ee334bf0acb4a798dc197e6f63bde99b9a0d6"

# Custom mode: .bob/custom_modes.yaml and .bob/rules-opensearch-builder/*.xml
MODE_ZIP_PATH="data/pipelines/rag/bob-modes/base-modes/opensearch-builder.zip"
MODE_ZIP_BLOB="efa9473d0146246c08a3ef9351f882b0b7a58e02"

# Skill: .bob/skills/opensearch-vector-search/SKILL.md
SKILL_ZIP_PATH="data/pipelines/rag/bob-skills/opensearch-vector-search.zip"
SKILL_ZIP_BLOB="916e1f974f3a420006f76335bff14e5c3d64c9ae"

# The one documented change. Upstream writes the mode name as a block scalar
# with content on the same line, which is not valid YAML: PyYAML, Ruby Psych,
# the npm yaml package and js-yaml all reject the file at line 3, so the mode
# would never load. The shipped copy carries the plain scalar instead.
CUSTOM_MODES_FIX_BEFORE="    name: >- OpenSearch Vector Search Builder"
CUSTOM_MODES_FIX_AFTER="    name: OpenSearch Vector Search Builder"
