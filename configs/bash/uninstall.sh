# configs/bash/uninstall.sh — remove bash config files and bashrc.d loader
# Sourced by dispatcher; DC_CONFIG_DIR, DC_OS, hooks.sh and utils.sh are in scope.

dc_bold "Removing bash config..."

_dc_rm_file "${HOME}/.bashrc.d/alias.sh"               "bash/alias.sh"
_dc_rm_file "${HOME}/.bashrc.d/defaults.sh"            "bash/defaults.sh"
_dc_rm_file "${HOME}/.bashrc.d/devcontainer-agents.sh" "bash/devcontainer-agents.sh"

_profile="$(dc_profile_file)"
if grep -qF "$_DC_BASHRC_MARKER" "$_profile" 2>/dev/null; then
    _tmp="/tmp/devconf_remove_profile.$$"
    if sed '/# devconf: load bashrc\.d/,/unset _dc_f/d' "$_profile" > "$_tmp"; then
        if mv "$_tmp" "$_profile"; then
            dc_ok "bashrc.d loader removed from $_profile"
        else
            rm -f "$_tmp"
            dc_err "Failed to update $_profile"
        fi
    else
        rm -f "$_tmp"
        dc_err "Failed to remove bashrc.d loader from $_profile"
    fi
else
    dc_skip "bashrc.d loader (not in $_profile)"
fi
