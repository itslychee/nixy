require("conform").setup {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { { "ruff_fix", "ruff_format" } },
    nix = { "alejandra" },
    golang = { { "goimports", "gofmt" } },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
    quiet = true,
  },
}

vim.keymap.set("n", ",f", function()
  require("conform").format {
    lsp_fallback = true,
    quiet = true,
  }
end, {
  noremap = true,
  silent = true,
  buffer = bufnr,
  desc = "Format document",
})
