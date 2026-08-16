vim9script

# clangd env setup
var clangd_name = 'clangd'
var clangd_path = 'clangd'
var clangd_args =  ['--background-index', '--clang-tidy', '-header-insertion=never']

if g:is_avap
  clangd_name = 'avap'
  var project_root = '/home/yt75534/avap_example'
  clangd_path = $'{project_root}/clangd_in_docker.sh'
  clangd_args = []
  set makeprg=./avap-util/scripts/enter-container.sh\ build_avap\ linux
endif

# ----- LSP servers config ------------------

var lspServers = [
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

# -------- Python LSP servers config -----
var pyright_config = {
  settings: {
    python: {
      analysis: {
        autoSearchPaths: true,
        diagnosticMode: "openFilesOnly",
        useLibraryCodeForTypes: true,
      },
      pythonPath: exepath('python'),
    # venvPath: '/opt/homebrew/Caskroom/miniconda/base/envs/myenv',
    # venv: 'myenv'
    },
    verboseOutput: true
  },
}

var pyright_lsp = {
  name: "pyright",
  filetype: ["python"],
  path: "pyright-langserver",
  workspaceConfig: pyright_config,
  rootSearch: [
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    "pyrightconfig.json",
    ".git"
  ],
  args: ['--stdio']
}

var zuban_lsp = {
  name: 'Zuban', # This is a dummy name
  filetype: ['python'],
  path: 'zuban', # This is the executable name
  # workspaceConfig: pylsp_config,
  # debug: true,
  args: ['server'],
}

var python_lsp = zuban_lsp
add(lspServers, python_lsp)
# --------
g:lsp_servers = lspServers

# ---- lsp options -----
var lspOpts = {'showDiagOnStatusLine': true, 'noNewlineInCompletion': true}
g:lsp_options = lspOpts
