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
    var input_file = expand('%:p')
    var output_file = expand('%:p:r') .. "." .. format
    var css_style = ""
    if format ==# 'html'
        css_style = "-c ~/dotfiles/my_css_style.css"
    endif
    exe "make " .. input_file  .. " -o " ..  output_file .. " -s " .. css_style
    silent exe $'!{g:start_cmd} {shellescape(expand("%:r"))}.{format}'
enddef

# Usage :MarkdownRender, :MarkdownRender pdf, :MarkdownRender docx, etc
command! -nargs=? -buffer MarkdownRender MarkdownRender(<f-args>)
