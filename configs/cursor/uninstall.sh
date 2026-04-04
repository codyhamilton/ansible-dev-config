# configs/cursor/uninstall.sh — remove Cursor config files
# Sourced by dispatcher; DC_CONFIG_DIR, DC_OS, hooks.sh and utils.sh are in scope.

dc_bold "Removing Cursor config..."

_dc_rm_file "${HOME}/.cursor/argv.json" "cursor/argv.json"
_dc_rm_file "${HOME}/.cursor/mcp.json"  "cursor/mcp.json"
