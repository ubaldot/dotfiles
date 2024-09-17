vim9script

# TODO:
# - xdotool don't work on WSL
# - Backwards search don't work with zathura and WSL
# - pywinctl does not work on WSL

# It requires:
# All: latexmk, python3 and pywinget
# MacOs: Skim.app
# Linux: zathura, xdotool
#
# OS detection
var os = ''
def IsWSL(): bool
  if has("unix")
    if filereadable("/proc/version") # avoid error on Android
      var lines = readfile("/proc/version")
      if lines[0] =~ "microsoft"
        return true
      endif
    endif
  endif
  return false
enddef

if has("win64") || has("win32") || has("win16")
  os = "Windows"
elseif IsWSL()
  os = 'WSL'
else
  os = substitute(system('uname'), '\n', '', '')
endif

sign define ChangeEnv linehl=CursorLine

# global vars
var latex_engine = 'xelatex'

def Echoerr(msg: string)
  echohl ErrorMsg | echom $'{msg}' | echohl None
enddef

def Echowarn(msg: string)
  echohl WarningMsg | echom $'{msg}' | echohl None
enddef

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
  silent write
  var target_file = empty(filename) ? expand('%:p') : fnamemodify(filename, ':p')

  # You must be in the same source file directory to build
  if getcwd() != fnamemodify(target_file, ':h')
    exe $'cd {fnamemodify(target_file, ':h')}'
  endif
  # Build and open
  &l:makeprg = $'latexmk -pdf -{latex_engine} -synctex=1 -quiet -interaction=nonstopmode {target_file}'
  silent make
  return $'{fnamemodify(target_file, ':r')}.pdf'
enddef

def MoveAndResizeWin(pdf_name: string)
  # TODO: to finish
  g:pdf_name = pdf_name
  python3 << END
import pywinctl as gw
import vim

title = vim.eval('g:pdf_name')
#
windows = gw.getWindowsWithTitle(title)
if windows:
  window = windows[0]
  window.resizeTo(800, 600)
  window.moveTo(100, 100)
  window.activate()
  else:
  print(f"No window found with title: {title}")
END
  unlet g:pdf_name
enddef


def LatexRenderLinux()
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
  var open_file_cmd = $'zathura --config-dir=$HOME/.config/zathura/zathurarc --fork {pdf_name}'
  var move_and_resize_cmd = $'xdotool search --onlyvisible --name {pdf_name} windowsize 900 1000 windowmove 1000 0'
  silent job_start(open_file_cmd)
  # TODO This wait is a bit ugly. Consider using a callback instead.
  sleep 100m
  silent job_start(move_and_resize_cmd)
enddef


def LatexRenderWin()
  # if !executable('sumatra')
  #   echoerr $"'zathura' not installed!"
  #   return
  # endif

  var pdf_name = LatexBuildCommon()
  # TODO opencmd

  if has('python3')
    silent exe '!python3 -c "import pywinctl"'
    if !v:shell_error
      silent MoveAndResizeWin(pdf_name)
    endif
  else
    Echowarn("You need Vim with 'python3' support and 'pywinctl' package installed")
  endif
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

def ChangeLatexEnvironment()
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
  var forward_sync_cmd = $'zathura --config-dir=$HOME/.config/zathurarc --synctex-forward {line('.')}:1:{filename_root}.tex {filename_root}.pdf'
  job_start(forward_sync_cmd)
  var win_activate_cmd = $'xdotool search --onlyvisible --name {filename_root}.pdf windowactivate'
  # exe $'!xdotool windowactivate {filename_root}'
  system(win_activate_cmd)
enddef

def ForwardSyncWin()
   # TODO : ALL!
enddef

var ForwardSync: func
var LatexRender: func
if os == "Darwin"
  ForwardSync = ForwardSyncMac
  LatexRender = LatexRenderAndOpenMac
elseif os ==# "Linux" || os ==# 'WSL'
  ForwardSync = ForwardSyncLinux
  LatexRender = LatexRenderLinux
else
  ForwardSync = ForwardSyncWin
  LatexRender = LatexRenderWin
endif


def g:BackwardSync(line: number, filename: string)
  # exe $'edit {filename}'
  exe $'buffer {bufnr(fnamemodify(filename, ':.'))}'
  cursor(line, 1)
  # echom $"filename: {filename}, line: {line}"
  exe $"sign place 4 line={line} name=ChangeEnv buffer={bufnr(fnamemodify(filename, ':.'))}"
  autocmd! InsertEnter * ++once exe $"sign unplace 4 buffer={bufnr('%')}"
enddef


# ----------- Outline fetaure
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
nnoremap <buffer> <c-l>c <Scriptcmd>ChangeLatexEnvironment()<cr>
nnoremap <buffer> <c-l>d <Scriptcmd>DeleteEnvironment()<cr>
nnoremap <buffer> <c-l>h <Scriptcmd>HighlightOuterEnvironment()<cr>
