#!/bin/bash

CACHE_DIR="/var/lib/facter"
CACHE="${CACHE_DIR}/facts.cache"
TEMP_CACHE="/tmp/temp_cache"

mkdir -p $CACHE_DIR
facter -y > $TEMP_CACHE
mv $TEMP_CACHE $CACHE