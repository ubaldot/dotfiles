vim9script

# If prettier is not available, then the buffer content will be canceled upon
# write
augroup PRETTIER
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> call Prettify()
augroup END

def Prettify()
    if executable('prettier')
        var win_view = winsaveview()
        silent exe $":%!prettier 2>{g:null_device} --prose-wrap always
                    \ --print-width {&l:textwidth} --stdin-filepath {shellescape(expand("%"))}"
        winrestview(win_view)
    else
        echom "prettier not installed!"
    endif
enddef

def MarkdownRender()
    var out_html = $"{g:tmp}/md_rendered.html"
    silent exe $"!pandoc {shellescape(expand("%")} -f gfm -o {out_html}"
    silent exe $"!{g:start_cmd} {out_html}"
enddef

command -buffer MarkdownRender MarkdownRender()
