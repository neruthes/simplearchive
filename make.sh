#!/bin/bash

function _bt () {
    echo "Building target: $1"
}

case $1 in
    '' | all )
        _bt all
        mkdir -p build
        rm -rf build
        mkdir -p build
        find src -type f | sort | while read -r fn; do
            cat "$fn" >> build/simplearchive.sh
        done
        du -h build/simplearchive.sh
        ;;
    install )
        _bt install
        install build/simplearchive.sh -v -m755 "$HOME/.local/bin/simplearchive.sh"
        ;;
    '@' | dev_fast_all )
        _bt dev_fast_all
        ./make.sh all
        ./make.sh install
        ;;
    doc/MANUAL.md )
        pandoc -i doc/MANUAL.md -s --number-sections -o doc/MANUAL.pdf --pdf-engine=xelatex -V papersize=A4
        ;;
    data/ )
        cd data &&
        [[ "$USER" == neruthes ]] && shareDirToNasPublic -a
        ;;
esac
