--
-- Shows how to use the DAP plugin to debug your code.
--
-- https://github.com/mfussenegger/nvim-dap
-- luacheck: globals vim
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    -- Creates a beautiful debugger UI
    "rcarriga/nvim-dap-ui",

    -- Installs the debug adapters for you
    "williamboman/mason.nvim",
    "jay-babu/mason-nvim-dap.nvim",

    -- Add your own debuggers here
    "leoluz/nvim-dap-go",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    require("mason-nvim-dap").setup({
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_setup = true,
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      -- handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        "bash",
        "delve",
        "jq",
        "js",
        "lua",
        "php",
        "python",
        "stylua",
      },
      handlers = {
        function(config)
          -- all sources with no handler get passed here

          -- Keep original functionality
          require("mason-nvim-dap").default_setup(config)
        end,
      },
    })

    local wk = require("which-key")
    wk.register({
      -- Basic debugging keymaps, feel free to change to your liking!
      ["<F5>"] = { dap.continue, "Debug: Start/Continue" },
      ["<F1>"] = { dap.step_into, "Debug: Step Into" },
      ["<F2>"] = { dap.step_over, "Debug: Step Over" },
      ["<F3>"] = { dap.step_out, "Debug: Step Out" },
      ["<leader>Db"] = { dap.toggle_breakpoint, "Debug: Toggle Breakpoint" },
      ["<leader>DB"] = {
        function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
        "Debug: Set Breakpoint",
      },
      -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
      ["<F7>"] = { dapui.toggle, "Debug: See last session result." },
    }, { prefix = "", mode = "n" })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup({
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
      controls = {
        icons = {
          pause = "⏸",
          play = "▶",
          step_into = "⏎",
          step_over = "⏭",
          step_out = "⏮",
          step_back = "b",
          run_last = "▶▶",
          terminate = "⏹",
          disconnect = "⏏",
        },
      },
    })

    dap.listeners.after.event_initialized["dapui_config"] = dapui.open
    dap.listeners.before.event_terminated["dapui_config"] = dapui.close
    dap.listeners.before.event_exited["dapui_config"] = dapui.close

    -- Install golang specific config
    require("dap-go").setup()
  end,
}
