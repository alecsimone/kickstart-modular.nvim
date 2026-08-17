-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

vim.pack.add {
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
}

vim.keymap.set('n', '\\', '<Cmd>Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })

require('neo-tree').setup {
  -- Quit Neovim rather than leaving a lone file tree sitting in an empty window.
  close_if_last_window = true,

  window = {
    width = 28,

    mappings = {
      -- Neo-tree ships with double-click to open. This adds single click, the
      --  way a VS Code explorer behaves. `open` does the right thing for both
      --  kinds of row: it opens a file, and expands or collapses a directory.
      --
      -- Bound to the release rather than the press because Neovim moves the
      --  cursor on <LeftMouse>; mapping the press itself would swallow that and
      --  `open` would act on whichever node the cursor was already sitting on.
      ['<LeftRelease>'] = 'open',
    },
  },

  filesystem = {
    -- Keep the tree in sync with the buffer you are editing, so the sidebar
    --  always shows where you are -- the same way VS Code's explorer does.
    follow_current_file = { enabled = true, leave_dirs_open = true },

    -- Notice files created or deleted by other programs (yazi, git, a build)
    --  instead of showing a stale listing until manually refreshed.
    use_libuv_file_watcher = true,

    filtered_items = {
      -- Show everything: dotfiles (matching `show_hidden = true` in your yazi
      --  config) and git-ignored files alike. Ignored entries are still drawn
      --  dimmed, so you can tell them apart at a glance without losing access.
      visible = true,
      hide_dotfiles = false,
      hide_gitignored = false,

      -- The one exception. `.git` is git's internal object database, not
      --  content -- thousands of files no one navigates by hand, and expanding
      --  it would attach a filesystem watcher to every one.
      never_show = { '.git' },
    },

    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
  },
}

-- NOTE: there is deliberately no autocommand here to open the tree on startup.
--
-- `nvim <directory>` already opens it: `hijack_netrw_behavior` defaults to
--  "open_default", so neo-tree takes over directory buffers by itself. Firing a
--  `Neotree show` on top of that raced with the hijack -- the command captures
--  the current window and restores focus to it from an async callback, but the
--  hijack had already replaced that window, giving "Invalid window id".
--
-- `nvim` with no arguments is handled in custom/plugins/sessions.lua, where it
--  can be sequenced *after* the session is restored. Doing it here would open
--  the tree first and then have the restore rewrite the windows underneath it.
