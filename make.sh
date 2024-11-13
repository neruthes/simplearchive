#!/bin/bash

case $1 in
    '' | all )
        mkdir -p build
        rm -rf build
        mkdir -p build
        find src -type f | sort | while read -r fn; do
            cat "$fn" >> build/simplearchive.sh
        done
        ;;
    install )
        install build/simplearchive.sh -m755 "$HOME/.local/bin/simplearchive.sh"
        ;;
    dev_fast_all )
        ./make.sh all
        ./make.sh install
        ;;
    doc/MANUAL.md )
        pandoc -i doc/MANUAL.md -s --number-sections -o doc/MANUAL.pdf --pdf-engine=xelatex -V papersize=A4
        ;;
esac
