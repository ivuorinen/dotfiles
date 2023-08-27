return {
  "chrisgrieser/nvim-origami",
  event = "BufReadPost", -- later or on keypress would prevent saving folds
  opts = {
    keepFoldsAcrossSessions = true,
    pauseFoldsOnSearch = true,
    setupFoldKeymaps = true,
  },
}
