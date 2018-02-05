if has("gui_macvim")
	set guifont=Monaco\ for\ Powerline:h15
else
	set guifont=Monaco\ for\ Powerline:h14
endif

" Open the current directory in finder
nnoremap <leader>o :! open %:h<CR>

" Upload file using Transmit
nmap <leader>u <Plug>TransmittyUploadLook<CR>:redraw!<CR>

