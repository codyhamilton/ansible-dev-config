# configs/tmux/uninstall.sh — remove tmux config files
# Sourced by dispatcher; DC_CONFIG_DIR, DC_OS, hooks.sh and utils.sh are in scope.

dc_bold "Removing tmux config..."

_dc_rm_file "${HOME}/.tmux.conf" "tmux/tmux.conf"

if _dc_confirm "Remove TPM at ${HOME}/.tmux/plugins/tpm?"; then
    _dc_rm_dir "${HOME}/.tmux/plugins/tpm" "tpm"
else
    dc_skip "tpm (kept)"
fi
