vim9script

# LSP setup
# ---------------------------
# This json-like style to encode configs like
# pylsp.plugins.pycodestyle.enabled = true
var pylsp_config = {
  'pylsp': {
    'ConfigurationSources': 'flake8',
    'plugins': {
      'pylsp_mypy': {
         'enabled': true,
         'live_mode': true,
         'strict': false,
         'exclude': ["tests/*", "manual_tests/*", "docs/*"]},
      'pycodestyle': {
        'enabled': false},
      'pyflakes': {
        'enabled': true},
      'pydocstyle': {
        'enabled': false},
      'mccabe': {
        'enabled': false},
      'autopep8': {
        'enabled': false}, }, }, }


# clangd env setup
var clangd_name = 'clangd'
var clangd_path = 'clangd'
var clangd_args =  ['--background-index', '--clang-tidy', '-header-insertion=never']

var is_avap = true
if is_avap
  clangd_name = 'avap'
  var project_root = '/home/yt75534/avap_example'
  clangd_path = $'{project_root}/clangd_in_docker.sh'
  clangd_args = []
  set makeprg=./avap-util/scripts/enter-container.sh\ build_avap\ linux

  # au! BufReadPost quickfix  setlocal modifiable
  # 	\ | silent exe ':%s/^\/app/\/home\/yt75534\/avap_example/g'
  # 	\ | setlocal nomodifiable

endif

var lspServers = [
  {
    name: 'pylsp', # This is a dummy name
    filetype: ['python'],
    path: 'pylsp', # This is the executable name
    workspaceConfig: pylsp_config,
    args: ['--check-parent-process', '-v'],
  },
  {
    name: clangd_name,
    filetype: ['c', 'cpp'],
    path: clangd_path,
    args: clangd_args,
    debug: true,
  },
  {
    name: 'texlab',
    filetype: ['tex'],
    path: 'texlab',
  },
]

autocmd VimEnter * g:LspAddServer(lspServers)

var lspOpts = {'showDiagOnStatusLine': true, 'noNewlineInCompletion': true}
autocmd VimEnter * g:LspOptionsSet(lspOpts)
highlight link LspDiagLine NONE

nnoremap <silent> <leader>p <Cmd>LspDiag prev<cr>
nnoremap <silent> <leader>n <Cmd>LspDiag next<cr>
nnoremap <silent> <leader>d <Cmd>LspDiag current<cr>
nnoremap <silent> <leader>i <Cmd>LspGotoImpl<cr>
nnoremap <silent> <leader>k <Cmd>LspHover<cr>
nnoremap <silent> <leader>g <Cmd>LspGotoDefinition<cr>
nnoremap <silent> <leader>r <Cmd>LspShowReferences<cr>
