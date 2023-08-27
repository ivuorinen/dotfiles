return {
  "echasnovski/mini.nvim",
  version = "*",
  config = function()
    -- Common configuration presets
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-basics.md
    require("mini.basics").setup()

    -- Fast and flexible start screen
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-starter.md
    local starter = require("mini.starter")
    starter.setup({
      header = table.concat({
        "         ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄        ",
        "       ▄▀░░░░░░░░░░░░▄░░░░░░░▀▄      ",
        "       █░░▄░░░░▄░░░░░░░░░░░░░░█      ",
        "       █░░░░░░░░░░░░▄█▄▄░░▄░░░█ ▄▄▄  ",
        "▄▄▄▄▄  █░░░░░░▀░░░░▀█░░▀▄░░░░░█▀▀░██ ",
        "██▄▀██▄█░░░▄░░░░░░░██░░░░▀▀▀▀▀░░░░██ ",
        " ▀██▄▀██░░░░░░░░▀░██▀░░░░░░░░░░░░░▀██",
        "   ▀████░▀░░░░▄░░░██░░░▄█░░░░▄░▄█░░██",
        "      ▀█░░░░▄░░░░░██░░░░▄░░░▄░░▄░░░██",
        "      ▄█▄░░░░░░░░░░░▀▄░░▀▀▀▀▀▀▀▀░░▄▀ ",
        "     █▀▀█████████▀▀▀▀████████████▀   ",
        "     ████▀  ███▀      ▀███  ▀██▀     ",
      }, "\n"),
      evaluate_single = true,
      items = {
        starter.sections.telescope(),
        starter.sections.builtin_actions(),
        starter.sections.recent_files(5, true, true),
      },
      content_hooks = {
        starter.gen_hook.adding_bullet(),
        starter.gen_hook.aligning("center", "center"),
      },
    })

    -- Miscellaneous useful functions
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-misc.md
    require("mini.misc").setup()

    -- Extend and create a/i textobjects
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-ai.md
    require("mini.ai").setup()

    -- Align text interactively
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-align.md
    require("mini.align").setup()

    -- Animate common Neovim actions
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-animate.md
    require("mini.animate").setup()

    -- Go forward/backward with square brackets
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-bracketed.md
    require("mini.bracketed").setup()

    -- Comment lines
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-comment.md
    require("mini.comment").setup()

    -- Autocompletion and signature help plugin
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-completion.md
    require("mini.completion").setup()

    -- Automatic highlighting of word under cursor
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-cursorword.md
    require("mini.cursorword").setup()

    -- Highlight patterns in text
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-hipatterns.md
    local hipatterns = require("mini.hipatterns")
    hipatterns.setup({
      highlighters = {
        -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
        fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
        hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
        todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
        note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

        -- Highlight hex color strings (`#rrggbb`) using that color
        hex_color = hipatterns.gen_highlighter.hex_color(),
      },
    })

    -- Visualize and work with indent scope
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-indentscope.md
    require("mini.indentscope").setup()

    -- Jump to next/previous single character
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-jump.md
    require("mini.jump").setup()

    -- Jump within visible lines via iterative label filtering
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-jump2d.md
    require("mini.jump2d").setup()

    -- Window with buffer text overview, scrollbar, and highlights
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-map.md
    require("mini.map").setup()

    -- Move any selection in any direction
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-move.md
    require("mini.move").setup()

    -- Text edit operators
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-operators.md
    -- require("mini.operators").setup()

    -- Minimal and fast autopairs
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-pairs.md
    require("mini.pairs").setup()

    -- Split and join arguments
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-splitjoin.md
    require("mini.splitjoin").setup()

    -- Minimal and fast statusline module with opinionated default look
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-statusline.md
    require("mini.statusline").setup()

    -- Minimal and fast tabline showing listed buffers
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-tabline.md
    require("mini.tabline").setup()

    -- Work with trailing whitespace
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-trailspace.md
    require("mini.trailspace").setup()
  end,
}
