#!/bin/sh
# install.sh — bootstrap devconf
# Usage: curl -fsSL https://raw.githubusercontent.com/codyhamilton/ansible-dev-config/master/install.sh | sh

set -e

DEVCONF_REPO_URL="https://github.com/codyhamilton/ansible-dev-config.git"
DEVCONF_INSTALL_DIR="${HOME}/.local/opt/devconf"
DEVCONF_BIN_DIR="${HOME}/.local/bin"
DEVCONF_BIN="${DEVCONF_BIN_DIR}/devconf"
_DC_PATH_MARKER="# devconf: PATH"

# ── Helpers ───────────────────────────────────────────────────────────────────

_info()  { printf '  %s\n' "$*"; }
_ok()    { printf '  \033[32m[ok]\033[0m  %s\n' "$*"; }
_err()   { printf '  \033[31m[err]\033[0m %s\n' "$*" >&2; }
_bold()  { printf '\033[1m%s\033[0m\n' "$*"; }

# ── Require git ───────────────────────────────────────────────────────────────

if ! command -v git > /dev/null 2>&1; then
  _err "git is required. Install it and re-run this script."
  exit 1
fi

# ── Clone or update repo ──────────────────────────────────────────────────────

_bold "Installing devconf..."
echo ""

if [ -d "${DEVCONF_INSTALL_DIR}/.git" ]; then
  _info "Updating existing install at $DEVCONF_INSTALL_DIR"
  git -C "$DEVCONF_INSTALL_DIR" pull --rebase
  _ok "Repo updated"
else
  _info "Cloning to $DEVCONF_INSTALL_DIR"
  mkdir -p "$(dirname "$DEVCONF_INSTALL_DIR")"
  git clone --depth=1 "$DEVCONF_REPO_URL" "$DEVCONF_INSTALL_DIR"
  _ok "Repo cloned"
fi

# ── Create symlink ────────────────────────────────────────────────────────────

mkdir -p "$DEVCONF_BIN_DIR"
ln -sf "${DEVCONF_INSTALL_DIR}/bin/devconf" "$DEVCONF_BIN"
chmod +x "${DEVCONF_INSTALL_DIR}/bin/devconf"
_ok "Symlink: $DEVCONF_BIN → ${DEVCONF_INSTALL_DIR}/bin/devconf"

# ── Add ~/.local/bin to PATH (idempotent, marker-guarded) ─────────────────────

if [ "$(uname -s)" = "Darwin" ]; then
  _profile="${HOME}/.bash_profile"
else
  _profile="${HOME}/.bashrc"
fi

if ! grep -qF "$_DC_PATH_MARKER" "$_profile" 2>/dev/null; then
  mkdir -p "$(dirname "$_profile")"
  cat >> "$_profile" << 'PATHBLOCK'

# devconf: PATH
export PATH="${HOME}/.local/bin:${PATH}"
PATHBLOCK
  _ok "Added ~/.local/bin to PATH in $_profile"
else
  _ok "~/.local/bin already in PATH ($_profile)"
fi

# ── Run devconf configure ─────────────────────────────────────────────────────

echo ""
_bold "Running: devconf configure"
echo ""

# Reopen /dev/tty so interactive prompts work when piped through sh
if [ -t 0 ]; then
  "$DEVCONF_BIN" configure
else
  "$DEVCONF_BIN" configure < /dev/tty
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
_bold "Install complete!"
_info "Run the following to activate in your current shell:"
echo ""
printf '    source %s\n' "$_profile"
echo ""
