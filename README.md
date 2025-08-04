# TabTerm

Yet Another Plugin for Multi-Terminal in Neovim.

## Installation (with [folke/lazy.nvim](https://github.com/folke/lazy.nvim))

```lua
{
  'offGustavo/TabTerm.nvim',
  opts = {}, -- Calls setup()
  -- Or use require('TabTerm').setup() somewhere in your config
  -- For customization, see below
  lazy = true,
  keys = function()
    local keys = {
      -- [[ Example Keymaps ]] --

      -- Tmux-like Prefix
      { mode = { 'i', 'n', 't' }, "<C-s>c", function() require('TabTerm').new() end, desc = "Create Terminal" },
      { mode = { 'i', 'n', 't' }, "<C-s>x", function() require('TabTerm').close() end, desc = "Close Terminal" },
      { mode = { 'i', 'n', 't' }, "<C-s>d", function() require('TabTerm').toggle() end, desc = "Toggle Terminal" },
      { mode = { 'i', 'n', 't' }, "<C-s>,", function() require('TabTerm').rename() end, desc = "Rename Terminal" },

      -- Vim Leader-style
      { "<leader>tc", function() require('TabTerm').new() end, desc = "Create Terminal" },
      { "<leader>tx", function() require('TabTerm').close() end, desc = "Close Terminal" },
      { "<leader>td", function() require('TabTerm').toggle() end, desc = "Toggle Terminal" },
      { "<leader>t,", function() require('TabTerm').rename() end, desc = "Rename Terminal" },

      -- Shortcut-style
      { mode = { 'i', 'n', 't' }, "<A-n>", function() require('TabTerm').new() end, desc = "Create Terminal" },
      { mode = { 'i', 'n', 't' }, "<A-x>", function() require('TabTerm').close() end, desc = "Close Terminal" },
      { mode = { 'i', 'n', 't' }, "<A-/>", function() require('TabTerm').toggle() end, desc = "Toggle Terminal" },
      { mode = { 'i', 'n', 't' }, "<A-,>", function() require('TabTerm').rename() end, desc = "Rename Terminal" },
    }

    for i = 1, 9 do
      table.insert(keys, {
        mode = { 'i', 'n', 't' },
        "<C-s>" .. i,
        function()
          require('TabTerm').goto(i)
        end,
        desc = "Go to Terminal [" .. i .. "]",
      })
    end

    return keys
  end,
}
````

Or use your favorite plugin manager.

---

## Vim Commands

* Create a new terminal:

  ```
  :TabTermNew<CR>
  ```

* Toggle the bottom terminal window:

  ```
  :TabTermToggle<CR>
  ```

* Close the current terminal:

  ```
  :TabTermClose<CR>
  ```

* Close terminal by ID:

  ```
  :TabTermClose {1..n}<CR>
  ```

* Prompt to rename the current terminal (uses `vim.input()`):

  ```
  :TabTermRename<CR>
  ```

* Rename current terminal to `new_name`:

  ```
  :TabTermRename new_name<CR>
  ```

* Rename terminal with ID `<n>` to `new_name`:

  ```
  :TabTermRename {1..n}:new_name<CR>
  ```

* Go to terminal with ID `<n>`:

  ```
  :TabTermGoTo {1..n}<CR>
  ```

---

## Customization

### Default Configuration

```lua
{
  separator_right = "",
  separator_left = "",
  separator_first = "█",
  tab_highlight = "%#TablineSel#",
  default_highlight = "%#Tabline#",
}
```

### Custom Examples

```lua
opts = {
  separator_right = "",
  separator_left = "",
  separator_first = "█",
}

-- or just 

require('TabTerm').setup({
  separator_right = "",
  separator_left = "",
  separator_first = "█",
})
```

---

## ⚠️ Plugin Status: Alpha

This plugin is currently in early development.
If you encounter any issues, please open an issue — I’d be happy to help!

---

### Fixes


---

### Todo

* [ ] Rewrite winbar configuration to allow more customization
* [ ] Add Vim help documentation
* [ ] Allow `goto` keymaps to support relative motions (e.g. `+1`, `-1`)


