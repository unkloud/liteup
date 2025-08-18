#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <src_dir> <bin|dll|static> <dest_dir>" >&2
    exit 1
}

die() {
    echo "Error: $*" >&2
    exit 1
}

abspath() {
    # If path is absolute, print as-is; otherwise prefix with PWD
    local p
    p="$1"
    case "$p" in
        /*) printf '%s\n' "$p" ;;
        *) printf '%s\n' "$PWD/$p" ;;
    esac
}

main() {
    local src type dest target script_dir build_dir

    src="${1:-}"; type="${2:-}"; dest="${3:-}"
    [[ -n "$src" && -n "$type" && -n "$dest" ]] || usage

    case "$type" in
        bin) target="cli" ;;
        dll) target="shared" ;;
        static) target="static" ;;
        *) die "Invalid build type '$type'. Expected one of: bin, dll, static" ;;
    esac

    src="$(abspath "$src")"
    dest="$(abspath "$dest")"

    [[ -d "$src" ]] || die "Source dir not found: $src"
    [[ "$dest" != "/" ]] || die "Destination cannot be the root directory '/'"
    mkdir -p "$dest" || die "Cannot create destination dir: $dest"

    script_dir="$(cd "$(dirname "$0")" && pwd)"
    build_dir="$dest/.build"
    mkdir -p "$build_dir" || die "Cannot create build dir: $build_dir"

    command -v make >/dev/null 2>&1 || die "'make' not found"

    MAKEFLAGS= make -C "$script_dir" \
        "$target" \
        SRC_DIR="$src" \
        BUILD_DIR="$build_dir" \
        BIN_DIR="$dest" \
        LIB_DIR="$dest"
}

main "$@"
