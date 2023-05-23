vim9script
# Tell vim where is Python. OBS: this is independent of the plugins!
# You must check in the vim version what dll is required in the field -DDYNAMIC_PYTHON_DLL=\python310.dll\

setlocal foldmethod=indent

augroup BLACK
    autocmd!
    autocmd BufWritePost <buffer> silent exe "!black " .. expand('<afile>') | edit!
                # \ | echo expand('%:t') .. " formatted."
augroup END

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
