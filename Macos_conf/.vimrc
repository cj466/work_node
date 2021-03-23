set t_Co=256
syntax enable
set number
set ignorecase
set hlsearch
call plug#begin('~/.vim/plugged')
Plug 'mhinz/vim-startify'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'arcticicestudio/nord-vim'
call plug#end()

let g:airline_theme='luna'

