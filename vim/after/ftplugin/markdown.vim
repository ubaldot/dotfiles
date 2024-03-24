vim9script

var null_device = "/dev/null"
if has("win32")
   null_device = "nul"
endif


augroup PRETTIER
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> call Prettify()
augroup END

def Prettify()
    var win_view = winsaveview()
    silent exe $":%!prettier --prose-wrap always --print-width {&l:textwidth}
                \ --stdin-filepath {shellescape(expand("%"))}"
    winrestview(win_view)
    # echo "File prettified!"
enddef

# Consequently, this does not work
nnoremap <buffer> g- <ScriptCmd>Prettify()<cr>

def MarkdownRender()
    if has("win32")
        silent exe "!type " .. expand('%') .. " | pandoc -f gfm -o C:\\temp\\md_rendered.html | start C:\\temp\\md_rendered.html"
    elseif has("mac")
        silent exe "!cat " .. expand('%') .. " | pandoc -f gfm -o /tmp/md_rendered.html | open /tmp/md_rendered.html"
    else
        silent exe "!cat " .. expand('%') .. " | pandoc -f gfm -o /tmp/md_rendered.html | xdg-open /tmp/md_rendered.html"
    endif
enddef

command -buffer MarkdownRender MarkdownRender()
