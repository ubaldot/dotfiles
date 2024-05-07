vim9script
#
# args key inside configuration is args to pass to program ${file}
#
# Remote-cmdline in the configuration is the value of %CMD% in the adapter
#
g:vimspector_enable_mappings = 'HUMAN'
g:vimspector_base_dir = g:dotvim .. "/plugins/vimspector"

# Python
var python_path = system("where python")

# C/C++
var debugger_path = "/opt/ST/STM32CubeCLT/GNU-tools-for-STM32/bin/"
if g:os == "Windows"
    debugger_path = "C:/ST/STM32CubeCLT/GNU-tools-for-STM32/bin/"
endif

var debugger = "arm-none-eabi-gdb"

var openocd_script = "openocd_stm32f4x_stlink.sh\n"
var openocd_cmd = 'source ../gdb_stuff/' .. openocd_script
if g:os == "Windows"
    openocd_cmd = "..\\gdb_stuff\\openocd_stm32f4x_stlink.bat\n\r"
endif

var gdb_stuff_path = fnamemodify(getcwd(), ":h") .. "/gdb_stuff"
var elf_filename = fnamemodify(getcwd(), ":t") .. ".elf"
var elf_fullpath = getcwd() .. "/build/" .. elf_filename

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
    "vscode-cpptools-extended": {
      "extends": "vscode-cpptools",
      "launch": {
        "remote": {
          "runCommand": [gdb_stuff_path .. "/openocd_stm32f4x_stlink.sh"],
        }
      },
     },
  }

g:vimspector_configurations = {
    # PYTHON
    # May be replaced once "Python run generic script (NOK)"
    # will reckon virtual environments
    "Remote: launch and attach (OK)": {
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
        "python": [python_path],
        "stopOnEntry": true,
        "console": "integratedTerminal",
        "justMyCode": false,
        "autoReload": {
        "enable": true
        },
      }
    },

        "Python run generic script (NOK)": {
         # Launch current file with debugy. It doed not recognize virtual
         # environments. Opened a issue on debugpy.
         "adapter": "debugpy",
         "filetypes": ["python"],
         "configuration": {
         # If you use "attach" you must specify a processID if you run everything
         # locally OR you should use remote-request: launch
           "request": "launch",
           "program": "${file}",
           # "python": [python_path],
           # "type": "python",
           "cwd": "${fileDirname}",
           "stopOnEntry": true,
           "console": "integratedTerminal",
           "runInTerminal": true,
           "autoReload": {
           "enable": true
           },
         }
         },


    # Embedded C
    # TODO: openocd does not close when vimspector closes
    "STM32F436RE Debug (OK)": {
      "adapter": "vscode-cpptools-extended",
      "filetypes": ["c", "cpp"],
      "default": true,
      "remote-request": "launch",
      "configuration": {
        "request": "launch",
        "program": elf_fullpath,
        "MImode": "gdb",
        "MIDebuggerPath": debugger_path .. debugger,
        "miDebuggerServerAddress": "localhost:3333",
        "console": "integratedTerminal"
      }
    },
  }


####### WRONG ADAPTERS ##################

# "dymoval_adapter": {
#   "extends": "debugpy",
#   "variables": {
#     "Host": "localhost",
#     "Port": "5678"
#   },
#    "command": [
#          "python",
#          "-Xfrozen_modules=off",
#          "-m",
#          "debugpy",
#          "--listen",
#          "${Host}:${Port}",
#          "--wait-for-client",
#    ],
#   "port": "${Port}",
# },

# "OpenOCDServer": {
#   # NOK!
#   # "command": HERE YOU SHALL SPECIFY THE DAP! FOR EXAMPLE OpenDebugAD7.
#   "launch": {
#     "remote": {
#       "runCommand": [gdb_stuff_path .. "/openocd_stm32f4x_stlink.sh"],
#     }
#   }
# },


####### WRONG CONFIGURATIONS ##################

# "Dymoval (NOK)": {
#   "adapter": "dymoval_adapter",
#   "filetypes": ["python"],
#   "configuration": {
#    # If "request" is "launch" then the file to be debugged is specified in
#    # "program"
#     "request": "attach",
#     "program": "${file}",
#     "python": [python_path],
#     "stopOnEntry": true,
#     "console": "integratedTerminal",
#     # args is what to pass to "program" along with ${file}.
#     # "args": ["-Xfrozen_modules=off"]
#     "autoReload": {
#     "enable": true
#     },
#   },
#   # "delay": "1000m",
# },
#
#
#gdb -> openocd (NOK)": {
# This is similar to what I have in Termdebug. I should use a DAP to make
# vimspector to work. THIS DOES NOT WORK!
# "adapter": "OpenOCDServer",
# "filetypes": ["c", "cpp"],
# "remote-request": "launch",
# "configuration": {
#   "request": "launch",
#   "program": elf_fullpath,
#   "console": "integratedTerminal",
#   "MImode": "gdb",
#   "MIDebuggerPath": debugger_path .. debugger,
#   "miDebuggerServerAddress": "localhost:3333",
# }
# },
