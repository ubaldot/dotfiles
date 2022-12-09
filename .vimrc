" Some good VIM notes
" ======================
" "." used for concatenating 
" au = autocmd. au! clean up the command list connected to an event
" function! override if a function name is already defined. 
" a:variable used inside functions
" :h whatever is your friend
" Learn Vim the hard way is a great book
"
"=====================
" OBS! If using Python, you first need to 
" activate a virtual environment and then you 
" can open gvim fron the shell of that virtual environment. 
" If you open gvim and then you activate an environment,
" then things won't work!
" ==========================
set encoding=utf-8
set autoread
set nu
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nobackup
set backspace=indent,eol,start
set nocompatible              " required
set clipboard=unnamed
set splitright 
set laststatus=2
set statusline=%f "tail of the filename
set incsearch " for displaying while searching
set smartcase
set hidden
set noswapfile
set spell spelllang=en_us

" Set terminal with 256 colors
set termguicolors
set nofoldenable
set foldmethod=syntax
set foldlevelstart=20
" Set fonts for gvim
if has("gui_win32")
    let g:fontface = "FiraCode_NFM"
    let g:fontsize_small = ":h8:cANSI:qDRAFT" 
    let g:fontsize_large = ":h11:cANSI:qDRAFT" 
    let g:shell = "powershell"
    let g:dotvim = $HOME."\\vimfiles"
    let g:conda_env = trim(system("echo %CONDA_DEFAULT_ENV%"))
    " Open gvim in full-screen
    au GUIEnter * simalt ~x
    " The following is very slow
    "set shell="C:\\\\link\\\\to\\\\Anaconda\\\\powershell.exe"
    "set shellcmdflag=-command
elseif has("mac")
    let g:fontface = "Fira\ Code"
    let g:fontsize_small = ":h8"
    let g:fontsize_large = ":h14"
    let g:shell = "bash"
    let g:dotvim = $HOME."/.vim"
    let g:conda_env = trim(system("echo $CONDA_DEFAULT_ENV"))
endif
" guifont is reserved word (aka 'option')
let &guifont=g:fontface.g:fontsize_large

set completeopt-=preview

" Terminal not in the buffer list
" autocmd TerminalOpen * if bufwinnr('') > 0 | setlocal nobuflisted | endif
"
" Some key bindings
" Remap <leader> key
let mapleader = ","
nnoremap <leader>b :ls!<CR>:b
nnoremap <leader>d :bp<cr>:bd #<cr> " Add a condition that if you are in a terminal, then you must run <c-w>N first
noremap <silent> <c-n> :bprev<CR>
noremap <silent> <c-m> :bnext<CR>
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
nnoremap <c-k> <c-w>k
nnoremap <c-j> <c-w>j
" Enable folding with the spacebar
nnoremap <space> za
"Zoom in and out"
nnoremap <silent> <c-z><c-o> :let &guifont=g:fontface . g:fontsize_small<cr>
nnoremap <silent> <c-z><c-i> :let &guifont=g:fontface . g:fontsize_large<cr>

" Open and close brackets automatically. OBS! set paste must not be set.
""inoremap ( ()<left>
""inoremap [ []<left>
""inoremap { {}<left>
""inoremap {<CR> {<CR>}<ESC>O
""inoremap {;<CR> {<CR>};<ESC>O
""inoremap " ""<left>
""inoremap ' ''<left>
" to be able to undo accidental c-w"
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>
" Still on brackets
xnoremap ( <ESC>`>a)<ESC>`<i(<ESC>
xnoremap [ <ESC>`>a]<ESC>`<i[<ESC>
xnoremap { <ESC>`>a}<ESC>`<i{<ESC>
" xnoremap " <ESC>`>a"<ESC>`<i"<ESC>
" Indent without leaving the cursor positon 
nnoremap g= :let b:PlugView=winsaveview()<CR>gg=G:call winrestview(b:PlugView) <CR>:echo "file indented"<CR>

" Some terminal remapping
" When using iPython to avoid that shift space gives 32;2u
tnoremap <S-space> <space>
tnoremap <ESC> <c-w>N 
tnoremap <c-h> <c-w>h
tnoremap <c-l> <c-w>l
tnoremap <c-k> <c-w>k
tnoremap <c-j> <c-w>j
tnoremap <c-n> <c-w>:silent bprev<CR>
tnoremap <c-m> <c-w>:silent bnext<CR>


"Open terminal below all splits
exe "cabbrev bter bo terminal ". g:shell
exe "cabbrev vter vert botright terminal ". g:shell

" Stuff to be run before loading plugins
let g:ale_completion_enabled = 1
let g:ale_completion_autoimport = 1
set omnifunc=ale#completion#OmniFunc
"
" --- VUNDLE PLUGIN STUFF BEGIN --------
filetype off                  " required
" Vundle plugin manager
"set the runtime path to include Vundle and initialize
exe 'set rtp+=' . g:dotvim."/bundle/Vundle.vim"
call vundle#begin(g:dotvim."/bundle")
Plugin 'gmarik/Vundle.vim'
Plugin 'sainnhe/everforest'
Plugin 'preservim/nerdtree'
Plugin 'dense-analysis/ale'
Plugin 'liuchengxu/vista.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'leftbones/helpme-vim'
call vundle#end()            " required
filetype plugin indent on    " required for Vundle
" ---- VUNDLE PLUGIN STUFF END ----------

" Colorscheme
let hour = strftime("%H")
if 6 <= hour && hour < 15 
    set background=light 
else 
    set background=dark
    let g:airline_theme='dark'
endif 
colorscheme everforest

" ---- NERDTree settings ------
map <F1> :NERDTreeToggle<CR>
augroup DIRCHANGE
    au!
    autocmd DirChanged global :NERDTreeCWD
    autocmd DirChanged global :call ChangeTerminalDir()
augroup END
" Close NERDTree when opening a file"
let g:NERDTreeQuitOnOpen = 1

" change all the terminal directories when you change vim directory 
function! ChangeTerminalDir()
    for ii in term_list()
        call term_sendkeys(ii,"cd ".getcwd()."\n")
    endfor
endfunction

source $HOME/helpme.vim 

" ALE Fixers
let g:ale_fixers = {
            \   'c':['clang-format','remove_trailing_lines', 'trim_whitespace'], 
            \ 'cpp':['clang-format'],
            \ 'python':['remove_trailing_lines', 'trim_whitespace','autoflake','black'],
            \}
let g:ale_python_autoflake_options = '--in-place --remove-unused-variables --remove-all-unused-imports'
let g:ale_python_black_options = '--line-length=80'
let g:ale_fix_on_save = 1

" Source additional files
" source $HOME/PE.vim
" source $HOME/VAS.vim
" source $HOME/dymoval.vim

syntax on



" To have nice colors during autocompletion
hi Pmenu guibg=lightgray guifg=black
hi PmenuSel guibg=darkgray guifg=gray

" In case you use a terminal you want the same
hi Pmenu ctermbg=lightgray ctermfg=black
hi PmenuSel ctermbg=darkgray ctermfg=gray


" Some useful functions
" Commit dot message
function! GitCommit()
    exe "silent !git add -u && call git commit -m '.'"
endfunction

function! Manim(scene)
    exe "silent !manim ".expand("%:t")." ".a:scene." -pql"
endfunction


