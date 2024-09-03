vim9script
#
# args key inside configuration is args to pass to program ${file}
#
# Remote-cmdline in the configuration is the value of %CMD% in the adapter
#
# g:vimspector_enable_mappings = 'HUMAN'
if g:os == "Windows"
  g:vimspector_base_dir = g:dotvim .. "\\plugins\\vimspector"
else
  g:vimspector_base_dir = g:dotvim .. "/plugins/vimspector"
endif

command! VimspectorLaunch feedkeys('\<Plug>VimspectorContinue', 't')

# C/C++
# For all defrecs framework
var elf_filename = fnamemodify(getcwd(), ":t") .. ".elf"
var elf_fullpath = getcwd() .. "/build/" .. elf_filename
var gdb_stuff_path = fnamemodify(getcwd(), ":h") .. "/gdb_stuff"

# STM32F4xx
var stm32f4xx_runCommand = [$'{gdb_stuff_path}/openocd_stm32f4x_stlink.sh']
if g:os == "Windows"
  stm32f4xx_runCommand = ['cmd.exe', '/c', $'{gdb_stuff_path}\\openocd_stm32f4x_stlink.bat']
endif

# Mappings
g:vimspector_mappings = { C: '<Plug>VimspectorContinue',
    B: '<Plug>VimspectorToggleBreakpoint',
    I: '<Plug>VimspectorStepInto',
    O: '<Plug>VimspectorStepOver',
    F: '<Plug>VimspectorStepOut',
    X: '<cmd>VimspectorReset<cr>',
    S: '<Plug>VimspectorStop'}

var existing_mappings = {}
def SetupVimspectorMappings()
  if exists('g:vimspector_mappings')
    for key in keys(g:vimspector_mappings)
      # Save possibly existing mappings
      if !empty(mapcheck(key, "n"))
        existing_mappings[key] = maparg(key, 'n', false, true)
      endif
      exe 'nnoremap <expr> ' .. key .. " " .. $"$'{g:vimspector_mappings[key]}'"
    endfor
  endif
enddef

def TeardownVimspectorMappings()
  if exists('g:vimspector_mappings')
    for key in keys(g:vimspector_mappings)
      if has_key(existing_mappings, key)
        mapset('n', 0, existing_mappings[key])
      else
        exe $"nunmap {key}"
      endif
    endfor
  endif
  existing_mappings = {}
enddef

augroup VimspectorMappings
  autocmd!
  autocmd User VimspectorUICreated SetupVimspectorMappings()
  autocmd User VimspectorDebugEnded TeardownVimspectorMappings()
augroup END

##################################
# ADAPTERS
##################################

g:vimspector_adapters = {
  # PYTHON
  # May be replaced once "Python run generic script (NOK)"
  # will reckon virtual environments
  "python-remote-launch": {
    "variables": {
      "Host": "localhost",
      "Port": "5678"
    },
    "port": "${Port}",
    "host": "${Host}",
    "launch": {
      "remote": {
        "runCommand": [
          "python",
          "-Xfrozen_modules=off",
          "-m",
          "debugpy",
          "--listen",
          "${Host}:${Port}",
          "--wait-for-client",
          "%CMD%"
        ]
      }
    },
  # "delay": "1000m",
  },

  # Embedded C
  # Launch an openocd server
  "stm32f4xx": {
    "extends": "vscode-cpptools",
    "launch": {
      "remote": {
        "runCommand": stm32f4xx_runCommand,
      }
    },
  },
}

##################################
# CONFIGURATIONS
##################################
g:vimspector_configurations = {
  # PYTHON
  # For debugpy configuration, see here: https://code.visualstudio.com/docs/python/debugging
  # May be replaced once "Python run generic script (NOK)"
  # will reckon virtual environments
  "Remote: launch and attach (slow)": {
    "adapter": "python-remote-launch",
    "filetypes": ["python"],
    # Instead of manually run a process and fetch the PID, you directly
    # lunch the process in the remote and connect to it.
    "remote-request": "launch",
    # "default": true,
    # This replaces %CMD% in the adapter.
    "remote-cmdLine": [
      "${file}"
    ],
    "configuration": {
      # You attach to the process launched in the remote.
      "request": "attach",
      "program": "${file}",
      "python": [exepath('python')],
      "stopOnEntry": true,
      "console": "integratedTerminal",
      "justMyCode": false,
      "autoReload": {
        "enable": true
      },
    }
  },

  "Simple debugger": {
    # For debugpy configuration, see here: https://code.visualstudio.com/docs/python/debugging
    # Launch current file with debugy. It doed not recognize virtual
    # environments. Opened a issue on debugpy.
    "adapter": "debugpy",
    "filetypes": ["python"],
    "configuration": {
      # If you use "attach" you must specify a processID if you run everything
      # locally OR you should use remote-request: launch
      "request": "launch",
      "program": "${file}",
      "python": [exepath('python')],
      "type": "python",
      "cwd": "${fileDirname}",
      "stopOnEntry": true,
      "console": "integratedTerminal",
      "justMyCode": false,
      "runInTerminal": true,
      "autoReload": {
        "enable": true
      },
    }
  },


  # Embedded C
  # TODO: openocd does not close when vimspector closes
  "STM32F436RE Debug": {
    "adapter": "stm32f4xx",
    "filetypes": ["c", "cpp"],
    "remote-request": "launch",
    "configuration": {
      "request": "launch",
      "program": elf_fullpath,
      "MImode": "gdb",
      # "MIDebuggerPath": debugger_path .. debugger,
      "MIDebuggerPath": exepath('arm-none-eabi-gdb'),
      "miDebuggerServerAddress": "localhost:3333",
      "console": "integratedTerminal"
    }
  },
}
