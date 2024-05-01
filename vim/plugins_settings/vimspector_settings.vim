vim9script

# vimspector TODO
g:vimspector_enable_mappings = 'HUMAN'
g:vimspector_base_dir = g:dotvim .. "/plugins/vimspector"
g:vimspector_configurations = {
  "$schema": "https://puremourning.github.io/vimspector/schema/vimspector.schema.json",
  "adapters": {
    "run_with_debugpy": {
      "extends": "debugpy",
      "variables": {
        "Host": "localhost",
        "Port": "5678"
      },
      "command": [
        "python -m debugpy --wait-for-client --listen ${Host}:${Port} ${file}"
      ],
      "port": "${Port}"
    },

    // This does not extends debugpy. Will it work?
    "python-remote": {
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
            "-m",
            "debugpy",
            "--listen",
            "${Host}:${Port}",
            "--wait-for-client",
            "%CMD%"
          ]
        }
      }
    }
  },

  "configurations": {
    "Remote: attach": {
      "adapter": "run_with_debugpy",
      "filetypes": ["python"],
      "configuration": {
        "request": "attach",
        "program": "${file}",
        "stopOnEntry": true,
        "console": "integratedTerminal",
        "args": [""]
      }
    },
    "Simple: launch": {
      // This should be the simplest
      // No adapter defined. Use a standard gadget.
      "adapter": "debugpy",
      "filetypes": ["python"],
      // "default": true,
      "configuration": {
        "request": "launch",
        "program": "${file}",
        "stopOnEntry": true,
        "console": "integratedTerminal"
        // args to pass to program ${file}
        // "args": ["*${args:--update-gadget-config}"]
        // "args": [ "*${args}" ]
      }
    },

    "Remote: launch": {
      "adapter": "python-remote",
      "filetypes": ["python"],
      "remote-request": "launch",
      "remote-cmdLine": [
        // This is the value of %CMD% in the adapter
        // Were ${RemoteRoot} is defined?
        // "${RemoteRoot}/${fileBasename}",
        // "*${args}"
        "${file}"
      ],
      "configuration": {
        "request": "launch",
        "program": "${file}",
        "stopOnEntry": true,
        "console": "integratedTerminal",
        "args": ["*${args}"]
      }
    },

    "run current script": {
      "adapter": "debugpy",
      "configuration": {
        "request": "launch",
        "type": "python",
        "cwd": "${fileDirname}",
        "program": "${file}",
        "stopOnEntry": true,
        "console": "integratedTerminal"
        // "args": [ "*${args}" ]
      }
    },
    "platformio_configuration": {
      "adapter": "vscode-cpptools",
      "configuration": {
        "request": "launch",
        "cwd": "${workspaceRoot}",
        "program": "${workspaceRoot}/.pio/build/nucleo_h743zi/firmware.elf",
        "MIMode": "gdb",
        "miDebuggerPath": "piodebuggdb",
        "miDebuggerArgs": "--project-dir ${workspaceRoot} -x .pioinit"
      }
    },
    //openocd -f interface/jlink.cfg -c 'transport select swd' -f target/stm32f4x.cfg
    "OpenOCD": {
      // "adapter": "vscode-cpptools",
      "adapter": "vscode-lldb",
      "configuration": {
        "request": "launch",
        "program": "${workspaceRoot}/build/zephyr/zephyr.elf",
        "MImode": "gdb",
        "MIDebuggerPath": "~/zephyr-sdk-0.16.0/arm-zephyr-eabi/bin/arm-zephyr-eabi-gdb",
        "miDebuggerServerAddress": "127.0.0.1:3333"
      }
    }
  }
}
