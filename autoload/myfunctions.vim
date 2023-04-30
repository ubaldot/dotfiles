vim9script

# Remove trailing white spaces at the end of each line and at the end of the file
export def g:TrimWhitespace()
    var currwin = winsaveview()
    var save_cursor = getpos(".")
    silent! :keeppatterns :%s/\s\+$//e
    silent! :%s/\($\n\s*\)\+\%$//
    winrestview(currwin)
    setpos('.', save_cursor)
enddef

# Commit a dot.
# It is related to the opened buffer not to pwd!
export def g:CommitDot()
    # curr_dir = pwd
    cd %:p:h
    exe "!git add -u && git commit -m '.'"
    # cd curr_dir
enddef




export def g:Diff(spec: string)
    vertical new
    setlocal bufhidden=wipe buftype=nofile nobuflisted noswapfile
    var cmd = bufname('#')
    if !empty(spec)
        cmd = "!git -C " .. shellescape(fnamemodify(finddir('.git', '.;'), ':p:h:h')) .. " show " .. spec .. ":#"
    endif
    execute "read " .. cmd
    silent :0d _
    &filetype = getbufvar('#', '&filetype')
    augroup Diff
      autocmd!
      autocmd BufWipeout <buffer> diffoff!
    augroup END
    diffthis
    wincmd p
    diffthis
enddef
