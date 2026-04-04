# configs/devcon/install.sh — sourced by bin/devconf with DC_MODE, DC_CONFIG_DIR, DC_OS in scope
[ "$DC_MODE" = "configure" ] || return 0
if [ ! -f "$DC_CONFIG_DIR/devcon" ]; then
    dc_err "devcon script not found at $DC_CONFIG_DIR/devcon"
    return 1
fi
chmod +x "$DC_CONFIG_DIR/devcon"
ln -sf "$DC_CONFIG_DIR/devcon" "$HOME/.local/bin/devcon"
dc_ok "devcon symlink → $HOME/.local/bin/devcon"
