-- [[ Winbar: the file path, at the top of each window ]]
--
-- Neovim has a per-window bar along the top (`:help 'winbar'`) that is separate
--  from the statusline along the bottom. That split maps neatly onto the two
--  jobs the one bottom bar was doing at once:
--
--    winbar     -- which file is this? A title. Belongs to the window.
--    statusline -- what am I doing? Mode, git, diagnostics, position.
--
-- The win here is splits. A statusline shows the *active* window's file, so in
--  a three-way split two of the panes are unlabelled. A winbar labels every
--  pane, all the time, which is the whole point of having them side by side.

local function esc(s) return (s:gsub('%%', '%%%%')) end

function _G.Winbar()
  local path = vim.fn.expand '%:.'
  if path == '' then return '%#Comment# [No Name]%*' end

  local dir = vim.fn.fnamemodify(path, ':h')
  local file = vim.fn.fnamemodify(path, ':t')

  -- Directory dimmed, filename emphasised -- the eye should land on the name
  --  first and read the path only when it needs to.
  local prefix = (dir ~= '' and dir ~= '.') and ('%#Comment#' .. esc(dir) .. '/%*') or ''
  local modified = vim.bo.modified and '%#DiagnosticWarn# ●%*' or ''

  return ' ' .. prefix .. '%#Title#' .. esc(file) .. '%*' .. modified
end

-- The winbar is applied per window rather than globally, because an empty
--  result still reserves the line -- a blank bar would sit above the file tree
--  and every terminal, help and quickfix window. Setting the option to an empty
--  string on those windows removes the bar entirely instead.
local function apply_winbar()
  if vim.api.nvim_win_get_config(0).relative ~= '' then return end -- floats never show one

  local skip = vim.bo.buftype ~= '' or vim.bo.filetype == 'neo-tree'
  vim.wo.winbar = skip and '' or '%{%v:lua.Winbar()%}'
end

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufEnter', 'WinEnter', 'FileType', 'BufModifiedSet' }, {
  group = vim.api.nvim_create_augroup('custom-winbar', { clear = true }),
  callback = apply_winbar,
})

-- vim: ts=2 sts=2 sw=2 et
