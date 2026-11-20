# nvim

My Neovim config: [LazyVim](https://github.com/LazyVim/LazyVim) on Neovim 0.12,
plus org-mode, org-roam, an Overleaf-style LaTeX workspace, and R.

## Install

On a fresh Arch box:

```sh
git clone <this-repo> ~/.config/nvim
~/.config/nvim/install.sh
```

The script installs the system packages, moves any existing Neovim state aside
(to `*.bak.<timestamp>`), links `bin/texide` into `~/.local/bin`, creates
`~/orgfiles`, and restores plugins at the exact commits in `lazy-lock.json`.
It is safe to re-run.

On anything that is not Arch it prints the package list instead of installing,
and does the rest.

## What's in here

| Path | What it does |
| --- | --- |
| `lua/config/` | LazyVim bootstrap, options, keymaps, autocmds |
| `lua/plugins/dashboard.lua` | Vim-logo ASCII header for the snacks dashboard |
| `lua/plugins/latex.lua` | vimtex + latexmk in continuous mode, PDF in a tmux pane |
| `lua/plugins/org-mode.lua` | orgmode, plus Emacs-style entity and sub/superscript concealing |
| `lua/plugins/org-roam.lua` | org-roam, plus `<leader>ng` to render the graph in a browser |
| `lua/plugins/R-nvim.lua` | R.nvim; `<Enter>` sends a line or selection to the console |
| `lua/plugins/jupynium.lua` | Jupyter notebooks as `.ju.py` text, synced into Firefox |
| `lua/plugins/smear_cursor.lua` | smear-cursor |
| `bin/texide` | tmux LaTeX workspace: editor pane left, `tdf` PDF pane right |
| `bin/jupynium-venv` | builds the Python venv Jupynium drives; run by its `build` step |

## Things that live outside this repo

- **`~/orgfiles/`** — agenda files and `~/orgfiles/roam` are hardcoded in
  `lua/plugins/org-mode.lua` and `org-roam.lua`. The install script creates the
  directories; the notes themselves are yours to copy or sync separately.
- **A Nerd Font**, selected in the terminal emulator, not here. The install
  script pulls `ttf-jetbrains-mono-nerd`.
- **`tdf`**, the terminal PDF viewer `texide` opens. AUR package — the script
  installs it through `paru` or `yay`, bootstrapping `yay-bin` from the AUR
  first if neither is there.
- **`R_AUTO_START=true`** — set this env var to have R.nvim start the console
  and object browser on startup. Unset, R stays manual.
- **`~/.virtualenvs/jupynium`** — the Python environment Jupynium runs in,
  built by `bin/jupynium-venv` during the plugin's install. Rebuild it any time
  with `:Lazy build jupynium.nvim`, or repair just the Jupyter side by running
  `jupynium-venv` with no arguments. Override the location with
  `JUPYNIUM_VENV`.

## Notebooks

Open a `.ju.py` file and Jupynium starts its server, opens Firefox at
`localhost:8888/nbclassic` and begins syncing. Cells are `# %%` markers; the
`.ipynb` is written out on save.

| Key | Does |
| --- | --- |
| `<localleader>x` | Execute the current cell (or the selected ones) |
| `<localleader>c` | Clear those cells' outputs |
| `<localleader>k` | Inspect the variable under the cursor |
| `<localleader>jc` / `<localleader>jo` | Scroll the browser to the cell / its output |
| `<localleader>js` | Start syncing, if it was not automatic |
| `<PageUp>` / `<PageDown>` | Scroll the browser |

Sync runs one way, Neovim to browser. Edits made in the browser do not come
back and will desync the two — treat the browser as output only.

## Updating plugins

`:Lazy sync`, then commit the changed `lazy-lock.json` so the other machine
gets the same versions.
