-- Enable faster startup by caching compiled Lua modules
vim.loader.enable()

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
--  See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- This machine is a headless server reached over SSH, so there is no X display
--  and tools like `xclip` cannot reach a real clipboard. OSC 52 is an escape
--  sequence that asks the *terminal* to put the text on the clipboard of the
--  machine you are sitting at, so yanking here lands in your local clipboard.
--  See `:help clipboard-osc52`
--
-- Copying is a one-way send, so it just works. Reading back does not: nvim has
--  to *ask* the terminal for the clipboard and wait for an answer, and terminals
--  refuse to answer on purpose -- otherwise any program on a remote box could
--  silently read whatever you last copied. The built-in handler waits 1s, then
--  another 9s, then gives up, which makes every `p` hang for ten seconds.
--
-- So: keep OSC 52 for copy, and paste from nvim's own unnamed register instead
--  of interrogating the terminal. `p` becomes instant and pastes what you last
--  yanked. To paste something copied *outside* nvim, use the terminal's own
--  paste (ctrl+shift+v), which types the text in directly and needs no reply.
local osc52 = require 'vim.ui.clipboard.osc52'

local function paste_from_unnamed() return vim.split(vim.fn.getreg '"', '\n') end

vim.g.clipboard = {
  name = 'osc52-copy-only',
  copy = { ['+'] = osc52.copy '+', ['*'] = osc52.copy '*' },
  paste = { ['+'] = paste_from_unnamed, ['*'] = paste_from_unnamed },
}

-- Enable break indent
vim.o.breakindent = true

-- Wrapping is on by default in Neovim, but it breaks at whatever column the
--  window happens to end, splitting words in half. `linebreak` makes it break
--  at spaces and punctuation instead, which is what "word wrap" means in an
--  editor like VS Code. Combined with `breakindent` above, a wrapped line stays
--  aligned under its own indent rather than jumping to column zero.
vim.o.linebreak = true

-- Mark continuation lines, so a wrapped line is never mistaken for a new one.
vim.o.showbreak = '↳ '

-- With wrapping on, `j` and `k` jump over an entire wrapped line at a time,
--  which feels like the cursor is skipping. `gj`/`gk` move by screen line
--  instead. Mapping them only when no count is given keeps `5j` meaning five
--  real lines, which is what you want for jumps you counted off in the gutter.
vim.keymap.set({ 'n', 'x' }, 'j', function() return vim.v.count == 0 and 'gj' or 'j' end, { expr = true, desc = 'Down by screen line' })
vim.keymap.set({ 'n', 'x' }, 'k', function() return vim.v.count == 0 and 'gk' or 'k' end, { expr = true, desc = 'Up by screen line' })

-- One statusline for the whole editor rather than one per window.
--  Each window now carries its own title in the winbar (see
--  custom/plugins/winbar.lua), so a per-window statusline would repeat the
--  filename directly under it -- and in a three-way split that is three bars of
--  chrome saying things the winbar already said. A single bar reports on
--  whichever window is focused and gives back a line per split.
vim.o.laststatus = 3

-- Enable undo/redo changes even after closing and reopening a file
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-guide-options`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- vim: ts=2 sts=2 sw=2 et
