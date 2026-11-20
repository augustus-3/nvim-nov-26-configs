-- Math/symbol entities, ported from Emacs's org-entities.el (the `t` /
-- latex-math-p entries only: Greek letters, operators, arrows, set theory,
-- etc). Typing e.g. "\int" or "\alpha" visually conceals to the matching
-- unicode glyph, same as `org-pretty-entities` in Emacs.
local org_entities = {
  -- Greek letters
  Alpha = "Α", alpha = "α",
  Beta = "Β", beta = "β",
  Gamma = "Γ", gamma = "γ",
  Delta = "Δ", delta = "δ",
  Epsilon = "Ε", epsilon = "ε", varepsilon = "ε",
  Zeta = "Ζ", zeta = "ζ",
  Eta = "Η", eta = "η",
  Theta = "Θ", theta = "θ", thetasym = "ϑ", vartheta = "ϑ",
  Iota = "Ι", iota = "ι",
  Kappa = "Κ", kappa = "κ",
  Lambda = "Λ", lambda = "λ",
  Mu = "Μ", mu = "μ",
  Nu = "Ν", nu = "ν",
  Xi = "Ξ", xi = "ξ",
  Omicron = "Ο", omicron = "ο",
  Pi = "Π", pi = "π",
  Rho = "Ρ", rho = "ρ",
  Sigma = "Σ", sigma = "σ", sigmaf = "ς", varsigma = "ς",
  Tau = "Τ", tau = "τ",
  Upsilon = "Υ", upsilon = "υ", upsih = "ϒ",
  Phi = "Φ", phi = "ɸ", varphi = "φ",
  Chi = "Χ", chi = "χ",
  Psi = "Ψ", psi = "ψ",
  Omega = "Ω", omega = "ω",
  piv = "ϖ", varpi = "ϖ",

  -- Hebrew / misc letters
  alefsym = "ℵ", aleph = "ℵ", gimel = "ℷ", beth = "ב", dalet = "ד",
  real = "ℜ", image = "ℑ", weierp = "℘", ell = "ℓ", imath = "ı", jmath = "ȷ", hbar = "ℏ",

  -- Calculus / operators
  partial = "∂", nabla = "∇", int = "∫", sum = "∑", prod = "∏",
  infin = "∞", infty = "∞", radic = "√",
  prime = "′", Prime = "″",
  prop = "∝", propto = "∝",

  -- Logic and set theory
  neg = "¬",
  land = "∧", wedge = "∧", lor = "∨", vee = "∨",
  cap = "∩", cup = "∪",
  forall = "∀", exist = "∃", exists = "∃", nexist = "∄", nexists = "∄",
  empty = "∅", emptyset = "∅",
  isin = "∈", notin = "∉", ni = "∋",
  sub = "⊂", subset = "⊂", sup = "⊃", supset = "⊃",
  nsub = "⊄", sube = "⊆", nsup = "⊅", supe = "⊇",

  -- Comparisons and relations
  ne = "≠", neq = "≠", equiv = "≡", triangleq = "≜",
  le = "≤", leq = "≤", ge = "≥", geq = "≥",
  lessgtr = "≶", lesseqgtr = "⋚",
  ll = "≪", Ll = "⋘", lll = "⋘", gg = "≫", Gg = "⋙", ggg = "⋙",
  prec = "≺", preceq = "≼", preccurlyeq = "≼",
  succ = "≻", succeq = "≽", succcurlyeq = "≽",
  sim = "∼", cong = "≅", simeq = "≅", asymp = "≈", approx = "≈",
  minus = "−",

  -- Geometry
  ang = "∠", angle = "∠", perp = "⊥", parallel = "∥",
  smile = "⌣", frown = "⌢",
  therefore = "∴", there4 = "∴", because = "∵",

  -- Delimiters
  lceil = "⌈", rceil = "⌉", lfloor = "⌊", rfloor = "⌋",
  lang = "⟨", rang = "⟩", langle = "⟨", rangle = "⟩",

  -- Misc math symbols
  sdot = "⋅", cdot = "⋅", star = "⋆", lowast = "∗",
  odot = "ʘ", oplus = "⊕", otimes = "⊗", mho = "℧", oline = "‾",
  cdots = "⋯",

  -- Arrows
  larr = "←", leftarrow = "←", gets = "←", lArr = "⇐", Leftarrow = "⇐",
  uarr = "↑", uparrow = "↑", uArr = "⇑", Uparrow = "⇑",
  rarr = "→", to = "→", rightarrow = "→", rArr = "⇒", Rightarrow = "⇒",
  darr = "↓", downarrow = "↓", dArr = "⇓", Downarrow = "⇓",
  harr = "↔", leftrightarrow = "↔", hArr = "⇔", Leftrightarrow = "⇔",
  crarr = "↵", hookleftarrow = "↵",

  check = "✓", checkmark = "✓",
}

local org_entities_ns = vim.api.nvim_create_namespace("org_entities")

local function render_org_entities(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, org_entities_ns, 0, -1)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for lnum, line in ipairs(lines) do
    local pos = 1
    while true do
      local s, e, name = line:find("\\(%a+)", pos)
      if not s then
        break
      end
      local symbol = org_entities[name]
      if symbol then
        vim.api.nvim_buf_set_extmark(bufnr, org_entities_ns, lnum - 1, s - 1, {
          end_col = e,
          conceal = symbol,
        })
      end
      pos = e + 1
    end
  end
end

-- Subscript/superscript rendering for org's native `base_{...}` /
-- `base^{...}` (and single-char `base_x` / `base^x`) syntax, same idea as
-- `org-use-sub-superscripts` in Emacs. Unicode only defines subscript
-- glyphs for digits, a few symbols, and these 17 lowercase letters
-- (no uppercase at all); superscript covers all lowercase and most
-- uppercase. Anything outside that (e.g. subscript "D") has no real
-- glyph, so it's left as plain unconcealed text rather than faked.
local subscript_map = {
  ["0"] = "₀", ["1"] = "₁", ["2"] = "₂", ["3"] = "₃", ["4"] = "₄",
  ["5"] = "₅", ["6"] = "₆", ["7"] = "₇", ["8"] = "₈", ["9"] = "₉",
  ["+"] = "₊", ["-"] = "₋", ["="] = "₌", ["("] = "₍", [")"] = "₎",
  a = "ₐ", e = "ₑ", h = "ₕ", i = "ᵢ", j = "ⱼ", k = "ₖ", l = "ₗ",
  m = "ₘ", n = "ₙ", o = "ₒ", p = "ₚ", r = "ᵣ", s = "ₛ", t = "ₜ",
  u = "ᵤ", v = "ᵥ", x = "ₓ",
}
local superscript_map = {
  ["0"] = "⁰", ["1"] = "¹", ["2"] = "²", ["3"] = "³", ["4"] = "⁴",
  ["5"] = "⁵", ["6"] = "⁶", ["7"] = "⁷", ["8"] = "⁸", ["9"] = "⁹",
  ["+"] = "⁺", ["-"] = "⁻", ["="] = "⁼", ["("] = "⁽", [")"] = "⁾",
  a = "ᵃ", b = "ᵇ", c = "ᶜ", d = "ᵈ", e = "ᵉ", f = "ᶠ", g = "ᵍ",
  h = "ʰ", i = "ⁱ", j = "ʲ", k = "ᵏ", l = "ˡ", m = "ᵐ", n = "ⁿ",
  o = "ᵒ", p = "ᵖ", q = "𐞥", r = "ʳ", s = "ˢ", t = "ᵗ", u = "ᵘ",
  v = "ᵛ", w = "ʷ", x = "ˣ", y = "ʸ", z = "ᶻ",
  A = "ᴬ", B = "ᴮ", D = "ᴰ", E = "ᴱ", G = "ᴳ", H = "ᴴ", I = "ᴵ",
  J = "ᴶ", K = "ᴷ", L = "ᴸ", M = "ᴹ", N = "ᴺ", O = "ᴼ", P = "ᴾ",
  R = "ᴿ", T = "ᵀ", U = "ᵁ", V = "ⱽ", W = "ᵂ",
}

---Map every char in `content` through `map`; nil if any char has no glyph.
local function to_script(content, map)
  local out = {}
  for char in content:gmatch(".") do
    local mapped = map[char]
    if not mapped then
      return nil
    end
    table.insert(out, mapped)
  end
  return table.concat(out)
end

local org_scripts_ns = vim.api.nvim_create_namespace("org_scripts")

local function render_org_scripts(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, org_scripts_ns, 0, -1)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for lnum, line in ipairs(lines) do
    local i = 1
    local n = #line
    while i <= n do
      local advance = 1
      local trigger = line:sub(i, i)
      if (trigger == "_" or trigger == "^") and i > 1 and line:sub(i - 1, i - 1):match("[%w%)%]}]") then
        local content, content_end
        if line:sub(i + 1, i + 1) == "{" then
          local braced = line:sub(i + 1):match("^%b{}")
          if braced and #braced > 2 then
            content = braced:sub(2, -2)
            content_end = i + #braced
          end
        else
          local single = line:sub(i + 1, i + 1)
          -- require a word boundary right after, so identifiers like
          -- "cov_matrix" or "#+begin_src" don't get mangled
          if single:match("%w") and not line:sub(i + 2, i + 2):match("%w") then
            content = single
            content_end = i + 1
          end
        end
        if content then
          local map = (trigger == "_") and subscript_map or superscript_map
          local display = to_script(content, map)
          if display then
            vim.api.nvim_buf_set_extmark(bufnr, org_scripts_ns, lnum - 1, i - 1, {
              end_col = content_end,
              conceal = "",
              virt_text = { { display } },
              virt_text_pos = "inline",
            })
          end
          advance = (content_end - i) + 1
        end
      end
      i = i + advance
    end
  end
end

return {
  "nvim-orgmode/orgmode",
  event = "VeryLazy",
  config = function()
    -- Setup orgmode
    require("orgmode").setup({
      org_agenda_files = "~/orgfiles/**/*",
      org_default_notes_file = "~/orgfiles/refile.org",
    })
    -- Experimental LSP support
    vim.lsp.enable("org")

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "org",
      callback = function(ev)
        render_org_entities(ev.buf)
        render_org_scripts(ev.buf)
        vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave" }, {
          buffer = ev.buf,
          callback = function()
            render_org_entities(ev.buf)
            render_org_scripts(ev.buf)
          end,
        })

        -- Add (or show) a file-level :ID: property, same as Emacs's
        -- `org-id-get-create` on a whole file. Idempotent: re-running on a
        -- file that already has an ID just returns it, no duplicate drawer.
        vim.keymap.set("n", "<leader>nI", function()
          local id = require("orgmode").files:get_current_file():id_get_or_create()
          vim.notify("Org ID: " .. id)
        end, { buffer = ev.buf, desc = "Add/show file-level org ID" })
      end,
    })

    -- conceallevel/concealcursor are window-local, so re-apply on every
    -- window that shows an org buffer (splits, tabs, etc), not just the
    -- first one. BufWinEnter's `pattern` matches the filename, not
    -- filetype, hence the explicit filetype check below.
    -- concealcursor="nc" means: concealed in Normal/Command mode,
    -- revealed as raw text on the cursor line while in Insert/Visual.
    local function set_org_conceal_opts()
      if vim.bo.filetype == "org" then
        vim.wo.conceallevel = 2
        vim.wo.concealcursor = "nc"
      end
    end
    vim.api.nvim_create_autocmd("FileType", { pattern = "org", callback = set_org_conceal_opts })
    vim.api.nvim_create_autocmd("BufWinEnter", { callback = set_org_conceal_opts })
  end,
}
