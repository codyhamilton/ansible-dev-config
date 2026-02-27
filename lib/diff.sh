#!/bin/sh
# lib/diff.sh — diff engine, merge/sync interactive prompts

# ── Colored diff display ──────────────────────────────────────────────────────

dc_show_diff() {
  # dc_show_diff <file_a> <file_b>
  # Prints a colored unified diff of file_a vs file_b
  diff -u "$1" "$2" | while IFS= read -r line; do
    case "$line" in
      ---*|+++*) printf '\033[1m%s\033[0m\n'  "$line" ;;
      +*)        printf '\033[32m%s\033[0m\n' "$line" ;;
      -*)        printf '\033[31m%s\033[0m\n' "$line" ;;
      *)         printf '%s\n'                "$line" ;;
    esac
  done
}

dc_files_identical() {
  # dc_files_identical <a> <b>  — returns 0 if identical, 1 if different
  diff -q "$1" "$2" > /dev/null 2>&1
}

# ── Merge prompt (repo → live) ────────────────────────────────────────────────

dc_merge_prompt() {
  # dc_merge_prompt <src> <dest> <label>
  # Shows diff and prompts: [a]ccept repo / [k]eep current / [e]dit in vim
  local src="$1" dest="$2" label="$3"

  while true; do
    dc_bold "─── $label ───────────────────────────────────────"
    if [ -f "$dest" ]; then
      dc_show_diff "$dest" "$src"
    else
      dc_yellow "  (destination does not exist; will create)"
    fi
    printf '\n  [a]ccept repo  [k]eep current  [e]dit in vim  > '
    read -r _dc_choice
    case "$_dc_choice" in
      a|A)
        dc_ensure_parent "$dest"
        cp "$src" "$dest"
        dc_ok "$label"
        return 0
        ;;
      k|K)
        dc_skip "$label (keeping current)"
        return 0
        ;;
      e|E)
        ${VISUAL:-${EDITOR:-vim}} "$dest"
        # Re-loop to show updated diff
        ;;
      *)
        dc_warn "Unknown choice '$_dc_choice'; enter a, k, or e"
        ;;
    esac
  done
}

# ── Sync prompt (live → repo) ─────────────────────────────────────────────────

dc_sync_prompt() {
  # dc_sync_prompt <live> <repo_dest> <label>
  # Shows diff live→repo and prompts: [a]dd to repo / [k]eep repo / [e]dit / [s]kip
  local live="$1" repo_dest="$2" label="$3"

  while true; do
    dc_bold "─── $label ───────────────────────────────────────"
    if [ -f "$repo_dest" ]; then
      dc_show_diff "$repo_dest" "$live"
    else
      dc_yellow "  (not in repo yet; will add)"
    fi
    printf '\n  [a]dd to repo  [k]eep repo  [e]dit in vim  [s]kip  > '
    read -r _dc_choice
    case "$_dc_choice" in
      a|A)
        dc_ensure_parent "$repo_dest"
        cp "$live" "$repo_dest"
        dc_ok "$label → repo"
        return 0  # signal: changed
        ;;
      k|K)
        dc_skip "$label (keeping repo version)"
        return 1  # signal: not changed
        ;;
      e|E)
        ${VISUAL:-${EDITOR:-vim}} "$live"
        ;;
      s|S)
        dc_skip "$label (skipped)"
        return 1
        ;;
      *)
        dc_warn "Unknown choice '$_dc_choice'; enter a, k, e, or s"
        ;;
    esac
  done
}
