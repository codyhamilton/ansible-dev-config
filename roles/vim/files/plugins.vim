" ================ Plugin Init ====================
call plug#begin('~/.vim/plugged')

	" Core plugins
	Plug 'embear/vim-localvimrc'
	Plug 'scrooloose/nerdtree'
	Plug 'jistr/vim-nerdtree-tabs'
	Plug 'altercation/vim-colors-solarized'
	Plug 'wincent/Command-T'
	Plug 'bufkill.vim'
	Plug 'powerline/powerline', { 'rtp' : 'powerline/bindings/vim/' }

	" Filetypes
	Plug 'scrooloose/syntastic'
	Plug 'othree/html5.vim'
	Plug 'hail2u/vim-css3-syntax'
	Plug 'groenewege/vim-less'
	Plug 'pangloss/vim-javascript'
	Plug 'elzr/vim-json'
	Plug 'tpope/vim-liquid'
	Plug 'parkr/vim-jekyll'
	Plug 'vim-ruby/vim-ruby'
	Plug 'chase/vim-ansible-yaml'

	" Integrations
	Plug 'hlissner/vim-transmitty'
	Plug 'tpope/vim-fugitive'
	Plug 'airblade/vim-gitgutter'
	Plug 'rizzatti/dash.vim'

	" Text manipulation
	Plug 'terryma/vim-multiple-cursors'
	Plug 'scrooloose/nerdcommenter'
	Plug 'godlygeek/tabular'
	Plug 'kana/vim-textobj-user'
	Plug 'nelstrom/vim-textobj-rubyblock'
	Plug 'Olical/vim-enmasse'

	Plug 'taglist.vim'
	Plug 'mattn/emmet-vim'
	Plug 'Lokaltog/vim-easymotion'
	Plug '29decibel/vim-stringify'
	Plug 'tpope/vim-surround'
	Plug 'tpope/vim-dispatch'
	Plug 'xolox/vim-misc'
	Plug 'xolox/vim-easytags'
	Plug 'tpope/vim-endwise'
	Plug 'slim-template/vim-slim'
	Plug 'joonty/vdebug'
	Plug 'evidens/vim-twig'
	Plug 'majutsushi/tagbar'

call plug#end()
