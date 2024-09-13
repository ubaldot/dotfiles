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

export def g:GetExtremes(): list<number>
    # var lower = search('\v\s*(\\begin\{\w+\}|\\end\{\w+\})', 'ncbW')
    var lower = search('\v\s*\\begin\{\w+\}', 'ncbW')
    var environment = getline(lower)->matchstr('{\w\+}')
    var upper = search($'\s*\\end{environment}', 'ncW')
    return [lower, upper]
enddef
