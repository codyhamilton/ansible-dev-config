# configs/tmux/install.sh — sourced by bin/devconf with DC_MODE, DC_CONFIG_DIR, DC_OS in scope
dc_sync tmux.conf "$HOME/.tmux.conf"

# TPM (configure mode only — idempotent)
if [ "$DC_MODE" = "configure" ]; then
    _tpm_dir="${HOME}/.tmux/plugins/tpm"
    if [ -d "$_tpm_dir/.git" ]; then
        dc_ok "tpm (already installed)"
    else
        dc_require_cmd git
        dc_ensure_dir "${HOME}/.tmux/plugins"
        git clone --depth=1 "https://github.com/tmux-plugins/tpm" "$_tpm_dir"
        dc_ok "tpm installed"
    fi
fi
