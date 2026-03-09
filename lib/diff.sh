#!/bin/sh
# lib/diff.sh — diff engine, merge/sync interactive prompts

# ── Colored diff display ──────────────────────────────────────────────────────

dc_show_diff() {
  # dc_show_diff <file_a> <file_b>
  # Prints a colored unified diff of file_a vs file_b, ignoring whitespace-only changes
  diff -u -b "$1" "$2" | while IFS= read -r line; do
    case "$line" in
      ---*|+++*) printf '\033[1m%s\033[0m\n'  "$line" ;;
      +*)        printf '\033[32m%s\033[0m\n' "$line" ;;
      -*)        printf '\033[31m%s\033[0m\n' "$line" ;;
      *)         printf '%s\n'                "$line" ;;
    esac
  done
}

dc_files_identical() {
  # dc_files_identical <a> <b>  — returns 0 if identical (ignoring whitespace), 1 if different
  diff -bq "$1" "$2" > /dev/null 2>&1
}

# ── Hunk-by-hunk split apply ──────────────────────────────────────────────────

_dc_split_apply() {
  # _dc_split_apply <src> <dest> <label> [repo_file] [filter_sed]
  # Shows each diff hunk individually; user picks per-hunk action:
  #   [u]pdate  — apply hunk repo→live
  #   [s]kip    — leave this hunk unchanged
  #   [S]ync    — apply hunk live→repo (reverse) and stage
  #   [q]uit    — stop processing remaining hunks
  local src="$1" dest="$2" label="$3"
  local repo_file="${4:-$src}"
  local filter_sed="${5:-}"
  local pid="$$"
  local tmp_work="/tmp/devconf_work.${pid}"
  local tmp_repo_work="/tmp/devconf_repo_work.${pid}"
  local tmp_combined="/tmp/devconf_combined.${pid}"
  local tmp_rcombined="/tmp/devconf_rcombined.${pid}"
  local applied_any=0 synced_any=0 first_accepted=1 first_synced=1 hunk_num=0 total_hunks=0

  cp "$dest" "$tmp_work"
  cp "$repo_file" "$tmp_repo_work"

  # Extract all hunks into individual temp files
  diff -u -b "$dest" "$src" 2>/dev/null | awk -v pid="$pid" '
    BEGIN { n=0; hdr1=""; hdr2=""; buf="" }
    /^--- /  { hdr1=$0; next }
    /^\+\+\+ / { hdr2=$0; next }
    /^@@ / {
      if (buf != "") {
        f = "/tmp/devconf_h_" n "_" pid
        print hdr1 > f; print hdr2 > f
        printf "%s", buf > f
        close(f); n++
      }
      buf = $0 "\n"; next
    }
    { buf = buf $0 "\n" }
    END {
      if (buf != "") {
        f = "/tmp/devconf_h_" n "_" pid
        print hdr1 > f; print hdr2 > f
        printf "%s", buf > f
        close(f); n++
      }
      print n > ("/tmp/devconf_hcount_" pid)
    }
  ' || true

  if [ -f "/tmp/devconf_hcount_${pid}" ]; then
    total_hunks=$(cat "/tmp/devconf_hcount_${pid}")
    rm -f "/tmp/devconf_hcount_${pid}"
  fi

  if [ "$total_hunks" -eq 0 ]; then
    dc_ok "$label (no meaningful differences)"
    rm -f "$tmp_work" "$tmp_repo_work"
    return 1
  fi

  : > "$tmp_combined"
  : > "$tmp_rcombined"

  while [ "$hunk_num" -lt "$total_hunks" ]; do
    local hunk_file="/tmp/devconf_h_${hunk_num}_${pid}"
    local quit_split=0
    dc_bold "─── $label: change $((hunk_num+1))/$total_hunks ───"
    tail -n +3 "$hunk_file" | while IFS= read -r line; do
      case "$line" in
        +*) printf '\033[32m%s\033[0m\n' "$line" ;;
        -*) printf '\033[31m%s\033[0m\n' "$line" ;;
        *)  printf '%s\n' "$line" ;;
      esac
    done
    printf '\n  [U]pdate  [s]kip  [S]ync to repo  [q]uit  > '
    read -r _dc_hchoice
    case "$_dc_hchoice" in
      u|U|"")
        if [ "$first_accepted" = "1" ]; then
          cat "$hunk_file" >> "$tmp_combined"
          first_accepted=0
        else
          tail -n +3 "$hunk_file" >> "$tmp_combined"
        fi
        applied_any=1
        ;;
      S)
        if [ "$first_synced" = "1" ]; then
          cat "$hunk_file" >> "$tmp_rcombined"
          first_synced=0
        else
          tail -n +3 "$hunk_file" >> "$tmp_rcombined"
        fi
        synced_any=1
        ;;
      q|Q)
        quit_split=1
        ;;
      # s or any other key: skip
    esac
    rm -f "$hunk_file"
    hunk_num=$((hunk_num+1))
    [ "$quit_split" = "1" ] && break
  done

  # Remove any remaining hunk files (if quit early)
  while [ "$hunk_num" -lt "$total_hunks" ]; do
    rm -f "/tmp/devconf_h_${hunk_num}_${pid}"
    hunk_num=$((hunk_num+1))
  done

  # Apply forward hunks (repo → live)
  if [ "$applied_any" = "1" ]; then
    patch -u "$tmp_work" < "$tmp_combined" > /dev/null 2>&1 \
      && cp "$tmp_work" "$dest" \
      && dc_ok "$label (partial update applied)" \
      || dc_warn "  Could not apply hunks cleanly; no changes made to live"
  fi

  # Apply reverse hunks (live → repo) and stage
  if [ "$synced_any" = "1" ]; then
    if patch -R "$tmp_repo_work" < "$tmp_rcombined" > /dev/null 2>&1; then
      if [ -n "$filter_sed" ]; then
        sed "$filter_sed" "$tmp_repo_work" > "$repo_file"
      else
        cp "$tmp_repo_work" "$repo_file"
      fi
      git -C "$DEVCONF_REPO" add "$repo_file"
      dc_ok "$label (hunk(s) synced to repo; staged)"
    else
      dc_warn "  Could not reverse-apply hunk(s) to repo; no repo changes made"
    fi
  fi

  if [ "$applied_any" = "0" ] && [ "$synced_any" = "0" ]; then
    dc_skip "$label (no hunks applied)"
  fi

  rm -f "$tmp_work" "$tmp_repo_work" "$tmp_combined" "$tmp_rcombined"
  return "$applied_any"
}

# ── Merge prompt (repo → live) ────────────────────────────────────────────────

dc_merge_prompt() {
  # dc_merge_prompt <src> <dest> <label> [repo_file] [filter_sed]
  #   src        = repo/template version (may be a temp expanded file)
  #   dest       = live (current) version to update
  #   label      = display name
  #   repo_file  = actual repo path for [S]ync option (defaults to src)
  #   filter_sed = sed expression applied to dest before writing to repo_file
  local src="$1" dest="$2" label="$3"
  local repo_file="${4:-$1}"
  local filter_sed="${5:-}"

  while true; do
    dc_bold "─── $label ───────────────────────────────────────"
    if [ -f "$dest" ]; then
      dc_show_diff "$dest" "$src"
    else
      dc_yellow "  (destination does not exist; will create)"
    fi
    printf '\n  [k]eep ours  [U]pdate  [s]plit  [S]ync upstream  [e]dit  > '
    read -r _dc_choice
    case "$_dc_choice" in
      u|U|"")
        dc_ensure_parent "$dest"
        cp "$src" "$dest"
        dc_ok "$label (updated)"
        return 0
        ;;
      k|K)
        dc_skip "$label (keeping ours)"
        return 0
        ;;
      s)
        _dc_split_apply "$src" "$dest" "$label" "$repo_file" "$filter_sed"
        return 0
        ;;
      S)
        # Sync: push our live version to repo, commit, optional push
        if [ -n "$filter_sed" ]; then
          sed "$filter_sed" "$dest" > "$repo_file"
        else
          cp "$dest" "$repo_file"
        fi
        git -C "$DEVCONF_REPO" add "$repo_file"
        local _default_msg="sync: $label from $(hostname)"
        printf 'Commit message [%s]: ' "$_default_msg"
        read -r _dc_smsg
        [ -z "$_dc_smsg" ] && _dc_smsg="$_default_msg"
        git -C "$DEVCONF_REPO" commit -m "$_dc_smsg"
        printf 'Push to remote? [y/N] '
        read -r _dc_spush
        case "$_dc_spush" in
          y|Y) git -C "$DEVCONF_REPO" push && dc_ok "Pushed." ;;
          *) dc_info "Not pushed. Run: git -C \"$DEVCONF_REPO\" push" ;;
        esac
        dc_ok "$label (synced to repo)"
        return 0
        ;;
      e|E)
        ${VISUAL:-${EDITOR:-vim}} "$dest"
        # Re-loop to show updated diff
        ;;
      *)
        dc_warn "Unknown choice; enter k, u, s, S, or e"
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
