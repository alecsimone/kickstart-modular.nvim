-- [[ Colorscheme: Alec ]]
--
-- Ported from the hand-tuned Monokai customisation in VS Code. The colours
--  themselves live in ~/.config/theme/palette.toml and are generated into
--  lua/custom/theme_palette.lua -- this file is the *mapping*, and is meant to
--  be edited by hand. Regenerating never touches it.
--
-- To change a colour:  edit palette.toml, then :ThemeReload
-- To change a role:    edit the tables below, then :ThemeReload

local p = require 'custom.theme_palette'

-- mini.base16 does the breadth: every UI, plugin, diagnostic and LSP group,
--  derived coherently from 16 inputs (it computes ~21 distinct values, blending
--  in proper Luv/LCh space rather than by hand).
require('mini.base16').setup { palette = p.base16 }
vim.g.colors_name = 'alec'

-- [[ Restore the terminal colours ]]
--
-- mini.base16 also fills vim.g.terminal_color_* from the base16 slots. Those
--  slots are filled ROLE-accurately above -- base0E holds this theme's keyword
--  blue, base0B its string gold -- so :terminal buffers would inherit blue for
--  ANSI magenta and gold for ANSI green, and `git diff` inside Neovim would
--  disagree with `git diff` in a plain pane.
--
-- Restore them hue-accurately from the [ansi] table, so a terminal inside
--  Neovim matches Windows Terminal exactly.
local ansi = {
  p.ansi.black, p.ansi.red, p.ansi.green, p.ansi.yellow,
  p.ansi.blue, p.ansi.magenta, p.ansi.cyan, p.ansi.white,
  p.ansi.bright_black, p.ansi.bright_red, p.ansi.bright_green, p.ansi.bright_yellow,
  p.ansi.bright_blue, p.ansi.bright_magenta, p.ansi.bright_cyan, p.ansi.bright_white,
}
for i, color in ipairs(ansi) do
  vim.g['terminal_color_' .. (i - 1)] = color
end

-- [[ Syntax, by role ]]
--
-- base16's slot conventions assume keywords are purple, functions blue and
--  strings green. This theme says otherwise, and treesitter captures are far
--  more specific than the legacy groups mini.base16 targets -- so the captures
--  that carry the theme's identity are set explicitly here.
local s = p.syntax

local function hl(group, opts) vim.api.nvim_set_hl(0, group, opts) end

local syntax_groups = {
  -- Keywords: blue, not purple. The signature of this theme.
  ['@keyword'] = { fg = s.keyword },
  ['@keyword.function'] = { fg = s.keyword },
  ['@keyword.operator'] = { fg = s.operator },
  ['@keyword.return'] = { fg = s.control_flow },
  ['@keyword.conditional'] = { fg = s.control_flow },
  ['@keyword.repeat'] = { fg = s.control_flow },
  ['@keyword.exception'] = { fg = s.control_flow },
  ['@operator'] = { fg = s.operator },

  -- Functions: green, not blue.
  ['@function'] = { fg = s['function'] },
  ['@function.call'] = { fg = s['function'] },
  ['@function.method'] = { fg = s['function'] },
  ['@function.method.call'] = { fg = s['function'] },
  ['@constructor'] = { fg = s.type },

  -- Strings: gold, not green.
  ['@string'] = { fg = s.string },
  ['@string.escape'] = { fg = p.ansi.cyan },
  ['@string.special'] = { fg = p.ansi.cyan },

  -- Numbers and constants: purple, not orange.
  ['@number'] = { fg = s.number },
  ['@number.float'] = { fg = s.number },
  ['@boolean'] = { fg = s.constant },
  ['@constant'] = { fg = s.constant },
  ['@constant.builtin'] = { fg = s.constant },

  -- Types and JSX/HTML tags.
  ['@type'] = { fg = s.type },
  ['@type.builtin'] = { fg = s.type },
  ['@type.definition'] = { fg = s.type },
  ['@attribute'] = { fg = s.type },
  ['@tag'] = { fg = s.tag },
  ['@tag.builtin'] = { fg = s.tag },
  ['@tag.attribute'] = { fg = s.type },
  ['@tag.delimiter'] = { fg = s.punctuation },

  -- Variables. Parameters get their own orange, as in VS Code.
  ['@variable'] = { fg = s.variable },
  ['@variable.builtin'] = { fg = s.variable },
  ['@variable.member'] = { fg = s.type },
  ['@variable.parameter'] = { fg = s.parameter },
  ['@property'] = { fg = s.type },

  ['@comment'] = { fg = s.comment, italic = true },
  ['@punctuation.bracket'] = { fg = s.punctuation },
  ['@punctuation.delimiter'] = { fg = s.punctuation },
  ['@punctuation.special'] = { fg = s.punctuation },
}

-- Import machinery, deliberately faded so it recedes. These sit below the
--  normal contrast floor on purpose -- see the note in palette.toml. Do not
--  "fix" them; the whole point is that imports fall away when scanning a file.
local imports = {
  ['@keyword.import'] = { fg = s.import.keyword.color, italic = true },
  ['@module'] = { fg = s.import.alias.color, italic = true },
  ['@string.import'] = { fg = s.import.path.color, italic = true },
}

for group, opts in pairs(syntax_groups) do hl(group, opts) end
for group, opts in pairs(imports) do hl(group, opts) end

-- Legacy (non-treesitter) groups, so a buffer without a parser still looks
--  like this theme rather than like stock base16.
for group, opts in pairs {
  Keyword = { fg = s.keyword },
  Function = { fg = s['function'] },
  String = { fg = s.string },
  Number = { fg = s.number },
  Type = { fg = s.type },
  Constant = { fg = s.constant },
  Comment = { fg = s.comment, italic = true },
  Operator = { fg = s.operator },
  Statement = { fg = s.control_flow },
  Identifier = { fg = s.variable },
} do
  hl(group, opts)
end

-- [[ Diagnostics and git, from the semantic table ]]
local sem = p.semantic
for group, color in pairs {
  DiagnosticError = sem.error,
  DiagnosticWarn = sem.warning,
  DiagnosticInfo = sem.info,
  DiagnosticHint = sem.hint,
  DiffAdd = sem.added,
  DiffChange = sem.modified,
  DiffDelete = sem.removed,
  GitSignsAdd = sem.added,
  GitSignsChange = sem.modified,
  GitSignsDelete = sem.removed,
} do
  hl(group, { fg = color })
end

-- Directories, in the file tree and anywhere else Neovim names one (netrw,
--  :Explore, telescope's path column). base16 puts these on base0D, which in
--  this palette is the function green -- directories reading as function calls
--  was confusing, so they are plain foreground instead, matching files. That is
--  what VS Code does: the folder icon carries the distinction, not the colour.
--
-- CHANGE THIS ONE LINE to recolour every directory. `p.ground.fg` for plain
--  text, `s.string` for the gold, `s.type` for the light blue.
local directory_color = s.comment

hl('Directory', { fg = directory_color })
hl('NeoTreeDirectoryName', { fg = directory_color })
hl('NeoTreeDirectoryIcon', { fg = directory_color })

-- The root is the project name at the top of the tree -- a heading rather than
--  something you navigate into, so it keeps full foreground while the
--  directories beneath it recede.
hl('NeoTreeRootName', { fg = p.ground.fg, bold = true })

-- Telescope results: filename at full foreground, its directory dimmed to
--  comment grey. The dimming is what makes the list scannable, so the filename
--  needs no colour of its own -- it just has to be the thing that is not faded.
--  The split is produced by the `path_display` function in
--  kickstart/plugins/telescope.lua; these two groups only colour it.
hl('TelescopeResultsFileName', { fg = p.ground.fg })
hl('TelescopeResultsComment', { fg = s.comment })

-- The gold accent: the one colour that says "you are here". Kept scarce.
hl('CursorLineNr', { fg = p.ground.accent, bold = true })
hl('WinBar', { fg = p.ground.fg, bg = p.ground.bg })
hl('WinBarNC', { fg = s.comment, bg = p.ground.bg })

-- Floating windows and the file tree sit on their own darker ground, the way
--  VS Code layers its four dark levels.
hl('NormalFloat', { bg = p.ground.bg_widget })
hl('FloatBorder', { fg = p.ground.chrome, bg = p.ground.bg_widget })
hl('NeoTreeNormal', { bg = p.ground.bg_widget })
hl('NeoTreeNormalNC', { bg = p.ground.bg_widget })

-- [[ :ThemeReload ]]
--
-- Regenerate from palette.toml and reapply without restarting. Tuning colours
--  means looking at the result constantly; restarting Neovim for each hex would
--  make the fiddly part of this miserable.
vim.api.nvim_create_user_command('ThemeReload', function()
  local result = vim.system({ vim.fn.expand '~/.config/theme/generate', 'nvim' }):wait()
  if result.code ~= 0 then
    vim.notify('theme generate failed:\n' .. (result.stderr or ''), vim.log.levels.ERROR)
    return
  end
  package.loaded['custom.theme_palette'] = nil
  package.loaded['custom.plugins.colorscheme'] = nil
  require 'custom.plugins.colorscheme'
  vim.notify('theme reloaded', vim.log.levels.INFO)
end, { desc = 'Regenerate the colorscheme from palette.toml and reapply' })

-- vim: ts=2 sts=2 sw=2 et
