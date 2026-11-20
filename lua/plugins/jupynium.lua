-- Jupyter notebooks, edited as plain text.
--
-- Jupynium drives a real Jupyter Notebook in Firefox over Selenium and mirrors
-- this buffer into it on every keystroke, so cells run with their output in the
-- browser while the editing happens here. The file on disk is an ordinary
-- `.ju.py` script with `# %%` cell markers -- the `.ipynb` is downloaded from
-- the browser on save.
--
-- Sync is one-way, Neovim -> browser. Editing the notebook in the browser
-- desyncs the two, so treat the browser as read-only output.
--
-- Three things have to line up outside this file, all handled by
-- bin/jupynium-venv and install.sh:
--   * the Python package, in its own venv (Arch's system Python is
--     externally-managed, so pip cannot write to it)
--   * Firefox and geckodriver, for Selenium
--   * nbclassic -- Jupynium does not support Notebook 7's interface
local venv = vim.fn.expand("~/.virtualenvs/jupynium")

return {
  "kiyoon/jupynium.nvim",
  -- Installs the plugin's own Python package into that venv, creating it on
  -- first install. lazy.nvim runs this from the plugin directory, which is
  -- the argument the script wants.
  build = vim.fn.stdpath("config") .. "/bin/jupynium-venv",
  -- The default ft/event lazy-loading never fires for `.ju.py`, which Neovim
  -- sees as plain python; the plugin does its own filename matching instead.
  lazy = false,
  opts = {
    -- Point at the venv rather than `python3`/`jupyter` on PATH, so the
    -- notebook stack stays independent of whatever Python the system has.
    python_host = venv .. "/bin/python",
    jupyter_command = venv .. "/bin/jupyter",
    default_notebook_URL = "localhost:8888/nbclassic",

    -- Opening a `.ju.*` file starts the server, launches Firefox and begins
    -- syncing, so there is no setup command to remember. Markdown files are
    -- deliberately left out: attaching is harmless, but auto-launching a
    -- browser for every README is not.
    auto_start_server = { enable = true, file_pattern = { "*.ju.*" } },
    auto_start_sync = { enable = true, file_pattern = { "*.ju.*" } },
    auto_attach_to_server = { enable = true, file_pattern = { "*.ju.*", "*.md" } },

    -- Keep the .ipynb on disk current, and close the browser tab on exit so
    -- tabs do not pile up across sessions -- same reasoning as the LaTeX
    -- viewer panes in latex.lua.
    auto_download_ipynb = true,
    auto_close_tab = true,

    -- The defaults bind <space>x, <space>c and <space>K, which shadow
    -- LazyVim's <leader>x, <leader>c and <leader>K prefixes in exactly the
    -- buffers where code actions and formatting are wanted. Rebound below
    -- under <localleader>, where R.nvim's mappings already live.
    use_default_keybindings = false,
  },
  config = function(_, opts)
    require("jupynium").setup(opts)

    -- Buffer-local, and only for Jupynium files. BufEnter rather than
    -- FileType because `.ju.py` has filetype `python` like any other script,
    -- so the filename is the only thing that distinguishes it.
    vim.api.nvim_create_autocmd({ "BufEnter" }, {
      group = vim.api.nvim_create_augroup("jupynium_keymaps", { clear = true }),
      pattern = { "*.ju.*" },
      callback = function(ev)
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
        end

        map({ "n", "x" }, "<localleader>x", "<cmd>JupyniumExecuteSelectedCells<cr>", "Execute cell(s)")
        map({ "n", "x" }, "<localleader>c", "<cmd>JupyniumClearSelectedCellsOutputs<cr>", "Clear cell output(s)")
        map("n", "<localleader>k", "<cmd>JupyniumKernelHover<cr>", "Inspect variable under cursor")
        map({ "n", "x" }, "<localleader>jc", "<cmd>JupyniumScrollToCell<cr>", "Scroll browser to cell")
        map({ "n", "x" }, "<localleader>jo", "<cmd>JupyniumScrollToOutput<cr>", "Scroll browser to output")
        map("n", "<localleader>js", "<cmd>JupyniumStartSync<cr>", "Start sync")
        map("", "<PageUp>", "<cmd>JupyniumScrollUp<cr>", "Scroll browser up")
        map("", "<PageDown>", "<cmd>JupyniumScrollDown<cr>", "Scroll browser down")
      end,
    })
  end,
}
