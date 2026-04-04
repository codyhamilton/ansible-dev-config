# configs/git/install.sh — sourced by bin/devconf with DC_MODE, DC_CONFIG_DIR, DC_OS in scope

# File syncs
dc_sync git-prompt-colors.sh "$HOME/.git-prompt-colors.sh"
dc_sync gitprompt.sh         "$HOME/.bashrc.d/gitprompt.sh"
dc_sync gitcomplete.sh       "$HOME/.bashrc.d/gitcomplete.sh"

# bash-git-prompt clone (configure mode only — idempotent)
if [ "$DC_MODE" = "configure" ]; then
    _dest="${HOME}/.bashrc.d/git-prompt"
    if [ -d "$_dest/.git" ]; then
        dc_ok "bash-git-prompt (already installed)"
    else
        dc_require_cmd git
        git clone --depth=1 "https://github.com/magicmonty/bash-git-prompt.git" "$_dest"
        dc_ok "bash-git-prompt installed"
    fi
fi

# git global settings (configure mode only)
if [ "$DC_MODE" = "configure" ]; then
    git config --global push.default simple
    git config --global core.editor vim
    dc_ok "push.default=simple, core.editor=vim"
fi

# gitconfig-aliases: parse key=value → git config --global (configure) or dump live → repo (sync)
if [ "$DC_MODE" = "configure" ]; then
    _alias_file="$DC_CONFIG_DIR/gitconfig-aliases"
    while IFS='=' read -r _name _value; do
        case "$_name" in ''|\#*) continue ;; esac
        git config --global "alias.$_name" "$_value"
        dc_ok "alias.$_name"
    done < "$_alias_file"
elif [ "$DC_MODE" = "sync" ]; then
    # Dump live aliases and compare to repo
    _alias_file="$DC_CONFIG_DIR/gitconfig-aliases"
    _tmp_live="/tmp/devconf_aliases_live.$$"
    _tmp_repo="/tmp/devconf_aliases_repo.$$"
    git config --global --list 2>/dev/null | grep '^alias\.' | sed 's/^alias\.//' | sort > "$_tmp_live"
    sort "$_alias_file" > "$_tmp_repo"
    if ! diff -q "$_tmp_repo" "$_tmp_live" > /dev/null 2>&1; then
        dc_bold "─── git aliases ───────────────────────────────────"
        dc_show_diff "$_tmp_repo" "$_tmp_live"
        printf '\n  [a]dd live aliases to repo  [k]eep repo  [s]kip  > '
        read -r _dc_choice
        case "$_dc_choice" in
            a|A) git config --global --list 2>/dev/null | grep '^alias\.' | sed 's/^alias\.//' | sort > "$_alias_file"; dc_ok "git aliases → repo" ;;
            k|K) dc_skip "git aliases (keeping repo version)" ;;
            s|S) dc_skip "git aliases (skipped)" ;;
        esac
    else
        dc_ok "git aliases"
    fi
    rm -f "$_tmp_live" "$_tmp_repo"
fi
