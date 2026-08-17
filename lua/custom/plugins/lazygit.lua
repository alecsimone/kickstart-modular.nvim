-- [[ Git ]]
--
-- lazygit is a full terminal UI for git -- staging individual lines, rebasing,
--  branch management, resolving conflicts. It replaces VS Code's Source Control
--  panel, and does considerably more than it.
--
-- This opens it in a floating window over Neovim, so it shares the current
--  buffer's repository and returns you to your place on quit. gitsigns already
--  handles the small stuff inline (gutter marks, staging a single hunk); reach
--  for lazygit when you want to see the whole repository at once.
--
-- https://github.com/kdheepak/lazygit.nvim

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'kdheepak/lazygit.nvim',
  gh 'nvim-lua/plenary.nvim',
}

-- Nearly fullscreen. The default leaves a wide margin that wastes space on the
--  three-column layout lazygit wants.
vim.g.lazygit_floating_window_scaling_factor = 0.95

-- Reusing the running Neovim for commit messages needs `neovim-remote` (nvr),
--  which is not installed here. Left off, so lazygit opens its own editor
--  instead of failing to reach a server that is not listening. Most commit
--  messages can be typed in lazygit's own prompt without an editor at all.
vim.g.lazygit_use_neovim_remote = 0

vim.keymap.set('n', '<leader>gg', '<Cmd>LazyGit<CR>', { desc = '[G]it: open lazy[g]it' })
vim.keymap.set('n', '<leader>gf', '<Cmd>LazyGitFilter<CR>', { desc = '[G]it: commits for this [f]ile' })

-- vim: ts=2 sts=2 sw=2 et
