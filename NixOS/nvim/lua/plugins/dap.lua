return {
  {
    "nvim-dap",
    dir = plugin_path("nvim-dap"),
    name = "nvim-dap",
    dependencies = {
      {
        "nvim-dap-ui",
        dir = plugin_path("nvim-dap-ui"),
        name = "nvim-dap-ui",
      },
      {
        "nvim-nio",
        dir = plugin_path("nvim-nio"),
        name = "nvim-nio",
      },
    },
    keys = {
      { "<leader>dc", function() require("dap").continue() end, desc = "DAP Continue" },
      { "<leader>do", function() require("dap").step_over() end, desc = "DAP Step Over" },
      { "leader>di", function() require("dap").step_into() end, desc = "DAP Step Into" },
      { "leader>dO", function() require("dap").step_out() end, desc = "DAP Step Out" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dB", function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end, desc = "Conditional Breakpoint" },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "DAP REPL" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup({})

      -- Автоматически открывать/закрывать UI при старте/завершении отладки
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.after.event_stopped["dapui_config"] = function()
        dapui.open()
      end

      -- Знаки для точек останова
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn" })

      -- === Python: debugpy ===
      dap.adapters.python = {
        type = "executable",
        command = "python3",
        args = { "-m", "debugpy.adapter" },
      }

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            return "python3"
          end,
        },
      }

      -- === C / C++: gdb (нужен GDB >= 14) ===
      dap.adapters.gdb = {
        id = "gdb",
        type = "executable",
        command = "gdb",
        args = { "--quiet", "--interpreter=dap" },
      }

      dap.configurations.c = {
        {
          name = "Run executable (GDB)",
          type = "gdb",
          request = "launch",
          program = function()
            local path = vim.fn.input({
              prompt = "Path to executable: ",
              default = vim.fn.getcwd() .. "/",
              completion = "file",
            })
            return (path and path ~= "") and path or dap.ABORT
          end,
          cwd = "${workspaceFolder}",
        },
        {
          name = "Attach to process (GDB)",
          type = "gdb",
          request = "attach",
          processId = require("dap.utils").pick_process,
        },
      }

      dap.configurations.cpp = dap.configurations.c
    end,
  },
}
