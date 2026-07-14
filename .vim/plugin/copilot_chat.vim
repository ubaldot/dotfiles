vim9script

g:copilot_chat_disable_mappings = true

def CopilotWindowToggle()
  var unlisted_buffers = filter(getbufinfo(), (_, v) => !v.listed)
  if unlisted_buffers->filter('v:val =~ "^Copilot-Chat"')->!empty()
    exe "CopilotChatToggle"
  else
    exe "CopilotChatOpen"
  endif
enddef

nnoremap <leader>CC <scriptcmd>CopilotWindowToggle()<cr>
xnoremap <leader>CE <Plug>CopilotChatAddSelection
