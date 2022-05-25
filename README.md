# Telescope basher

Use a bash command to display the result in Telescope and apply an custom action to the selected entry.

This plugin is still in development.

## Why use this plugin

I wanted to list all my http files and call a command on the file selected ([rest.nvim](https://github.com/NTBBloodbath/rest.nvim)). I finally make this plugin more generalist.

If you need to list of filter files and/or apply a custom action this plugin might help you. You don't need to a new plugin for that.

Note: Every command in this file is in lua. Don't forget to translate to vimscript if you need.


## Why not use it

Telescope can do a lot of thing with the built-in, maybe look at that before using this plugins.

Likewise if you need a tricky or a pipe command to get your files, it is currently not possible with this plugin.


## Installation

First you need [Telescope](https://github.com/nvim-telescope/telescope.nvim).

Then install this plugin with your favorite package manager
```lua
use "Ezechi3l/telescope-bashed.nvim"
```

You need to add this plugin to telescope
```lua
require('telescope').load_extension('bashed')
```


## Add a command

Bashed will dynamically generated the telescope commands on loading.


### List

By default there is only one command `list`, to list all generated command and pick one.
```vim
:Telescope bashed list
```


### Add a bash command

In order to generated your command you have to put them on the `vim.g.bashed_commands`. Bashed attempt to handle string or table.
```lua
vim.g.bashed_commands = {
  css = "fd -t f -e css"
}

-- OR

vim.g.bashed_commands = {
  css = { "fd -t f -e css" }
}

-- OR the command as a table (the recommanded way)

vim.g.bashed_commands = {
  css = { { "fd", "-t", "f", "-e", "css" } }
}
```

This command will show all `css` files then will open the file selected (open the file is the default action).


### Add a custom action

If you need to make a custom action on the selected entry then you need to use a table
```lua
vim.g.bashed_commands = {
  css = "fd -t f -e css",
  css_del = { 'fd -t f -e css', ':!rm %s' },
}
```

Now `Telescope bashed css_del` will remove the css file.


### Add a description

Finally you can add a description to the bashed's list as third entry in your command:
```lua
vim.g.bashed_commands = {
  css = "fd -t f -e css",
  css_del = { 'fd -t f -e css', ':!rm %s', 'List and remove a css file' },
}
```

### Advanced usage

You can have multiple actions, for example to handle http files and run rest.nvim

```lua
  vim.g.bashed_commands = {
    http = {
      { 'fd', '-t', 'f', '-e', 'http' },
      { ':e %s', 'lua require("rest-nvim").run()' },
      "List all http files inside the project to run rest.nvim on one"
    },
  }

