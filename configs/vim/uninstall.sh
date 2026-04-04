# configs/vim/uninstall.sh — remove vim config files
# Sourced by dispatcher; DC_CONFIG_DIR, DC_OS, hooks.sh and utils.sh are in scope.

dc_bold "Removing vim config..."

if command -v nvim > /dev/null 2>&1; then
    if _dc_confirm "Remove ${HOME}/.config/nvim/init.vim and ${HOME}/.config/nvim/?"; then
        _dc_rm_file "${HOME}/.config/nvim/init.vim" "nvim/init.vim"
        _dc_rm_dir  "${HOME}/.config/nvim"          "nvim prefix dir"
    else
        dc_skip "nvim (kept)"
    fi
fi
if command -v vim > /dev/null 2>&1; then
    if _dc_confirm "Remove ${HOME}/.vimrc and ${HOME}/.vim/?"; then
        _dc_rm_file "${HOME}/.vimrc" "vimrc"
        _dc_rm_dir  "${HOME}/.vim"   "vim prefix dir"
    else
        dc_skip "vim (kept)"
    fi
fi
