vim9script

# It requires:
# All: latexmk
# MacOs: Skim.app
# Linux: zathura, xdotool

sign define ChangeEnv linehl=CursorLine
var latex_engine = 'xelatex'

# This is only needed for the 'errorformat'
if !empty(getcompletion('latexmk', 'compiler'))
  compiler latexmk
endif

def LatexBuildCommon(filename: string = ''): string
  # Return a string which is the pdf filename, e.g. example.pdf
  if !executable('latexmk')
    echoerr "'latexmk' not installed!"
    return ''
  endif

  # Save the .tex file, compile, and return the .pdf name (fullpath)
  write
  var target_file = empty(filename) ? expand('%:p') : fnamemodify(filename, ':p')

  # You must be in the same source file directory to build
  if getcwd() != fnamemodify(target_file, ':h')
    exe $'cd {fnamemodify(target_file, ':h')}'
  endif
  # Build and open
  &l:makeprg = $'latexmk -pdf -{latex_engine} -synctex=1 -interaction=nonstopmode {target_file}'
  silent make
  return $'{fnamemodify(target_file, ':r')}.pdf'
enddef

def LatexRenderAndOpenLinux()
  if !executable('zathura')
    echoerr "'zathura' not installed!"
    return
  endif

  var pdf_name = LatexBuildCommon()
  # TODO: at the moment we close and re-open zathura window.
  silent system($'xdotool search --onlyvisible --name {pdf_name} windowclose')
  # In case the xdotool windowsclose does not work, just kill the zathura
  # process.
  # silent! exe "!pkill zathura"
  # var fork = empty(system($'xdotool search --onlyvisible --name {pdf_name}')) ? '--fork' : ''
  var open_file_cmd = $'zathura --config-dir=$HOME/.config/zathura --fork {pdf_name}'
  var move_and_resize_cmd = $'xdotool search --onlyvisible --name {pdf_name} windowsize 900 1000 windowmove 1000 0'
  silent job_start(open_file_cmd)
  sleep 100m
  silent job_start(move_and_resize_cmd)
enddef

def LatexRenderAndOpenMac(filename: string = '')
  # Open Skim
  var open_file_cmd = $'open -a Skim.app {LatexBuildCommon()}'
  silent exe $"!{open_file_cmd}"
enddef

def GetExtremes(): list<number>
  # var begin_line = search('\v\s*(\\begin\{\w+\}|\\end\{\w+\})', 'ncbW')
  cursor(line('.'), 1)
  var begin_line = search('\v^\s*\\begin\{\w+\}', 'cnbW')
  var begin_env = getline(begin_line)->matchstr('{\w\+}')
  cursor(line('.'), 1)
  var end_line = search('\v^\s*\\end\{\w+\}', 'cnW')
  var end_env = getline(end_line)->matchstr('{\w\+}')

  # If the environments between consecutive \begin \end don't match it means
  # that there are nested environments. Search more
  if begin_env !=# end_env
    # search UP
    cursor(line('.'), 1)
    var curr_begin_line = search($'^\s*\\begin{end_env}', 'nbW')
    # If cannot find UP, search DOWN
    if curr_begin_line == 0
      cursor(line('.'), 1)
      end_line = search($'^\s*\\end{begin_env}', 'cnW')
    else
      begin_line = curr_begin_line
    endif
  endif
  return [begin_line, end_line]
enddef

def JumpTag()
  var extremes = GetExtremes()
  echom extremes
  if line('.') == extremes[1]
    cursor(extremes[0], 1)
    norm! ^
  else
    cursor(extremes[1], 1)
    norm! ^
  endif
enddef

def DeleteEnvironment()
  var extremes = GetExtremes()
  HighlightOuterEnvironment()
  # Obs! The number of line changes after the first deletion
  deletebufline(bufnr(), extremes[0])
  deletebufline(bufnr(), extremes[1] - 1)
enddef

def HighlightOuterEnvironment()
  var cur_pos = getcurpos()
  var extremes = GetExtremes()
  if extremes[0] != 0 && extremes[1] != 0
    exe $"sign place 1 line={extremes[0]} name=ChangeEnv buffer={bufnr('%')}"
    exe $"sign place 2 line={extremes[1]} name=ChangeEnv buffer={bufnr('%')}"
    redraw
    setpos('.', cur_pos)
    sleep 600m
    exe $"sign unplace 1 buffer={bufnr('%')}"
    exe $"sign unplace 2 buffer={bufnr('%')}"
  endif
enddef

def ChangeEnvironment()
  # Positioning
  var extremes = GetExtremes()
  cursor(extremes[0], 1)
  norm! ^
  exe $"sign place 1 line={extremes[0]} name=ChangeEnv buffer={bufnr('%')}"
  exe $"sign place 2 line={extremes[1]} name=ChangeEnv buffer={bufnr('%')}"
  redraw

  # Replacement
  var new_env = input('Enter new environment name: ')
  if !empty(new_env)
    var old_env = getline(extremes[0])->matchstr('{\zs\w\+\ze}')
    for line_nr in extremes
      setline(line_nr, getline(line_nr)->substitute(old_env, new_env, ''))
    endfor
  endif
  exe $"sign unplace 1 buffer={bufnr('%')}"
  exe $"sign unplace 2 buffer={bufnr('%')}"
enddef

# Synctex stuff
def ForwardSyncMac()
  exe $"silent !/Applications/Skim.app/Contents/SharedSupport/displayline {line('.')} {expand('%:p:r')}.pdf"
enddef

def ForwardSyncLinux()
    var filename_root = expand('%:p:r')
    var forward_sync_cmd = $'zathura --config-dir=$HOME/.config/zathura --synctex-forward {line('.')}:1:{filename_root}.tex {filename_root}.pdf'
    job_start(forward_sync_cmd)
    var win_activate_cmd = $'xdotool search --onlyvisible --name {filename_root}.pdf windowactivate'
    # exe $'!xdotool windowactivate {filename_root}'
    system(win_activate_cmd)
enddef

var ForwardSync: func
var LatexRender: func
if g:os == "Darwin"
  ForwardSync = ForwardSyncMac
  LatexRender = LatexRenderAndOpenMac
elseif g:os ==# "Linux" || g:os ==# 'WSL'
  ForwardSync = ForwardSyncLinux
  LatexRender = LatexRenderAndOpenLinux
endif


def g:BackwardSearch(line: number, filename: string)
  # exe $'edit {filename}'
  exe $'buffer {bufnr(fnamemodify(filename, ':.'))}'
  cursor(line, 1)
  echom $"filename: {filename}, line: {line}"
  exe $"sign place 4 line={line} name=ChangeEnv buffer={bufnr(fnamemodify(filename, ':.'))}"
  autocmd! InsertEnter * ++once exe $"sign unplace 4 buffer={bufnr('%')}"
enddef


def LatexOutline()
  var outline = getline(1, '$') ->filter('v:val =~ "^\\\\\\w*section"')
    ->map((idx, val) => substitute(val, '\\section{\(.*\)}', '\1', ''))
    ->map((idx, val) => substitute(val, '\\subsection{\(.*\)}', '  \1', ''))
    ->map((idx, val) => substitute(val, '\\subsection{\(.*\)}', '    \1', ''))
    ->map((idx, val) => substitute(val, '\\subsection{\(.*\)}', '      \1', ''))
  # echom outline
  win_execute(win_getid(), 'vertical split' )

  var outline_id = win_getid(winnr('$'))
  win_execute(outline_id, $'enew')
  win_execute(outline_id, $'vertical resize {&columns / 4}')
  win_execute(outline_id, 'setlocal bufhidden=wipe' )
  win_execute(outline_id, 'setlocal nobuflisted' )
  win_execute(outline_id, 'setlocal noswapfile' )

  # Fill in
  win_execute(outline_id, 'file Outline' )
  win_execute(outline_id, 'setlocal buftype=nofile' )
  var bufname = expand("%:p")
  var title = $'Outline - {fnamemodify(bufname, ':.')}'
  var separator = repeat('-', strlen(title))
  appendbufline('Outline', 0, [title])
  appendbufline('Outline', 1, [separator])

  # Some sugar
  win_execute(outline_id, $'matchadd("WarningMsg", "{title}")')
  win_execute(outline_id, $'matchadd("WarningMsg", "{separator}")')
  win_execute(outline_id, 'setlocal cursorline' )

  deletebufline('Outline', 3, line('$'))
  setbufline('Outline', 3, outline)

  # <cr> mapping
  setwinvar(outline_id, 'bufname', bufname)
  win_execute(outline_id, 'nnoremap <cr> <ScriptCmd>Outline2Buffer(w:bufname)<cr>' )

  # winfixbuf
  if exists('+winfixbuf')
    win_execute(outline_id, 'setlocal winfixbuf' )
  endif
enddef

def Outline2Buffer(bufname: string)
  var line = getline(line('.'))
  if line =~ '^\S'
    line = printf('\\section{%s}', line)
    # echom line
  elseif line =~ '^  '
    line = printf('\\subsection{%s}', trim(line))
    # echom line
  elseif line =~ '^    '
    line = printf('\\subsubsection{%s}', trim(line))
    # echom line
  endif
  close
  exe $'buffer {bufname}'
  search(line, 'cw')
enddef

# API
def LatexFilesCompletion(A: any, L: any, P: any): list<string>
  return getcompletion('\w*.tex', 'file')
enddef
command! -nargs=? -buffer -complete=customlist,LatexFilesCompletion LatexRender LatexRender(<f-args>)
command! -buffer LatexOutline silent LatexOutline()

nnoremap <buffer> % <ScriptCmd>JumpTag()<cr>
nnoremap <buffer> <F5> <Scriptcmd>ForwardSync()<cr>
nnoremap <buffer> <c-l>c <Scriptcmd>ChangeEnvironment()<cr>
nnoremap <buffer> <c-l>d <Scriptcmd>DeleteEnvironment()<cr>
nnoremap <buffer> <c-l>h <Scriptcmd>HighlightOuterEnvironment()<cr>
