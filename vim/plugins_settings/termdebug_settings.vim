vim9script

# Termdebug stuff
# Call as Termdebug build/myfile.elf
# OBS! BE sure to be in the project root folder and that a build/ folder exists!
g:termdebug_config = {}
var debugger_path = "/opt/ST/STM32CubeCLT/GNU-tools-for-STM32/bin/"
if has("gui_win32") || has("win32")
    debugger_path = "C:/ST/STM32CubeCLT/GNU-tools-for-STM32/bin/"
endif

var debugger = "arm-none-eabi-gdb"

var openocd_script = "openocd_stm32f4x_stlink.sh\n"
var openocd_cmd = 'source ../gdb_stuff/' .. openocd_script
if has("gui_win32") || has("win32")
    openocd_cmd = "..\\gdb_stuff\\openocd_stm32f4x_stlink.bat\n\r"
endif

g:termdebug_config['command'] = [debugger_path .. debugger, "-x", "../gdb_stuff/gdb_init_commands.txt"]
g:termdebug_config['variables_window'] = 1

packadd termdebug
# The windows debugger sucks. It is based on cmd.exe. Use an external debugger (like use MinGW64).
def MyTermdebug()
    # The .elf name is supposed to be the same as the folder name.
    # Before calling this function you must launch a openocd server.
    # This happens inside this script with

    #   source ../openocd_stm32f4x_stlink.sh
    #
    # Then Termdebug is launched.
    # When Termdebug is closed, then the server is automatically shutoff

    # Start a openocd terminal

    var ii = term_start(&shell, {'term_name': 'OPENOCD', 'hidden': 1, 'term_finish': 'close'})
    term_sendkeys(ii, openocd_cmd)

    var filename = fnamemodify(getcwd(), ':t')
    echo filename
    execute "Termdebug build/" .. filename .. ".elf"
    execute "close " ..  bufwinnr("debugged program")
enddef

augroup OpenOCDShutdown
    autocmd!
    autocmd User TermdebugStopPost {
        for bufnum in term_list()
            if bufname(bufnum) ==# 'OPENOCD'
                execute "bw! " .. bufnum
            endif
        endfor
    }
augroup END

command! Debug vim9cmd MyTermdebug()
