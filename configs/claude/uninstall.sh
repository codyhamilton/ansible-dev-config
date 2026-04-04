# configs/claude/uninstall.sh — remove Claude config files
# Sourced by dispatcher; DC_CONFIG_DIR, DC_OS, hooks.sh and utils.sh are in scope.

dc_bold "Removing Claude config..."

_dc_rm_file "${HOME}/.claude/settings.json" "claude/settings.json"
dc_skip "claude/CLAUDE.md (user-specific; not removed)"
