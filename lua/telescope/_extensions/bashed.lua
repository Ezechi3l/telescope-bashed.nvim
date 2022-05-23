local ok, telescope = pcall(require, "telescope")

if not ok then
  error(
    "This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)"
  )
  return
end

local action_state = require "telescope.actions.state"
local actions = require "telescope.actions"
local conf = require("telescope.config").values -- our picker function: colors
local finders = require "telescope.finders"
local pickers = require "telescope.pickers"

local sep = " - "

local function is_type_or_error(t, val, message)
  if type(val) == t then
    return true
  end

  if not message then
    message = string.format("Value '%s' should be of type %s (%s found)", vim.inspect(val), t, type(val))
  end

  error(message)
end

-- Command with space in arguments will not work
local function split_command(command)
  is_type_or_error("table", command)

  local cmd = command[1]
  if type(cmd) == "string" then
    cmd = vim.split(cmd, " ", { trimempty = true })
  end

  is_type_or_error("table", cmd)

  return {
    cmd,
    command[2]
  }
end

local function notify(message, level)
  if not level then
    level = vim.log.levels.ERROR
  end

  vim.notify(
    message,
    level,
    { title = "Bashed error" }
  )
end

local function generate_command(key, command)
  is_type_or_error("string", key)

  return function(opts)
    if type(command) == "string" then
      command = { command }
    end

    local split_ok, splitted_command = pcall(split_command, command)

    if not split_ok then
      notify(splitted_command)
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
            notify(string.format("Action %s returned error", formatted_action))

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

local function bashed(keys)
  is_type_or_error("table", keys)

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
        entry = vim.split(entry, sep, { trimempty = true })[1]

        local formatted_action = ":Telescope bashed " .. entry

        local action_ok, _ = pcall(
          vim.api.nvim_command,
          formatted_action
        )

        if not action_ok then
          notify(string.format("Action %s returned error", formatted_action))
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

local function get_exports()
  local exports = {}

  local commands = vim.g.bashed_commands

  if not commands then
    commands = {}
  end

  if type(commands) == "string" then
    commands = { commands }
  end

  is_type_or_error("table", commands)

  local keys = {}
  local n = 0

  local function get_command_name(key, command)
    local str = key

    if command[3] then
      str = str .. sep .. command[3]
    end

    return str
  end

  for k, v in pairs(commands) do
    n = n + 1
    keys[n] = get_command_name(k, v)
    exports[k] = generate_command(k, v)
  end

  -- Get list of bashed commands
  exports.list = bashed(keys)

  return exports
end

return telescope.register_extension({ exports = get_exports() })
