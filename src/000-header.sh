#!/bin/bash


### Initialize constants
[[ -z "$DATADIR_PREFIX" ]] && DATADIR_PREFIX="$PWD/data"
[[ -z "$LOG_LEVEL" ]] && LOG_LEVEL=1


### Override constants from env
[[ -e .env ]] && source .env
[[ -e .envlocal ]] && source .envlocal


