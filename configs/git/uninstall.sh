# configs/git/uninstall.sh — remove git config files
# Sourced by dispatcher; DC_CONFIG_DIR, DC_OS, hooks.sh and utils.sh are in scope.

dc_bold "Removing git config..."

_dc_rm_file "${HOME}/.git-prompt-colors.sh"    "git/git-prompt-colors.sh"
_dc_rm_file "${HOME}/.bashrc.d/gitprompt.sh"   "git/gitprompt.sh"
_dc_rm_file "${HOME}/.bashrc.d/gitcomplete.sh" "git/gitcomplete.sh"
_dc_rm_dir  "${HOME}/.bashrc.d/git-prompt"     "git/bash-git-prompt"
