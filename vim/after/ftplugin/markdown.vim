vim9script

if executable('pandoc')
  compiler pandoc
else
  echoerr "'pandoc' not installed. 'MarkdownRender' won't work"
endif

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
