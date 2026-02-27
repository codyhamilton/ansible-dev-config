#!/bin/sh
# lib/sync.sh — all dc_sync_* functions (live → repo) + git alias sync

# Tracks which repo files were updated
_DC_SYNC_CHANGED=""

_dc_sync_changed_add() {
  _DC_SYNC_CHANGED="${_DC_SYNC_CHANGED} $1"
}

# ── Generic file sync ─────────────────────────────────────────────────────────

_dc_sync_file() {
  # _dc_sync_file <live> <repo_dest> <label>
  local live="$1" repo_dest="$2" label="$3"
  if [ ! -f "$live" ]; then
    dc_skip "$label (live file not found)"
    return
  fi
  if [ ! -f "$repo_dest" ]; then
    dc_sync_prompt "$live" "$repo_dest" "$label" && _dc_sync_changed_add "$repo_dest"
  elif dc_files_identical "$live" "$repo_dest"; then
    dc_ok "$label"
  else
    dc_sync_prompt "$live" "$repo_dest" "$label" && _dc_sync_changed_add "$repo_dest"
  fi
}

# ── Bash ──────────────────────────────────────────────────────────────────────

dc_sync_bash() {
  dc_bold "Syncing bash configs..."
  _dc_sync_file "${HOME}/.bashrc.d/alias.sh"    "${DEVCONF_REPO}/configs/bash/alias.sh"    "bash/alias.sh"
  _dc_sync_file "${HOME}/.bashrc.d/defaults.sh" "${DEVCONF_REPO}/configs/bash/defaults.sh" "bash/defaults.sh"
}

# ── Git files ─────────────────────────────────────────────────────────────────

dc_sync_git_files() {
  dc_bold "Syncing git files..."
  _dc_sync_file "${HOME}/.git-prompt-colors.sh"    "${DEVCONF_REPO}/configs/git/git-prompt-colors.sh" "git/git-prompt-colors.sh"
  _dc_sync_file "${HOME}/.bashrc.d/gitprompt.sh"   "${DEVCONF_REPO}/configs/git/gitprompt.sh"         "git/gitprompt.sh"
  _dc_sync_file "${HOME}/.bashrc.d/gitcomplete.sh" "${DEVCONF_REPO}/configs/git/gitcomplete.sh"       "git/gitcomplete.sh"
}

# ── Git aliases ───────────────────────────────────────────────────────────────

dc_sync_git_aliases() {
  dc_bold "Syncing git aliases..."
  local alias_file="${DEVCONF_REPO}/configs/git/gitconfig-aliases"
  local live_aliases tmp_live changed=0

  # Dump current global aliases
  tmp_live="/tmp/devconf_aliases.$$"
  git config --global --list 2>/dev/null \
    | grep '^alias\.' \
    | sed 's/^alias\.//' \
    | sort > "$tmp_live"

  # Build sorted repo version for comparison
  local tmp_repo="/tmp/devconf_aliases_repo.$$"
  sort "$alias_file" > "$tmp_repo"

  if ! diff -q "$tmp_repo" "$tmp_live" > /dev/null 2>&1; then
    dc_bold "─── git aliases ───────────────────────────────────"
    dc_show_diff "$tmp_repo" "$tmp_live"
    printf '\n  [a]dd live aliases to repo  [k]eep repo  [s]kip  > '
    read -r _dc_choice
    case "$_dc_choice" in
      a|A)
        # Write live aliases (sorted) to repo
        git config --global --list 2>/dev/null \
          | grep '^alias\.' \
          | sed 's/^alias\.//' \
          | sort > "$alias_file"
        dc_ok "git aliases → repo"
        _dc_sync_changed_add "$alias_file"
        changed=1
        ;;
      k|K)
        dc_skip "git aliases (keeping repo version)"
        ;;
      s|S)
        dc_skip "git aliases (skipped)"
        ;;
    esac
  else
    dc_ok "git aliases"
  fi
  rm -f "$tmp_live" "$tmp_repo"
}

# ── Vim ───────────────────────────────────────────────────────────────────────

dc_sync_vim() {
  dc_bold "Syncing vim config..."
  local vim_prefix vim_init
  if command -v nvim > /dev/null 2>&1; then
    vim_prefix="${HOME}/.config/nvim"
    vim_init="${vim_prefix}/init.vim"
  else
    vim_prefix="${HOME}/.vim"
    vim_init="${HOME}/.vimrc"
  fi

  if [ ! -f "$vim_init" ]; then
    dc_skip "vimrc (not found at $vim_init)"
    return
  fi

  local tmp_repo="/tmp/devconf_vimrc_repo.$$"
  # Reverse-substitute: replace actual prefix back to token
  sed "s|${vim_prefix}|__VIM_PREFIX__|g" "$vim_init" > "$tmp_repo"

  if dc_files_identical "$tmp_repo" "${DEVCONF_REPO}/configs/vim/vimrc"; then
    dc_ok "vimrc"
  else
    dc_sync_prompt "$tmp_repo" "${DEVCONF_REPO}/configs/vim/vimrc" "vimrc" \
      && _dc_sync_changed_add "${DEVCONF_REPO}/configs/vim/vimrc"
  fi
  rm -f "$tmp_repo"
}

# ── Cursor ────────────────────────────────────────────────────────────────────

dc_sync_cursor() {
  dc_bold "Syncing Cursor configs..."
  local cursor_dir="${HOME}/.cursor"
  if [ ! -d "$cursor_dir" ]; then
    dc_skip "Cursor (not installed)"
    return
  fi

  # For argv.json: strip crash-reporter-id before comparing
  local live_argv="${cursor_dir}/argv.json"
  local repo_argv="${DEVCONF_REPO}/configs/cursor/argv.json"
  if [ -f "$live_argv" ]; then
    local tmp_argv="/tmp/devconf_argv.$$"
    # Remove the crash-reporter-id line before syncing
    grep -v '"crash-reporter-id"' "$live_argv" > "$tmp_argv"
    if dc_files_identical "$tmp_argv" "$repo_argv"; then
      dc_ok "cursor/argv.json"
    else
      dc_sync_prompt "$tmp_argv" "$repo_argv" "cursor/argv.json" \
        && _dc_sync_changed_add "$repo_argv"
    fi
    rm -f "$tmp_argv"
  fi

  _dc_sync_file "${cursor_dir}/mcp.json" "$repo_argv/../mcp.json" "cursor/mcp.json"
}

# ── Claude ────────────────────────────────────────────────────────────────────

dc_sync_claude() {
  dc_bold "Syncing Claude configs..."
  local claude_dir="${HOME}/.claude"
  _dc_sync_file "${claude_dir}/settings.json" "${DEVCONF_REPO}/configs/claude/settings.json" "claude/settings.json"
  # Don't sync CLAUDE.md back — it's user-specific per project
}

# ── Commit helper ─────────────────────────────────────────────────────────────

dc_sync_commit() {
  if [ -z "$_DC_SYNC_CHANGED" ]; then
    dc_ok "Nothing changed; no commit needed."
    return
  fi

  dc_bold "Changed files:"
  for f in $_DC_SYNC_CHANGED; do
    dc_info "  $f"
  done

  # Stage changed files
  # shellcheck disable=SC2086
  git -C "$DEVCONF_REPO" add $_DC_SYNC_CHANGED

  # Prompt for commit message
  local default_msg="sync: update configs from $(hostname)"
  printf '\nCommit message [%s]: ' "$default_msg"
  read -r _dc_msg
  [ -z "$_dc_msg" ] && _dc_msg="$default_msg"

  git -C "$DEVCONF_REPO" commit -m "$_dc_msg"

  # Ask to push
  printf '\nPush to remote? [y/N] '
  read -r _dc_push
  case "$_dc_push" in
    y|Y)
      git -C "$DEVCONF_REPO" push
      dc_ok "Pushed."
      ;;
    *)
      dc_info "Not pushed. Run: git -C \"$DEVCONF_REPO\" push"
      ;;
  esac
}
