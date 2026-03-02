#!/bin/sh
# lib/configure.sh — all dc_configure_* functions (repo → live)

# ── Helpers ───────────────────────────────────────────────────────────────────

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

# ── Bash ──────────────────────────────────────────────────────────────────────

dc_configure_bash() {
  dc_bold "Configuring bash..."
  dc_ensure_dir "${HOME}/.bashrc.d"
  _dc_apply_file "${DEVCONF_REPO}/configs/bash/alias.sh"    "${HOME}/.bashrc.d/alias.sh"    "bash/alias.sh"
  _dc_apply_file "${DEVCONF_REPO}/configs/bash/defaults.sh" "${HOME}/.bashrc.d/defaults.sh" "bash/defaults.sh"
  _dc_inject_bashrc_loader
}

# ── Git files ─────────────────────────────────────────────────────────────────

dc_configure_git_files() {
  dc_bold "Configuring git files..."
  dc_ensure_dir "${HOME}/.bashrc.d"
  _dc_apply_file "${DEVCONF_REPO}/configs/git/git-prompt-colors.sh" "${HOME}/.git-prompt-colors.sh"         "git/git-prompt-colors.sh"
  _dc_apply_file "${DEVCONF_REPO}/configs/git/gitprompt.sh"         "${HOME}/.bashrc.d/gitprompt.sh"        "git/gitprompt.sh"
  _dc_apply_file "${DEVCONF_REPO}/configs/git/gitcomplete.sh"       "${HOME}/.bashrc.d/gitcomplete.sh"      "git/gitcomplete.sh"
}

# ── Git aliases ───────────────────────────────────────────────────────────────

dc_configure_git_aliases() {
  dc_bold "Configuring git aliases and settings..."
  git config --global push.default simple
  git config --global core.editor vim
  dc_ok "push.default=simple, core.editor=vim"

  local alias_file="${DEVCONF_REPO}/configs/git/gitconfig-aliases"
  while IFS='=' read -r name value; do
    # Skip blank lines and comments
    case "$name" in ''|\#*) continue ;; esac
    git config --global "alias.$name" "$value"
    dc_ok "alias.$name"
  done < "$alias_file"
}

# ── bash-git-prompt install ───────────────────────────────────────────────────

dc_configure_gitprompt_install() {
  local dest="${HOME}/.bashrc.d/git-prompt"
  local repo_url="https://github.com/magicmonty/bash-git-prompt.git"
  dc_bold "Configuring bash-git-prompt..."
  if [ -d "$dest/.git" ]; then
    dc_ok "bash-git-prompt (already installed at $dest)"
  else
    dc_require_cmd git
    git clone --depth=1 "$repo_url" "$dest"
    dc_ok "bash-git-prompt installed"
  fi
}

# ── Vim ───────────────────────────────────────────────────────────────────────

_dc_vim_prefix() {
  if command -v nvim > /dev/null 2>&1; then
    echo "${HOME}/.config/nvim"
  else
    echo "${HOME}/.vim"
  fi
}

_dc_vim_init() {
  local prefix
  prefix="$(_dc_vim_prefix)"
  if command -v nvim > /dev/null 2>&1; then
    echo "${prefix}/init.vim"
  else
    echo "${HOME}/.vimrc"
  fi
}

dc_configure_vim() {
  dc_bold "Configuring vim..."
  local vim_prefix vim_init tmp_vimrc
  vim_prefix="$(_dc_vim_prefix)"
  vim_init="$(_dc_vim_init)"
  tmp_vimrc="/tmp/devconf_vimrc.$$"

  dc_ensure_dir "$vim_prefix"

  # Expand __VIM_PREFIX__ token
  sed "s|__VIM_PREFIX__|${vim_prefix}|g" \
    "${DEVCONF_REPO}/configs/vim/vimrc" > "$tmp_vimrc"

  if [ ! -f "$vim_init" ]; then
    dc_ensure_parent "$vim_init"
    cp "$tmp_vimrc" "$vim_init"
    dc_ok "vimrc (created at $vim_init)"
  elif dc_files_identical "$tmp_vimrc" "$vim_init"; then
    dc_ok "vimrc"
  else
    _dc_backup_file "$vim_init"
    dc_merge_prompt "$tmp_vimrc" "$vim_init" "vimrc" \
      "${DEVCONF_REPO}/configs/vim/vimrc" \
      "s|${vim_prefix}|__VIM_PREFIX__|g"
  fi
  rm -f "$tmp_vimrc"

  # OS-specific vim file
  dc_detect_os
  local os_vim="${DEVCONF_REPO}/configs/vim/${DC_OS}.vim"
  if [ -f "$os_vim" ]; then
    _dc_apply_file "$os_vim" "${vim_prefix}/${DC_OS}.vim" "vim/${DC_OS}.vim"
    # Source it from vimrc if not already included
    if ! grep -qF "source.*${DC_OS}.vim" "$vim_init" 2>/dev/null; then
      echo "" >> "$vim_init"
      echo "source ${vim_prefix}/${DC_OS}.vim" >> "$vim_init"
      dc_ok "Added source for ${DC_OS}.vim in vimrc"
    fi
  fi
}

dc_configure_vimplug() {
  dc_bold "Configuring vim-plug..."
  local vim_prefix
  vim_prefix="$(_dc_vim_prefix)"
  local plug_path="${vim_prefix}/autoload/plug.vim"
  if [ -f "$plug_path" ]; then
    dc_ok "vim-plug (already installed)"
  else
    dc_require_cmd curl
    dc_ensure_dir "${vim_prefix}/autoload"
    curl -fsSLo "$plug_path" \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    dc_ok "vim-plug installed"
  fi
}

# ── Cursor ────────────────────────────────────────────────────────────────────

dc_configure_cursor() {
  dc_bold "Configuring Cursor..."
  local cursor_dir="${HOME}/.cursor"
  if [ ! -d "$cursor_dir" ] && ! command -v cursor > /dev/null 2>&1; then
    dc_skip "Cursor (not installed)"
    return
  fi
  dc_ensure_dir "$cursor_dir"
  _dc_apply_file "${DEVCONF_REPO}/configs/cursor/argv.json" "${cursor_dir}/argv.json" "cursor/argv.json"
  _dc_apply_file "${DEVCONF_REPO}/configs/cursor/mcp.json"  "${cursor_dir}/mcp.json"  "cursor/mcp.json"
}

# ── Claude ────────────────────────────────────────────────────────────────────

dc_configure_claude() {
  dc_bold "Configuring Claude..."
  local claude_dir="${HOME}/.claude"
  dc_ensure_dir "$claude_dir"
  _dc_apply_file "${DEVCONF_REPO}/configs/claude/settings.json" "${claude_dir}/settings.json" "claude/settings.json"
  # Only create CLAUDE.md if it doesn't exist (it's user-specific)
  if [ ! -f "${claude_dir}/CLAUDE.md" ]; then
    cp "${DEVCONF_REPO}/configs/claude/CLAUDE.md" "${claude_dir}/CLAUDE.md"
    dc_ok "claude/CLAUDE.md (created; edit to customize)"
  else
    dc_ok "claude/CLAUDE.md (exists; not overwriting)"
  fi
}

# ── Tmux ──────────────────────────────────────────────────────────────────────

dc_configure_tmux() {
  dc_bold "Configuring tmux..."
  _dc_apply_file "${DEVCONF_REPO}/configs/tmux/tmux.conf" "${HOME}/.tmux.conf" "tmux/tmux.conf"
  local tpm_dir="${HOME}/.tmux/plugins/tpm"
  if [ -d "${tpm_dir}/.git" ]; then
    dc_ok "tpm (already installed)"
  else
    dc_require_cmd git
    dc_ensure_dir "${HOME}/.tmux/plugins"
    git clone --depth=1 "https://github.com/tmux-plugins/tpm" "$tpm_dir"
    dc_ok "tpm installed at $tpm_dir"
  fi
}
