vim9script

set noautocomplete

def SendQuery()
  exe $"CopilotChatSetActive {bufnr()}"
  exe "CopilotChatSubmit"
enddef

nnoremap <buffer> <CR> <scriptcmd>SendQuery()<cr>
inoremap <buffer> <CR> <scriptcmd>SendQuery()<cr>
inoremap <buffer> <s-CR> <cr>
nnoremap <buffer> <leader>CD <cmd>bwipe<cr>
nnoremap <buffer> <leader>D <cmd>bwipe<cr>
nnoremap <buffer> <leader>S <cmd>CopilotChatSetActive<cr>
