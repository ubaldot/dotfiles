vim9script

# Termdebug stuff
#
# 1. It opens openocd in a terminal
# 2. Connect gdb to openocd via telnet (see gdb_init_commands.txt)
# 3. Be sure that the local and the loaded on target .elf files are the same.
#
# OBS! Be sure to be in the project root folder and that a build/ folder exists!
#
# OBS! The windows debugger sucks. It is based on cmd.exe. Use an external debugger (like use MinGW64).

# 1. OpenOCD settings
var openocd_script = "openocd_stm32f4x_stlink.sh\n"
var openocd_cmd = 'source ../gdb_stuff/' .. openocd_script
if g:os == "Windows"
    openocd_cmd = "..\\gdb_stuff\\openocd_stm32f4x_stlink.bat\n\r"
endif


# 2. Debugger settings
g:termdebug_config = {}
var debugger_path = "/opt/ST/STM32CubeCLT/GNU-tools-for-STM32/bin/"
if g:os == "Windows"
    debugger_path = "C:/ST/STM32CubeCLT/GNU-tools-for-STM32/bin/"
endif

var debugger = "arm-none-eabi-gdb"

g:termdebug_config['command'] = [debugger_path .. debugger, "-x", "../gdb_stuff/gdb_init_commands.txt"]
g:termdebug_config['variables_window'] = 1


# Run all the machinery
packadd termdebug
def MyTermdebug()
    # The .elf name is supposed to be the same as the project name.
    # Before calling this function you must launch a openocd server.
    # This happens inside this script with

    #   source ../openocd_stm32f4x_stlink.sh
    #
    # Then Termdebug is launched.
    # When Termdebug is closed, then the server is automatically shutoff

    # 1. Start a openocd terminal
    var ii = term_start(&shell, {'term_name': 'OPENOCD', 'hidden': 1, 'term_finish': 'close'})
    term_sendkeys(ii, openocd_cmd)

    # 2. Start arm-eabi-none-gdb and connect to openocd (see g:termdebug_config['command'])
    # OBS! Be sure that the local and the loaded .elf file in the remote are the same!
    var filename = fnamemodify(getcwd(), ':t')
    echo "Starting debugger for project: " .. filename
    execute "Termdebug build/" .. filename .. ".elf"
    execute "close " ..  bufwinnr("debugged program")

    # Create serial monitor
    wincmd W
    win_execute(win_getid(), 'term_start("make monitor",
                        \ {"term_name": "serial_monitor"})' )

    # TODO: can be done better
    # Jumping around and resizing
    wincmd j
    wincmd j
    resize 8
    wincmd k

    # Unlist the various buffers opened by termdebug
    setbufvar("debugged program", "&buflisted", 0)
    setbufvar("gdb communication", "&buflisted", 0)
    setbufvar(debugger, "&buflisted", 0)
    setbufvar("Termdebug-variables-listing", "&buflisted", 0)
    setbufvar("OPENOCD", "&buflisted", 0)
    setbufvar("serial_monitor", "&buflisted", 0)
enddef

def ShutoffTermdebug()
    for bufnum in term_list()
        if bufname(bufnum) ==# 'OPENOCD' || bufname(bufnum) ==# 'serial_monitor'
            execute "bw! " .. bufnum
        endif
    endfor
enddef

augroup OpenOCDShutdown
    autocmd!
    autocmd User TermdebugStopPost ShutoffTermdebug()
augroup END


# Mappings
var map_CC = ""
var map_B = ""
var map_C = ""
var map_S = ""
var map_O = ""
var map_F = ""
var map_X = ""

def SetUpTermDebugOverrides()
    if !empty(mapcheck("CC", "n"))
        map_CC = maparg('CC', 'n')
    endif
    if !empty(mapcheck("B", "n"))
        map_B = maparg('B', 'n')
    endif
    if !empty(mapcheck("C", "n"))
        map_C = maparg('C', 'n')
    endif
    if !empty(mapcheck("S", "n"))
        map_S = maparg('S', 'n')
    endif
    if !empty(mapcheck("O", "n"))
        map_O = maparg('O', 'n')
    endif
    if !empty(mapcheck("F", "n"))
        map_F = maparg('F', 'n')
    endif
    if !empty(mapcheck("X", "n"))
        map_X = maparg('X', 'n')
    endif

    nnoremap C <Cmd>Continue<CR>
    nnoremap B <Cmd>Break<CR>
    nnoremap CC <Cmd>Clear<CR>
    nnoremap S <Cmd>Step<CR>
    nnoremap O <Cmd>Over<CR>
    nnoremap F <Cmd>Finish<CR>
    nnoremap X <Cmd>Stop<CR>
enddef

def TearDownTermDebugOverrides()
    if !empty(map_CC)
        nnoremap CC expand(map_CC)
    else
        nunmap CC
    endif
    if !empty(map_B)
        nnoremap B expand(map_B)
    else
        nunmap B
    endif
    if !empty(map_C)
        nnoremap C expand(map_C)
    else
        nunmap C
    endif
    if !empty(map_S)
        nnoremap S expand(map_S)
    else
        nunmap S
    endif
    if !empty(map_O)
        nnoremap O expand(map_O)
    else
        nunmap O
    endif
    if !empty(map_F)
        nnoremap F expand(map_F)
    else
        nunmap F
    endif
    if !empty(map_X)
        nnoremap X expand(map_X)
    else
        nunmap X
    endif
enddef

augroup MyTermDebugOverrides
    autocmd!
    autocmd User TermdebugStartPost SetUpTermDebugOverrides()
    autocmd User TermdebugStopPost  TearDownTermDebugOverrides()
augroup END

command! Debug vim9cmd MyTermdebug()
