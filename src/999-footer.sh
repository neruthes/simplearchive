case $1 in
    new_slot)
        create_new_slot
        ;;
    build_website_full)
        build_website_full
        ;;
    check_toml)
        check_toml "$2"
        ;;
esac
