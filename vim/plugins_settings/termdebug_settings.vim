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
    # Resize gdb window. It could be improved...
    resize 5
    wincmd k

    # Unlist the various buffers opened by termdebug
    setbufvar("debugged program", "&buflisted", 0)
    setbufvar("gdb communication", "&buflisted", 0)
    setbufvar("arm-none-eabi-gdb", "&buflisted", 0)
    setbufvar("Termdebug-variables-listing", "&buflisted", 0)
    setbufvar("OPENOCD", "&buflisted", 0)
enddef

def ShutoffTermdebug()
    for bufnum in term_list()
        if bufname(bufnum) ==# 'OPENOCD'
            execute "bw! " .. bufnum
        endif
    endfor
enddef

augroup OpenOCDShutdown
    autocmd!
    autocmd User TermdebugStopPost ShutoffTermdebug()
augroup END

command! Debug vim9cmd MyTermdebug()
