-- Mapping data with "desc" stored directly by vim.keymap.set().
--
-- Please use this mappings table to set keyboard mapping since this is the
-- lower level configuration and more robust one. (which-key will
-- automatically pick-up stored data by this setting.)
return {
  -- first key is the mode
  n = {
    -- second key is the lefthand side of the map
    -- mappings seen under group name "Buffer"
    ["<leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
    ["<leader>bD"] = {
      function()
        require("astronvim.utils.status").heirline.buffer_picker(
          function(bufnr) require("astronvim.utils.buffer").close(bufnr) end
        )
      end,
      desc = "Pick to close",
    },
    -- tables with the `name` key will be registered with which-key
    -- if it's installed this is useful for naming menus
    ["<leader>b"] = { name = "Buffers" },
    -- quick save (change description)
    ["<C-s>"] = { ":w!<cr>", desc = "Save File" },
    ["<leader>P"] = {
      ":Telescope projects<cr>",
      desc = "Update Projects listing"
    },
    -- close_buffers
    ['<leader>bch'] = {
      "<CMD>lua require('close_buffers').delete({type = 'hidden'})<CR>",
      desc = "Delete hidden buffers"
    },
    -- comment-box
    ["<leader>bb"] = {
      "<cmd>lua require('comment-box').lbox()<cr>",
      desc = "Left aligned fixed size box with left aligned text"
    },
    ["<leader>bc"] = {
      "<cmd>lua require('comment-box').ccbox()<cr>",
      desc = "Centered adapted box with centered text"
    },
    ["<leader>bl"] = {
      "<cmd>lua require('comment-box').cline()<cr>",
      desc = "Centered line"
    },
  },
  t = {
    -- setting a mapping to false will disable it
    -- ["<esc>"] = false,
  },
}
