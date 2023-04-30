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
# set colorcolumn=80


# Select the IPYTHON profile settings in  ~/.ipython
b:profile = 'autoreload_profile'

setlocal foldmethod=indent

# Manim stuff
# Render with bang.
def Manim(scene: string, dryrun: bool)
    var flags = ""
    if dryrun
        flags = " --dry_run"
    else
        flags = " -pql"
    endif
    var closeQT = "osascript ~/QuickTimeClose.scpt"
    var cmd = "manim " .. shellescape(expand("%:t")) .. " " .. scene .. flags .. " --disable_caching -v WARNING"
    exe "!" .. closeQT .. " && " .. cmd
enddef

# Render in a terminal buffer
def ManimTerminal(scene: string, dryrun: bool)
    var flags = ""
    if dryrun
        flags = " --dry_run"
    else
        flags = " -pql"
    endif
    var closeQT = "osascript ~/QuickTimeClose.scpt"
    var cmd = "manim " .. expand("%:t") .. " " .. scene .. flags .. " --disable_caching -v WARNING"
    var terms_name = []
    for ii in term_list()
        add(terms_name, bufname(ii))
    endfor
    echo terms_name
    if term_list() == [] || index(terms_name, 'MANIM') == -1
        vert term_start(&shell, {'term_name': 'MANIM' })
        set nowrap
    endif
    term_sendkeys(bufnr('MANIM'), "clear \n" .. closeQT .. "&& " .. cmd .. "\n")
enddef

# Manim user-defined commands
command -nargs=+ -complete=command Manim silent call
            \ Manim(<f-args>, false)
command -nargs=+ -complete=command ManimDry silent call
            \ Manim(<f-args>, true)
command -nargs=+ -complete=command ManimTerminal silent call
            \ ManimTerminal(<f-args>, false)
command -nargs=+ -complete=command ManimTerminalDry silent call
            \ ManimTerminal(<f-args>, true)
