vim9script

# vim-poptools
g:poptools_config = {}
g:poptools_config['preview_recent_files'] = false
g:poptools_config['preview_buffers'] = true
g:poptools_config['preview_grep'] = true
g:poptools_config['preview_vimgrep'] = true
g:poptools_config['fuzzy_search'] = false

nnoremap <c-p> <cmd>PoptoolsFindFile<cr>
# Copy in the selected text into t register ad leave it. Who cares about the t
# register?
nnoremap <c-p>l <cmd>PoptoolsLastSearch<cr>
nnoremap <c-tab> <cmd>PoptoolsBuffers<cr>
nnoremap <c-p>o <cmd>PoptoolsRecentFiles<cr>

def ShowRecentFiles()
  var readable_args = copy(v:argv[1 : ])->filter((_, x) =>
    !empty(x) && filereadable(x)
  )
  if len(readable_args) == 0
    execute('PoptoolsRecentFiles')
  endif
enddef
