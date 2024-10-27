vim9script
# Tell vim where is Python. OBS: this is independent of the plugins!

setlocal foldmethod=indent

# Usage: make .
if executable('pytest')
  compiler pytest
endif

if exists(':LspHover') != 0
  &l:keywordprg = ':LspHover'
endif


# Autocmd to format with black.
augroup BLACK
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> Black(&l:textwidth)
augroup END

def Black(textwidth: number)
    # If black is not available, then the buffer content will be canceled upon
    # write. To avoid appending stdout and stderr to the buffer we use
    # --quiet.
    var win_view = winsaveview()
    if executable('black') && &filetype == 'python'
                # var cur_pos = getcursorcharpos()
                exe $":%!black - --line-length {textwidth}
                      \ --stdin-filename {shellescape(expand("%"))} --quiet"
                # setcharpos('.', cur_pos)
    else
        echom "black not installed!"
    endif

    if v:shell_error != 0
      undo
      winrestview(win_view)
      # throw prevents writing on disk
      # throw "'black' errors!"
      # redraw!
      echoerr "'black' errors!"
    endif
    winrestview(win_view)
enddef

# Call black to format 120 line length
command! -buffer Black120 Black(120)

# pytest
command! -buffer Pytest execute('!coverage run --branch -m pytest .')

# Manim
if has("mac")
    command! -buffer ManimDocs silent :!open -a safari.app
            \ ~/Documents/manimce-latest/index.html
elseif has("Linux")
    command! -buffer ManimDocs silent :!xdg-open
            \ ~/Documents/manimce-latest/index.html
else
    command! -buffer ManimDocs silent :!start
            \ ~/Documents/manimce-latest/index.html
endif

# Manim: Jump to next-prev section
nnoremap <buffer> <c-m> /\<self.next_section\><cr>
nnoremap <buffer> <c-n> ?\<self.next_section\><cr>

# For replica
# nmap <buffer> <c-enter> <Plug>ReplicaSendCell<cr>j

# ========== FOLD ==============
# Syntax tweaks for Python files
# Adds folding for classes and functions

&l:foldcolumn = 2
if &l:foldmethod != 'diff'
  &l:foldmethod = 'expr'
endif

def MyFoldExpr(): string
  # Check if the current line contains 'def' or 'class'
  var fold_level = '='
  if getline(v:lnum - 1) =~ '^\s*\(def\|class\)'
  # if getline(v:lnum ) =~ '^\s*\(def\|class\)'
    fold_level = '>1'
  # Check if the next line contains 'def' or 'class' to close the fold
  # elseif getline(v:lnum + 1) =~ '^\s*\(def\|class\)'
  elseif getline(v:lnum + 1) =~ '^\s*\(def\|class\|return\)'
    fold_level = '<1'
  else
    fold_level = '='
  endif
  return fold_level
enddef

&l:foldexpr = 'MyFoldExpr()'
# def PythonFoldLevel(lineno: number): string
#   # very primitive at the moment, but actually works quite well in practice
#   var line = getline(lineno)
#   if line == ''
#     line = getline(lineno + 1)
#     if line =~ '^\(def\|class\)\>'
#       return '0'
#     elseif line =~ '^@'
#       return '0'
#     elseif line =~ '^    \(def\|class\|#\)\>'
#       return '1'
#     else
#       var lvl = foldlevel(lineno + 1)
#       return lvl >= 0 ? nr2char(lvl) : '-1'
#     endif
#   elseif line =~ '^\(def\|class\)\>'
#     return '  1'
#   elseif line =~ '^@'   # multiline decorator maybe
#     return '  1'
#   elseif line =~ '^    \(def\|class\)\>'
#     return '  2'
#   elseif line =~ '^[^] #)]'
#     # a non-blank character at the first column stops a fold, except
#     # for '#', so that comments in the middle of functions don't break folds,
#     # and ')', so that I can have multiline function signatures like
#     #
#     #     def fn(
#     #         arg1,
#     #         arg2,
#     #     ):
#     #         ...
#     return '0'
#   elseif line =~ '^# \|^#$' # except when they're proper comments and not commentd-out code (for which I use ##
#     return '0'
#   elseif line =~ '^    [^ )]' # end method folds except watch for black-style signatures
#     return '1'
#   else
#     var lvl = foldlevel(lineno - 1)
#     return lvl >= 0 ? nr2char(lvl) : '='
#   endif
# enddef
# &l:foldexpr = PythonFoldLevel(v:lnum)
