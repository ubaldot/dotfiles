vim9script

# txtfmt settings
# TODO fix this and change the Shortcuts with R Y and G rather than r,y,g
g:txtfmtBgcolor2 = '^R$,c:LightRed,g:' .. matchstr(execute('highlight DiffDelete'), 'guibg=\zs#\x\+')
g:txtfmtBgcolor3 = '^Y$,c:LightYellow,g:' .. matchstr(execute('highlight DiffChange'), 'guibg=\zs#\x\+')
g:txtfmtBgcolor5 = '^G$,c:LightGreen,g:' .. matchstr(execute('highlight DiffAdd'), 'guibg=\zs#\x\+')

g:txtfmtShortcuts = []

# Note: Shortcuts that don't specify modes will get select mode mappings if and only if txtfmtShortcutsWorkInSelect=1.
# bold-underline (\u for Visual and Operator)
add(g:txtfmtShortcuts, 'h1 kR')
add(g:txtfmtShortcuts, 'h2 kY')
add(g:txtfmtShortcuts, 'h3 kG')
add(g:txtfmtShortcuts, 'hh k-')

augroup SetTxtFmt
    autocmd!
    autocmd BufRead,BufNewFile *.txt set filetype=text.txtfmt
    autocmd BufRead,BufNewFile *.md set filetype=markdown.txtfmt
augroup END

augroup SetHeadersAsCfiletype
    autocmd!
    autocmd BufRead,BufNewFile *.h set filetype=c
augroup END

# Delete MakeTestPage so when typing :Ma I get Manim as first hit
# augroup deletePluginCommand
#     autocmd!
#     autocmd VimEnter * delcommand MakeTestPage
# augroup END
