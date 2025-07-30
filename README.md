# TabTerm

Yet Another Minimal Plugin for Multi Term

## Install with [folke/lazy.nvim: 💤 A modern plugin manager for Neovim](https://github.com/folke/lazy.nvim)

``` lua
  { -- lazy.nvim
    'offGustavo/TabTerm.nvim',
    opts = {}, --  Call setup()
    -- Or use require('TabTerm.nvim').setup() in somewhere in your config
    -- if you want some customization see bellow
    lazy = true,
    keys = function()
      local keys = {

        -- [[ Keymaps Exemples ]]--
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

or use your favorite plugin manager


** Vim Commands

- Create a new TabTerm terminal
:TabTermNew<Cr>

- Toggle TabTerm bottom window
:TabTermToggle<Cr>

- Close current terminal
:TabTermClose<Cr>

- Close terminal by id
:TabTermClose {1..n}<Cr>

- Prompt for a new name for the current terminal (uses vim.input)
:TabTermRename<Cr>

- Rename the current terminal to 'new_name'
:TabTermRename new_name<Cr>

- Rename the terminal with ID <n> to 'new_name'
:TabTermRename {1..n}:new_name<Cr>

- Go to terminal with ID <n>
:TabTermGoTo {1..n}<Cr>

** Customization

*** Default Config

```lua
{
  separator_right = "",
  separator_left = "",
  separator_first = "█",
  tab_highlight = "%#TablineSel#",
  default_highlight = "%#Tabline#",
}
#+end_src

*** Custom Exemples
#+begin_src  lua
opts = {
    separator_right = "",
    separator_left = "",
    separator_first = "█",
},

    -- or

require('TabTerm').setup({
    separator_right = "",
    separator_left = "",
    separator_first = "█",
})

```

# This Plugin is in Alpha!!

For some problem you have make an issue, i would like to help you

## Todo
- [ ] Remade the winbar config, to make it more customizable
- [ ] Make Vim Docs
- [ ] Allow the goto keymap acepts +1 or -1 motions
## Fix
- [ ] Split Always Bellow
- [ ] When toggle keymap is activate, if it was not a tabterm window go to tabterm
