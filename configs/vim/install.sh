# configs/vim/install.sh — sourced by bin/devconf with DC_MODE, DC_CONFIG_DIR, DC_OS in scope

_dc_apply_vim_editor() {
    # _dc_apply_vim_editor <vim_prefix> <vim_init>
    local vim_prefix="$1" vim_init="$2"
    dc_sync vimrc "$vim_init"

    local os_vim="$DC_CONFIG_DIR/${DC_OS}.vim"
    if [ -f "$os_vim" ]; then
        dc_sync "${DC_OS}.vim" "${vim_prefix}/${DC_OS}.vim"
    fi

    if [ "$DC_MODE" = "configure" ]; then
        local plug_path="${vim_prefix}/autoload/plug.vim"
        if [ -f "$plug_path" ]; then
            dc_ok "vim-plug (already installed)"
        else
            dc_require_cmd curl
            dc_ensure_dir "${vim_prefix}/autoload"
            curl -fsSLo "$plug_path" \
                https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
            dc_ok "vim-plug installed"
        fi
    fi
}

if command -v nvim > /dev/null 2>&1; then
    _dc_apply_vim_editor "${HOME}/.config/nvim" "${HOME}/.config/nvim/init.vim"
fi
if command -v vim > /dev/null 2>&1; then
    _dc_apply_vim_editor "${HOME}/.vim" "${HOME}/.vimrc"
fi
