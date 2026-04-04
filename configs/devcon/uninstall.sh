# configs/devcon/uninstall.sh — remove devcon symlink
# Sourced by dispatcher; DC_CONFIG_DIR, DC_OS, hooks.sh and utils.sh are in scope.

dc_bold "Removing devcon..."

_dc_rm_file "${HOME}/.local/bin/devcon" "devcon symlink"
