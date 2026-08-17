-- [[ Session persistence ]]
--
-- Reopen Neovim in a project and get your windows, splits and open files back,
--  the way VS Code reopens a folder where you left it. Sessions are keyed by
--  working directory, so each repo remembers its own layout.
--
-- https://github.com/folke/persistence.nvim

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'folke/persistence.nvim' }

-- `localoptions` is the important one: without it a restored buffer loses its
--  filetype, and with no filetype there is no treesitter highlighting and no
--  language server. The rest is Neovim's default set.
vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

-- A saved session records the windows that were open, and a file tree is not
--  something worth restoring as one -- it comes back as an ordinary buffer full
--  of tree drawing characters, and neo-tree then refuses to build its real tree
--  because a buffer of that name already exists.
--
-- `Neotree close` alone is not enough. It closes the visible tree, but neo-tree
--  keeps its scratch buffers around unlisted, and any of those still attached to
--  a window gets written into the session. That is self-reinforcing: a session
--  saved with tree windows restores them next launch, which produces more, which
--  get saved again. Wipe every neo-tree buffer instead, which takes their
--  windows with them and guarantees a session holds only real files.
--
-- IMPORTANT: this autocommand is registered *before* `persistence.setup()`
--  below, and the order is load-bearing. Persistence writes the session from
--  its own VimLeavePre handler, and handlers for one event run in the order
--  they were created -- so registering this second meant the tree was still
--  open at the moment the session was written, and the cleanup ran afterwards
--  against a file already on disk.
vim.api.nvim_create_autocmd('VimLeavePre', {
  group = vim.api.nvim_create_augroup('custom-session-cleanup', { clear = true }),
  callback = function()
    pcall(vim.cmd, 'Neotree close')
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == 'neo-tree' then pcall(vim.api.nvim_buf_delete, buf, { force = true }) end
    end
  end,
})

require('persistence').setup {}

-- Restore automatically when Neovim is opened with no arguments, which is what
--  starting work in a project looks like. Opening a specific file is a quick
--  edit and is left alone; opening a directory is handled by neo-tree's own
--  netrw hijack. `load` is a no-op when this directory has no saved session, so
--  a first visit still starts clean.
--
-- The file tree is opened here rather than in neo-tree.lua so that it lands
--  *after* the restore. Restoring a session rewrites the window layout, so a
--  tree opened beforehand would either be clobbered or leave neo-tree holding a
--  window id that no longer exists.
vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('custom-session-restore', { clear = true }),
  nested = true,
  callback = function()
    if vim.fn.argc() ~= 0 then return end

    require('persistence').load()

    -- Let the restore settle before adding the sidebar, and never let a failure
    --  here take down startup -- a missing tree is a nuisance, a stack trace on
    --  every launch is not.
    vim.schedule(function() pcall(vim.cmd, 'Neotree show') end)
  end,
})

-- `s` is taken by the search pickers, so sessions live under capital S.
vim.keymap.set('n', '<leader>Ss', function() require('persistence').load() end, { desc = '[S]ession: restore for this directory' })
vim.keymap.set('n', '<leader>Sl', function() require('persistence').load { last = true } end, { desc = '[S]ession: restore [l]ast used' })
vim.keymap.set('n', '<leader>Sd', function() require('persistence').stop() end, { desc = '[S]ession: [d]on\'t save this one' })

-- vim: ts=2 sts=2 sw=2 et
