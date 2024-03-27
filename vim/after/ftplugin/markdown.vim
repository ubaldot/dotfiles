vim9script

augroup PRETTIER
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> call Prettify()
augroup END

def Prettify()
    var win_view = winsaveview()
    silent exe $":%!prettier 2>{g:null_device} --prose-wrap always
                \ --print-width {&l:textwidth} --stdin-filepath {shellescape(expand("%"))}"
    winrestview(win_view)
    # echo "File prettified!"
enddef

# Consequently, this does not work
nnoremap <buffer> g- <ScriptCmd>Prettify()<cr>


def MarkdownRender()
    var out_html = $"{g:tmp}/md_rendered.html"
    silent exe $"!pandoc {shellescape(expand("%")} -f gfm -o {out_html}"
    silent exe $"!{g:start_cmd} {out_html}"
enddef

command -buffer MarkdownRender MarkdownRender()
