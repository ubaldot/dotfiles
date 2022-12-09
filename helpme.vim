" HelpMe list
let g:HelpMeItems = [
            \"",
            \"C-CODING:",
            \"jump to/from definition         :ALEFindDefinition/<c-o> (previous cursor position)",
            \"find all references             :ALEFindReferences",
            \"re-open preview window           :ALERepeatSelection",
            \"autocompletion                  <c-x><c-o> or <c-p> and <c-n> (vim omnicomplete)",
            \"autoindent                      g= (remapped)",
            \"commenting multiple lines (//)  <c-v><select>I//<esc>" ,
            \"open local list (local)         :lopen",
            \"open quickfix list (global)     :copen",
            \"",
            \"SEARCH/REPLACE:",
            \"find next/prev (under cursor)      */#",
            \"search in current file             /<type_your_word><CR> (n=next, N=prev)",
            \"open search/replace window (gvim)  :promptrepl",
            \"replace old_name with new_nam      :%s/old_name/new_name/gci (g=global, c=confirm, i=case insensitive, \<new_name\> = match word)",
            \"search word in files               :vimgrep /<word>/ <files_pattern>",
            \"",
            \"MOVING:",
            \"scroll down/scroll up        <c-e/<c-y> (remapped)",
            \"jump beginning/end of line    0/$",
            \"jump to top/bottom/line 109  gg/G/109gg",
            \"jump to previous/next cursor position    <c-o>/<c-i> (:help jump-motion)",
            \"Move cursor to next/prev/above/below win    <ctrl-left,right,up,down>",
            \"",
            \"REGISTERS:",
            \ "select register \"a\" to yank or paste   \"a then you choose what to do, e.g yy or p",
            \ "clipboard register  +",
            \ "filename register  %" ,
            \ "access register from command line <c-r> (it gives you the \")",
            \"",
            \"NERDTree:",
            \"copy NERDTree dir to pwd     cd",
            \"open/close NERDTree          <F1> (:NERDToggle, remapped)",
            \"switch to C: drive           :NERDTree c:/",
            \"show hidden files            I",
            \"open file and stay           go",
            \"",
            \"IPYTHON-CODING:",
            \"Run current cell           <c-enter> (custom)",
            \"",
            \"TERMINAL:",
            \"open terminal below/side  :bterm/:vterm ",
            \"toggle vim/terminal mode  <esc>/i (when you are in a terminal, remapped)",
            \"WINDOWS:",
            \"Place current split   <c-w>HJKL",
            \"",
            \"BUFFERS:",
            \"switch to buff prev/next      <c-PgUp>/<c-PgDown> (equal to :bprev/:bnext) (remapped)",
            \"close current buffer          ,q (remapped)",
            \"list all the opened buffers   ,b (remapped)",
            \"force closure of buffer \"n\"   :bd! n",
            \"",
            \"HELP: :h <something>",
            \ ]

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


