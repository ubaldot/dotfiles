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

echo system("source ~/.zshrc")

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
" set statusline=%f "tail of the filename
set incsearch " for displaying while searching
set smartcase
set hidden
set noswapfile
set spell spelllang=en_us
set nofoldenable
set foldmethod=syntax
set foldlevelstart=20
set wildmenu
set completeopt-=preview

if has("gui_win32")
    let g:shell = "powershell"
    let g:dotvim = $HOME."\\vimfiles"
    let g:conda_env = trim(system("echo %CONDA_DEFAULT_ENV%"))
    " The following is very slow
    "set shell="C:\\\\link\\\\to\\\\Anaconda\\\\powershell.exe"
    "set shellcmdflag=-command
elseif has("mac")
    set shell=zsh " to be able to source ~/.zshrc (conda init)
    let g:shell = "zsh"
    let g:dotvim = $HOME."/.vim"
    let g:conda_env = trim(system("echo $CONDA_DEFAULT_ENV"))
endif
"
" Terminal not in the buffer list
" autocmd TerminalOpen * if bufwinnr('') > 0 | setlocal nobuflisted | endif
"
" Some key bindings
" Remap <leader> key
let mapleader = ","
nnoremap <leader>w :w<cr>
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
"tnoremap <c-n> <c-w>:silent bprev<CR>
"tnoremap <c-m> <c-w>:silent bnext<CR>


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

source $HOME/.vim/helpme.vim 

" Vista! Current function
function! NearestMethodOrFunction() abort
    return get(b:, 'vista_nearest_method_or_function', '')
endfunction

augroup FuncNameGet
    autocmd!
    autocmd VimEnter * call vista#RunForNearestMethodOrFunction()
augroup END

" Vista for showing outline 
silent! map <F8> :Vista!!<CR>

" Get git branch name for airline. OBS !It may need to be changed for other OS.
function! Gitbranch()
    let l:current_branch = trim(system("git -C " . expand("%:h") . " branch --show-current"))
    if l:current_branch =~ "not a git repository"
        return "(no repo)"
    else
        return l:current_branch
    endif 
endfunction

augroup Gitget
    autocmd!
    autocmd BufEnter * let b:git_branch = Gitbranch()
augroup END


" Commenting blocks of code.
augroup commenting_blocks_of_code
    autocmd!
    autocmd FileType c,cpp,java,scala let b:comment_leader = '// '
    autocmd FileType sh,ruby,python   let b:comment_leader = '# '
    autocmd FileType conf,fstab       let b:comment_leader = '# '
    autocmd FileType tex              let b:comment_leader = '% '
    autocmd FileType mail             let b:comment_leader = '> '
    autocmd FileType vim              let b:comment_leader = '" '
augroup END
" To be modified
noremap <silent> <c-1> :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
noremap <silent> <c-2> :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>
"
" vim-airline show buffers
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#tabline#ignore_bufadd_pat = 'defx|gundo|nerd_tree|startify|tagbar|undotree|vimfiler'
" 
" 
" If mode()==t then change the statusline 
au User AirlineAfterInit  :let g:airline_section_a = airline#section#create([' %{b:git_branch}'])
au User AirlineAfterInit  :let g:airline_section_b = airline#section#create(['%f']) 
au User AirlineAfterInit  :let g:airline_section_c =
            \  airline#section#create([':%{NearestMethodOrFunction()}'])  
au User AirlineAfterInit  :let g:airline_section_z = airline#section#create(['col: %v'])
"au User AirlineAfterInit  :let g:airline_section_x = airline#section#create(['(%{g:conda_env})
au User AirlineAfterInit  :let g:airline_section_x = airline#section#create([g:conda_env])
let g:airline_extensions = ['ale','tabline']


" ALE linter stuff
" If you want clangd as LSP add it to the linter list.
"let g:ale_disable_lsp = 1
nmap <silent> <leader>k <Plug>(ale_previous_wrap)
nmap <silent> <leader>j <Plug>(ale_next_wrap)
let g:ale_linters = {
            \'c':['clangd','cppcheck','gcc'],
            \'python':['flake8','pylsp','mypy'], 
            \}
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_c_clangtidy_checks = ['*']
let g:ale_python_flake8_options = '--ignore=E501,W503'
let g:ale_python_pyright_config = {
            \ 'pyright': {
            \   "extraPaths": "C:/VAS/github/dymoval",
            \},
            \}


let g:ale_python_pylsp_config = {
            \   'pylsp': {
            \     'plugins': {
            \       'pycodestyle': {
            \         'enabled': v:false,
            \       },
            \       'pyflakes': {
            \         'enabled': v:false,
            \       },
            \       'pydocstyle': {
            \         'enabled': v:false,
            \       },
            \         'autopep8': {
            \         'enabled': v:false,
            \       },
            \     },
            \   },
            \}


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
hi Pmenu ctermbg=lightgray ctermfg=black
hi PmenuSel ctermbg=darkgray ctermfg=gray


" Some useful functions
" Commit dot message
function! GitCommit()
    exe "silent !git add -u && call git commit -m '.'"
endfunction

function! Manim(scene)
    exe "silent !manim ".shellescape(expand("%:t"))." ".a:scene." -pql"
endfunction


