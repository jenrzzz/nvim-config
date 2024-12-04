-- require("typescript-tools").setup {
--   settings = {
--     code_lens = "all",
--     tsserver_plugins = {
--       "@styled/typescript-styled-plugin",
--     },
--   },
--   on_attach = function(client)
--     client.config.flags.allow_incremental_sync = false
--     -- client.config.flags.debounce_text_changes = 500
--     client.server_capabilities.semanticTokensProvider = nil
--   end,
-- }

local meta = require("meta")
require("meta.lsp")

require("lspconfig")["eslint@meta"].setup {
}

require("lspconfig")["prettier@meta"].setup {
}

vim.lsp.set_log_level("debug")
local nvim_lsp_util = require('lspconfig.util')
local flow_root_dir_finder = nvim_lsp_util.root_pattern('.flowconfig')

require('lspconfig').flow.setup({
    cmd = { 'flow', 'lsp' },
    on_attach = on_attach,
    root_dir = flow_root_dir_finder,
    on_new_config = function(config, new_root_dir)
      -- We'll only create new LSP client for root_dirs that are
      -- not the same as the one from the cwd, because the `flow` name
      -- is already used for that, avoiding the creation of a duplica
      -- client.
      if flow_root_dir_finder(vim.loop.cwd()) ~= new_root_dir then
        config.name = 'flow-' .. new_root_dir
        -- This makes LspRestart work with the new client configs
        local lspconfigs = require('lspconfig.configs')
        rawset(lspconfigs, config.name, lspconfigs.flow)
      end
    end,
})

local fmt_augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    meta.null_ls.diagnostics.arclint,
    meta.null_ls.formatting.arclint,
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = fmt_augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = fmt_augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end
  end,
})

require("lspconfig").hhvm.setup {
  cmd = { 'hh_client', 'lsp', '--from', 'vim' }
}

local function add_ruby_deps_command(client, bufnr)
  vim.api.nvim_buf_create_user_command(bufnr, "ShowRubyDeps", function(opts)
    local params = vim.lsp.util.make_text_document_params()
    local showAll = opts.args == "all"

    client.request("rubyLsp/workspace/dependencies", params, function(error, result)
      if error then
        print("Error showing deps: " .. error)
        return
      end

      local qf_list = {}
      for _, item in ipairs(result) do
        if showAll or item.dependency then
          table.insert(qf_list, {
            text = string.format("%s (%s) - %s", item.name, item.version, item.dependency),
            filename = item.path
          })
        end
      end

      vim.fn.setqflist(qf_list)
      vim.cmd('copen')
    end, bufnr)
  end,
  {nargs = "?", complete = function() return {"all"} end})
end

require("lspconfig").ruby_lsp.setup({
  on_attach = function(client, buffer)
    client.server_capabilities.semanticTokensProvider = nil
    add_ruby_deps_command(client, buffer)
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format({
        async = true,
        filter = function(client)
            return client.name == "null-ls"
        end
      })
    end, opts)
  end,
})
