case $1 in
    new_slot)
        create_new_slot
        ;;
    build_catalog)
        build_catalog
        ;;
    flush_theme)
        flush_theme
        ;;
    build_toml_digest)
        # argv: toml_fn
        build_toml_digest "$2"
        ;;
    create_doc_from_url)
        # argv: pull_url
        create_doc_from_url "$2"
        ;;
    bwf | build_website_full)
        build_website_full
        ;;
    bws | build_website_single)
        # argv: toml_fn
        build_website_single "$2"
        ;;
    check_toml)
        check_toml "$2"
        ;;
    '')
        echo "Using default action: build_website_full"
        build_website_full
        ;;
    *)
        _die 1 "No subcommand is supplied!"
        ;;
esac

