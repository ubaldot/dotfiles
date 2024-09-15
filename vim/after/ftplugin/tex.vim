vim9script

# It requires:
# MacOs: Skim.app
# Linux: zathura, xdotool
# latexmk.

# TODO: add checks for xodtools
# Compiler sprcify
compiler latexmk
sign define ChangeEnv linehl=CursorLine
var latex_engine = 'xelatex'

def LatexRenderCommon(filename: string = ''): string
  # Save the .tex file, compile, and return the .pdf name (fullpath)
  write
  var target_file = empty(filename) ? expand('%:p') : fnamemodify(filename, ':p')

  # You must be in the same source file directory to build
  if getcwd() != fnamemodify(target_file, ':h')
    exe $'cd {fnamemodify(target_file, ':h')}'
  endif
  # Build and open
  # &l:makeprg = $'latexmk -pdf -{latex_engine} -synctex=1 -interaction=nonstopmode {fnamemodify(target_file, ':r')}.tex'
  &l:makeprg = $'latexmk -pdf -{latex_engine} -synctex=1 -interaction=nonstopmode {target_file}'
  silent make
  return $'{fnamemodify(target_file, ':r')}.pdf'
enddef

def LatexRenderAndOpenLinux()
  if executable('zathura')
    echoerr "zathura not installed!"
    return
  endif
  var open_file_cmd = $'zathura {LatexRenderCommon()}'
  job_start(open_file_cmd)

  # Resize and position windows
  if executable('xdotool')
    #
  endif
enddef

def LatexRenderAndOpenMac(filename: string = '')
  # Open Skim
  var open_file_cmd = $'open -a Skim.app {LatexRenderCommon()}'
  silent exe $"!{open_file_cmd}"
enddef

def LatexFilesCompletion(A: any, L: any, P: any): list<string>
  return getcompletion('\w*.tex', 'file')
enddef
command! -nargs=? -buffer -complete=customlist,LatexFilesCompletion LatexRender LatexRender(<f-args>)

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

var ForwardSync: func
var LatexRender: func
if g:os == "Darwin"
  ForwardSync = ForwardSyncMac
  LatexRender = LatexRenderAndOpenMac
endif

nnoremap <buffer> % <ScriptCmd>JumpTag()<cr>
nnoremap <buffer> <F5> <Scriptcmd>ForwardSync()<cr>
nnoremap <buffer> <c-l>c <Scriptcmd>ChangeEnvironment()<cr>
nnoremap <buffer> <c-l>d <Scriptcmd>DeleteEnvironment()<cr>
nnoremap <buffer> <c-l>h <Scriptcmd>HighlightOuterEnvironment()<cr>
