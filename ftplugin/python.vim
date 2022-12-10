" Python stuff, like REPL, etc.

" Tell vim where is Python. OBS: this is independent of the plugins!
" You must check in the vim version what dll is required in the field -DDYNAMIC_PYTHON_DLL=\"python310.dll\
if has("gui_win32")
    set pythonthreehome=$HOME."\\Miniconda3"
    set pythonthreedll=$HOME."\\Miniconda3\\python39.dll"
    let g:filename = $TMP . "\\my_cell.tmp"
elseif has("mac")
    let g:filename = expand("~/my_cell.tmp")
    " let g:filename = expand("~/Library/Caches/TemporaryItems/my_cell.tmp")
endif
"
"" My python custom shit. " Python stuff, like REPL, etc.

" Tell vim where is Python. OBS: this is independent of the plugins!
" You must check in the vim version what dll is required in the field -DDYNAMIC_PYTHON_DLL=\"python310.dll\
if has("gui_win32")
    set pythonthreehome=$HOME."\\Miniconda3"
    set pythonthreedll=$HOME."\\Miniconda3\\python39.dll"
    let g:filename = $TMP . "\\my_cell.tmp"
elseif has("mac")
    let g:filename = expand("~/my_cell.tmp")
    " let g:filename = expand("~/Library/Caches/TemporaryItems/my_cell.tmp")
endif
"
"" My python custom shit. 
let g:conda_activate = 'myenv'
let g:ipython_terminal_name = 'IPYTHON'
let g:cell_delimiter = "# %%" 
" Select the IPYTHON profile settings in  ~/.ipython 
let g:ipython_profile = 'autoreload_profile' 

" Highlight colors for "# %%" string
match VisualNOS /#\ %%/ 

" Nice exercise but it may not be needed as we for the statusline we are
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

func! Repl(...)
    let env = get(a:, 1, g:conda_activate)
    let ipy_term = get(a:, 2, g:ipython_terminal_name)
    let ipy_profile = get(a:, 3, g:ipython_profile)
    if has("gui_win32")
        call  term_start('C:\\Users\\yt75534\\Miniconda3\\condabin\\conda.bat activate ' . env . 
                   \ ' && call echo Conda env:%CONDA_DEFAULT_ENV% && ipython --profile=' .ipy_profile, 
                   \ {'term_name': ipy_term, 'vertical': v:true} )
    elseif has("mac")
        call term_start('ipython',{'term_name': ipy_term, 'vertical': v:true} )
   endif
endfunc

" This is my own REPL
func! SendCell()
    let env = get(a:, 1, g:conda_activate)
    let ipy_term = get(a:, 2, g:ipython_terminal_name)
    let ipy_profile = get(a:, 3, g:ipython_profile)
    let delim = get(a:, 4, g:cell_delimiter)
    if !bufexists(ipy_term)
        call Repl(env,ipy_term,ipy_profile)
        wincmd h
    endif
    " var is the syntax for using a variable in a function
    " In Normal mode, go to the next line
    norm! j
    " echo delim
    " In search n is for don't move the cursor, b is backwards and W to don't wrap
    " around
    let l:line_in = search(delim,'nbW')
    " We use -1 because we want right-open intervals, i.e. [a,b). 
    " Note that here we want the cursor to move to the next cell!
    norm! k
    let l:line_out = search(delim,'W')-1
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
    call term_sendkeys(ipy_term,"run -i ". g:filename . "\n")
endfunc


command REPL :call Repl()
" Some key-bindings
nnoremap <F9> yy \| :call term_sendkeys(g:ipython_terminal_name,@")<cr>j0
vnoremap <F9> y \| :call term_sendkeys(g:ipython_terminal_name,@")<cr>j0
nnoremap <C-enter> :call SendCell()<cr>
" Clear REPL
nnoremap <C-l> :call term_sendkeys(g:ipython_terminal_name,"\<c-l>")<cr>
setlocal foldmethod=indent



let g:conda_activate = 'myenv'
let g:ipython_terminal_name = 'IPYTHON'
let g:cell_delimiter = "# %%" 
" Select the IPYTHON profile settings in  ~/.ipython 
let g:ipython_profile = 'autoreload_profile' 

" Highlight colors for "# %%" string
match VisualNOS /#\ %%/ 

" Nice exercise but it may not be needed as we for the statusline we are
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


" This is my own REPL
func! SendCell(delim,env,ipy_term,ipy_profile)
    if !bufexists(a:ipy_term)
       call  term_start('C:\\Users\\yt75534\\Miniconda3\\condabin\\conda.bat activate ' . a:env . 
                   \ ' && call echo Conda env:%CONDA_DEFAULT_ENV% && ipython --profile=' .a:ipy_profile, 
                   \ {'term_name': a:ipy_term, 'vertical': v:true} )
    endif
    " a:var is the syntax for using a variable in a function
    " In Normal mode, go to the next line
    norm! j
    " echo a:delim
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
    call term_sendkeys(a:ipy_term,"run -i ". g:filename . "\n")
endfunc



" Some key-bindings
nnoremap <F9> yy \| :call term_sendkeys(g:ipython_terminal_name,@")<cr>j0
vnoremap <F9> y \| :call term_sendkeys(g:ipython_terminal_name,@")<cr>j0
nnoremap <C-enter> :call SendCell(g:cell_delimiter,g:conda_activate,g:ipython_terminal_name,g:ipython_profile)<cr>
" Clear REPL
nnoremap <C-l> :call term_sendkeys(g:ipython_terminal_name,"\<c-l>")<cr>
setlocal foldmethod=indent


