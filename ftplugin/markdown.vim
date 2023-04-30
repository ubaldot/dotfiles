vim9script

# Markdown
# def MarkdownRender()
#     write
#     var tmp = tempname() .. ".html"
#     exe ":%!markdown"
#     writefile(getline(1, '$'), tmp, 'b')
#     normal u
#     exe "!open -a safari.app " .. tmp
# enddef

def MarkdownRender()
    silent exe "!cat " .. expand('%') .. " | pandoc -f gfm | browser"
enddef

command -buffer MarkdownRender :call MarkdownRender()
