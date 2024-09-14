vim9script

compiler latexmk
# &l:makeprg = $'cd {fnamemodify(filename, ':h')} && xelatex {fnamemodify(filename, ':r')}.tex && {g:start_cmd} -x "set-zoom 3.0" {fnamemodify(filename, ':r')}.pdf'

def LatexRender(filename: string = '')
  var target_file = empty(filename) ? expand('%') : filename
  silent! exe "!pkill zathura"
  var open_file_cmd = $'{g:start_cmd} {fnamemodify(target_file, ':r')}.pdf'
  # Build and open
  &l:makeprg = $'xelatex {fnamemodify(target_file, ':r')}.tex'
  silent make
  job_start(open_file_cmd)
  redraw!
enddef

def LatexFiles(A: any, L: any, P: any): list<string>
  return getcompletion('\w*.tex', 'file')
enddef

command! -nargs=? -buffer -complete=customlist,LatexFiles LatexRender LatexRender(<f-args>)

def GetExtremes(): list<number>
  # var begin_line = search('\v\s*(\\begin\{\w+\}|\\end\{\w+\})', 'ncbW')
  cursor(line('.'), 1)
  var begin_line = search('\v^\s*\\begin\{\w+\}', 'cnbW')
  var begin_env = getline(begin_line)->matchstr('{\w\+}')
  cursor(line('.'), 1)
  var end_line = search('\v^\s*\\end\{\w+\}', 'cnW')
  var end_env = getline(end_line)->matchstr('{\w\+}')

  # If the environments between consecutive \begin \end don't match search
  # more
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
  if line('.') == extremes[0]
    cursor(extremes[1], 1)
    norm! ^
  elseif line('.') == extremes[1]
    cursor(extremes[0], 1)
    norm! ^
  endif
enddef

nnoremap <buffer> % <ScriptCmd>JumpTag()<cr>
