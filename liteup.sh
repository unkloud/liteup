#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC2155
readonly TMP_DIR="$(mktemp -d)"
readonly VER_FILE=".sqlite_ver"
readonly DEFAULT_DEST="src"

trap 'rm -rf "$TMP_DIR"' EXIT

declare -Ar SQLITE_VERSIONS=(
    ["3.5.4"]="3500400"
    ["3.5.3"]="3500300"
    ["3.5.2"]="3500200"
    ["3.5.1"]="3500100"
    ["3.5.0"]="3500000"
    ["3.49.2"]="3490200"
    ["3.49.1"]="3490100"
)

declare -Ar SQLITE_YEARS=(
    ["3.5.4"]="2025"
    ["3.5.3"]="2025"
    ["3.5.2"]="2025"
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

check_existing_version() {
    local version="$1"
    local dest_dir="$2"
    local ver_file="$dest_dir/$VER_FILE"

    # Return early if no version file exists
    [[ -f "$ver_file" ]] || return 0

    # Check version match
    local existing_version
    existing_version="$(head -n1 "$ver_file" 2>/dev/null || echo "")"
    [[ "$existing_version" == "$version" ]] || return 0

    # Check if SQLite files exist
    if ls "$dest_dir"/*.c "$dest_dir"/*.h >/dev/null 2>&1; then
        exit 0
    fi
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
    echo "$version" > "$extract/$VER_FILE"
    echo "$extract"
}

validate_destination() {
    local dest="$1" abs=""
    [[ -n "$dest" ]] || die "Destination must not be empty"
    [[ "$dest" != "." && "$dest" != "/" ]] || die "Invalid destination: $dest"
    [[ "$dest" != /* ]] || die "Absolute paths are not allowed: $dest"
    [[ "$dest" != *..* ]] || die "Parent directory references are not allowed in destination: $dest"
    if [[ -d "$dest" ]]; then
        abs="$(cd "$dest" && pwd)"
        [[ "$abs" != "$PWD" ]] || die "Refusing to operate on repository root"
    fi
}

clean_destination() {
    local dest="$1"
    [[ -d "$dest" ]] || return 0
    find "$dest" -maxdepth 1 \( -name "*.c" -o -name "*.h" -o -name "$VER_FILE" \) -delete
}

install_files() {
    local src_dir="$1"
    local dest_dir="$2"
    mkdir -p "$dest_dir"
    clean_destination "$dest_dir"
    install -m 644 "$src_dir"/*.{c,h} "$dest_dir"/ 2>/dev/null ||
        die "No SQLite files found or install failed"
    install -m 644 "$src_dir/$VER_FILE" "$dest_dir"/ ||
        die "Failed to install version file"
}

version="${1:-}"
dest="${2:-$DEFAULT_DEST}"
[[ -n "$version" ]] || {
    echo "Usage: $0 <version> [dir]" >&2
    display_supported_versions
    exit 1
}
validate_destination "$dest"
check_existing_version "$version" "$dest"
src_dir="$(download_sqlite "$version")"
install_files "$src_dir" "$dest"
