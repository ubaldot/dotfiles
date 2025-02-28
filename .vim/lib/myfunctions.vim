vim9script

export def Echoerr(msg: string)
  echohl ErrorMsg | echom $'{msg}' | echohl None
enddef

export def Echowarn(msg: string)
  echohl WarningMsg | echom $'{msg}' | echohl None
enddef
# Search and replace in files.
# Risky calls external 'sed' and it won't ask for confirmation.
def g:ClearAllMatches()
    for match in getmatches()
        matchdelete(match.id)
    endfor
enddef

def SearchReplacementHelper(search_user: string = ''): list<string>
  var return_val = []
  w:match_id = 0
  var search_text = ''

  # First round
  if empty(search_user)
    augroup SEARCH_HI
      autocmd!
      autocmd CmdlineChanged @ {
                        if w:match_id > 0
                          matchdelete(w:match_id)
                        endif
                        var inserted_text = getcmdline()
                        w:match_id = matchadd('IncSearch', inserted_text)
                        search(inserted_text, 'w')
                        redraw
                      }
    augroup END

    search_text = input("Pattern to search: ")
    autocmd! SEARCH_HI
    augroup! SEARCH_HI

  else
    search_text = search_user
    search(search_text, 'w')
    w:match_id = matchadd('IncSearch', search_text)
  endif

  # second round
  redraw!
  echo "String to search: " .. search_text
  if !empty(search_text)
    var replacement_text = input("Replacement: ")
    return_val = empty(replacement_text) ? [] : [search_text, replacement_text]
  endif

  # Cleanup
  if w:match_id > 0
    matchdelete(w:match_id)
  endif
  unlet w:match_id
  return return_val
enddef

def SearchAndReplaceInFiles(search_user: string = '')
  echo "Search & replace in files\n"
  var search_replacement = SearchReplacementHelper(search_user)
  var search = ''
  var replacement = ''
  if empty(search_replacement)
    return
  else
    search = search_replacement[0]
    replacement = search_replacement[1]
  endif
  var pattern = input("\nIn files: ", '**/*.')
  if empty(pattern)
    echom ""
    return
  endif

  # Search part
  var vimgrep_opts =
    input("\nVimgrep options (g = add every match, j = no direct jump, f = fuzzy search): ", 'gj')
  if empty(vimgrep_opts)
    echo ''
    return
  endif
  var search_cmd = $'vimgrep /{search}/{vimgrep_opts} {pattern}'
  echo $"\n{search_cmd}"
  exe search_cmd

  # Replacement part
  var substitute_opts = input("\nSubstitute options: ", 'gci')
  if empty(substitute_opts)
    echo ''
    return
  endif
  # TODO to be tested
  exe $'noautocmd cdo :s/{search}/{replacement}/{substitute_opts} | update'
  echo "\nType ':cdo bw' to close all the files or ':cdo u' to undo"
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

# TODO it may be limiting to have 'string' only
export def KeysFromValue(dict: dict<string>, target_value: string): list<string>
    # Given a value, return all the keys associated to it
    return keys(filter(copy(dict), $'v:val == "{target_value}"'))
enddef

export def DictToListOfDicts(d: dict<any>): list<dict<any>>
  # Convert a dict in a list of dict.
  #
  # For example, {a: 'foo', b: 'bar', c: 'baz'} becomes
  # [{a: 'foo'}, {b: 'bar'}, {c: 'baz'}]
  #
  var list_of_dicts = []
  for [k, v] in items(d)
    add(list_of_dicts, {[k]: v})
  endfor
  return list_of_dicts
enddef

export def ZipLists(l1: list<any>, l2: list<any>): list<list<any>>
    # Zip-like function, like in Python
    var min_len = min([len(l1), len(l2)])
    return map(range(min_len), $'[{l1}[v:val], {l2}[v:val]]')
enddef

export def GetTextObject(textobject: string): dict<any>
  # You pass a text object like 'iw' and it returns the text
  # associated to it along with the start and end positions.
  #
  # Note that when you yank some text, the registers '[' and ']' are set, so
  # after call this function, you can retrieve start and end position of the
  # text-object by looking at such marks.
  #
  # The function also work with motions.

  # Backup the content of register t (arbitrary choice, YMMV) and marks
  var oldreg = getreg("t")
  var saved_A = getcharpos("'[")
  var saved_B = getcharpos("']")
  # silently yank the text covered by whatever text object
  # was given as argument into register t. Yank also set marks '[ and ']
  noautocmd execute 'silent normal "ty' .. textobject

  var text = getreg("t")
  var start_pos = getcharpos("'[")
  var end_pos = getcharpos("']")

  # restore register t and marks
  setreg("t", oldreg)
  setcharpos("'[", saved_A)
  setcharpos("']", saved_B)

  return {text: text, start: start_pos, end: end_pos}
enddef

export def RemoveSurrounding(
    open_delimiter_dict: dict<string>,
    close_delimiter_dict: dict<string>)
    var interval = IsInRange(open_delimiter_dict, close_delimiter_dict)
    if !empty(interval)
      # Remove left delimiter
      var lA = interval[0][1]
      var cA = interval[0][2]
      var newline =
        strcharpart(getline(lA), 0, cA - 1 - len(keys(open_delimiter_dict)[0]))
        .. strcharpart(getline(lA), cA - 1)
      setline(lA, newline)

      # Remove right delimiter
      var lB = interval[1][1]
      var cB = interval[1][2]
      # The value of cB may no longer be valid since we shortened the line
      if lA == lB
        cB = cB - len(keys(open_delimiter_dict)[0])
      endif

      newline =
        strcharpart(getline(lB), 0, cB)
        .. strcharpart(getline(lB), cB + len(keys(close_delimiter_dict)[0]))
      setline(lB, newline)
    endif
enddef

export def SurroundSimple(open_delimiter: string,
    close_delimiter: string,
    open_delimiters_dict: dict<string>,
    close_delimiters_dict: dict<string>,
    type: string = '')

  if getcharpos("'[") == getcharpos("']")
    return
  endif

  var open_string = open_delimiter
  var open_regex = open_delimiters_dict[open_string]
  var open_delimiter_dict = {open_string: open_regex}

  var close_string = close_delimiter
  var close_regex = close_delimiters_dict[close_string]
  var close_delimiter_dict = {close_string: close_regex}

  # line and column of point A
  var lA = line("'[")
  var cA = col("'[")

  # line and column of point B
  var lB = line("']")
  var cB = col("']")

  var toA = strcharpart(getline(lA), 0, cA - 1) .. open_string
  var fromB = close_string .. strcharpart(getline(lB), cB)

  # If on the same line
  if lA == lB
    # Overwrite everything that is in the middle
    var A_to_B = strcharpart(getline(lA), cA - 1, cB - cA + 1)
    setline(lA, toA .. A_to_B .. fromB)
  else
    var lineA = toA .. strcharpart(getline(lA), cA - 1)
    setline(lA, lineA)
    var lineB = strcharpart(getline(lB), 0, cB - 1) .. fromB
    setline(lB, lineB)
    var ii = 1
    # Fix intermediate lines
    while lA + ii < lB
      setline(lA + ii, getline(lA + ii))
      ii += 1
    endwhile
  endif
enddef

export def SurroundSmart(open_delimiter: string,
    close_delimiter: string,
    open_delimiters_dict: dict<string>,
    close_delimiters_dict: dict<string>,
    type: string = '')

  if getcharpos("'[") == getcharpos("']")
    return
  endif

  var open_string = open_delimiter
  var open_regex = open_delimiters_dict[open_string]
  var open_delimiter_dict = {open_string: open_regex}

  var close_string = close_delimiter
  var close_regex = close_delimiters_dict[close_string]
  var close_delimiter_dict = {close_string: close_regex}
  #
  # line and column of point A
  var lA = line("'[")
  var cA = col("'[")

  # line and column of point B
  var lB = line("']")
  var cB = col("']")
  # -------- SMART DELIMITERS BEGIN ---------------------------
  # We check conditions like the following and we adjust the style
  # delimiters
  # We assume that the existing style ranges are (C,D) and (E,F) and we want
  # to place (A,B) as in the picture
  #
  # -E-------A------------
  # ------------F---------
  # ------------C------B--
  # --------D-------------
  #
  # We want to get:
  #
  # -E------FA------------
  # ----------------------
  # ------------------BC--
  # --------D-------------
  #
  # so that all the styles are visible

  # We need a list-of-dicts [{a: 'foo'}, {b: 'bar'}, {c: 'baz'}]
  var open_delimiters_dict_list = DictToListOfDicts(open_delimiters_dict)
  var close_delimiters_dict_list = DictToListOfDicts(close_delimiters_dict)

  # Check if A falls in an existing interval
  var found_delimiters_interval = []
  cursor(lA, cA)
  var old_right_delimiter = ''
  for delim in ZipLists(open_delimiters_dict_list,
      close_delimiters_dict_list)

    found_delimiters_interval = IsInRange(delim[0], delim[1])

    if !empty(found_delimiters_interval)
      old_right_delimiter = keys(delim[0])[0]
      # Existing blocks shall be disjoint,
      # so we can break as soon as we find a delimiter
      break
    endif
  endfor

  # Try to preserve overlapping ranges by moving the delimiters.
  # For example. If we have the pairs (C, D) and (E,F) as it follows:
  # ------C-------D------E------F
  #  and we want to add (A, B) as it follows
  # ------C---A---D-----E--B---F
  #  then the results becomes a mess. The idea is to move D before A and E
  #  after E, thus obtaining:
  # ------C--DA-----------BE----F
  #
  # TODO:
  # If you don't want to try to automatically adjust existing ranges, then
  # remove 'old_right_delimiter' and 'old_left_limiter' from what follows,
  # AND don't remove anything between A and B
  #
  # TODO: the following is specifically designed for markdown, so if you use
  # for other languages, you may need to modify it!
  var toA = ''
  if !empty(found_delimiters_interval) && old_right_delimiter != open_string
    toA = strcharpart(getline(lA), 0, cA - 1)->substitute('\s*$', '', '')
      .. $'{old_right_delimiter} {open_string}'
  elseif !empty(found_delimiters_interval) && old_right_delimiter == open_string
    # If the found interval is a text style equal to the one you want to set,
    # i.e. you would end up in adjacent delimiters like ** ** => Remove both
    toA = strcharpart(getline(lA), 0, cA - 1)
  else
    toA = strcharpart(getline(lA), 0, cA - 1) .. open_string
  endif

  # Check if B falls in an existing interval
  cursor(lB, cB)
  var old_left_delimiter = ''
  found_delimiters_interval = []
  for delim in ZipLists(close_delimiters_dict_list,
      close_delimiters_dict_list)

    found_delimiters_interval = IsInRange(delim[0], delim[0])

    if !empty(found_delimiters_interval)
      old_left_delimiter = keys(delim[0])[0]
      # Existing blocks shall be disjoint,
      # so we can break as soon as we find a delimiter
      break
    endif
  endfor

  var fromB = ''
  if !empty(found_delimiters_interval) && old_left_delimiter != close_string
    fromB = $'{close_string} {old_left_delimiter}'
      .. strcharpart(getline(lB), cB)->substitute('^\s*', '', '')
  elseif !empty(found_delimiters_interval) && old_left_delimiter == close_string
      fromB = strcharpart(getline(lB), cB)
  else
    fromB = close_string .. strcharpart(getline(lB), cB)
  endif

  # ------- SMART DELIMITERS PART END -----------
  # We have compute the partial strings until A and the partial string that
  # leaves B. Existing delimiters are set.
  # Next, we have to adjust the text between A and B, by removing all the
  # possible delimiters left between them.

  var delimiters_to_remove = values(
    extendnew(open_delimiters_dict, close_delimiters_dict)
  )
  # If on the same line
  if lA == lB
    # Overwrite everything that is in the middle
    var A_to_B = ''
    A_to_B = strcharpart(getline(lA), cA - 1, cB - cA + 1)
    for regex in delimiters_to_remove
      A_to_B = A_to_B->substitute(regex, '', 'g')
    endfor

    # Set the whole line
    setline(lA, toA .. A_to_B .. fromB)

  else
    # Set line A
    var afterA = strcharpart(getline(lA), cA - 1)
    for regex in delimiters_to_remove
      afterA = afterA->substitute(regex, '', 'g')
    endfor
    var lineA = toA .. afterA
    setline(lA, lineA)

    # Set line B
    var beforeB = strcharpart(getline(lB), 0, cB)
    for regex in delimiters_to_remove
      beforeB = beforeB->substitute(regex, '', 'g')
    endfor
    var lineB = beforeB .. fromB
    setline(lB, lineB)

    # Fix intermediate lines
    var ii = 1
    while lA + ii < lB
      var middleline = getline(lA + ii)
      for regex in delimiters_to_remove
        middleline = middleline-> substitute(regex, '', 'g')
      endfor
      setline(lA + ii, middleline)
      ii += 1
    endwhile
  endif

enddef

export def SurroundToggle(open_delimiter: string,
    close_delimiter: string,
    open_delimiter_dict: dict<string>,
    close_delimiter_dict: dict<string>,
    )
  # Usage:
  #   Select text and hit <leader> + e.g. parenthesis
  #
  # 'open_delimiter' and 'close_delimiter' are the strings to add to the text.
  # They also serves as keys for the dics 'open_delimiters_dict' and
  # 'close_delimiters_dict'.
  #
  # We need dicts because we need the strings to add to the text for
  # surrounding purposes, but also a mechanism to search the surrounding
  # delimiters in the text.
  # We need regex because the delimiters strings may not be disjoint (think
  # for example, in the markdown case, you have '*' delimiter which is
  # contained in the '**' delimiter) and therefore we cannot find the
  # delimiting string as-is.
  # Finally, open_delimiters_dict[ii] is zipped with
  # close_delimiters_dict[ii], therefore be sure that there is correspondence
  # between opening and closing delimiters.
  #
  # Remember that Visual Selections and Text Objects are cousins.
  # Also, remember that a yank set the marks '[ and '].


  var tmp = IsInRange(open_delimiter_dict, close_delimiter_dict)
  echom "range: " .. string(tmp)
  if !empty(IsInRange(open_delimiter_dict, close_delimiter_dict))
    echom "FOO"
    RemoveSurrounding(open_delimiter_dict, open_delimiter_dict)
  else
    echom "BAR"
    SurroundSimple(open_delimiter,
      close_delimiter,
      open_delimiter_dict,
      close_delimiter_dict,
    )
  endif
enddef

export def GetTextBetweenMarks(A: string, B: string): list<string>
    # Usage: GetTextBetweenMarks("'A", "'B").
    #
    # Arguments must be marks called with the back ticks to get the exact
    # position ('a jump to the marker but places the cursor
    # at the beginning of the line.)
    #
    var [_, l1, c1, _] = getcharpos(A)
    var [_, l2, c2, _] = getcharpos(B)

    if l1 == l2
        # Extract text within a single line
        return [getline(l1)[c1 - 1 : c2 - 1]]
    else
        # Extract text across multiple lines
        var lines = getline(l1, l2)
        lines[0] = lines[0][c1 - 1 : ]  # Trim the first line from c1
        lines[-1] = lines[-1][ : c2 - 1]  # Trim the last line up to c2
        return lines
    endif
enddef

export def GetDelimitersRanges(
    open_delimiter_dict: dict<string>,
    close_delimiter_dict: dict<string>,
    ): list<list<list<number>>>
  # It returns open-intervals, i.e. the delimiters are excluded.
  #
  # Passed delimiters are singleton dicts with key = the delimiter string,
  # value = the regex to exactly capture such a delimiter string
  #
  # It is assumed that the ranges have no intersections. This happens if
  # open_delimiter = close_delimiter, as in many languages.
  #
  # By contradiction, say that open_delimiter = * and close_delimiter = /. You may
  # have something like:
  # ----*---*===/---/-----
  # The part in === is an intersection between two ranges.
  # In these cases, this function will not work.
  # However, languages where open_delimiter = close_delimiter such intersections
  # cannot happen and this function apply.
  #
  var saved_cursor = getcursorcharpos()
  cursor(1, 1)

  var ranges = []

  var open_regex = values(open_delimiter_dict)[0]
  var open_string = keys(open_delimiter_dict)[0]
  var close_regex = values(close_delimiter_dict)[0]
  var close_string = keys(close_delimiter_dict)[0]

  # 2D format due to that searchpos() returns a 2D vector
  var open_regex_pos_short = [-1, -1]
  var close_regex_pos_short = [-1, -1]
  var open_regex_pos_short_final = [-1, -1]
  var close_regex_pos_short_final = [-1, -1]

  # 4D format due to that marks have 4-coordinates
  var open_regex_pos = [0] + open_regex_pos_short + [0]
  var open_regex_match = ''
  var close_regex_pos = [0] + close_regex_pos_short + [0]
  var close_regex_length = 0
  var close_regex_match = ''

  while open_regex_pos_short != [0, 0]

    # A. ------------ open_regex -----------------
    open_regex_pos_short = searchpos(open_regex, 'W')

    # If the open delimiter is the tail of the line,
    # then the open-interval starts from the next line, column 1
    if open_regex_pos_short[1] + len(open_string) == col('$')
      open_regex_pos_short_final[0] = open_regex_pos_short[0] + 1
      open_regex_pos_short_final[1] = 1
    else
      # Pick the open-interval
      open_regex_pos_short_final[0] = open_regex_pos_short[0]
      open_regex_pos_short_final[1] = open_regex_pos_short[1]
                                             + len(open_string)
    endif
    open_regex_pos = [0] + open_regex_pos_short_final + [0]

    # B. ------ Close regex -------
    close_regex_pos_short = searchpos(close_regex, 'W')

    # If the closed delimiter is the lead of the line, then the open-interval
    # starts from the previous line, last column
    if close_regex_pos_short[1] - 1 == 0
      close_regex_pos_short_final[0] = close_regex_pos_short[0] - 1
      close_regex_pos_short_final[1] = len(getline(close_regex_pos_short_final[0]))
    else
      close_regex_pos_short_final[0] = close_regex_pos_short[0]
      close_regex_pos_short_final[1] = close_regex_pos_short[1] - 1
    endif
    close_regex_pos = [0] + close_regex_pos_short_final + [0]

    add(ranges, [open_regex_pos, close_regex_pos])
  endwhile
  setcursorcharpos(saved_cursor[1 : 2])

  # Remove the last element junky [[0,0,len(open_delimiter),0], [0,0,-1,0]]
  # TODO it does not seems to remove anything...
  remove(ranges, -1)

  return ranges
enddef

export def IsLess(l1: list<number>, l2: list<number>): bool
  # Lexicographic comparison on common prefix, i.e.for two vectors in N^n and
  # N^m you compare their projections onto the smaller subspace.

  var min_length = min([len(l1), len(l2)])
  var result = false

  for ii in range(min_length)
    if l1[ii] < l2[ii]
      result = true
      break
    elseif l1[ii] > l2[ii]
      result = false
      break
    endif
  endfor
  return result
enddef

export def IsGreater(l1: list<number>, l2: list<number>): bool
  # Lexicographic comparison on common prefix, i.e.for two vectors in N^n and
  # N^m you compare their projections onto the smaller subspace.

  var min_length = min([len(l1), len(l2)])
  var result = false

  for ii in range(min_length)
    if l1[ii] > l2[ii]
      result = true
      break
    elseif l1[ii] < l2[ii]
      result = false
      break
    endif
  endfor
  return result
enddef

export def IsEqual(l1: list<number>, l2: list<number>): bool
  var min_length = min([len(l1), len(l2)])
  return l1[: min_length - 1] == l2[: min_length - 1]
enddef

export def IsBetweenMarks(A: string, B: string): bool
    var cursor_pos = getpos(".")
    var A_pos = getcharpos(A)
    var B_pos = getcharpos(B)

    if IsGreater(A_pos, B_pos)
      var tmp = B_pos
      B_pos = A_pos
      A_pos = tmp
    endif

    # Check 'A_pos <= cursor_pos <= B_pos'
    var result = (IsGreater(cursor_pos, A_pos) || IsEqual(cursor_pos, A_pos))
      && (IsGreater(B_pos, cursor_pos) || IsEqual(B_pos, cursor_pos))

    return result
enddef

export def IsInRange(
    open_delimiter_dict: dict<string>,
    close_delimiter_dict: dict<string>,
    ): list<list<number>>
  # Arguments must be singleton dicts.
  # Return the range of the delimiters if the cursor is within such a range,
  # otherwise return an empty list.
  var interval = []

  # OBS! Ranges are open-intervals!
  var ranges = GetDelimitersRanges(open_delimiter_dict, close_delimiter_dict)

  var saved_mark_a = getcharpos("'a")
  var saved_mark_b = getcharpos("'b")

  for range in ranges
    setcharpos("'a", range[0])
    setcharpos("'b", range[1])
    if IsBetweenMarks("'a", "'b")
      interval = [range[0], range[1]]
      break
    endif
  endfor

  # Restore marks 'a and 'b
  setcharpos("'a", saved_mark_a)
  setcharpos("'b", saved_mark_b)

  return interval
enddef

# Not used in markdown
export def DeleteTextBetweenMarks(A: string, B: string): string
  # To jump to the exact position (and not at the beginning of a line) you
  # have to call the marker with the backtick ` rather than with ', e.g. `a
  # instead of 'a
  # TODO
  # This implementation most likely modify the jumplist.
  # Find a solution based on functions instead
  var exact_A = substitute(A, "'", "`", "")
  var exact_B = substitute(B, "'", "`", "")
  execute $'norm! {exact_A}v{exact_B}"_d'
  # This to get rid off E1186
  return ''
enddef

export def SetBlock(open_block: dict<string>,
    close_block: dict<string>,
    type: string = '')
  # Put the selected text between open_block and close_block.
  var label = ''
  if exists('g:markdown_extras_config') != 0
      && has_key(g:markdown_extras_config, 'block_label')
    label = g:markdown_extras_config['block_label']
  else
    label = input('Enter code-block language: ')
  endif

  # TODO return or remove surrounding?
  if !empty(IsInRange(open_block, close_block))
      || getline('.') == $'{keys(open_block)[0] .. label}'
      || getline('.') == $'{keys(close_block)[0]}'
    return
  endif


  # We set cA=1 and cB = len(geline(B)) so we pretend that we are working
  # always line-wise
  var lA = line("'[")
  var cA = 1

  var lB = line("']")
  var cB = len(getline(lB))

  var firstline = getline(lA)
  var lastline = getline(lB)

  if firstline == lastline
    append(lA - 1, $'{keys(open_block)[0] .. label}')
    lA += 1
    lB += 1
    setline(lA, "  " .. getline(lA)->substitute('^\s*', '', ''))
    append(lA, $'{keys(open_block)[0] .. label}')
  else
    # Set first part
    setline(lA, strcharpart(getline(lA), 0, cA - 1))
    append(lA, [$'{keys(open_block)[0] .. label}',
      "  " .. strcharpart(firstline, cA - 1)])
    lA += 2
    lB += 2

    # Set intermediate part
    var ii = 1
    while lA + ii <= lB
      setline(lA + ii, "  " .. getline(lA + ii)->substitute('^\s*', '', ''))
      ii += 1
    endwhile

    # Set last part
    setline(lB, "  " .. strcharpart(lastline, 0, cB))
    append(lB, [$'{keys(close_block)[0]}', strcharpart(lastline, cB)])
  endif
enddef

export def UnsetBlock(open_block: dict<string>, close_block: dict<string>)
   var interval = IsInRange(open_block, close_block)
   var lA = interval[0][1]
   var lB = interval[1][1]
   if !empty(interval)
     deletebufline('%', lA - 1)
     deletebufline('%', lB)
   endif

   for line in range(lA - 1, lB - 1)
     setline(line, getline(line)->substitute('^\s*', '', 'g'))
   endfor
enddef
