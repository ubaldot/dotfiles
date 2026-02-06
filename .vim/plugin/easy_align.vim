vim9script

var total = 0.0
def SumBlock()

  var tmp = getreg('s')
  silent norm! "sy

  var numbers: list<any>
  if @s =~ "\|"
    numbers = split(@s, "\|")
  else
    numbers = split(@s)
  endif

  for v in numbers
    total += str2float(v)
  endfor

  echo total
  total = 0.0
  setreg('s', tmp)
enddef


export def InsertRowDelimiter()
  const p = '^\s*|\s*.*\s*|\s*$'
  const curr_line = line('.')
  if getline(curr_line) =~ p
    appendbufline('%', curr_line, getline(curr_line)
      ->substitute('[^\|]', '-', 'g'))
      # ->substitute('|-', '| ', 'g')
      # ->substitute('-|', ' |', 'g'))
  endif
enddef

export def Align()
  const p = '^\s*|\s*.*\s*|\s*$'
  if exists(':EasyAlign') != 0 && getline('.') =~# '^\s*|'

    # Save column and position
    const curpos = getcursorcharpos()

    # Search for first line
    var startline = line('.')
    if startline != 1
      while getline(startline - 1) =~ p
        startline = search(p, 'bW')
      endwhile
    endif
    setcursorcharpos(curpos[1], curpos[2])

    # Search for last line
    var endline = line('.')
    if endline != line('$')
      while getline(endline + 1) =~ p
        endline = search(p, 'W')
      endwhile
    endif
    setcursorcharpos(curpos[1], curpos[2])

    # Easy align
    execute $":{startline},{endline}EasyAlign *|"
    setcursorcharpos(curpos[1], strchars(getline(curpos[1])))

  endif
enddef

# Easy-align
# Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)*\|
# Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)*\|

xnoremap <c-s> <ScriptCmd>SumBlock()<cr>
inoremap <silent> <Bar> <Bar><Esc><ScriptCmd>myfunctions.Align()<CR>a
command! -nargs=0 EasyDelimiter myfunctions.InsertRowDelimiter()
