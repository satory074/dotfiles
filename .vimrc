syntax on
filetype plugin indent on

" Keybind
inoremap <silent> jj <ESC>
" let mapleader = '\ '
set backspace=indent,eol,start  " Valid Backspace

" Complement
set wildmenu                    " Complete the file name
set wildmode=list:longest       " wildmenu mode

" Display
set cursorline                  " Hilighting the cursor line
set number                      " Row number
set ruler                       " Position of the cursor at the bottom
set showcmd                     " Command being typed
set t_Co=256                    " 256 colors available

" File I/O
set autoread                    " Load again when changed externally
set encoding=utf-8
set fileencoding=utf-8
set fileformats=unix,dos,mac
set nobackup                    " Don't create *.*~

" Search
set ignorecase                  " Don't distinguish between upper and lower case when searching
set smartcase                   " Distinuish only upper case letters when searching
set incsearch                   " Highlight matches as you type
set hlsearch                    " Highlight all search matches

" Tab
set expandtab                   " Converting TAB to SPACE
set tabstop=4                   " Number of SPACE per TAB
set shiftwidth=4                " Number of SPACE per indent

" Other
set virtualedit=onemore         " Cursor can move up to one character ahead of the end of the line

" vim-sensible base (manual)
set complete-=i
set nrformats-=octal

if !has('nvim') && &ttimeoutlen == -1
  set ttimeout ttimeoutlen=100
endif

if has('reltime')
  set incsearch
endif

if maparg('<C-L>', 'n') ==# ''
  nnoremap <silent> <C-L> :nohlsearch<CR>
  if has('diff')
    nnoremap <silent> <C-L> :nohlsearch<CR>:diffupdate<CR>
  endif
endif

set laststatus=2
set scrolloff=1
set sidescroll=1
set sidescrolloff=2
set display+=lastline
if has('patch-7.4.2109')
  set display+=truncate
endif
set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
set list

set formatoptions+=j
set history=1000
set tabpagemax=50
set sessionoptions-=options
set viewoptions-=options
set viminfo^=!

set nolangremap
filetype plugin indent on
syntax enable

inoremap <C-U> <C-G>u<C-U>
inoremap <C-W> <C-G>u<C-W>

if !exists('g:loaded_matchit')
  runtime! macros/matchit.vim
endif
