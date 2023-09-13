-- luacheck: globals vim

-- To be used anywhere.
-- local function job(command) vim.api.nvim_command("call jobstart('" .. command .. "')") end

local function yaml_ft(path, bufnr)
  -- get content of buffer as string
  local content = vim.filetype.getlines(bufnr)
  if type(content) == "table" then content = table.concat(content, "\n") end

  -- check if file is in roles, tasks, or handlers folder
  local path_regex = vim.regex("(tasks\\|roles\\|handlers)/")
  if path_regex and path_regex:match_str(path) then return "yaml.ansible" end
  -- check for known ansible playbook text and if found, return yaml.ansible
  local regex = vim.regex("hosts:\\|tasks:")
  if regex and regex:match_str(content) then return "yaml.ansible" end

  -- return yaml if nothing else
  return "yaml"
end

-- In init.lua or filetype.nvim's config file
vim.filetype.add({
  extension = {

    h = function()
      -- Use a lazy heuristic that #including a C++ header means it's a
      -- C++ header
      if vim.fn.search("\\C^#include <[^>.]\\+>$", "nw") == 1 then return "cpp" end
      return "c"
    end,

    -- Spelling fix.
    md = function() vim.api.nvim_command("setlocal spell!") end,

    yml = yaml_ft,
    yaml = yaml_ft,

    --
    csv = "csv",
    cl = "opencl",
    env = "env",
    sh = "bash",
    --
  },
  pattern = {

    -- Go to root configuration of some projects.
    -- [".*config/nvim/.*"] = function() vim.api.nvim_command "cd ~/.config/nvim/" end,

    ---- Typescript Projects
    -- [".*/src/.*ts"] = function() format() end,
    -- [".*/src/.*json"] = function() format() end,
    -- [".*/src/.*scss"] = function() format() end,
    -- [".*/src/.*html"] = function() format() end,

    --[".*Code/ivuorinen/[project]/src/.*ts"] = function()
    --  vim.api.nvim_command('cd ~/Code/ivuorinen/[project]/')
    --  build('ts index')
    --end,
  },

  filename = {
    -- For eslint_d configuration file.
    [".eslintrc"] = "jsonc",

    -- For Typescript projects.
    ["tsconfig.json"] = "json5",

    [".ignore"] = "gitignore",
    ["docker-compose.yml"] = "yaml.docker-compose",
  },
})
