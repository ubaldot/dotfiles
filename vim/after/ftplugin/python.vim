vim9script
# Tell vim where is Python. OBS: this is independent of the plugins!

setlocal foldmethod=indent

# Autocmd to format with black.
augroup BLACK
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> Black(&l:textwidth)
augroup END

def Black(textwidth: number)
    # If black is not available, then the buffer content will be canceled upon
    # write. To avoid appending stdout and stderr to the buffer we use
    # --quiet.
    if executable('black') && &filetype == 'python'
                var win_view = winsaveview()
                exe $":%!black - --line-length {textwidth}
                      \ --stdin-filename {shellescape(expand("%"))} --quiet"
                winrestview(win_view)
    else
        echom "black not installed!"
    endif

    if v:shell_error != 0
      undo
      # throw prevents writing on disk
      # throw "'black' errors!"
      # redraw!
      echoerr "'black' errors!"
    endif
enddef

# Call black to format 120 line length
command! -buffer Black120 Black(120)

# Manim
if has("mac")
    command! -buffer ManimDocs silent :!open -a safari.app
            \ ~/Documents/manimce-latest/index.html
elseif has("Linux")
    command! -buffer ManimDocs silent :!xdg-open
            \ ~/Documents/manimce-latest/index.html
else
    command! -buffer ManimDocs silent :!start
            \ ~/Documents/manimce-latest/index.html
endif

# Manim: Jump to next-prev section
nnoremap <buffer> <c-m> /\<self.next_section\><cr>
nnoremap <buffer> <c-n> ?\<self.next_section\><cr>

# For replica
# nmap <buffer> <c-enter> <Plug>ReplicaSendCell<cr>j
