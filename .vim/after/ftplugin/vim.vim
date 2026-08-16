vim9script

# Vim9-conversion-aid
g:vim9_conversion_aid_fix_let = true
g:vim9_conversion_aid_fix_asl = true
packadd Vim9-conversion-aid

def Help(args: string)
  var syn_name = synIDattr(synID(line('.'), col('.'), 1), 'name')

  if syn_name =~# 'vimCommand'
    execute $'help {args}: '
  elseif syn_name =~# 'vimOption'
    execute $"help '{args}'"
  elseif syn_name =~# 'vimFunc'
    execute $'help {args}()'
  else
    execute $'help {args}'
  endif
enddef

command! -buffer -nargs=1 Help Help(<f-args>)
setlocal keywordprg=:Help
