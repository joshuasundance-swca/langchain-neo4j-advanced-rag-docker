#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
python /home/appuser/neo4j-advanced-rag/check_for_data.py \
  && python /home/appuser/neo4j-advanced-rag/packages/neo4j-advanced-rag/ingest.py \
  || exit 0
