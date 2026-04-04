# configs/bash/install.sh — sourced by bin/devconf with DC_MODE, DC_CONFIG_DIR, DC_OS in scope
dc_sync alias.sh               "$HOME/.bashrc.d/alias.sh"
dc_sync defaults.sh            "$HOME/.bashrc.d/defaults.sh"
dc_sync devcontainer-agents.sh "$HOME/.bashrc.d/devcontainer-agents.sh"
_dc_inject_bashrc_loader
