-- Static visual snapshot of the roam graph, since org-roam.nvim's own
-- graph extension is an unimplemented stub. Pulls nodes/links straight out
-- of the in-memory database (no separate indexing), renders with
-- vis-network (via CDN) in a throwaway HTML file, opened the same way PDF
-- links open (vim.ui.open -> default browser). No click-to-jump or live
-- sync -- just a visual map, regenerated on demand.
local function open_roam_graph()
  local roam = require("org-roam")
  local db = roam.database:internal_sync()

  local ids = db:ids()
  local id_set = {}
  for _, id in ipairs(ids) do
    id_set[id] = true
  end

  local nodes = {}
  for _, id in ipairs(ids) do
    local node = db:get(id)
    table.insert(nodes, {
      id = id,
      label = node.title or vim.fn.fnamemodify(node.file, ":t:r"),
      title = node.file,
    })
  end

  local edges = {}
  for _, id in ipairs(ids) do
    for target_id, _ in pairs(db:get_links(id)) do
      if id_set[target_id] then
        table.insert(edges, { from = id, to = target_id })
      end
    end
  end

  local dir = vim.fn.stdpath("cache") .. "/roam-graph"
  vim.fn.mkdir(dir, "p")
  local html_path = dir .. "/graph.html"

  local html = [[
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>Roam Graph</title>
<script src="https://cdn.jsdelivr.net/npm/vis-network@9/standalone/umd/vis-network.min.js"></script>
<style>
  html, body { margin: 0; height: 100%; background: #1e1e2e; }
  #graph { width: 100%; height: 100%; }
</style>
</head>
<body>
<div id="graph"></div>
<script>
  var nodes = new vis.DataSet(]] .. vim.json.encode(nodes) .. [[);
  var edges = new vis.DataSet(]] .. vim.json.encode(edges) .. [[);
  var container = document.getElementById("graph");
  var data = { nodes: nodes, edges: edges };
  var options = {
    nodes: {
      shape: "dot",
      size: 12,
      font: { color: "#cdd6f4", size: 14 },
      color: { background: "#89b4fa", border: "#74c7ec" },
    },
    edges: {
      color: { color: "#585b70", highlight: "#f9e2af" },
      smooth: { type: "continuous" },
      arrows: { to: { enabled: true, scaleFactor: 0.5 } },
    },
    physics: { stabilization: true, barnesHut: { gravitationalConstant: -3000 } },
    interaction: { hover: true, tooltipDelay: 100 },
  };
  new vis.Network(container, data, options);
</script>
</body>
</html>
]]

  local file = io.open(html_path, "w")
  if not file then
    return vim.notify("Failed to write " .. html_path, vim.log.levels.ERROR)
  end
  file:write(html)
  file:close()

  vim.ui.open(html_path)
  vim.notify(string.format("Roam graph: %d nodes, %d links -> %s", #nodes, #edges, html_path))
end

return {
  "chipsenkbeil/org-roam.nvim",
  dependencies = {
    "nvim-orgmode/orgmode",
  },
  config = function()
    require("org-roam").setup({
      directory = "~/orgfiles/roam",
    })
    vim.keymap.set("n", "<leader>ng", open_roam_graph, { desc = "Open roam graph (visual snapshot)" })
  end,
}
