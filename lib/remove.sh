#!/bin/sh
# lib/remove.sh — dc_remove_* functions for uninstalling devconf configs

# ── Helpers ───────────────────────────────────────────────────────────────────

_dc_rm_file() {
  # _dc_rm_file <path> <label>
  if [ -f "$1" ]; then
    rm -f "$1"
    dc_ok "$2 (removed)"
  else
    dc_skip "$2 (not found)"
  fi
}

_dc_rm_dir() {
  # _dc_rm_dir <path> <label>
  if [ -d "$1" ]; then
    rm -rf "$1"
    dc_ok "$2 (removed)"
  else
    dc_skip "$2 (not found)"
  fi
}

_dc_confirm() {
  # _dc_confirm <prompt>  — returns 0 if user says yes, 1 otherwise
  printf '%s [y/N] ' "$1"
  read -r _dc_yn
  case "$_dc_yn" in y|Y) return 0 ;; *) return 1 ;; esac
}

# ── Bash ──────────────────────────────────────────────────────────────────────

dc_remove_bash() {
  dc_bold "Removing bash config..."
  _dc_rm_file "${HOME}/.bashrc.d/alias.sh"    "bash/alias.sh"
  _dc_rm_file "${HOME}/.bashrc.d/defaults.sh" "bash/defaults.sh"
  dc_detect_os
  local profile
  profile="$(dc_profile_file)"
  if grep -qF "# devconf: load bashrc.d" "$profile" 2>/dev/null; then
    sed '/^# devconf: load bashrc\.d/,/^unset _dc_f/d' "$profile" > "${profile}.tmp" \
      && mv "${profile}.tmp" "$profile"
    dc_ok "bashrc.d loader (removed from $profile)"
  else
    dc_skip "bashrc.d loader (not found in $profile)"
  fi
}

# ── Git ───────────────────────────────────────────────────────────────────────

dc_remove_git() {
  dc_bold "Removing git config..."
  _dc_rm_file "${HOME}/.git-prompt-colors.sh"    "git/git-prompt-colors.sh"
  _dc_rm_file "${HOME}/.bashrc.d/gitprompt.sh"   "git/gitprompt.sh"
  _dc_rm_file "${HOME}/.bashrc.d/gitcomplete.sh" "git/gitcomplete.sh"
  _dc_rm_dir  "${HOME}/.bashrc.d/git-prompt"     "git/bash-git-prompt"
}

# ── Vim ───────────────────────────────────────────────────────────────────────

dc_remove_vim() {
  dc_bold "Removing vim config..."
  if command -v nvim > /dev/null 2>&1; then
    if _dc_confirm "Remove ${HOME}/.config/nvim/init.vim and ${HOME}/.config/nvim/?"; then
      _dc_rm_file "${HOME}/.config/nvim/init.vim" "nvim/init.vim"
      _dc_rm_dir  "${HOME}/.config/nvim"          "nvim prefix dir"
    else
      dc_skip "nvim (kept)"
    fi
  fi
  if command -v vim > /dev/null 2>&1; then
    if _dc_confirm "Remove ${HOME}/.vimrc and ${HOME}/.vim/?"; then
      _dc_rm_file "${HOME}/.vimrc" "vimrc"
      _dc_rm_dir  "${HOME}/.vim"   "vim prefix dir"
    else
      dc_skip "vim (kept)"
    fi
  fi
}

# ── Tmux ──────────────────────────────────────────────────────────────────────

dc_remove_tmux() {
  dc_bold "Removing tmux config..."
  _dc_rm_file "${HOME}/.tmux.conf" "tmux/tmux.conf"
  if _dc_confirm "Remove tpm plugin manager (${HOME}/.tmux/plugins/tpm)?"; then
    _dc_rm_dir "${HOME}/.tmux/plugins/tpm" "tpm"
  else
    dc_skip "tpm (kept)"
  fi
}

# ── Cursor ────────────────────────────────────────────────────────────────────

dc_remove_cursor() {
  dc_bold "Removing Cursor config..."
  _dc_rm_file "${HOME}/.cursor/mcp.json" "cursor/mcp.json"
}

# ── Claude ────────────────────────────────────────────────────────────────────

dc_remove_claude() {
  dc_bold "Removing Claude config..."
  _dc_rm_file "${HOME}/.claude/settings.json" "claude/settings.json"
  # Never remove ~/.claude/CLAUDE.md — it's user-specific
  dc_skip "claude/CLAUDE.md (user-specific; not removed)"
}
