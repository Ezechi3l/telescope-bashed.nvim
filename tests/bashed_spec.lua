P = function(v)
  print(vim.inspect(v))
end

local get_bashed = function()
  return require("telescope._extensions.bashed.main")
end

-- TODO: Test the generate fn, bashed fn. But
describe("bashed", function()
  it("can be loaded", function()
    get_bashed()
  end)

  -- TODO: convert to has_error
  it("returns an error on wrong type of input", function()
    local ok, _ = pcall(get_bashed().split_command, "fd")
    assert.are.same(ok, false)

    local ok, _ = pcall(get_bashed().split_command, false)
    assert.are.same(ok, false)

    local ok, _ = pcall(get_bashed().split_command, nil)
    assert.are.same(ok, false)
  end)

  it("splits the string as command", function()
    local command = get_bashed().split_command({ "fd -t f -e http" })

    assert.are.same(
      command[1],
      { "fd", "-t", "f", "-e", "http" }
    )
  end)

  it("doesn't split the table", function()
    local command = get_bashed().split_command({ { "fd", "-t", "f", "-e", "http" } })

    assert.are.same(
      command[1],
      { "fd", "-t", "f", "-e", "http" }
    )
  end)

  it("should send an error on invalid command type", function()
    local ok, _ = pcall(get_bashed().split_command, { { nil } })

    assert.are.same(ok, false)
  end)

  it("returns all bashed actions for the list action", function()
    -- TODO
    get_bashed().get_list()
  end)

  it("select correct bashed action from the entry picked", function()
    -- TODO
    get_bashed().get_action_from_picker()
  end)

  it("sends error on incorrect entry on list", function()
    -- TODO
    get_bashed().get_action_from_picker()
  end)

  it("notifies on command error", function()
    -- TODO
    get_bashed().execute_command()
  end)

  it("run all commands", function()
    -- TODO
    get_bashed().execute_commands()
  end)

  it("should returns telescope exports", function()
    local exports = get_bashed().get_exports({ http = { "fd -t f -e http" } })
    assert.is_function(exports.http)
    assert.is_function(exports.list)
  end)

end)
