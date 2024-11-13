function _die() {
    echo "[FATAL] $2" > /dev/stderr
    exit "$1"
}

function create_new_slot() {
    [[ -z "$uuid" ]] && uuid="$(uuidgen v4 | tr -d '-')"
    new_uuid_dir="$DATADIR_PREFIX/${uuid:0:2}/$uuid"
    mkdir -p "$new_uuid_dir"
    (
        echo "[document]"
        echo "uuid = '$uuid'"
        echo 'title = "NewUntitledDocument"'
        echo "is_local = true"
        echo 'author = "PlaceholderAuthorName"'
        echo 'publisher = "PlaceholderPublisherName"'
        echo 'filename = "MyDoc.pdf"'
    ) > "$new_uuid_dir/metadata.toml"
}



function build_website_full() {
    mkdir -p "$DATADIR_PREFIX/theme"
    find "$DATADIR_PREFIX" -name metadata.toml | while read -r toml_fn; do
        # toml_fn="$toml_fn" flush_hash_to_toml_single
        check_toml "$toml_fn" &&
        toml_fn="$toml_fn" build_website_single
    done
}

### This feature may be added later!
# function flush_hash_to_toml_single() {
#     [[ -z "$toml_fn" ]] && _die 1 "No toml_fn is set!"
#     echo "(flush_hash_to_toml_single)  Working on $toml_fn"
#     cached_hash="$(tomlq -rM .document.sha256hash "$toml_fn")"
#     echo "cached_hash=$cached_hash"
#     if [[ "$cached_hash" == null ]]; then
#         tomlq
#     fi
# }

function build_website_single() {
    [[ -z "$toml_fn" ]] && _die 1 "No toml_fn is set!"
    echo "(build_website_single)  Working on '$toml_fn' ..."
    workdir="$(dirname "$toml_fn")"
    html_fn="$workdir/index.html"
    digest_fn="$workdir/_digest.txt"
    cp -a "$DATADIR_PREFIX/../theme/detail.html" "$html_fn"
    real_fn="$workdir/$(tomlq -rM .document.filename "$toml_fn")"
    (
        printf 'hash='
        sha256sum "$real_fn" | cut -c1-64
        printf 'document_timestamp='
        date -r "$real_fn" -Is
        printf 'metadata_json='
        tomlq -cM '.[]' "$toml_fn" 
    ) > "$digest_fn"
    cat "$digest_fn"
}



function check_toml() {
    toml_fn="$1"
    [[ -z "$toml_fn" ]] && _die 1 "No toml_fn is set!"
    cached_filename="$(tomlq -rM .document.filename "$toml_fn")"
    [[ -e "$(dirname "$toml_fn")/$cached_filename" ]] || _die 2 "Cannot find $cached_filename as indicated in toml!"
    tmpstr="$(tomlq -rM .document.title "$toml_fn")"
    [[ "$tmpstr" == NewUntitledDocument ]] || [[ "$tmpstr" == null ]] && _die 3 "Document title is not set!"
    tmpstr="$(tomlq -rM .document.author "$toml_fn")"
    [[ "$tmpstr" == PlaceholderAuthorName ]] || [[ "$tmpstr" == null ]] && _die 4 "Document author is not set!"
    tmpstr="$(tomlq -rM .document.publisher "$toml_fn")"
    [[ "$tmpstr" == PlaceholderPublisherName ]] || [[ "$tmpstr" == null ]] && _die 5 "Document publisher is not set!"
    echo "(check_toml)  $toml_fn looks good."
}
