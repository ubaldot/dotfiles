vim9script
# Tell vim where is Python. OBS: this is independent of the plugins!
# You must check in the vim version what dll is required in the field -DDYNAMIC_PYTHON_DLL=\python310.dll\

setlocal foldmethod=indent

# Autocmd to format with black.
augroup BLACK
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> call Black(&l:textwidth)
augroup END

def Black(textwidth: number)
    # If black is not available, then the buffer content will be canceled upon
    # write
    if executable('black')
                var win_view = winsaveview()
                exe $":%!black - -q 2>{g:null_device} --line-length {textwidth}
                            \ --stdin-filename {shellescape(expand("%"))}"
                winrestview(win_view)
    else
        echom "black not installed!"
    endif
enddef

# Call black to format 120 line length
command! Black120 call Black(120)


# Manim
if has("mac")
    command! ManimDocs silent :!open -a safari.app
            \ ~/Documents/manimce-latest/index.html
elseif has("Linux")
    command! ManimDocs silent :!xdg-open
            \ ~/Documents/manimce-latest/index.html
else
    command! ManimDocs silent :!start
            \ ~/Documents/manimce-latest/index.html
endif

# Manim: Jump to next-prev section
nnoremap <buffer> <c-m> /\<self.next_section\><cr>
nnoremap <buffer> <c-n> ?\<self.next_section\><cr>
