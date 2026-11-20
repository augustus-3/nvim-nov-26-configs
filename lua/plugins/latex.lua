-- LaTeX workspace.
--
-- vimtex keeps latexmk running in continuous mode, so every write rebuilds the
-- PDF. tdf sits in a sibling tmux pane and reloads the file on its own. The pane
-- plumbing lives in ~/.local/bin/texide.
return {
  -- vimtex, the texlab LSP and the latex/bibtex treesitter parsers
  { import = "lazyvim.plugins.extras.lang.tex" },

  {
    "lervag/vimtex",
    -- `init` runs before the plugin loads, which is when vimtex reads these.
    -- LazyVim's extra sets a few more in its own `config`; both apply.
    init = function()
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        continuous = 1,
        aux_dir = "build", -- keep .aux/.log/.fls out of the way
        out_dir = "", -- but leave the PDF beside the .tex, where tdf expects it
        options = {
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }

      -- tdf is a terminal viewer with no inverse-search channel, so vimtex hands
      -- the PDF to our tmux helper instead of launching a GUI app.
      vim.g.vimtex_view_method = "general"
      vim.g.vimtex_view_general_viewer = "texide"
      vim.g.vimtex_view_general_options = "--view @pdf"

      -- Errors collect in the quickfix list but never steal the cursor mid-sentence.
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_quickfix_open_on_warning = 0

      -- Every PDF this session has opened a viewer pane for.
      local viewing = {}

      -- Start compiling as soon as a document opens, the way Overleaf does.
      vim.api.nvim_create_autocmd("User", {
        pattern = "VimtexEventInitPost",
        callback = function()
          -- With out_dir unset above, the PDF always lands beside the .tex.
          viewing[vim.b.vimtex.root .. "/" .. vim.b.vimtex.name .. ".pdf"] = true
          vim.cmd.VimtexCompile()
        end,
      })

      -- Close the PDF panes along with the editor so panes do not pile up.
      -- This runs synchronously: a detached job would not outlive the exit.
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          for pdf in pairs(viewing) do
            vim.fn.system({ "texide", "--close", pdf })
          end
        end,
      })

      -- Prose settings: soft wrap on words, spell check, concealed math.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "tex", "plaintex", "bib" },
        callback = function()
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
          vim.opt_local.spell = true
          vim.opt_local.conceallevel = 2
        end,
      })
    end,
  },
}
