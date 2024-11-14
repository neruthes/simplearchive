---
title: "SimpleArchive Manual"
author: "Neruthes"
---



# Introduction

This project offers a script to be used as an entry point for CGI or CI or manual maintenance.

The script helps maintaining a library of documents in varying formats but primarily PDF.

The script generates a static website according to metadata files in your filesystem.




# Installation

```sh
./make.sh all
./make.sh install
```




# Basic Usage

## Initialization

- Create a workspace directory and cd into it.
- Make sure `./data` subdir exists.
  - Alternatively, set env var `DATADIR_PREFIX` to supply a data path.
- Copy the default theme into `./theme` subdir from this repository.

## Advanced Notes

- Use symlink to keep multiple themes.
- Set env vars in `$PWD/.env` or `$PWD/.envlocal`.

## Put PDF Into Archive

```sh
simplearchive.sh create_doc_from_url 'https://example.com/MyDoc.pdf'
# Or...
simplearchive.sh curl 'https://example.com/MyDoc.pdf'
```




# Making Theme

This section may be expanded later.

Study the default theme contained in this repository to learn how data is supplied to the frontend.






# Extra Statements

- Do not use this software to facilitate unauthorized redistribution of copyrighted materials.
