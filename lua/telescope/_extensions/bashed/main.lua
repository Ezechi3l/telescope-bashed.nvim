local action_state = require "telescope.actions.state"
local actions = require "telescope.actions"
local conf = require("telescope.config").values -- our picker function: colors
local finders = require "telescope.finders"
local pickers = require "telescope.pickers"

local M = {}

M._sep = " - "

M.is_type_or_error = function(t, val, message)
  if type(val) == t then
    return true
  end

  if not message then
    message = string.format("Value '%s' should be of type %s (%s found)", vim.inspect(val), t, type(val))
  end

  error(message)
end

-- Command with space in arguments will not work
M.split_command = function(command)
  M.is_type_or_error("table", command)

  local cmd = command[1]

  if type(cmd) == "string" then
    if cmd == "" then
      error("Command is empty")
    end

    cmd = vim.split(cmd, " ", { trimempty = true })
  end

  M.is_type_or_error("table", cmd)

  if #cmd == 0 then
    error("Command is empty")
  end

  return {
    cmd,
    command[2]
  }
end

M.notify = function(message, level)
  if not level then
    level = vim.log.levels.ERROR
  end

  vim.notify(
    message,
    level,
    { title = "Bashed error" }
  )
end

M.generate_command = function(key, command)
  M.is_type_or_error("string", key)

  return function(opts)
    if type(command) == "string" then
      command = { command }
    end

    local split_ok, splitted_command = pcall(M.split_command, command)

    if not split_ok then
      M.notify(splitted_command)
      return
    end

    opts = opts or {}

    opts.attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)

        if (action_state.get_selected_entry() == nil) then
          return false
        end

        local entry = action_state.get_selected_entry()[1]
        local cmd_actions = splitted_command[2] or "e %s"

        if type(cmd_actions) == "string" then
          cmd_actions = { cmd_actions }
        end

        for _, action in pairs(cmd_actions) do
          local formatted_action = string.format(action, entry)

          local action_ok, _ = pcall(
            vim.api.nvim_command,
            formatted_action
          )

          if not action_ok then
            M.notify(string.format("Action %s returned error", formatted_action))

            return false
          end
        end
      end)

      return true
    end

    local picker = pickers.new(opts, {
      prompt_title = "Bashed",
      finder = finders.new_oneshot_job(
        splitted_command[1],
        opts
      ),
      previewer = conf.grep_previewer(opts),
      sorter = conf.file_sorter(opts),
    })

    picker:find()
  end
end

M.bashed = function(keys)
  M.is_type_or_error("table", keys)

  return function(opts)
    -- Reset values when reusing the plugin
    opts = opts or {}

    opts.attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)

        if (action_state.get_selected_entry() == nil) then
          return false
        end

        local entry = action_state.get_selected_entry()[1]
        entry = vim.split(entry, M._sep, { trimempty = true })[1]

        local formatted_action = ":Telescope bashed " .. entry

        local action_ok, _ = pcall(
          vim.api.nvim_command,
          formatted_action
        )

        if not action_ok then
          M.notify(string.format("Action %s returned error", formatted_action))
        end
      end)

      return true
    end

    local picker = pickers.new(opts, {
      prompt_title = "Choose one bashed action",
      finder = finders.new_table {
        results = keys
      },
      sorter = conf.file_sorter(opts),
    })

    picker:find()
  end
end

M.get_exports = function(commands)
  local exports = {}

  if not commands then
    commands = {}
  end

  if type(commands) == "string" then
    commands = { commands }
  end

  M.is_type_or_error("table", commands)

  local keys = {}
  local n = 0

  local function get_command_name(key, command)
    local str = key

    if command[3] then
      str = str .. M._sep .. command[3]
    end

    return str
  end

  for k, v in pairs(commands) do
    n = n + 1
    keys[n] = get_command_name(k, v)
    exports[k] = M.generate_command(k, v)
  end

  -- Get list of bashed commands
  exports.list = M.bashed(keys)

  return exports
end

return M
