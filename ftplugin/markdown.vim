vim9script

def MarkdownRender()
    silent exe "!cat " .. expand('%') .. " | pandoc -f gfm | browser"
enddef

command -buffer MarkdownRender MarkdownRender()
