vim9script

export def Echoerr(msg: string)
  echohl ErrorMsg | echom $'{msg}' | echohl None
enddef

export def Echowarn(msg: string)
  echohl WarningMsg | echom $'{msg}' | echohl None
enddef
# Search and replace in files.
# Risky calls external 'sed' and it won't ask for confirmation.
var match_id = 0
def SearchReplacementHelper(search_user: string = ''): list<string>
  augroup SEARCH_HI | autocmd!
    autocmd CmdlineChanged @ if match_id > 0 | matchdelete(match_id) | endif |
    search(getcmdline(), 'w') | match_id = matchadd('IncSearch', getcmdline())
      | redraw!
    autocmd CmdlineLeave @ if match_id > 0 | matchdelete(match_id) | match_id
    = 0 | endif
  augroup END
  var search = empty(search_user) ? input("String to search: ") : search_user
  if !empty(search_user)
    if match_id > 0
      matchdelete(match_id)
    endif
    match_id = matchadd('IncSearch', search_user)
    redraw!
  endif
  if empty(search)
    echom ""
    autocmd! SEARCH_HI
    augroup! SEARCH_HI
    return []
  endif
  autocmd! SEARCH_HI
  augroup! SEARCH_HI
  if match_id > 0
    matchdelete(match_id)
  endif
  echo ""
  var replacement = input("\nReplacement: ")
  return [search, replacement]
enddef

def SearchAndReplaceInFiles(search_user: string = '')
  echo "Search & replace in files\n"
  var search_replacement = SearchReplacementHelper(search_user)
  var search = search_replacement[0]
  var replacement = search_replacement[1]
  if empty(search_replacement)
    return
  endif
  var pattern = input("\nIn files: ", '*.')
  if empty(pattern)
    echom ""
    return
  endif
  var risky = input("\nRisky: ", 'n')
  if risky !~ "[yes]" &&  risky !~ "[no]" && empty(risky)
    return
  endif

  if risky[0] =~ "y"
    var cmd = 'Nothing'
    if g:os != 'Windows'
      cmd = printf('!find %s -type f -exec sed -i ''s/%s/%s/g'' {} \;',
        pattern, search, replacement)
    else
      # TODO: Command for Windows: to test
      # cmd = $'powershell -command "gci -Recurse -File | ForEach-Object \{
      #       \  (Get-Content $_.FullName) -replace ''{search}'',
      #       ''{replacement}'' | Set-Content $_.FullName
      #       \\}"'
    endif
    echo $"\n{cmd}"
  else
    var vimgrep_opts = input("\nVimgrep options: ", 'gj')
    var substitute_opts = input("\nSubstitute options: ", 'gci')
    if empty(substitute_opts)
      echo ''
      return
    endif
    var cmd = $'vimgrep /{search}/{vimgrep_opts} **/{pattern}'
    echo $"\n{cmd}"
    exe cmd
    cmd = $'cfdo :%s/{search}/{replacement}/{substitute_opts}'
    echo $"\n{cmd}"
    exe cmd
    echo "\nType ':wall' to save all or ':cfdo' u to undo"
  endif
enddef

# TODO: cannot distinguish when user hit esc or cr. Perhaps you want to use
# cmdleave?
def SearchAndReplace(search_user: string = '')
  echo "Search & replace in current buffer\n"
  var search_replacement = SearchReplacementHelper(search_user)
  if empty(search_replacement)
    return
  endif
  var search = search_replacement[0]
  if empty(search)
    return
  endif
  var replacement = search_replacement[1]
  var opts = input("\nSubstitute options: ", 'gci')
  if empty(opts)
    echo ''
    return
  endif
  var range = input("\nRange: ", '%')
  if empty(range)
    echo ''
    return
  endif
  # echom range
  # if range !~ "\(%\)"
  #   echom "  NOK"
  # else
  #   echom "  OK"
  # endif
  exe $':{range}s/{search}/{replacement}/{opts}'
enddef

command! -nargs=? SearchAndReplace SearchAndReplace(<f-args>)
command! -nargs=? SearchAndReplaceInFiles SearchAndReplaceInFiles(<f-args>)

# =======================
export def TrimWhitespace()
  var currwin = winsaveview()
  var save_cursor = getpos(".")
  silent! :keeppatterns :%s/\s\+$//e
  silent! :%s/\($\n\s*\)\+\%$//
  winrestview(currwin)
  setpos('.', save_cursor)
enddef

export def InsertInLine(lnum: number, pos: number, insert: string)
   # Insert string in the given column
   var line = getline(lnum)                      # Get the current line
   var new_line = strcharpart(line, 0, pos) .. insert .. strcharpart(line, pos)
   setline(lnum, new_line)                  # Set the modified line back
enddef

export def GetTextObject(textobject: string): dict<any>
  # You pass a text object like "inside word", etc. and it returns it, along
  # with the start and end positions.
  # Start and end positions are of the form
  # [buffer_number, line_number, column_number, screen_column].
  #
  # For example GetTextObjet('aw') it returns "around word".

  # backup the content of register t (arbitrary choice, YMMV)
  var oldreg = getreg("t")
  # silently yank the text covered by whatever text object
  # was given as argument into register t
  noautocmd execute 'silent normal "ty' .. textobject
  # save the content of register t into a variable
  var text = getreg("t")
  # restore register t
  setreg("t", oldreg)
  # return the content of given text object
  var text_object = {text: text, start_pos: getpos("'["), end_pos: getpos("']")}
  return text_object
enddef

export def Redir(cmd: string, rng: number, start: number, end: number)
  # Used to redirect the output from the terminal in a scratch buffer
  #
  # Example: :Redir !ls
  #
  # You can use it also to redirect the output of some Vim commands
  for win in range(1, winnr('$'))
    if !empty(getwinvar(win, 'scratch'))
      execute ":" .. win .. 'windo :close'
    endif
  endfor
  var output = []
  if cmd =~ '^!'
    var cmd_filt = cmd =~ ' %'
      ? matchstr(substitute(cmd, ' %', ' '
      .. shellescape(escape(expand('%:p'), '\')), ''), '^!\zs.*')
      : matchstr(cmd, '^!\zs.*')
    if rng == 0
      output = systemlist(cmd_filt)
    else
      var joined_lines = join(getline(start, end), '\n')
      var cleaned_lines = substitute(shellescape(joined_lines), "'\\\\''",
        "\\\\'", 'g')
      output = systemlist(cmd_filt .. " <<< $" .. cleaned_lines)
    endif
  else
    var tmp = execute(cmd)
    output = split(tmp, "\n")
  endif
  vnew
  w:scratch = 1
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  setline(1, output)
enddef


var color_is_shown = false
# export def ColorsShow(clear: bool = false): void
export def ColorsToggle(): void
  if exists('b:prop_ids')
    map(b:prop_ids, (_, p) => prop_remove({id: p}))
  endif

  if color_is_shown
    color_is_shown = false
    return
  endif

  # This is only needed for removing.
  b:prop_ids = []

  for row in range(1, line('$'))
    var current = getline(row)
    var cnt = 1
    var [hex, starts, ends] = matchstrpos(current, '#\x\{6\}', 0, cnt)
    while starts != -1
      var col_tag = "inline_color_" .. hex[1 : ]
      var col_type = prop_type_get(col_tag)
      if col_type == {}
        hlset([{name: col_tag, guibg: hex, guifg: "black"}])
        prop_type_add(col_tag, {highlight: col_tag})
      endif
      add(b:prop_ids, prop_add(row, starts + 1, { length: ends - starts,
        type: col_tag }))
      cnt += 1
      [hex, starts, ends] = matchstrpos(current, '#\x\{6\}', 0, cnt)
    endwhile
  endfor
  color_is_shown = true
enddef

# Highlight toggle
# TODO:
# 1) Three different highlights
# 2) Normal mode highlight current line
# 3) Set operation on selection.
def Highlight()
  if !exists('b:prop_id')
    b:prop_id = 0
  endif
  if prop_type_get('my_hl') == {}
    prop_type_add('my_hl', {'highlight': 'DiffDelete'})
  endif

  var start_line = line("'<")
  var end_line = line("'>")
  var start_col = col("'<")
  var end_col = col("'>")
  # echom prop_list(line('.'), {'types':$ ['my_hl']})
  # echom prop_list(start_line, {'types': ['my_hl']})


  # If there are no prop under the cursor position, then add, otherwise if a
  # prop is detected remove it.
  var no_prop = empty(prop_list(start_line, {'types': ['my_hl']}))
  if no_prop
    prop_add(start_line, start_col, {'end_lnum': end_line, 'end_col': end_col,
      'type': 'my_hl', 'id': b:prop_id})
    b:prop_id = b:prop_id + 1
  else
    var id = prop_list(start_line, {'types': ['my_hl']})[0]['id']
    prop_remove({'id': id})
  endif
enddef

# --------- General formatting function -----------------
export def FormatWithoutMoving(a: number = 0, b: number = 0)

  var view = winsaveview()
  if a == 0 && b == 0
    silent exe $":norm! gggqG"
  else
    var interval = b - a + 1
    silent exe $":norm! {a}gg{interval}gqq"
  endif

  if v:shell_error != 0
    undo
    echoerr $"'{&l:formatprg->matchstr('^\s*\S*')}' returned errors."
  else
    # Display format command
    redraw
    if !empty(&l:formatprg)
      Echowarn($'{&l:formatprg}')
    else
      Echowarn("'formatprg' is empty. Using default formatter.")
    endif
  endif
  winrestview(view)

enddef

var prettier_supported_filetypes = ['json', 'yaml', 'html', 'css']
def SetFormatter()
  if !empty(&filetype)
      && index(prettier_supported_filetypes, &filetype) != -1
      && executable('prettier')
    var cmd = $"prettier --prose-wrap always --print-width {&l:textwidth}
          \ --stdin-filepath {shellescape(expand('%'))}"
    &l:formatprg = cmd
  endif
enddef

augroup PRETTIFY
  autocmd!
  autocmd BufEnter * SetFormatter()
augroup END

# --------------------------------------------------------------

export def QuitWindow()
  # Close window and wipe buffer but it prevent to quit Vim if one window is
  # left.
  if winnr('$') != 1
    quit
  endif
enddef

# ------------ Terminal functions ------------------
# Change all the terminal directories when you change vim directory
export def ChangeTerminalDir()
  for ii in term_list()
    if bufname(ii) == "JULIA"
      term_sendkeys(ii, 'cd("' .. getcwd() .. '")' .. "\n")
    else
      term_sendkeys(ii, "cd " .. getcwd() .. "\n")
    endif
  endfor
enddef

# Close all terminals with :qa!
export def WipeoutTerminals()
  for buf_nr in term_list()
    exe "bw! " .. buf_nr
  endfor
enddef

# TERMINAL IN POPUP
# This function can be called only from a terminal windows/popup, so there is
# no risk of closing unwanted popups (such as HelpMe popups).

export def Quit_term_popup(quit: bool)
  if empty(popup_list())
    if quit
      exe "quit"
    else
      exe "close"
    endif
  else
    if quit
      var bufno = bufnr()
      popup_close(win_getid())
      exe "bw! " .. bufno
    else
      popup_close(win_getid())
    endif
  endif
enddef

var my_term_name = &shell
export def OpenMyTerminal()
  var terms_name = []
  for ii in term_list()
    add(terms_name, bufname(ii))
  endfor

  if term_list() == [] || index(terms_name, my_term_name) == -1
    # enable the following and remove the popup_create part if you want
    # the terminal in a "classic" window.
    # vert term_start(&shell, {'term_name': 'MANIM' })
    var saved_shell = &shell
    if g:os == "Windows"
      &shell = "powershell"
    endif
    var buf_no = term_start(&shell, {'term_name': my_term_name, 'hidden': 1,
      'term_finish': 'close'})
    setbufvar(buf_no, '&buflisted', 0)
    if g:os == "Windows"
      var curr_dir = expand('%:h')
      term_sendkeys(buf_no, $'cd("{curr_dir}")' .. "\n")
      &shell = saved_shell
    endif
  endif

  popup_create(bufnr(my_term_name), {
    title: my_term_name,
    line: &lines,
    col: &columns,
    pos: "botright",
    posinvert: false,
    borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
    border: [1, 1, 1, 1],
    maxheight: &lines - 1,
    minwidth: 80,
    minheight: 20,
    close: 'button',
    resize: true
  })
enddef

export def HideMyTerminal()
  var terms_name = []
  for ii in term_list()
    add(terms_name, bufname(ii))
  endfor
  # This works because once a terminal popup is in place, it takes all the
  # focus and you cannot go anywhere if you don't close it first.
  if index(terms_name, my_term_name) != -1 && !empty(popup_list())
    popup_close(popup_list()[0])
  endif
enddef


# Make vim to speak on macos
if has('mac')
  # <esc> is used in xnoremap because '<,'> are updated once you leave visual
  # mode
  xnoremap <leader>s <esc><ScriptCmd>TextToSpeech(line("'<"), line("'>"))<cr>
  command! -range Say vim9cmd TextToSpeech(<line1>, <line2>)

  def TextToSpeech(firstline: number, lastline: number)
    exe $":{firstline},{lastline}w !say"
  enddef
endif

# Some mappings to learn
# noremap <unique> <script> <Plug>Highlight <esc><ScriptCmd>Highlight()
#
# TODO: separate leading and trailing chars
# TODO: allow to use special chars like pre = '\<CR>\<ESC>ipippo'
export def VisualSurround(pre: string, post: string)
  # Usage:
  #   Visual select text and hit <leader> + parenthesis
  #
  var pre_len = strlen(pre)
  var post_len = strlen(post)
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
  var leading_chars = strcharpart(getline(line_start), column_start - 1 -
    pre_len, pre_len)
  var trailing_chars = strcharpart(getline(line_end), column_end, post_len)

  # echom "leading_chars: " .. leading_chars
  # echom "trailing_chars: " .. trailing_chars

  cursor(line_start, column_start)
  var offset = 0
  if leading_chars == pre
    exe $"normal! {pre_len}X"
    offset = -pre_len
  else
    exe $"normal! i{pre}"
    offset = pre_len
  endif

  # Some chars have been added if you are working on the same line
  if line_start == line_end
    cursor(line_end, column_end + offset)
  else
    cursor(line_end, column_end)
  endif

  if trailing_chars == post
    exe $"normal! l{post_len}x"
  else
    exe $"normal! a{post}"
  endif
enddef

export def Gx()

  if exists('g:start_cmd') == 0 && exists(':Open') == 0
    echohl Error
    echomsg "Can't find proper opener for an URL!"
    echohl None
    return
  endif

  # URL regexes
  var rx_base = '\%(\%(http\|ftp\|irc\)s\?\|file\)://\S'
  var rx_bare = rx_base .. '\+'
  var rx_embd = rx_base .. '\{-}'

  var URL = ""

  # markdown URL [link text](http://ya.ru 'yandex search')
  var save_view = winsaveview()
  defer winrestview(save_view)
  if searchpair('\[.\{-}\](', '', ')\zs', 'cbW', '', line('.')) > 0
    URL = matchstr(getline('.')[col('.') - 1 : ], '\[.\{-}\](\zs' .. rx_embd
      .. '\ze\(\s\+.\{-}\)\?)')
  endif

  # asciidoc URL http://yandex.ru[yandex search]
  if empty(URL)
    if searchpair(rx_bare .. '\[', '', '\]\zs', 'cbW', '', line('.')) > 0
      URL = matchstr(getline('.')[col('.') - 1 : ], '\S\{-}\ze[')
    endif
  endif

  # HTML URL <a href='http://www.python.org'>Python is here</a>
  #          <a href="http://www.python.org"/>
  if empty(URL)
    if searchpair('<a\s\+href=', '', '\%(</a>\|/>\)\zs', 'cbW', '', line('.'))
        > 0
      URL = matchstr(getline('.')[col('.') - 1 : ],
        'href=["' .. "'" .. ']\?\zs\S\{-}\ze["' .. "'" .. ']\?/\?>')
    endif
  endif

  # URL <http://google.com>
  if empty(URL)
    URL = matchstr(expand("<cWORD>"), $'^<\zs{rx_bare}\ze>$')
  endif

  # URL (http://google.com)
  if empty(URL)
    URL = matchstr(expand("<cWORD>"), $'^(\zs{rx_bare}\ze)$')
  endif

  # barebone URL http://google.com
  if empty(URL)
    URL = matchstr(expand("<cWORD>"), rx_bare)
  endif

  if empty(URL)
    echo "Invalid URL"
    return
  endif

  if exists(":Open") != 0
    exe $"Open {escape(URL, '#%!')}"
  else
    exe $'!{g:start_cmd} "{escape(URL, '#%!')}"'
  endif
enddef
