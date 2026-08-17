local function gh(repo) return 'https://github.com/' .. repo end

-- [[ Formatting ]]
vim.pack.add { gh 'stevearc/conform.nvim' }

-- Projects on this machine do not agree on a formatter: a couple use Biome, a
--  couple use Prettier, and most use ESLint alone with no separate formatter.
--  Running the wrong one would reformat a whole file against its project's
--  house style, so instead of picking a global default we ask the project.
--
-- Whichever config file sits at the project root wins. If neither is present we
--  return an empty list, which -- because `default_format_opts` below sets
--  `lsp_format = 'fallback'` -- hands formatting to the language server.
local function web_formatter(bufnr)
  if vim.fs.root(bufnr, { 'biome.json', 'biome.jsonc' }) then return { 'biome' } end

  local prettier_config = vim.fs.root(bufnr, {
    '.prettierrc',
    '.prettierrc.json',
    '.prettierrc.yml',
    '.prettierrc.yaml',
    '.prettierrc.js',
    '.prettierrc.mjs',
    'prettier.config.js',
    'prettier.config.mjs',
    'prettier.config.cjs',
  })
  if prettier_config then return { 'prettierd', 'prettier', stop_after_first = true } end

  return {}
end

require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    -- You can specify filetypes to autoformat on save here:
    local enabled_filetypes = {
      -- lua = true,
      -- python = true,
    }
    if enabled_filetypes[vim.bo[bufnr].filetype] then
      return { timeout_ms = 500 }
    else
      return nil
    end
  end,
  default_format_opts = {
    lsp_format = 'fallback', -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
  },
  -- You can also specify external formatters in here.
  formatters_by_ft = {
    -- rust = { 'rustfmt' },
    -- Conform can also run multiple formatters sequentially
    -- python = { "isort", "black" },
    --
    -- You can use 'stop_after_first' to run the first available formatter from the list
    -- javascript = { "prettierd", "prettier", stop_after_first = true },

    -- lua_ls has its formatting turned off in lspconfig.lua, so without this
    --  line <leader>f would silently do nothing in a Lua file.
    lua = { 'stylua' },

    -- The web filetypes all share one resolver -- see the note above it.
    javascript = web_formatter,
    javascriptreact = web_formatter,
    typescript = web_formatter,
    typescriptreact = web_formatter,
    json = web_formatter,
    jsonc = web_formatter,
    css = web_formatter,
    scss = web_formatter,
    html = web_formatter,
    markdown = web_formatter,
    yaml = web_formatter,
  },
}

vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })

-- vim: ts=2 sts=2 sw=2 et
