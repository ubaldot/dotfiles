vim9script

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
