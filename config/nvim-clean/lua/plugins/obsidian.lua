require("obsidian").setup({
  workspaces = {
    {
      name = "Notes",
      path = vim.fn.expand("$HOME/Code/ivuorinen/obsidian"),
    },
  },
})
