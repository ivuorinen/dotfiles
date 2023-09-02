-- File-tree manager.

-- Unless you are still migrating, remove the deprecated commands from v1.x
vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    {
      -- only needed if you want to use the commands with "_with_window_picker" suffix
      "s1n7ax/nvim-window-picker",
      config = function()
        require("window-picker").setup({
          autoselect_one = true,
          include_current = false,
          filter_rules = {
            -- filter using buffer options
            bo = {
              -- if the file type is one of following, the window will be ignored
              filetype = { "neo-tree", "neo-tree-popup", "notify" },

              -- if the buffer type is one of following, the window will be ignored
              buftype = { "terminal", "quickfix" },
            },
          },
          other_win_hl_color = "#e35e4f",
        })
      end,
    },
  },
  config = function()
    -- If you want icons for diagnostic errors, you'll need to define them somewhere:
    vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
    vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
    vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
    vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })

    require("neo-tree").setup({
      close_if_last_window = true,    -- Close Neo-tree if it is the last window left in the tab
      popup_border_style = "rounded", -- "double", "none", "rounded", "shadow", "single" or "solid"
      enable_git_status = true,
      enable_diagnostics = true,
      enable_normal_mode_for_inputs = false,                             -- Enable normal mode for input dialogs.

      open_files_do_not_replace_types = { "terminal", "trouble", "qf" }, -- when opening files, do not use windows containing these filetypes or buftypes

      -- popup_border_style is for input and confirmation dialogs.
      -- Configurtaion of floating window is done in the individual source sections.
      -- "NC" is a special style that works well with NormalNC set
      close_floats_on_escape_key = true,
      default_source = "filesystem",
      git_status_async = true,
      log_level = "info",               -- "trace", "debug", "info", "warn", "error", "fatal"
      log_to_file = false,              -- true, false, "/path/to/file.log", use :NeoTreeLogs to show the file
      open_files_in_last_window = true, -- false                                                                = open files in top left window
      resize_timer_interval = 100,      -- in ms, needed for containers to redraw right aligned and faded content
      sort_case_insensitive = true,     -- used when sorting files and directories in the tree
      use_popups_for_input = false,     -- If false, inputs will use vim.ui.input() instead of custom floats.
      sort_function = nil,              -- use a custom function for sorting files and directories in the tree

      event_handlers = {
        --  {
        --    event = "before_render",
        --    handler = function (state)
        --      -- add something to the state that can be used by custom components
        --    end
        --  },
        --  {
        --    event = "file_opened",
        --    handler = function(file_path)
        --      --auto close
        --      require("neo-tree").close_all()
        --    end
        --  },
        --  {
        --    event = "file_opened",
        --    handler = function(file_path)
        --      --clear search after opening a file
        --      require("neo-tree.sources.filesystem").reset_search()
        --    end
        --  },
        --  {
        --    event = "file_renamed",
        --    handler = function(args)
        --      -- fix references to file
        --      print(args.source, " renamed to ", args.destination)
        --    end
        --  },
        --  {
        --    event = "file_moved",
        --    handler = function(args)
        --      -- fix references to file
        --      print(args.source, " moved to ", args.destination)
        --    end
        --  },
        {
          event = "neo_tree_buffer_enter",
          handler = function()
            vim.cmd("set winbar=")
            vim.cmd("highlight CursorLine gui='bold'")
            vim.cmd("highlight CursorColumn guibg=NONE")
            --vim.cmd("set guicursor+=a:InvisibleCursor")
            --vim.cmd("highlight InvisibleCursor gui=reverse blend=100")
          end,
        },
        {
          event = "neo_tree_buffer_leave",
          handler = function()
            --vim.cmd("set guicursor-=a:InvisibleCursor")
            vim.cmd("highlight CursorLine gui=NONE")
          end,
        },
      },

      default_component_configs = {
        container = {
          enable_character_fade = true,
        },
        indent = {
          indent_size = 2,
          padding = 1, -- extra padding on left hand side
          -- indent guides
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
          highlight = "NeoTreeIndentMarker",
          -- expander config, needed for nesting files
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "-",
          -- The next two settings are only a fallback,
          -- if you use nvim-web-devicons and configure default icons there
          -- then these will never be used.
          default = "*",
          highlight = "NeoTreeFileIcon",
        },
        modified = {
          symbol = "[+]",
          highlight = "NeoTreeModified",
        },
        name = {
          trailing_slash = true,
          use_git_status_colors = false,
          highlight = "NeoTreeFileName",
        },
        git_status = {
          symbols = {
            -- Change type
            added = "˖", -- or "✚", but this is redundant info if you use git_status_colors on the name
            modified = "±", -- or "", but this is redundant info if you use git_status_colors on the name
            deleted = "✕", -- this can only be used in the git_status source
            renamed = "↪", -- this can only be used in the git_status source
            -- Status type
            untracked = "?",
            ignored = "⍨",
            unstaged = "·",
            staged = "✓",
            conflict = "",
          },
        },
      },
      renderers = {
        directory = {
          { "indent" },
          { "icon" },
          { "current_filter" },
          {
            "container",
            width = "100%",
            right_padding = 0,
            --max_width   = 60,
            content = {
              { "name",        zindex = 10 },
              -- {
              --   "symlink_target",
              --   zindex = 10,
              --   highlight = "NeoTreeSymbolicLinkTarget",
              -- },
              { "clipboard",   zindex = 10 },
              { "diagnostics", errors_only = true, zindex = 20, align = "right" },
            },
          },
        },
        file = {
          { "indent" },
          { "icon" },
          {
            "container",
            width = "100%",
            right_padding = 0,
            --max_width   = 60,
            content = {
              {
                "name",
                use_git_status_colors = false,
                zindex = 10,
              },
              -- {
              --   "symlink_target",
              --   zindex = 10,
              --   highlight = "NeoTreeSymbolicLinkTarget",
              -- },
              { "clipboard",   zindex = 10 },
              { "bufnr",       zindex = 10 },
              -- { "harpoon_index" }, --> This is what actually adds the component in where you want it
              { "modified",    zindex = 20, align = "right" },
              { "diagnostics", zindex = 20, align = "right" },
              { "git_status",  zindex = 20, align = "right" },
            },
          },
        },
      },
      -- A list of functions, each representing a global custom command
      -- that will be available in all sources (if not overridden in `opts[source_name].commands`)
      -- see `:h neo-tree-custom-commands-global`
      commands = {},
      window = {           -- see https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/popup for
        -- possible options. These can also be functions that return these options.
        position = "left", -- left, right, float, current
        width = 40,        -- applies to left and right positions
        mapping_options = {
          noremap = true,
          nowait = true,
        },
        popup = { -- settings that apply to float position only
          size = {
            height = "80%",
            width = "50%",
          },
          position = "50%", -- 50% means center it
          -- you can also specify border here, if you want a different setting from
          -- the global popup_border_style.
        },
        -- Mappings for tree window. See `:h nep-tree-mappings` for a list of built-in commands.
        -- You can also create your own commands by providing a function instead of a string.
        mappings = {
          ["<space>"] = {
            "toggle_node",
            nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
          },
          ["<2-LeftMouse>"] = "open",
          ["<cr>"] = "open",
          ["<esc>"] = "cancel", -- close preview or floating neo-tree window
          ["P"] = { "toggle_preview", config = { use_float = true } },
          ["l"] = "focus_preview",
          ["S"] = "open_split",
          ["s"] = "open_vsplit",
          -- ["S"] = "split_with_window_picker",
          -- ["s"] = "vsplit_with_window_picker",
          ["t"] = "open_tabnew",
          -- ["<cr>"] = "open_drop",
          -- ["t"] = "open_tab_drop",
          ["w"] = "open_with_window_picker",
          --["P"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
          ["C"] = "close_node",
          -- ['C'] = 'close_all_subnodes',
          ["z"] = "close_all_nodes",
          --["Z"] = "expand_all_nodes",
          ["a"] = {
            "add",
            -- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
            -- some commands may take optional config options, see `:h neo-tree-mappings` for details
            config = {
              show_path = "none", -- "none", "relative", "absolute"
            },
          },
          ["A"] = "add_directory", -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
          ["d"] = "delete",
          ["r"] = "rename",
          ["y"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["c"] = "copy", -- takes text input for destination, also accepts the optional config.show_path option like "add":
          -- ["c"] = {
          --  "copy",
          --  config = {
          --    show_path = "none" -- "none", "relative", "absolute"
          --  }
          --}
          ["m"] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
          ["q"] = "close_window",
          ["R"] = "refresh",
          ["?"] = "show_help",
          ["<"] = "prev_source",
          [">"] = "next_source",
        },
      },
      nesting_rules = {},
      filesystem = {
        commands = {}, -- Add a custom command or override a global one using the same function name
        components = {
          harpoon_index = function(config, node, state)
            local Marked = require("harpoon.mark")
            local path = node:get_id()
            local succuss, index = pcall(Marked.get_index_of, path)
            if succuss and index and index > 0 then
              return {
                text = string.format(" ⥤ %d", index), -- <-- Add your favorite harpoon like arrow here
                highlight = config.highlight or "NeoTreeDirectoryIcon",
              }
            else
              return {}
            end
          end,
        },
        filtered_items = {
          visible = false, -- when true, they will just be displayed differently than normal items
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_hidden = true, -- only works on Windows for hidden files/directories
          hide_by_name = {
            ".git",
            ".DS_Store",
            "thumbs.db",
            ".idea",
            ".mypy_cache",
            "node_modules",
          },
          hide_by_pattern = { -- uses glob style patterns
            --"*.meta",
            --"*/src/*/tsconfig.json",
            "*-cache",
            "*.cache",
            ".null-ls_*",
          },
          never_show = { -- remains hidden even if visible is toggled to true
            ".DS_Store",
            "thumbs.db",
          },
          always_show = { -- remains visible even if other settings would normally hide it
            ".gitignore",
            ".gitkeep",
          },
        },
        find_by_full_path_words = true,
        group_empty_dirs = false,               -- when true, empty folders will be grouped together
        bind_to_cwd = false,                    -- true creates a 2-way binding between vim's cwd and neo-tree's root
        search_limit = 50,                      -- max number of search results when using filters
        follow_current_file = {
          enabled = false,                      -- This will find and focus the file in the active buffer every time
          --               -- the current file is changed while the tree is open.
          leave_dirs_open = false,              -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
        },
        hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
        -- in whatever position is specified in window.position
        -- "open_current",  -- netrw disabled, opening a directory opens within the
        -- window like netrw would, regardless of window.position
        -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
        use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
        -- instead of relying on nvim autocmd events.
        window = {
          mappings = {
            ["."] = "set_root",
            ["/"] = "fuzzy_finder",
            ["#"] = "fuzzy_sorter", -- fuzzy sorting using the fzy algorithm
            ["<bs>"] = "navigate_up",
            ["<c-up>"] = "navigate_up",
            ["<c-x>"] = "clear_filter",
            ["D"] = "fuzzy_finder_directory",
            ["f"] = "filter_on_submit",
            ["gn"] = "next_git_modified",
            ["gp"] = "prev_git_modified",
            ["H"] = "toggle_hidden",
          },
          fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
            ["<down>"] = "move_cursor_down",
            ["<C-n>"] = "move_cursor_down",
            ["<up>"] = "move_cursor_up",
            ["<C-p>"] = "move_cursor_up",
          },
        },
      },
      buffers = {
        follow_current_file = {
          enabled = true,         -- This will find and focus the file in the active buffer every time
          --              -- the current file is changed while the tree is open.
          leave_dirs_open = true, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
        },
        group_empty_dirs = true,  -- when true, empty folders will be grouped together
        show_unloaded = true,
        window = {
          mappings = {
            ["bd"] = "buffer_delete",
            ["<bs>"] = "navigate_up",
            ["."] = "set_root",
          },
        },
      },
      git_status = {
        window = {
          position = "float",
          mappings = {
            ["A"] = "git_add_all",
            ["gu"] = "git_unstage_file",
            ["ga"] = "git_add_file",
            ["gr"] = "git_revert_file",
            ["gc"] = "git_commit",
            ["gp"] = "git_push",
            ["gg"] = "git_commit_and_push",
          },
        },
      },
    })

    vim.cmd([[nnoremap \ :Neotree reveal<cr>]])
  end,
}
