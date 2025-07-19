# TabTerm

Yet Another Minimal Plugin for Terminals with tabs in Neovim

## Install with [folke/lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
  { -- lazy.nvim
    'offGustavo/TabTerm.nvim',
    opts = {},
    keys = function()
      local keys = {

        -- Like Tmux Prefix
        { mode ={ 'i', 'n', 't'}, "<C-s>c", function () require('TabTerm').new() end, desc = "Create Terminal"},
        { mode ={ 'i', 'n', 't'}, "<C-s>x", function () require('TabTerm').close() end, desc = "Create Terminal"},
        { mode ={ 'i', 'n', 't'}, "<C-s>d", function () require('TabTerm').toggle() end, desc = "Create Terminal"},
        { mode ={ 'i', 'n', 't'}, "<C-s>,", function () require('TabTerm').rename() end, desc = "Create Terminal"},

        -- Like Vim Leader
        { "<leader>tc", function () require('TabTerm').new() end, desc = "Create Terminal"},
        { "<leader>tx", function () require('TabTerm').close() end, desc = "Create Terminal"},
        { "<leader>td", function () require('TabTerm').toggle() end, desc = "Create Terminal"},
        { "<leader>t,", function () require('TabTerm').rename() end, desc = "Create Terminal"},

        -- Just Shortcuts
        { mode ={ 'i', 'n', 't'}, "<A-n>", function () require('TabTerm').new() end, desc = "Create Terminal"},
        { mode ={ 'i', 'n', 't'}, "<A-x>", function () require('TabTerm').close() end, desc = "Create Terminal"},
        { mode ={ 'i', 'n', 't'}, "<A-/>", function () require('TabTerm').toggle() end, desc = "Create Terminal"},
        { mode ={ 'i', 'n', 't'}, "<A-,>", function () require('TabTerm').rename() end, desc = "Create Terminal"},

      }

      for i = 1, 9 do
        table.insert(keys, {
          mode ={ 'i', 'n', 't'},
          "<C-s>" .. i,
          function()
            require('TabTerm').goto(i)
          end,
          desc = "Goto to Terminal [" .. i .. "]",
        })
      end
      return keys
    end,
  },
```



# My Config

```lua
return {
  'offGustavo/TabTerm.nvim',
  opts = {},
  keys = function()
    local keys = {

      { mode ={ 'i', 'n', 't'}, "<A-m>c", function () require('TabTerm').new() end, desc = "Create Terminal"},
      { mode ={ 'i', 'n', 't'}, "<A-m>x", function () require('TabTerm').close() end, desc = "Close Terminal"},
      { mode ={ 'i', 'n', 't'}, "<A-m>d", function () require('TabTerm').toggle() end, desc = "Toggle Terminal"},
      { mode ={ 'i', 'n', 't'}, "<A-m>,", function () require('TabTerm').rename() end, desc = "Rename Terminal"},

      { mode ={ 'i', 'n', 't'}, "<A-n>", function () require('TabTerm').new() end, desc = "Create Terminal"},
      { mode ={ 'i', 'n', 't'}, "<A-x>", function () require('TabTerm').close() end, desc = "Close Terminal"},
      { mode ={ 'i', 'n', 't'}, "<A-/>", function () require('TabTerm').toggle() end, desc = "Toggle Terminal"},
      { mode ={ 'i', 'n', 't'}, "<A-,>", function () require('TabTerm').rename() end, desc = "Rename Terminal"},

    }

    for i = 1, 9 do
      table.insert(keys, {
        mode ={ 'i', 'n', 't'},
        "<A-m>" .. i,
        function()
          require('TabTerm').goto(i)
        end,
        desc = "Goto to Terminal [" .. i .. "]",
      })
    end
    return keys
  end,
}
```
