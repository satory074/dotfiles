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

" Tab
set expandtab                   " Converting TAB to SPACE
set tabstop=4                   " Number of SPACE per TAB
set shiftwidth=4                " Number of SPACE per indent

" Other
set virtualedit=onemore         " Cursor can move up to one character ahead of the end of the line
