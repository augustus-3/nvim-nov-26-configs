-- Overrides LazyVim's default "LAZYVIM" dashboard header (set in
-- LazyVim/lua/lazyvim/plugins/ui.lua) with the classic Vim logo (diamond,
-- large V, small "im"), rendered as ASCII. Source: the official SVG at
-- vim/vim's runtime/vimlogo.svg, rendered at 1600x1600, lightly blurred
-- (imagemagick `-blur 0x3`) to smooth anti-aliased edges before
-- quantization, then converted with
-- `chafa -f symbols --size=52x20 --symbols block --colors none -w 1`.
-- The blur pass + max work-factor is what cleaned up the "im" text (flat
-- filled stroke bottoms, no stray dithering flecks in the gaps) vs the
-- first attempt. Not hand-drawn. lazy.nvim merges plugin specs targeting
-- the same plugin name, so this just needs to supply the one field we want
-- to change.
--
-- Note: this uses Unicode block/quadrant characters (U+2580-259F). If these
-- render misaligned in this terminal's font (as an earlier Neovim-logo
-- attempt did), swap --symbols block for --symbols ascii in the chafa
-- command above and regenerate -- plain ASCII is guaranteed monospace
-- everywhere, at the cost of a much noisier/less recognizable image.
return {
  "snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        header = [[
███████████████████▛▜███████████████████
████▀▂▂▂▂▂▂▂▂▂▂▂▂▀▘  ▝▜▛▀▂▂▂▂▂▂▂▂▂▂▂▂▀██
███▌▐████████████▔      ▐███████████▉ ▐█
███▙▝▔▐███████▌▔▔       ▝▔▐████████▀  ▟█
█████▌▐███████▌         ▂▟███████▀▔ ▄███
█████▌▐███████▌       ▂▟███████▛▘ ▃▇████
█████▌▐███████▌     ▂▟███████▛▔ ▗▇██████
█████▌▐███████▌   ▂▟███████▛▘    ▝▜█████
███▛▘ ▐███████▌ ▂▟███████▛▘        ▝▜███
█▛▘   ▐███████▌▟███████▛▘            ▝▜█
█▙▁   ▐██████████████▛▂▃              ▄█
███▅▁ ▐█████████████▀▕▀▀            ▄███
█████▌▐███████████▀ ▂▂▂  ▂▂▂  ▂▂▂ ▁▂▂▝▜█
█████▌▐█████████▀   ▟█▌  ▟█▛▀▜██▛▇▜██▌▐█
█████▌▐███████▀    ▗█▛  ▗█▉▗▖▗█▛▗▖▗█▛▗██
█████▌▐█████▀      ██▘  ██▘▝ ██▘▝ ██▘▐██
█████▌▐███▀▔ ▄▁   ▝▀▀▘ ▝▀▀▁▁▝▀▀▁▁▝▀▀▁▟██
██████▄▂▂▂▂▃███▅▁       ▄███████████████
█████████████████▅▁   ▄█████████████████
███████████████████▅▄███████████████████
]],
      },
    },
  },
}
