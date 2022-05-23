# telescope-http-files.nvim
Plugin to integrate rest.nvim with telescope


## TODO

* Enter command as a table (avoiding the split of spaces)
* Maybe add config on a command to return absolute path ?
* Maybe add config on a command to disabled it

## TEST (TODO)
  - global is empty or not a valid type
  - commands can be empty or a table
  - command can be a string or table
  - command[0] should be string or table
  - command[1] can be empty, string or table
  - command[1] should have default to open file
  - command[0] with spaces in string should not be split
  - error from running command[2] should display a good error message
    - display the entry, the current action done

