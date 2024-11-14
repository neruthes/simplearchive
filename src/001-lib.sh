function _die() {
    # argv: exit_code, error_message
    echo "[FATAL] $2" > /dev/stderr
    exit "$1"
}

function _log() {
    req_level="$1"
    log_text="$2"
    if [[ "$LOG_LEVEL" -ge "$req_level" ]]; then
        echo "[LOG] $log_text"
    fi
}








function gen_uuid() {
    uuidgen v4 | tr -d '-'
}

function create_new_slot() {
    [[ -z "$uuid" ]] && uuid="$(gen_uuid)"
    new_uuid_dir="$DATADIR_PREFIX/${uuid:0:2}/$uuid"
    mkdir -p "$new_uuid_dir" # Might be created already, if pulling the same URL
    [[ -z $d_filename ]] && d_filename="./PlaceholderDocFilename.pdf"
    (
        echo "[document]"
        printf 'uuid = "%s"\n' "$uuid"
        echo 'title = "NewUntitledDocument"'
        echo 'author = "PlaceholderAuthorName"'
        echo 'publisher = "PlaceholderPublisherName"'
        printf 'filename = "%s"\n' "$d_filename"
    ) > "$new_uuid_dir/metadata.toml"
}





function flush_theme() {
    cp -av "$DATADIR_PREFIX/../theme/catalog.html" "$DATADIR_PREFIX/index.html"
    cp -av "$DATADIR_PREFIX/../theme/styles.css" "$DATADIR_PREFIX/styles.css"
    find "$DATADIR_PREFIX" -mindepth 2 -name index.html | sort | while read -r html_fn; do
        cp -av "$DATADIR_PREFIX/../theme/detail.html" "$html_fn"
    done
}

function build_catalog() {
    catalog_fn="$DATADIR_PREFIX/_catalog.txt"
    printf '' > "$catalog_fn"
    find "$DATADIR_PREFIX" -name metadata.toml | sort | while read -r toml_fn; do
        check_toml "$toml_fn" || _die 1 "Found problem with $toml_fn"
        build_toml_digest "$toml_fn"
        base64 -w0 "$(dirname "$toml_fn")/_digest.txt" >> "$catalog_fn"
        printf '\n' >> "$catalog_fn"
    done
}




function build_website_full() {
    mkdir -p "$DATADIR_PREFIX/../theme"
    build_catalog
    find "$DATADIR_PREFIX" -name metadata.toml | while read -r toml_fn; do
        check_toml "$toml_fn" &&
        bash "$0" build_website_single "$toml_fn"
    done
}

function build_website_single() {
    toml_fn="$1"
    [[ -z "$toml_fn" ]] && _die 1 "No toml_fn is set!"
    echo "(build_website_single)  Working on '$toml_fn' ..."
    workdir="$(dirname "$toml_fn")"
    html_fn="$workdir/index.html"
    cp -a "$DATADIR_PREFIX/../theme/detail.html" "$html_fn"
    bash "$0" build_toml_digest "$toml_fn"
}

function build_toml_digest() {
    toml_fn="$1"
    workdir="$(dirname "$toml_fn")"
    realdoc_fn="$workdir/$(tomlq -rM .document.filename "$toml_fn")"
    digest_fn="$workdir/_digest.txt"
    (
        printf 'hash='
        sha256sum "$realdoc_fn" | cut -c1-64
        printf 'document_timestamp='
        date -r "$realdoc_fn" -Is
        printf 'metadata_json='
        tomlq -acM '.[]' "$toml_fn" 
    ) > "$digest_fn"
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
    _log 5 "(check_toml)  $toml_fn looks good."
}




function create_doc_from_url() {
    pull_url="$1"
    # uuid="$(gen_uuid)"
    # Instead of actually generating a new one, we try using a fake uuid from input url
    uuid="$(sha256sum <<< "4306241f40ac4366848510a804047ecb:$pull_url" | cut -c1-32)"
    new_uuid_dir="$DATADIR_PREFIX/${uuid:0:2}/$uuid"
    actual_file_name="$(basename "$pull_url")"
    if ! grep -isq '.pdf$' <<< "$actual_file_name"; then
        actual_file_name="RenamedDocument.pdf"
        _log 0 "(create_doc_from_url)  pull_url '$pull_url' does not end with '.pdf' or '.PDF'!"
        _log 0 "(create_doc_from_url)  Using filename '$actual_file_name' instead."
    fi
    uuid="$uuid" d_filename="$actual_file_name" create_new_slot
    wget "$pull_url" -O "$new_uuid_dir/$actual_file_name" || _die 1 "Failed fetching document from the supplied URL."
    sed -i "s|PlaceholderDocFilename.pdf|$actual_file_name|g" "$new_uuid_dir/metadata.toml"
    _log 0 "HINT: You may want to modify  < $new_uuid_dir/metadata.toml >  to configure metadata for this entry."
    if [[ -z "$SA_EDITOR" ]]; then
        _log 0 "HINT: If you set env SA_EDITOR to editor binary name like '/bin/nano', this script can automatically open editor at this moment."
    else
        command "$SA_EDITOR" "$new_uuid_dir/metadata.toml"
    fi
}
