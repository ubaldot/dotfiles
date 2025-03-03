vim9script

inoremap ä `

def OpenNewLine(): string
  const a = getline('.')
  if a =~ '\v^\s*(-|\*|-\s*\[\s*\]|-\s*\[\s*x\s*\])'
    return $"A\<cr>{a->matchstr('^\W*')}"
  else
    return "o"
  endif
enddef

nnoremap <buffer> <expr> o OpenNewLine()

# export def Make(...args: list<string>)
#   var input_file = $'"{expand('%:p')}"'

#   # Set output filename
#   var output_file = expand('%:r')

#   # Check if user passed an output file and quote it
#   var o_idx = index(args, '-o')
#   var output_idx = index(args, '--output')

#   if o_idx != -1
#     output_file = $'{args[o_idx + 1]}'
#     args->remove(o_idx, o_idx + 1)
#   elseif o_idx != -1
#     output_file = $'{args[output_idx + 1]}'
#     args->remove(output_idx, output_idx + 1)
#   else
#     output_file = $'{expand('%:p:r')}'
#   endif

#   # Set output file extension
#   var t_match = copy(args)->filter("v:val =~ '-t=\w*'")
#   var to_match = copy(args)->filter("v:val =~ '-to=\w*'")

#   var file_extension = 'html'
#   if !empty(t_match)
#     var t_idx = index(args, t_match[0])
#     file_extension = args[t_idx]->matchstr('=\s*\zs\w\+')
#   elseif !empty(to_match)
#     var to_idx = index(args, to_match[0])
#     file_extension = args[to_idx]->matchstr('=\s*\zs\w\+')
#   endif
#   output_file = $'"{output_file}.{file_extension}"'

#   echom "file_extension :" .. file_extension
#   var css_style = file_extension == 'html' ? $"{$HOME}/dotfiles/my_css_style.css" : ''

#   &l:makeprg = $'pandoc --standalone --metadata '
#     .. $'--from=markdown --output {output_file} '
#     .. $'{join(args)} --css={css_style} --title=""'
#     .. $'{input_file}'

#   var cmd = execute('make')
#   echom cmd

#   if exists(':Open') != 0
#     exe $'Open {output_file->substitute('"', '', 'g')}'
#   endif
# enddef

# export def MakeCompleteList(A: any, L: any, P: any): list<string>
#   return ['--to=html', '--to=docx', '--to=pdf', '--to=jira',
#     '--to=csv', '--to=ipynb', '--to=latex', '--to=odt', '--to=rtf']
# enddef

# # Usage :Make, :Make pdf, :Make docx, etc
# command! -nargs=* -buffer -complete=customlist,MakeCompleteList
#       \ RenderMarkdown Make(<f-args>)
