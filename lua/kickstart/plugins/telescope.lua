local function gh(repo) return 'https://github.com/' .. repo end

-- [[ Fuzzy Finder (files, lsp, etc) ]]
--
-- Telescope is a fuzzy finder that comes with a lot of different things that
-- it can fuzzy find! It's more than just a "file finder", it can search
-- many different aspects of Neovim, your workspace, LSP, and more!
--
-- There are lots of other alternative pickers (like snacks.picker, or fzf-lua)
-- so feel free to experiment and see what you like!
--
-- The easiest way to use Telescope, is to start by doing something like:
--  :Telescope help_tags
--
-- After running this command, a window will open up and you're able to
-- type in the prompt window. You'll see a list of `help_tags` options and
-- a corresponding preview of the help.
--
-- Two important keymaps to use while in Telescope are:
--  - Insert mode: <c-/>
--  - Normal mode: ?
--
-- This opens a window that shows you all of the keymaps for the current
-- Telescope picker. This is really useful to discover what Telescope can
-- do as well as how to actually do it!

---@type (string|vim.pack.Spec)[]
local telescope_plugins = {
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-telescope/telescope.nvim',
  gh 'nvim-telescope/telescope-ui-select.nvim',
}
if vim.fn.executable 'make' == 1 then table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim') end

-- NOTE: You can install multiple plugins at once
vim.pack.add(telescope_plugins)

-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  -- You can put your default mappings / updates / etc. in here
  --  All the info you're looking for is in `:help telescope.setup()`
  --
  -- defaults = {
  --   mappings = {
  --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
  --   },
  -- },

  -- Telescope's built-in keys for opening a result in a split are <C-v> for a
  --  vertical one and <C-x> for a horizontal one. <C-x> arrives fine, but <C-v>
  --  never reaches Neovim on this setup -- the terminal claims it for paste, so
  --  pressing it drops clipboard text into the prompt instead of splitting.
  --
  -- <C-\> takes its place, pairing with the stock <C-x> for horizontal. It is a
  --  genuine control character (0x1C), not an escape sequence, so it survives a
  --  multiplexer and an SSH hop more reliably than an alt combination. Normally
  --  the tty would read it as the SIGQUIT key, but Neovim puts the terminal in
  --  raw mode, which disables that signal handling and delivers the byte.
  --
  -- PRESS ctrl+shift+\ (ctrl+|), not plain ctrl+\, which Windows Terminal eats.
  --  There is no separate mapping for it and none is possible: `\` is 0x5C and
  --  `|` is 0x7C, and ctrl masks both to 0x1C, so the two chords are the same
  --  byte on the wire. Only the Kitty keyboard protocol encodes the modifier
  --  separately, and herdr does not speak it -- see the note in
  --  ~/.config/herdr/config.toml. Neovim therefore cannot tell them apart, and
  --  this one mapping answers to both.
  --
  -- Mapping it does shadow the built-in CTRL-\ CTRL-N inside the picker prompt.
  --  That costs nothing here -- it is one of several ways to leave insert mode,
  --  and <Esc> still does the job.
  --
  -- The alt pair below is a fallback while <C-\> is unproven on this connection;
  --  once it is confirmed working, they can be deleted. The stock <C-v>/<C-x>
  --  are left alone, so nothing is lost if the terminal ever stops eating <C-v>.
  defaults = {
    -- Filename first, then its directory -- and the two are coloured
    --  differently so a results list can be scanned by name.
    --
    -- Telescope's built-in "filename_first" only tags the *directory* half
    --  (TelescopeResultsComment); the filename inherits whatever the results
    --  window uses, so colouring it would tint every other picker too -- help
    --  tags, commands, keymaps. A function may return its own style ranges, so
    --  this tags both halves explicitly and touches nothing else.
    --
    -- Colours for these two groups live in custom/plugins/colorscheme.lua.
    path_display = function(_, path)
      local sep = package.config:sub(1, 1)
      local relative = vim.fn.fnamemodify(path, ':.')
      local parts = vim.split(relative, sep)
      local filename = table.remove(parts, #parts)
      local directory = table.concat(parts, sep)

      -- A file at the root has no directory half to dim.
      if directory == '' then return filename, { { { 0, #filename }, 'TelescopeResultsFileName' } } end

      local transformed = filename .. '  ' .. directory
      return transformed, {
        { { 0, #filename }, 'TelescopeResultsFileName' },
        { { #filename, #transformed }, 'TelescopeResultsComment' },
      }
    end,

    mappings = {
      i = {
        ['<C-\\>'] = require('telescope.actions').select_vertical,
        ['<M-v>'] = require('telescope.actions').select_vertical,
        ['<M-s>'] = require('telescope.actions').select_horizontal,
      },
      n = {
        ['<C-\\>'] = require('telescope.actions').select_vertical,
        ['<M-v>'] = require('telescope.actions').select_vertical,
        ['<M-s>'] = require('telescope.actions').select_horizontal,
      },
    },
  },
  -- pickers = {}
  extensions = {
    ['ui-select'] = { require('telescope.themes').get_dropdown() },
  },
}

-- Enable Telescope extensions if they are installed
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

-- See `:help telescope.builtin`
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
-- Grep pickers append `:line:col` to whatever path_display returns. With the
--  filename-first split that would read `page.tsx  app/about:12:5`, attaching
--  the coordinates to the directory rather than the file. `path_display = {}`
--  restores the conventional single path for these three.
local grep_opts = { path_display = {} }

vim.keymap.set({ 'n', 'v' }, '<leader>sw', function() builtin.grep_string(grep_opts) end, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', function() builtin.live_grep(grep_opts) end, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

-- Add Telescope-based LSP pickers when an LSP attaches to a buffer.
-- If you later switch picker plugins, this is where to update these mappings.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf

    -- Find references for the word under your cursor.
    vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

    -- Jump to the implementation of the word under your cursor.
    -- Useful when your language has ways of declaring types without an actual implementation.
    vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })

    -- Jump to the definition of the word under your cursor.
    -- This is where a variable was first declared, or where a function is defined, etc.
    -- To jump back, press <C-t>.
    vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })

    -- Fuzzy find all the symbols in your current document.
    -- Symbols are things like variables, functions, types, etc.
    vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })

    -- Fuzzy find all the symbols in your current workspace.
    -- Similar to document symbols, except searches over your entire project.
    vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })

    -- Jump to the type of the word under your cursor.
    -- Useful when you're not sure what type a variable is and you want to see
    -- the definition of its *type*, not where it was *defined*.
    vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
  end,
})

-- Override default behavior and theme when searching
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to Telescope to change the theme, layout, etc.
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

-- It's also possible to pass additional configuration options.
--  See `:help telescope.builtin.live_grep()` for information about particular keys
vim.keymap.set(
  'n',
  '<leader>s/',
  function()
    builtin.live_grep {
      grep_open_files = true,
      prompt_title = 'Live Grep in Open Files',
      path_display = {},
    }
  end,
  { desc = '[S]earch [/] in Open Files' }
)

-- Shortcut for searching your Neovim configuration files
vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config', follow = true } end, { desc = '[S]earch [N]eovim files' })

-- vim: ts=2 sts=2 sw=2 et
