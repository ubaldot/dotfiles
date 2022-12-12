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
" can open gvim from the shell of that virtual environment. 
" If you open gvim and then you activate an environment,
" then things won't work!
" ==========================
"
" For auto-completion, jumps to definitions, etc
" you can either use ctags or LSP. 
" gutentags automatically creates ctags as you open files
" so you don't need to create them manually.
" You need to activate vim omnicomplete though, which is disables
" by default and you should disable LSP 
" Uncomment set omnifunc=... few lines below"
" 

" To activate myenv conda environment for MacVim
if has("mac")
    call system("source ~/.zshrc")
endif

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
nnoremap <leader>w :bp<cr>:bw! #<cr>
nnoremap <leader>b :ls!<CR>:b
nnoremap <leader>d :bp<cr>:bd #<cr> " Add a condition that if you are in a terminal, then you must run <c-w>N first
noremap <c-left> :bprev<CR>
noremap <c-right> :bnext<CR>
noremap <c-PageDown> :bprev<CR>
noremap <c-PageUp> :bnext<CR>
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
nnoremap <c-k> <c-w>k
nnoremap <c-j> <c-w>j
" Enable folding with the spacebar
nnoremap <space> za

" Open and close brackets automatically. OBS! set paste must not be set.
""inoremap ( ()h
""inoremap [ []h
""inoremap { {}h
""inoremap {<CR> {<CR>}<ESC>O
""inoremap {;<CR> {<CR>};<ESC>O
""inoremap " ""h
""inoremap ' ''h
" to be able to undo accidental c-w"
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>
" Automatically surround highlighted selection
xnoremap ( <ESC>`>a)<ESC>`<i(<ESC>
xnoremap [ <ESC>`>a]<ESC>`<i[<ESC>
xnoremap { <ESC>`>a}<ESC>`<i{<ESC>
" xnoremap " <ESC>`>a"<ESC>`<i"<ESC>
" Indent without leaving the cursor position 
nnoremap g= :let b:PlugView=winsaveview()<CR>gg=G:call winrestview(b:PlugView) <CR>:echo "file indented"<CR>

" Some terminal remapping
" When using iPython to avoid that shift space gives 32;2u
tnoremap <S-space> <space>
tnoremap <ESC> <c-w>N 
tnoremap <c-h> <c-w>h
tnoremap <c-l> <c-w>l
tnoremap <c-k> <c-w>k
tnoremap <c-j> <c-w>j
" I have to find some good key-bindings here...
tnoremap <c-PageDown> <c-w>:bprev<CR>
tnoremap <c-PageUp> <c-w>:bnext<CR>


"Open terminal below all splits
exe "cabbrev bter bo terminal ". g:shell
exe "cabbrev vter vert botright terminal ". g:shell

" Stuff to be run before loading plugins
" Use the internal autocompletion (no deoplete, no asyncomplete plugins)
let g:ale_completion_enabled = 1
let g:ale_completion_autoimport = 1
"Omnifunc is kinda disabled so I don't have to hit <c-x><c-o> for getting
"suggestions
" set omnifunc=ale#completion#OmniFunc
"set omnifunc=syntaxcomplete#Complete
"let g:ale_disable_lsp = 1


" ============================================
" Plugins  manager
" ============================================
filetype off                  " required
" Vundle plugin manager
"set the runtime path to include Vundle and initialize
exe 'set rtp+=' . g:dotvim."/bundle/Vundle.vim"
call vundle#begin(g:dotvim."/bundle")
Plugin 'gmarik/Vundle.vim'
Plugin 'sainnhe/everforest'
Plugin 'preservim/nerdtree'
Plugin 'dense-analysis/ale'
" Plugin 'ludovicchabant/vim-gutentags'
Plugin 'liuchengxu/vista.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'leftbones/helpme-vim'
call vundle#end()            " required
filetype plugin indent on    " required for Vundle

" ============================================
" Plugins settings
" ============================================
" Helpme
source $HOME/.vim/helpme.vim 

" everforest colorscheme
let hour = strftime("%H")
if 6 <= hour && hour < 15 
    set background=light 
else 
    set background=dark
    let g:airline_theme='dark'
endif 
colorscheme everforest

" NERDTree 
map <F1> :NERDTreeToggle<CR>
augroup DIRCHANGE
    au!
    autocmd DirChanged global :NERDTreeCWD
    autocmd DirChanged global :call ChangeTerminalDir()
augroup END
" Close NERDTree when opening a file"
let g:NERDTreeQuitOnOpen = 1


" Vista! 
let g:vista_close_on_jump = 1
let g:vista_default_executive = 'ctags'
function! NearestMethodOrFunction() abort
    return get(b:, 'vista_nearest_method_or_function', '')
endfunction

augroup FuncNameGet
    autocmd!
    autocmd VimEnter * call vista#RunForNearestMethodOrFunction()
augroup END

" Vista for showing outline 
silent! map <F8> :Vista!!<CR>

" vim-airline show buffers
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#tabline#ignore_bufadd_pat = 'defx|gundo|nerd_tree|startify|tagbar|undotree|vimfiler'
" If mode()==t then change the statusline 
au User AirlineAfterInit  :let g:airline_section_a = airline#section#create([' %{b:git_branch}'])
au User AirlineAfterInit  :let g:airline_section_b = airline#section#create(['%f']) 
au User AirlineAfterInit  :let g:airline_section_c = airline#section#create(['f:%{NearestMethodOrFunction()}'])  
au User AirlineAfterInit  :let g:airline_section_z = airline#section#create(['col: %v'])
"au User AirlineAfterInit  :let g:airline_section_x = airline#section#create(['(%{g:conda_env})
au User AirlineAfterInit  :let g:airline_section_x = airline#section#create([g:conda_env])
let g:airline_extensions = ['ale','tabline']


" ALE 
" If you want clangd as LSP add it to the linter list.
nmap <silent> <leader>k <Plug>(ale_previous_wrap)
nmap <silent> <leader>j <Plug>(ale_next_wrap)
nmap <c-]> :ALEGoToDefinition<cr>
let g:ale_linters = {
            \'c':['clangd','cppcheck','gcc'],
            \'python':['flake8','pylsp','mypy'], 
            \}
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_c_clangtidy_checks = ['*']
let g:ale_python_flake8_options = '--ignore=E501,W503'
" let g:ale_python_pyright_config = {
"             \ 'pyright': {
"             \   "extraPaths": "C:/VAS/github/dymoval",
"             \},
"             \}

" I don't remember how to set the following
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

" ============================================
" Self-defined functions
" ============================================
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

" Some useful functions
" change all the terminal directories when you change vim directory 
function! ChangeTerminalDir()
    for ii in term_list()
        call term_sendkeys(ii,"cd ".getcwd()."\n")
    endfor
endfunction

" Commit dot message
function! GitCommit()
    exe "silent !git add -u && call git commit -m '.'"
endfunction

"" This is my own REPL
func! Repl(repl_type,repl_name)
    echo a:repl_name
    if a:repl_type == "terminal"
        exe "botright terminal ". g:shell
    else
        call term_start(a:repl_type,{'term_name': a:repl_name, 'vertical': v:true} )
    endif
endfunc
"
func! SendCell(repl_type,repl_name,delim)
    if !bufexists(a:repl_name)
        call Repl(a:repl_type,a:repl_name)
        wincmd h
    endif
    " var is the syntax for using a variable in a function
    " In Normal mode, go to the next line
    norm! j
    " echo delim
    " In search n is for don't move the cursor, b is backwards and W to don't wrap
    " around
    let l:line_in = search(a:delim,'nbW')
    " We use -1 because we want right-open intervals, i.e. [a,b). 
    " Note that here we want the cursor to move to the next cell!
    norm! k
    let l:line_out = search(a:delim,'W')-1
    if l:line_out == -1
        let l:line_out = line("$")
    endif
    " For debugging
    " echo [l:line_in, l:line_out]
    call delete(fnameescape(g:filename))
    " getline() returns a list of lines
    call writefile(getline(l:line_in+1,l:line_out), g:filename,"a")
    "call term_sendkeys(term_list()[0],"run -i ". g:filename . "\n")
    " At startup, it is always terminal 2 or the name is hard-coded IPYTHON
    call term_sendkeys(a:repl_name,"run -i ". g:filename . "\n")
    echo "Code cell sent."
endfunc
"
"" Defaults for the REPL
let g:repl_type_default = 'terminal'
let g:repl_name_default = "TERMINAL"
let g:cell_delimiter_default = "None"

""
if has("gui_win32")
    set pythonthreehome=$HOME."\\Miniconda3"
    set pythonthreedll=$HOME."\\Miniconda3\\python39.dll"
    let g:filename = $TMP . "\\my_cell.tmp"
elseif has("mac")
    let g:filename = expand("~/my_cell.tmp")
endif
"
"# Define my own command
echo get(b:,'repl_type','repl_type_default')
command REPL :call Repl(get(b:,'repl_type',g:repl_type_default),get(b:,'repl_name',g:repl_name_default))
"
"" Some key-bindings for the REPL
nnoremap <F9> yy \| :call term_sendkeys(get(b:,'repl_name',g:repl_name_default),@")<cr>j0
vnoremap <F9> y \| :call term_sendkeys(get(b:,'repl_name',g:repl_name_default),@")<cr>j0
nnoremap <C-enter> :call SendCell(get(b:,'repl_type',g:repl_type_default),get(b:,'repl_name',g:repl_name_default),get(b:,'cell_delimiter',g:cell_delimiter_default))<cr><cr>
"" Clear REPL
nnoremap <c-c> :call term_sendkeys(get(b:,'repl_name',g:repl_name_default),"\<c-l>")<cr>

" manim render
function! Manim(scene)
    exe "silent !manim ".shellescape(expand("%:t"))." ".a:scene." -pql"
endfunction

" The following was a nice exercise but it may not be needed as we for the statusline we are
" just using trim(system("echo \%CONDA_DEFAULT_ENV\%").  
" Get conda virtual environment
" function Condaenv(env)
"    " You use 'call' in MS-DOS to delay a bit
"    return trim(system("conda activate ". a:env. " && call echo %CONDA_DEFAULT_ENV%"))
" endfunction
" 
" " Someone said that this function is called very often. 
" augroup Condaenvget
"     autocmd!
"     autocmd VimEnter * let g:conda_env = Condaenv(g:conda_activate)
" augroup END


