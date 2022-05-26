local ok, telescope = pcall(require, "telescope")

if not ok then
  error(
    "This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)"
  )
  return
end

local bashed = require("telescope._extensions.bashed.main")
local commands = vim.g.bashed_commands

return telescope.register_extension({ exports = bashed.get_exports(commands) })
