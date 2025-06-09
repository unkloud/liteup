#!/usr/bin/env bash

set -euo pipefail

readonly TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

declare -Ar SQLITE_VERSIONS=(
    ["3.5.1"]="3500100"
    ["3.5.0"]="3500000"
    ["3.49.2"]="3490200"
    ["3.49.1"]="3490100"
)

declare -Ar SQLITE_YEARS=(
    ["3.5.1"]="2025"
    ["3.5.0"]="2025"
    ["3.49.2"]="2025"
    ["3.49.1"]="2025"
)

display_supported_versions() {
    echo "Supported SQLite versions:" >&2
    printf '  - %s\n' "${!SQLITE_VERSIONS[@]}" >&2
}

die() {
    echo "Error: $*" >&2
    [[ $# -gt 1 ]] && display_supported_versions
    exit 1
}

download_sqlite() {
    local version="$1"
    local num_ver="${SQLITE_VERSIONS[$version]:-}"
    local year="${SQLITE_YEARS[$version]:-}"
    [[ -n "$num_ver" ]] || die "Unsupported version '$version'" show_versions
    local url="https://sqlite.org/${year}/sqlite-amalgamation-${num_ver}.zip"
    local zip="$TMP_DIR/sqlite.zip"
    local extract="$TMP_DIR/extracted"
    { curl -sSLf "$url" || wget -qO- "$url"; } > "$zip" 2>/dev/null ||
        die "Download failed. Install curl or wget."
    mkdir -p "$extract"
    unzip -jq "$zip" -d "$extract" || die "Extract failed"
    echo "$extract"
}

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <version> [dir]" >&2
    display_supported_versions
    exit 1
fi

dest="${2:-src}"
[[ "$dest" != *..* && "$dest" != /* ]] || die "Invalid destination"

src_dir="$(download_sqlite "$1")"
mkdir -p "$dest"

# Safe cleanup: only remove SQLite files
if [[ -d "$dest" ]]; then
    find "$dest" -maxdepth 1 -name "*.c" -o -name "*.h" | xargs -r rm -f
fi

install -m 644 "$src_dir"/*.{c,h} "$dest"/ 2>/dev/null ||
    die "No SQLite files found or install failed"
