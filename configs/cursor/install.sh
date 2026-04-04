# configs/cursor/install.sh — sourced by bin/devconf with DC_MODE, DC_CONFIG_DIR, DC_OS in scope
_cursor_dir="${HOME}/.cursor"
if [ ! -d "$_cursor_dir" ] && ! command -v cursor > /dev/null 2>&1; then
    dc_skip "Cursor (not installed)"
    return
fi
dc_ensure_dir "$_cursor_dir"

# argv.json: sync with crash-reporter-id filter (sync direction only — strip it when syncing back)
dc_sync argv.json "$_cursor_dir/argv.json" '/crash-reporter-id/d'
dc_sync mcp.json  "$_cursor_dir/mcp.json"
