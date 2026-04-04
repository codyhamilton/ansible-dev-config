#!/bin/sh
# lib/hooks.sh — shared utilities sourced by the dispatcher before any per-domain
#                install.sh or uninstall.sh hook script runs.
#
# DC_MODE and DC_CONFIG_DIR are set by the dispatcher before sourcing hooks.

# ── File apply (repo → live) ──────────────────────────────────────────────────

_dc_backup_file() {
  # _dc_backup_file <path>  — create a timestamped backup if file exists
  [ -f "$1" ] && cp "$1" "${1}.bak.$(date +%Y%m%d_%H%M%S)"
}

_dc_apply_file() {
  # _dc_apply_file <src> <dest> <label>
  local src="$1" dest="$2" label="$3"
  if [ ! -f "$dest" ]; then
    dc_ensure_parent "$dest"
    cp "$src" "$dest"
    dc_ok "$label (created)"
  elif dc_files_identical "$src" "$dest"; then
    dc_ok "$label"
  else
    _dc_backup_file "$dest"
    dc_merge_prompt "$src" "$dest" "$label"
  fi
}

# ── bashrc.d loader injection ─────────────────────────────────────────────────

_DC_BASHRC_MARKER="# devconf: load bashrc.d"

_dc_inject_bashrc_loader() {
  local profile
  profile="$(dc_profile_file)"
  if grep -qF "$_DC_BASHRC_MARKER" "$profile" 2>/dev/null; then
    dc_ok "bashrc.d loader (already in $profile)"
    return
  fi
  dc_ensure_parent "$profile"
  cat >> "$profile" << 'LOADER'

# devconf: load bashrc.d
for _dc_f in "${HOME}/.bashrc.d/"*.sh; do
  [ -f "$_dc_f" ] && . "$_dc_f"
done
unset _dc_f
LOADER
  dc_ok "bashrc.d loader → $profile"
}

# ── File sync (live → repo) ───────────────────────────────────────────────────

_dc_sync_file() {
  # _dc_sync_file <live> <repo_dest> <label>
  local live="$1" repo_dest="$2" label="$3"
  if [ ! -f "$live" ]; then
    dc_skip "$label (live file not found)"
    return
  fi
  if [ ! -f "$repo_dest" ]; then
    dc_sync_prompt "$live" "$repo_dest" "$label"
  elif dc_files_identical "$live" "$repo_dest"; then
    dc_ok "$label"
  else
    dc_sync_prompt "$live" "$repo_dest" "$label"
  fi
}

# ── Remove helpers ────────────────────────────────────────────────────────────

_dc_confirm() {
  # _dc_confirm <prompt>  — returns 0 if user says yes, 1 otherwise
  printf '%s [y/N] ' "$1"
  read -r _dc_yn
  case "$_dc_yn" in y|Y) return 0 ;; *) return 1 ;; esac
}

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

# ── dc_sync — unified configure/sync dispatcher for hook scripts ──────────────

# dc_sync <repo-relative-path> <live-dest> [sed-filter]
# Called from install.sh hooks. DC_MODE and DC_CONFIG_DIR are set by dispatcher.
# configure mode: _dc_apply_file repo→live
# sync mode:      _dc_sync_file live→repo (with optional sed filter on live before comparing)
dc_sync() {
  local rel="$1" live="$2" filter="${3:-}"
  local repo="$DC_CONFIG_DIR/$rel"
  case "$DC_MODE" in
    configure)
      _dc_apply_file "$repo" "$live" "$rel"
      ;;
    sync)
      if [ -n "$filter" ]; then
        local tmp="/tmp/devconf_sync_$$.tmp"
        if ! sed "$filter" "$live" > "$tmp" 2>/dev/null; then
            dc_warn "dc_sync: sed filter failed for $rel, using unfiltered"
            cp "$live" "$tmp"
        fi
        _dc_sync_file "$tmp" "$repo" "$rel"
        rm -f "$tmp"
      else
        _dc_sync_file "$live" "$repo" "$rel"
      fi
      ;;
    *)
      dc_err "dc_sync: unknown DC_MODE '${DC_MODE:-unset}'"
      return 1
      ;;
  esac
}
