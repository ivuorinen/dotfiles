-- A better annotation generator. Supports multiple languages and annotation conventions.
-- https://github.com/danymat/neogen
return {
  "danymat/neogen",
  dependencies = "nvim-treesitter/nvim-treesitter",
  version = "*",
  cmd = "Neogen",
  opts = {
    snippet_engine = "luasnip",
    languages = {
      lua = { template = { annotation_convention = "ldoc" } },
      typescript = { template = { annotation_convention = "tsdoc" } },
      typescriptreact = { template = { annotation_convention = "tsdoc" } },
    },
  },
  keys = {
    { "<leader>baa", function() require("neogen").generate({ type = "current" }) end, desc = "Current" },
    { "<leader>bac", function() require("neogen").generate({ type = "class" }) end, desc = "Class" },
    { "<leader>baf", function() require("neogen").generate({ type = "func" }) end, desc = "Function" },
    { "<leader>bat", function() require("neogen").generate({ type = "type" }) end, desc = "Type" },
    { "<leader>baF", function() require("neogen").generate({ type = "file" }) end, desc = "File" },
  },
}
