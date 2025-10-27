#!/bin/bash

set -euo pipefail

REPO_OWNER="n0b0dyCN"
REPO_NAME="ai-utils"
BRANCH="master"
TAR_URL="https://codeload.github.com/${REPO_OWNER}/${REPO_NAME}/tar.gz/refs/heads/${BRANCH}"

print_usage() {
  cat <<EOF
Usage:
  apply.sh [--project|--home] [--prefix PATH]

Options:
  --project, -p    Install into current project's .cursor directory (./.cursor)
  --home           Install into user's home .cursor directory (~/.cursor) [default]
  --prefix PATH    Install into PATH/.cursor (overrides --project/--home)
  -h, --help       Show this help message

Examples:
  # Install to home (works with curl | bash)
  curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/refs/heads/${BRANCH}/apply.sh | bash

  # Install to current project (note the "--" after -s)
  curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/refs/heads/${BRANCH}/apply.sh | bash -s -- --project

  # Install to a custom prefix
  curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/refs/heads/${BRANCH}/apply.sh | bash -s -- --prefix /opt/tools
EOF
}

INSTALL_MODE="home"
TARGET_PREFIX=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project|-p)
      INSTALL_MODE="project"
      shift
      ;;
    --home)
      INSTALL_MODE="home"
      shift
      ;;
    --prefix)
      if [[ $# -lt 2 ]]; then
        echo "Error: --prefix requires a PATH argument" >&2
        exit 1
      fi
      TARGET_PREFIX="$2"
      shift 2
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      print_usage
      exit 1
      ;;
  esac
done

if [[ -n "$TARGET_PREFIX" ]]; then
  TARGET_DIR="${TARGET_PREFIX%/}/.cursor"
else
  if [[ "$INSTALL_MODE" == "project" ]]; then
    TARGET_DIR="${PWD}/.cursor"
  else
    TARGET_DIR="${HOME}/.cursor"
  fi
fi

mkdir -p "${TARGET_DIR}/rules" "${TARGET_DIR}/commands"

resolve_script_dir() {
  # Try to resolve the directory where this script resides, when available
  local src="${BASH_SOURCE[0]:-}"
  if [[ -n "$src" && "$src" != "bash" && -e "$src" ]]; then
    (cd "$(dirname "$src")" >/dev/null 2>&1 && pwd -P)
    return 0
  fi
  echo ""
}

copy_from_source_dir() {
  local src_dir="$1"
  if [[ ! -d "$src_dir/rules" || ! -d "$src_dir/commands" ]]; then
    echo "Source directory does not contain 'rules' and 'commands': $src_dir" >&2
    exit 1
  fi
  cp -a "$src_dir/rules/." "${TARGET_DIR}/rules/"
  cp -a "$src_dir/commands/." "${TARGET_DIR}/commands/"
}

download_and_extract() {
  local td="$1"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$TAR_URL" | tar -xz -C "$td"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$TAR_URL" | tar -xz -C "$td"
  else
    echo "Error: Neither curl nor wget is available to download the repository." >&2
    exit 1
  fi
}

main() {
  local script_dir
  script_dir="$(resolve_script_dir)"

  # If running from a local checkout, copy directly from the repo next to the script
  if [[ -n "$script_dir" && -d "$script_dir/rules" && -d "$script_dir/commands" ]]; then
    copy_from_source_dir "$script_dir"
  # If current directory contains the folders (e.g., running "./apply.sh" from repo root), use it
  elif [[ -d "./rules" && -d "./commands" ]]; then
    copy_from_source_dir "$PWD"
  else
    # Otherwise, fetch from GitHub tarball
    local tmpdir
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' EXIT
    download_and_extract "$tmpdir"
    local extracted
    extracted="$(find "$tmpdir" -maxdepth 1 -mindepth 1 -type d -name "${REPO_NAME}-*" | head -n 1)"
    if [[ -z "$extracted" ]]; then
      echo "Error: Failed to extract repository contents." >&2
      exit 1
    fi
    copy_from_source_dir "$extracted"
  fi

  echo "Installed ${REPO_NAME} rules and commands into: ${TARGET_DIR}"
  echo
  echo "Next steps:"
  if [[ "$INSTALL_MODE" == "project" || -n "$TARGET_PREFIX" ]]; then
    echo "- Commit the '.cursor' directory to your project if desired."
  else
    echo "- You're ready to use the commands globally from Cursor."
  fi
}

main "$@"