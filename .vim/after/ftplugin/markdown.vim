vim9script

import g:dotvim .. "/lib/myfunctions.vim"
&l:tabstop = 2

# Bold, italic, strikethrough
xnoremap <buffer> <silent> <leader>b
      \ <esc><ScriptCmd>myfunctions.Surround('**', '**')<cr>
xnoremap <buffer> <silent> <leader>i
      \ <esc><ScriptCmd>myfunctions.Surround('*', '*')<cr>
xnoremap <buffer> <silent> <leader>s
      \ <esc><ScriptCmd>myfunctions.Surround('~~', '~~')<cr>

inoremap ä `

if executable('prettier')
  &l:formatprg = $"prettier --prose-wrap always --print-width {&l:textwidth}
        \ --stdin-filepath {shellescape(expand('%'))}"

  # Autocmd to format with ruff
  augroup MARKDOWN_FORMAT_ON_SAVE
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> myfunctions.FormatWithoutMoving()
  augroup END
else
  echoerr "'prettier' not installed!'"
endif

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

export def MarkdownRender(format = "html")
  var input_file = expand('%:p')
  var output_file = $'{expand('%:p:r')}.{format}'
  var css_style = ""
  if format ==# 'html'
    css_style = $"-c {$HOME}/dotfiles/my_css_style.css"
  endif
  silent exe $"make {input_file} -o {output_file} -s {css_style}"

  var open_file_cmd = $'{g:start_cmd} {shellescape(output_file)}'
    ->substitute("'", "", "g")
  # echom open_file_cmd
  job_start(open_file_cmd)
enddef

export def MarkdownRenderCompleteList(A: any, L: any, P: any): list<string>
  return ['html', 'docx', 'pdf', 'txt', 'jira', 'csv', 'ipynb', 'latex',
    'odt', 'rtf']
enddef

def IsLink(): bool
  # Compare foo with [foo]. If they match, then what is inside the [] it
  # possibly be a link. Next, it check if there is a (bla_bla) just after ].
  # Link alias must be words.
  # Assume that a link (or a filename) cannot be broken into multiple lines
  var saved_curpos = getcurpos()
  var is_link = false
  var alias_link = myfunctions.GetTextObject('iw')

  # Handle singularity if the cursor is on '[' or ']'
  if alias_link == '['
    norm! l
    alias_link = myfunctions.GetTextObject('iw')
  elseif alias_link == ']'
    norm! h
    alias_link = myfunctions.GetTextObject('iw')
  endif

  # Check if foo and [foo] match and if there is a (bla bla) after ].
  var alias_link_bracket = myfunctions.GetTextObject('a[')
  if alias_link == alias_link_bracket[1 : -2]
    norm! f]
    if getline('.')[col('.')] == '('
      var line_open_parenthesis = line('.')
      norm! l%
      var line_close_parenthesis = line('.')
      if line_open_parenthesis == line_close_parenthesis
        # echo "Is a link"
        is_link = true
      else
        # echo "Is not a link"
        is_link = false
      endif
    else
      is_link = false
      # echo "Is not a link"
    endif
  else
    is_link = false
    # echo "Is not a link"
  endif
  setpos('.', saved_curpos)
  return is_link
  # TEST:
  # echo (line[start] == '[' && line[nd] == ']') ? 'Word is surrounded by []'
  # : 'Word is not [surrounoded]( by [] # )'
enddef

def ToggleMark()
  var line = getline('.')
  if match(line, '\[\s*\]') != -1
    setline('.', substitute(line, '\[\s*\]', '[x]', ''))
  elseif match(line, '\[x\]') != -1
    setline('.', substitute(line, '\[x\]', '[ ]', ''))
  endif
enddef
nnoremap <buffer> <silent> <leader>x <ScriptCmd>ToggleMark()<cr>

def HandleLink()
  if IsLink()
    norm! f(l
    var link = myfunctions.GetTextObject('i(')
    if filereadable(link)
      exe $'edit {link}'
    elseif exists(':Open')
      exe $'Open {link}'
    else
      exe $'!{g:start_cmd} -a safari.app {link}'
    endif
  else
    var link = input('Insert link: ', '', 'file')
    if !empty(link)
      # Create link
      norm! lbi[
      norm! ea]
      execute $'norm! a({link})'
      norm! F]h
      if link !~ '^https://'
        exe $'edit {link}'
        write
      endif
    endif
  endif
enddef

nnoremap <buffer> <silent> <enter> <ScriptCmd>HandleLink()<cr>
nnoremap <buffer> <silent> <backspace> <Cmd>buffer #<cr>

# Usage :MarkdownRender, :MarkdownRender pdf, :MarkdownRender docx, etc
command! -nargs=? -buffer -complete=customlist,MarkdownRenderCompleteList
      \ MarkdownRender MarkdownRender(<f-args>)
