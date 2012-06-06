#!/bin/bash
set -e

CACHE_DIR="/var/lib/facter"
CACHE="${CACHE_DIR}/facts.yaml"
TEMP_CACHE=`mktemp "${CACHE_DIR}/facts.yaml.tempXXXXXX"`

mkdir -p "$CACHE_DIR"
facter -y -p > "$TEMP_CACHE"
chmod 0644 "$TEMP_CACHE"
mv "$TEMP_CACHE" "$CACHE"