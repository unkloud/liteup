#!/usr/bin/env bash

set -euo pipefail

TMP_DIR=$(mktemp -d)
# trap 'rm -rf "$TMP_DIR"' EXIT

declare -A SQLITE_VERSIONS=(
    ["3.5.0"]="3500000"
    ["3.49.2"]="3490200"
    ["3.49.1"]="3490100"
)

declare -A SQLITE_YEARS=(
    ["3.5.0"]="2025"
    ["3.49.2"]="2025"
    ["3.49.1"]="2025"
)

display_supported_versions() {
    echo "Supported SQLite versions:" >&2
    for ver in "${!SQLITE_VERSIONS[@]}"; do
        echo "  - $ver" >&2
    done
}

download_and_extract() {
    local version=$1
    local numeric_version=${SQLITE_VERSIONS[$version]}
    local year=${SQLITE_YEARS[$version]}

    if [[ -z "$numeric_version" ]]; then
        echo "Error: Version '$version' is not supported." >&2
        display_supported_versions >&2
        exit 1
    fi

    local uri="https://sqlite.org/${year}/sqlite-amalgamation-${numeric_version}.zip"
    local archive_path="$TMP_DIR/sqlite.zip"
    local extract_dir="$TMP_DIR/extracted"
    if command -v curl >/dev/null; then
        curl -sSLo "$archive_path" "$uri"
    elif command -v wget >/dev/null; then
        wget -qO "$archive_path" "$uri"
    else
        echo "Error: Neither curl nor wget found. Please install one to proceed." >&2
        exit 1
    fi
    unzip -jo "$archive_path" -d "$extract_dir" >/dev/null
    echo "$extract_dir"
}

if [[ "$#" -lt 1 ]]; then
    echo "Usage: $0 <version>" >&2
    display_supported_versions >&2
    exit 1
fi

VERSION_TO_DOWNLOAD="$1"
extracted_path=$(download_and_extract "$VERSION_TO_DOWNLOAD")

mkdir -p src
rm -rf src/*
install -m 644 "$extracted_path"/*.c "$extracted_path"/*.h src/
