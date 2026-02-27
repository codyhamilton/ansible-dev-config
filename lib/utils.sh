#!/bin/sh
# lib/utils.sh — output helpers, OS detection, dir/file utils, fetch

# ── Output helpers ────────────────────────────────────────────────────────────

dc_green()  { printf '\033[32m%s\033[0m\n' "$*"; }
dc_red()    { printf '\033[31m%s\033[0m\n' "$*"; }
dc_yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
dc_bold()   { printf '\033[1m%s\033[0m\n'  "$*"; }
dc_info()   { printf '  %s\n' "$*"; }

dc_ok()   { printf '  \033[32m[ok]\033[0m  %s\n' "$*"; }
dc_skip() { printf '  \033[33m[skip]\033[0m %s\n' "$*"; }
dc_warn() { printf '  \033[33m[warn]\033[0m %s\n' "$*"; }
dc_err()  { printf '  \033[31m[err]\033[0m  %s\n' "$*" >&2; }

# ── OS Detection ──────────────────────────────────────────────────────────────

DC_OS=""

dc_detect_os() {
  if [ "$(uname -s)" = "Darwin" ]; then
    DC_OS="Darwin"
  elif [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    case "$ID_LIKE $ID" in
      *debian*|*ubuntu*) DC_OS="Debian" ;;
      *rhel*|*fedora*|*centos*) DC_OS="RedHat" ;;
      *) DC_OS="Unknown" ;;
    esac
  else
    DC_OS="Unknown"
  fi
  export DC_OS
}

# ── Directory / file utilities ────────────────────────────────────────────────

dc_ensure_dir() {
  # dc_ensure_dir <path>  — create directory if it doesn't exist
  [ -d "$1" ] || mkdir -p "$1"
}

dc_ensure_parent() {
  # dc_ensure_parent <file>  — ensure parent directory exists
  dc_ensure_dir "$(dirname "$1")"
}

# ── Command requirement ───────────────────────────────────────────────────────

dc_require_cmd() {
  # dc_require_cmd <cmd> [message]
  if ! command -v "$1" > /dev/null 2>&1; then
    dc_err "${2:-Required command '$1' not found. Please install it and try again.}"
    exit 1
  fi
}

# ── Fetch / download ──────────────────────────────────────────────────────────

dc_fetch() {
  # dc_fetch <url> <dest>  — download url to dest using curl or wget
  if command -v curl > /dev/null 2>&1; then
    curl -fsSL "$1" -o "$2"
  elif command -v wget > /dev/null 2>&1; then
    wget -qO "$2" "$1"
  else
    dc_err "Neither curl nor wget found. Cannot download $1"
    return 1
  fi
}

# ── Bashrc profile path ───────────────────────────────────────────────────────

dc_profile_file() {
  # Returns the appropriate shell profile file for the current OS
  if [ "$DC_OS" = "Darwin" ]; then
    echo "${HOME}/.bash_profile"
  else
    echo "${HOME}/.bashrc"
  fi
}
