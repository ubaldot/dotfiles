" Some good VIM notes
" ======================
" This file is sourced AFTER .vimrc
" ==========================

call system('source ~/.zshrc')
" call system('conda activate myenv')

" Set terminal with 256 colors
set termguicolors
" Set fonts for gvim
if has("gui_win32")
    let g:fontface = "FiraCode_NFM"
    let g:fontsize_small = ":h8:cANSI:qDRAFT" 
    let g:fontsize_large = ":h11:cANSI:qDRAFT" 
    " Open gvim in full-screen
    au GUIEnter * simalt ~x
elseif has("gui_macvim")
    set shell=zsh " to be able to source ~/.zshrc (conda init)
    let g:fontface = "Fira\ Code"
    let g:fontsize_small = ":h8"
    let g:fontsize_large = ":h14"
endif
" guifont is reserved word (aka 'option')
let &guifont=g:fontface.g:fontsize_large


" Some key bindings
"Zoom in and out"
nnoremap <silent> <c-z><c-o> :let &guifont=g:fontface . g:fontsize_small<cr>
nnoremap <silent> <c-z><c-i> :let &guifont=g:fontface . g:fontsize_large<cr>


" To have nice colors during autocompletion
hi Pmenu guibg=lightgray guifg=black
hi PmenuSel guibg=darkgray guifg=gray


