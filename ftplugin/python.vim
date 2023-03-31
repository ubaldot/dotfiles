vim9script
# Tell vim where is Python. OBS: this is independent of the plugins!
# You must check in the vim version what dll is required in the field -DDYNAMIC_PYTHON_DLL=\python310.dll\
#
#
set pythonthreehome=$HOME."\\Miniconda3"
set pythonthreedll=$HOME."\\Miniconda3\\python39.dll"

# Highlighth the whole section
# var N = 80
# var winid = win_getid()
# var winwidth = winwidth(winid)

# if winwidth > N
#     &colorcolumn = join(range(N + 1, winwidth), ",")
# endif

# ... or just set a tiny line for marking the limit
set colorcolumn=80


# Select the IPYTHON profile settings in  ~/.ipython
b:profile = 'autoreload_profile'

setlocal foldmethod=indent
