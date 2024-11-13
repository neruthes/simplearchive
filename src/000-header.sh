#!/bin/bash


### Initialize constants
[[ -z "$DATADIR_PREFIX" ]] && DATADIR_PREFIX="$PWD/data"


### Override constants from env
[[ -e .env ]] && source .env
[[ -e .envlocal ]] && source .envlocal


