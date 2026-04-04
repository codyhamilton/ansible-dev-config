# configs/claude/install.sh — sourced by bin/devconf with DC_MODE, DC_CONFIG_DIR, DC_OS in scope
_claude_dir="${HOME}/.claude"
dc_ensure_dir "$_claude_dir"
dc_sync settings.json "$_claude_dir/settings.json"
# CLAUDE.md: only create if not exists (configure mode); never sync back
if [ "$DC_MODE" = "configure" ]; then
    if [ ! -f "$_claude_dir/CLAUDE.md" ]; then
        cp "$DC_CONFIG_DIR/CLAUDE.md" "$_claude_dir/CLAUDE.md"
        dc_ok "claude/CLAUDE.md (created; edit to customize)"
    else
        dc_skip "claude/CLAUDE.md (exists; not overwriting)"
    fi
fi
