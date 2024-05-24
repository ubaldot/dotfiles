vim9script


compiler pandoc

augroup PRETTIER
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> call Prettify()
augroup END


def Prettify()
    # If prettier is not available, then the buffer content will be canceled upon
    # write
    if executable('prettier') && (&filetype == 'markdown' || &filetype == 'markdown.txtfmt')
        var win_view = winsaveview()
        exe $":%!prettier 2>{g:null_device} --prose-wrap always
                    \ --print-width {&l:textwidth} --stdin-filepath {shellescape(expand("%"))}"
        winrestview(win_view)
    else
        echom "prettier not installed OR current filetype is not markdown!"
    endif
enddef

def MarkdownRender(format = "html")
    exe "make " .. expand(format)
    silent exe $'!{g:start_cmd} {shellescape(expand("%:r"))}.{format}'
enddef

# Usage :MarkdownRender, :MarkdownRender pdf, :MarkdownRender docx, etc
command! -nargs=? -buffer MarkdownRender MarkdownRender(<f-args>)
