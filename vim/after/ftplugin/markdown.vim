vim9script

def Bold_Italic_Strikethrough(chars: string)
  # var [line_start, column_start] = getpos("v")[1 : 2]
  # var [line_end, column_end] = getpos(".")[1 : 2]
  var chars_len = strlen(chars)
  var [line_start, column_start] = getpos("'<")[1 : 2]
  var [line_end, column_end] = getpos("'>")[1 : 2]
  if line_start > line_end
    var tmp = line_start
    line_start = line_end
    line_end = tmp

    tmp = column_start
    column_start = column_end
    column_end = tmp
  endif
  if line_start == line_end && column_start > column_end
    var tmp = column_start
    column_start = column_end
    column_end = tmp
  endif
  var leading_chars = strcharpart(getline(line_start), column_start - 1 - chars_len, chars_len)
  var trailing_chars = strcharpart(getline(line_end), column_end, chars_len)

  # echom "leading_chars: " .. leading_chars
  # echom "trailing_chars: " .. trailing_chars

  cursor(line_start, column_start)
  var offset = 0
  if leading_chars == chars
    execute($"normal! {chars_len}X")
    offset = -chars_len
  else
    execute($"normal! i{chars}")
    offset = chars_len
  endif

  # Some chars have been added if you are working on the same line
  if line_start == line_end
    cursor(line_end, column_end + offset)
  else
    cursor(line_end, column_end)
  endif

  if trailing_chars == chars
      execute($"normal! l{chars_len}x")
  else
      execute($"normal! a{chars}")
  endif
enddef

xnoremap <buffer> <silent> b <esc><ScriptCmd>Bold_Italic_Strikethrough('**')<cr>
xnoremap <buffer> <silent> i <esc><ScriptCmd>Bold_Italic_Strikethrough('*')<cr>
xnoremap <buffer> <silent> s <esc><ScriptCmd>Bold_Italic_Strikethrough('~~')<cr>

if executable('pandoc')
  compiler pandoc
else
  echoerr "'pandoc' not installed. 'MarkdownRender' won't work"
endif

# if has('gui')
#   var fontsize = str2nr(matchstr(&guifont, '\v:h\zs(\d*)')) + 2
#   &l:guifont = "HackNF-Regular:h" .. string(fontsize)
#   # &l:guifont = "FiraCode-Regular:h" .. fontsize
# endif

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
