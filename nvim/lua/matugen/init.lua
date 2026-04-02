-- ~/.config/nvim/lua/matugen/init.lua
-- Reads the matugen-generated palette and applies it as a full colorscheme.

local M = {}

--- Safely load the generated palette. Returns nil if matugen hasn't run yet.
local function load_palette()
  local ok, pal = pcall(require, "matugen.palette")
  if not ok then
    vim.notify("[matugen] palette.lua not found. Run: matugen image /path/to/wallpaper.jpg", vim.log.levels.WARN)
    return nil
  end
  return pal.palette
end

--- Fill in any missing palette keys so nil bg values never cause transparency.
--- Older matugen versions may omit surface_container_* tones.
local function normalize(c)
  local bg = c.background or "#1a1a1a"
  local sfx = c.surface or bg
  local sfv = c.surface_variant or sfx

  -- Surface containers: derive from surface if absent
  c.surface_container_lowest = c.surface_container_lowest or sfx
  c.surface_container_low = c.surface_container_low or sfx
  c.surface_container = c.surface_container or sfv
  c.surface_container_high = c.surface_container_high or sfv
  c.surface_container_highest = c.surface_container_highest or sfv

  -- Remaining roles with safe fallbacks
  c.on_background = c.on_background or c.on_surface or "#e0e0e0"
  c.outline = c.outline or c.on_surface_variant or "#777777"
  c.outline_variant = c.outline_variant or c.outline
  c.inverse_surface = c.inverse_surface or c.on_surface
  c.inverse_on_surface = c.inverse_on_surface or bg
  c.inverse_primary = c.inverse_primary or c.primary

  c.error_container = c.error_container or sfv
  c.on_error_container = c.on_error_container or c.error
  c.secondary_container = c.secondary_container or sfv
  c.on_secondary_container = c.on_secondary_container or c.secondary
  c.tertiary_container = c.tertiary_container or sfv
  c.on_tertiary_container = c.on_tertiary_container or c.tertiary
  c.primary_container = c.primary_container or sfv
  c.on_primary_container = c.on_primary_container or c.primary

  return c
end

--- Apply a highlight group, skipping nil/empty values so they never
--- silently become transparent backgrounds.
---@param group string
---@param opts table
local function hi(group, opts)
  local clean = {}
  for k, v in pairs(opts) do
    if v ~= nil then
      clean[k] = v
    end
  end
  vim.api.nvim_set_hl(0, group, clean)
end

function M.setup()
  local c = load_palette()
  if not c then
    return
  end
  c = normalize(c)

  -- Reset existing highlights
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end
  vim.g.colors_name = "matugen"
  vim.o.termguicolors = true

  -- ── Editor ──────────────────────────────────────────────────────────────
  hi("Normal", { fg = c.on_background, bg = c.background })
  hi("NormalNC", { fg = c.on_surface_variant, bg = c.background })
  hi("NormalFloat", { fg = c.on_surface, bg = c.surface_container_lowest })
  hi("FloatBorder", { fg = c.outline, bg = c.surface_container_lowest })
  hi("FloatTitle", { fg = c.primary, bg = c.surface_container_lowest, bold = true })

  hi("Cursor", { fg = c.background, bg = c.primary })
  hi("CursorLine", { bg = c.surface_container })
  hi("CursorLineNr", { fg = c.primary, bold = true })
  hi("CursorColumn", { bg = c.surface_container })

  hi("LineNr", { fg = c.outline_variant })
  hi("SignColumn", { fg = c.outline_variant, bg = c.background })
  hi("FoldColumn", { fg = c.outline_variant, bg = c.background })
  hi("Folded", { fg = c.on_surface_variant, bg = c.surface_container_low })

  hi("ColorColumn", { bg = c.surface_container_high })
  hi("Conceal", { fg = c.outline })
  hi("NonText", { fg = c.outline_variant })
  hi("Whitespace", { fg = c.outline_variant })
  hi("SpecialKey", { fg = c.tertiary })
  hi("EndOfBuffer", { fg = c.surface_container })

  hi("Visual", { fg = c.on_primary_container, bg = c.primary_container })
  hi("VisualNOS", { fg = c.on_primary_container, bg = c.primary_container })

  hi("Search", { fg = c.on_tertiary_container, bg = c.tertiary_container })
  hi("IncSearch", { fg = c.on_primary, bg = c.primary })
  hi("CurSearch", { fg = c.on_primary, bg = c.primary })
  hi("Substitute", { fg = c.on_error_container, bg = c.error_container })

  -- ── Statusline / Tabline ─────────────────────────────────────────────────
  hi("StatusLine", { fg = c.on_surface, bg = c.surface_container_high })
  hi("StatusLineNC", { fg = c.on_surface_variant, bg = c.surface_container })
  hi("TabLine", { fg = c.on_surface_variant, bg = c.surface_container })
  hi("TabLineFill", { bg = c.surface_container_lowest })
  hi("TabLineSel", { fg = c.on_primary_container, bg = c.primary_container, bold = true })
  hi("WinBar", { fg = c.on_surface, bg = c.surface_container_high })
  hi("WinBarNC", { fg = c.on_surface_variant, bg = c.surface_container })

  -- ── Window chrome ────────────────────────────────────────────────────────
  hi("WinSeparator", { fg = c.outline_variant })
  hi("VertSplit", { fg = c.outline_variant })

  -- ── Popup menu ───────────────────────────────────────────────────────────
  hi("Pmenu", { fg = c.on_surface, bg = c.surface_container })
  hi("PmenuSel", { fg = c.on_primary_container, bg = c.primary_container })
  hi("PmenuSbar", { bg = c.surface_container_high })
  hi("PmenuThumb", { bg = c.outline })
  hi("PmenuMatch", { fg = c.primary, bold = true })
  hi("PmenuMatchSel", { fg = c.on_primary_container, bg = c.primary_container, bold = true })

  -- ── Messages / Prompts ───────────────────────────────────────────────────
  hi("ModeMsg", { fg = c.primary, bold = true })
  hi("MsgArea", { fg = c.on_surface })
  hi("MoreMsg", { fg = c.secondary })
  hi("Question", { fg = c.secondary })
  hi("Title", { fg = c.primary, bold = true })
  hi("WarningMsg", { fg = c.tertiary })
  hi("ErrorMsg", { fg = c.error })

  -- ── Spelling ─────────────────────────────────────────────────────────────
  hi("SpellBad", { sp = c.error, undercurl = true })
  hi("SpellCap", { sp = c.secondary, undercurl = true })
  hi("SpellLocal", { sp = c.tertiary, undercurl = true })
  hi("SpellRare", { sp = c.on_surface_variant, undercurl = true })

  -- ── Syntax ───────────────────────────────────────────────────────────────
  hi("Comment", { fg = c.on_surface_variant, italic = true })
  hi("Constant", { fg = c.tertiary })
  hi("String", { fg = c.tertiary })
  hi("Character", { fg = c.tertiary })
  hi("Number", { fg = c.secondary })
  hi("Boolean", { fg = c.primary })
  hi("Float", { fg = c.secondary })

  hi("Identifier", { fg = c.on_surface })
  hi("Function", { fg = c.primary })

  hi("Statement", { fg = c.primary })
  hi("Conditional", { fg = c.primary, bold = true })
  hi("Repeat", { fg = c.primary, bold = true })
  hi("Label", { fg = c.secondary })
  hi("Operator", { fg = c.on_surface_variant })
  hi("Keyword", { fg = c.primary, bold = true })
  hi("Exception", { fg = c.error })

  hi("PreProc", { fg = c.secondary })
  hi("Include", { fg = c.secondary })
  hi("Define", { fg = c.secondary })
  hi("Macro", { fg = c.secondary })
  hi("PreCondit", { fg = c.secondary })

  hi("Type", { fg = c.tertiary_container })
  hi("StorageClass", { fg = c.secondary })
  hi("Structure", { fg = c.secondary })
  hi("Typedef", { fg = c.secondary })

  hi("Special", { fg = c.tertiary })
  hi("SpecialChar", { fg = c.tertiary })
  hi("Tag", { fg = c.primary })
  hi("Delimiter", { fg = c.on_surface_variant })
  hi("SpecialComment", { fg = c.on_surface_variant, italic = true, bold = true })
  hi("Debug", { fg = c.error })

  hi("Underlined", { underline = true })
  hi("Ignore", { fg = c.outline_variant })
  hi("Error", { fg = c.error })
  hi("Todo", { fg = c.on_tertiary_container, bg = c.tertiary_container, bold = true })

  -- ── Treesitter ───────────────────────────────────────────────────────────
  -- Covers both pre-0.9 names and the 0.9+ renames so either version works.

  -- Comments
  hi("@comment", { link = "Comment" })
  hi("@comment.documentation", { fg = c.on_surface_variant, italic = true })
  hi("@comment.error", { fg = c.error, bold = true }) -- 0.9+
  hi("@comment.warning", { fg = c.tertiary, bold = true }) -- 0.9+
  hi("@comment.todo", { link = "Todo" }) -- 0.9+
  hi("@comment.note", { fg = c.secondary, bold = true }) -- 0.9+

  -- Keywords
  hi("@keyword", { fg = c.primary, bold = true })
  hi("@keyword.function", { fg = c.primary, bold = true })
  hi("@keyword.operator", { fg = c.primary })
  hi("@keyword.return", { fg = c.primary, bold = true })
  hi("@keyword.import", { fg = c.secondary })
  hi("@keyword.conditional", { fg = c.primary, bold = true }) -- 0.9+
  hi("@keyword.repeat", { fg = c.primary, bold = true }) -- 0.9+
  hi("@keyword.exception", { fg = c.error }) -- 0.9+
  hi("@keyword.modifier", { fg = c.secondary }) -- 0.9+
  hi("@keyword.type", { fg = c.secondary }) -- 0.9+
  hi("@keyword.coroutine", { fg = c.primary, italic = true }) -- 0.9+
  hi("@keyword.debug", { fg = c.error }) -- 0.9+
  hi("@keyword.directive", { fg = c.secondary }) -- 0.9+

  -- Functions
  hi("@function", { fg = c.primary })
  hi("@function.builtin", { fg = c.primary, italic = true })
  hi("@function.call", { fg = c.primary })
  hi("@function.macro", { fg = c.secondary })

  -- Methods (old: @method, new: @function.method)
  hi("@method", { fg = c.primary })
  hi("@method.call", { fg = c.primary })
  hi("@function.method", { fg = c.primary }) -- 0.9+
  hi("@function.method.call", { fg = c.primary }) -- 0.9+

  hi("@constructor", { fg = c.secondary })

  -- Variables & parameters
  hi("@variable", { fg = c.on_surface })
  hi("@variable.builtin", { fg = c.secondary, italic = true })
  hi("@variable.parameter", { fg = c.on_surface, italic = true }) -- 0.9+
  hi("@variable.member", { fg = c.on_surface }) -- 0.9+ (@field)

  -- Old names kept for pre-0.9 compat
  hi("@parameter", { fg = c.on_surface, italic = true })
  hi("@field", { fg = c.on_surface })
  hi("@property", { fg = c.on_surface })

  -- Types
  hi("@type", { fg = c.tertiary_container })
  hi("@type.builtin", { fg = c.tertiary_container, italic = true })
  hi("@type.qualifier", { fg = c.secondary }) -- 0.9+
  hi("@type.definition", { fg = c.tertiary_container, bold = true })

  -- Strings & literals
  hi("@string", { fg = c.tertiary })
  hi("@string.escape", { fg = c.secondary })
  hi("@string.regex", { fg = c.tertiary, italic = true }) -- pre-0.9
  hi("@string.regexp", { fg = c.tertiary, italic = true }) -- 0.9+
  hi("@string.special", { fg = c.secondary })
  hi("@string.special.symbol", { fg = c.tertiary })
  hi("@string.special.url", { fg = c.tertiary, underline = true })
  hi("@character", { fg = c.tertiary })
  hi("@character.special", { fg = c.secondary })

  -- Numbers / booleans
  hi("@number", { fg = c.secondary })
  hi("@number.float", { fg = c.secondary }) -- 0.9+ (@float)
  hi("@float", { fg = c.secondary })
  hi("@boolean", { fg = c.primary })

  -- Constants
  hi("@constant", { fg = c.tertiary, bold = true })
  hi("@constant.builtin", { fg = c.tertiary, italic = true })
  hi("@constant.macro", { fg = c.secondary })
  hi("@enum", { fg = c.tertiary_container }) -- 0.9+
  hi("@enumMember", { fg = c.tertiary }) -- 0.9+

  -- Namespaces / modules
  hi("@namespace", { fg = c.secondary, italic = true }) -- pre-0.9
  hi("@module", { fg = c.secondary, italic = true }) -- 0.9+
  hi("@module.builtin", { fg = c.secondary, italic = true }) -- 0.9+
  hi("@label", { fg = c.secondary })

  -- Operators & punctuation
  hi("@operator", { fg = c.on_surface_variant })
  hi("@punctuation.delimiter", { fg = c.on_surface_variant })
  hi("@punctuation.bracket", { fg = c.on_surface_variant })
  hi("@punctuation.special", { fg = c.secondary })

  -- Tags (HTML/JSX)
  hi("@tag", { fg = c.primary })
  hi("@tag.attribute", { fg = c.secondary, italic = true })
  hi("@tag.delimiter", { fg = c.outline })
  hi("@tag.builtin", { fg = c.primary, italic = true }) -- 0.9+

  -- Markup / text (pre-0.9: @text.*, 0.9+: @markup.*)
  hi("@text.title", { fg = c.primary, bold = true })
  hi("@text.strong", { bold = true })
  hi("@text.emphasis", { italic = true })
  hi("@text.underline", { underline = true })
  hi("@text.strike", { strikethrough = true })
  hi("@text.uri", { fg = c.tertiary, underline = true })
  hi("@text.reference", { fg = c.secondary })
  hi("@text.todo", { link = "Todo" })
  hi("@text.warning", { fg = c.tertiary, bold = true })
  hi("@text.danger", { fg = c.error, bold = true })
  hi("@text.note", { fg = c.secondary, bold = true })
  hi("@text.diff.add", { fg = c.tertiary })
  hi("@text.diff.delete", { fg = c.error })

  hi("@markup.heading", { fg = c.primary, bold = true }) -- 0.9+
  hi("@markup.heading.1", { fg = c.primary, bold = true })
  hi("@markup.heading.2", { fg = c.secondary, bold = true })
  hi("@markup.heading.3", { fg = c.tertiary, bold = true })
  hi("@markup.strong", { bold = true }) -- 0.9+
  hi("@markup.italic", { italic = true }) -- 0.9+
  hi("@markup.underline", { underline = true }) -- 0.9+
  hi("@markup.strikethrough", { strikethrough = true }) -- 0.9+
  hi("@markup.link", { fg = c.secondary }) -- 0.9+
  hi("@markup.link.url", { fg = c.tertiary, underline = true }) -- 0.9+
  hi("@markup.link.label", { fg = c.secondary }) -- 0.9+
  hi("@markup.raw", { fg = c.tertiary_container }) -- 0.9+
  hi("@markup.raw.block", { fg = c.tertiary_container }) -- 0.9+
  hi("@markup.list", { fg = c.primary }) -- 0.9+
  hi("@markup.list.checked", { fg = c.tertiary }) -- 0.9+
  hi("@markup.list.unchecked", { fg = c.outline_variant }) -- 0.9+
  hi("@markup.quote", { fg = c.on_surface_variant, italic = true }) -- 0.9+

  -- Diff (0.9+: @diff.*)
  hi("@diff.plus", { fg = c.tertiary }) -- 0.9+
  hi("@diff.minus", { fg = c.error }) -- 0.9+
  hi("@diff.delta", { fg = c.secondary }) -- 0.9+

  -- Conceal / misc
  hi("@conceal", { fg = c.outline_variant })
  hi("@none", {})

  -- ── Diagnostics ──────────────────────────────────────────────────────────
  hi("DiagnosticError", { fg = c.error })
  hi("DiagnosticWarn", { fg = c.tertiary })
  hi("DiagnosticInfo", { fg = c.secondary })
  hi("DiagnosticHint", { fg = c.primary })
  hi("DiagnosticOk", { fg = c.tertiary })

  hi("DiagnosticUnderlineError", { sp = c.error, undercurl = true })
  hi("DiagnosticUnderlineWarn", { sp = c.tertiary, undercurl = true })
  hi("DiagnosticUnderlineInfo", { sp = c.secondary, undercurl = true })
  hi("DiagnosticUnderlineHint", { sp = c.primary, undercurl = true })

  hi("DiagnosticVirtualTextError", { fg = c.error, bg = c.error_container, italic = true })
  hi("DiagnosticVirtualTextWarn", { fg = c.tertiary, bg = c.tertiary_container, italic = true })
  hi("DiagnosticVirtualTextInfo", { fg = c.secondary, bg = c.secondary_container, italic = true })
  hi("DiagnosticVirtualTextHint", { fg = c.primary, bg = c.primary_container, italic = true })

  hi("DiagnosticSignError", { fg = c.error })
  hi("DiagnosticSignWarn", { fg = c.tertiary })
  hi("DiagnosticSignInfo", { fg = c.secondary })
  hi("DiagnosticSignHint", { fg = c.primary })

  -- ── LSP ──────────────────────────────────────────────────────────────────
  hi("LspReferenceText", { bg = c.surface_container_high })
  hi("LspReferenceRead", { bg = c.surface_container_high })
  hi("LspReferenceWrite", { bg = c.surface_container_high, underline = true })
  hi("LspInlayHint", { fg = c.on_surface_variant, bg = c.surface_container, italic = true })
  hi("LspCodeLens", { fg = c.outline })
  hi("LspSignatureActiveParameter", { fg = c.primary, bold = true, underline = true })

  -- LSP hover / info floats — the most common source of transparent doc windows.
  -- Neovim renders hover docs in a NormalFloat window, but many LSP UIs define
  -- their own groups that can bypass NormalFloat entirely.
  local float_bg = c.surface_container_low
  local float_fg = c.on_surface

  -- Native Neovim LSP info float
  hi("LspInfoBorder", { fg = c.outline, bg = float_bg })

  -- lspsaga.nvim
  hi("SagaNormal", { fg = float_fg, bg = float_bg })
  hi("SagaBorder", { fg = c.outline, bg = float_bg })
  hi("HoverNormal", { fg = float_fg, bg = float_bg })
  hi("HoverBorder", { fg = c.outline, bg = float_bg })

  -- noice.nvim (intercepts hover / signature / cmdline)
  hi("NoicePopup", { fg = float_fg, bg = float_bg })
  hi("NoicePopupBorder", { fg = c.outline, bg = float_bg })
  hi("NoiceCmdlinePopup", { fg = float_fg, bg = float_bg })
  hi("NoiceCmdlinePopupBorder", { fg = c.outline, bg = float_bg })
  hi("NoicePopupmenu", { fg = float_fg, bg = float_bg })
  hi("NoicePopupmenuBorder", { fg = c.outline, bg = float_bg })

  -- nvim-cmp doc window (separate from the completion menu itself)
  hi("CmpDocumentation", { fg = float_fg, bg = float_bg })
  hi("CmpDocumentationBorder", { fg = c.outline, bg = float_bg })

  -- mason.nvim / other tool floats
  hi("MasonNormal", { fg = float_fg, bg = float_bg })

  -- Markdown rendered inside hover floats (LSP renders hover as markdown)
  hi("markdownH1", { fg = c.primary, bold = true })
  hi("markdownH2", { fg = c.secondary, bold = true })
  hi("markdownH3", { fg = c.tertiary, bold = true })
  hi("markdownCode", { fg = c.tertiary_container, bg = c.surface_container_high })
  hi("markdownCodeBlock", { fg = c.tertiary_container, bg = c.surface_container_high })
  hi("markdownUrl", { fg = c.tertiary, underline = true })

  -- ── Git (gitsigns.nvim) ───────────────────────────────────────────────────
  hi("GitSignsAdd", { fg = c.tertiary })
  hi("GitSignsChange", { fg = c.secondary })
  hi("GitSignsDelete", { fg = c.error })
  hi("GitSignsAddNr", { fg = c.tertiary })
  hi("GitSignsChangeNr", { fg = c.secondary })
  hi("GitSignsDeleteNr", { fg = c.error })
  hi("GitSignsAddLn", { bg = c.tertiary_container })
  hi("GitSignsChangeLn", { bg = c.secondary_container })
  hi("GitSignsDeleteLn", { bg = c.error_container })

  -- ── Diff ─────────────────────────────────────────────────────────────────
  hi("DiffAdd", { fg = c.tertiary, bg = c.tertiary_container })
  hi("DiffChange", { fg = c.secondary, bg = c.secondary_container })
  hi("DiffDelete", { fg = c.error, bg = c.error_container })
  hi("DiffText", { fg = c.on_secondary_container, bg = c.secondary_container, bold = true })

  -- ── Telescope ────────────────────────────────────────────────────────────
  hi("TelescopeBorder", { fg = c.outline, bg = c.surface_container_lowest })
  hi("TelescopeNormal", { fg = c.on_surface, bg = c.surface_container_lowest })
  hi("TelescopePromptBorder", { fg = c.primary, bg = c.surface_container_lowest })
  hi("TelescopePromptNormal", { fg = c.on_surface, bg = c.surface_container_lowest })
  hi("TelescopePromptPrefix", { fg = c.primary })
  hi("TelescopeSelection", { fg = c.on_primary_container, bg = c.primary_container })
  hi("TelescopeSelectionCaret", { fg = c.primary, bg = c.primary_container })
  hi("TelescopeMatching", { fg = c.primary, bold = true })
  hi("TelescopeResultsTitle", { fg = c.secondary, bold = true })
  hi("TelescopePreviewTitle", { fg = c.tertiary, bold = true })

  -- ── Which-key ────────────────────────────────────────────────────────────
  hi("WhichKey", { fg = c.primary })
  hi("WhichKeyGroup", { fg = c.secondary, bold = true })
  hi("WhichKeyDesc", { fg = c.on_surface })
  hi("WhichKeySeparator", { fg = c.outline_variant })
  hi("WhichKeyFloat", { bg = c.surface_container_lowest })
  hi("WhichKeyBorder", { fg = c.outline })

  -- ── nvim-cmp ─────────────────────────────────────────────────────────────
  hi("CmpItemAbbr", { fg = c.on_surface })
  hi("CmpItemAbbrMatch", { fg = c.primary, bold = true })
  hi("CmpItemAbbrMatchFuzzy", { fg = c.primary })
  hi("CmpItemAbbrDeprecated", { fg = c.outline, strikethrough = true })
  hi("CmpItemMenu", { fg = c.outline, italic = true })
  hi("CmpItemKindFunction", { fg = c.primary })
  hi("CmpItemKindMethod", { fg = c.primary })
  hi("CmpItemKindConstructor", { fg = c.secondary })
  hi("CmpItemKindVariable", { fg = c.on_surface })
  hi("CmpItemKindField", { fg = c.on_surface })
  hi("CmpItemKindProperty", { fg = c.on_surface })
  hi("CmpItemKindKeyword", { fg = c.primary })
  hi("CmpItemKindText", { fg = c.tertiary })
  hi("CmpItemKindEnum", { fg = c.tertiary_container })
  hi("CmpItemKindClass", { fg = c.tertiary_container })
  hi("CmpItemKindInterface", { fg = c.tertiary_container })
  hi("CmpItemKindStruct", { fg = c.tertiary_container })
  hi("CmpItemKindModule", { fg = c.secondary })
  hi("CmpItemKindUnit", { fg = c.secondary })
  hi("CmpItemKindValue", { fg = c.secondary })
  hi("CmpItemKindSnippet", { fg = c.tertiary })
  hi("CmpItemKindColor", { fg = c.tertiary })
  hi("CmpItemKindFile", { fg = c.on_surface_variant })
  hi("CmpItemKindFolder", { fg = c.on_surface_variant })
  hi("CmpItemKindEvent", { fg = c.error })
  hi("CmpItemKindOperator", { fg = c.on_surface_variant })
  hi("CmpItemKindTypeParameter", { fg = c.tertiary_container })

  -- ── indent-blankline ─────────────────────────────────────────────────────
  hi("IblIndent", { fg = c.surface_container_high })
  hi("IblScope", { fg = c.outline_variant })
  hi("IndentBlanklineChar", { fg = c.surface_container_high })
  hi("IndentBlanklineScopeChar", { fg = c.outline_variant })
end

--- Force every floating window to use NormalFloat for its Normal group.
--- This is the catch-all fix for plugins that open floats without explicitly
--- setting a background — their window-local Normal inherits terminal
--- transparency instead of our colorscheme bg.
local augroup = vim.api.nvim_create_augroup("MatugenFloatFix", { clear = true })
vim.api.nvim_create_autocmd("WinNew", {
  group = augroup,
  desc = "Force NormalFloat bg on every new floating window",
  callback = function()
    -- Schedule so the window config is fully populated before we read it
    vim.schedule(function()
      local win = vim.api.nvim_get_current_win()
      local ok, config = pcall(vim.api.nvim_win_get_config, win)
      if not ok then
        return
      end
      -- relative ~= "" means it's a floating window
      if config.relative ~= "" then
        local cur_whl = vim.wo[win].winhighlight or ""
        -- Only patch if Normal isn't already explicitly remapped
        if not cur_whl:find("Normal:") then
          local sep = cur_whl ~= "" and "," or ""
          vim.wo[win].winhighlight = cur_whl .. sep .. "Normal:NormalFloat,NormalNC:NormalFloat"
        end
      end
    end)
  end,
})

return M
