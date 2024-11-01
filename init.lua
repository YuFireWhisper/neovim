--[[
  Enhanced Neovim Configuration
  Author: YuWhisper
  Last Modified: 2024-11-01
  
  This configuration provides:
  - Modern LSP support with auto-completion
  - ESLint integration
  - Proper line ending handling
  - Enhanced syntax highlighting
  - Code formatting and intelligent indentation
  - Project-aware features
--]]

-------------------
-- Core Settings
-------------------

-- Define core editor behavior
local function setup_vim_options()
  local options = {
      -- Visual Settings
      termguicolors = true,
      background = "dark",
      number = true,
      relativenumber = true,
      signcolumn = "yes",
      cursorline = true,

      -- File Handling
      fileformat = "unix",           -- Force LF line endings
      fileformats = "unix,mac,dos",  -- Priority of file formats
      
      -- Editor Behavior
      mouse = 'a',
      wrap = true,
      breakindent = true,
      showmode = false,              -- Mode is shown in status line instead
      
      -- Search Settings
      ignorecase = true,
      smartcase = true,
      hlsearch = true,
      
      -- Indentation
      tabstop = 2,
      shiftwidth = 2,
      expandtab = true,
      smartindent = true,
      autoindent = true,
      
      -- Performance
      updatetime = 250,              -- Faster completion
      timeoutlen = 300,              -- Faster key sequence completion
      
      -- Completion
      completeopt = "menu,menuone,noselect",
  }

  -- Apply options
  for key, value in pairs(options) do
      vim.opt[key] = value
  end

  -- Special handling for clipboard
  vim.opt.clipboard:append("unnamedplus")
end

-- Global variables setup
local function setup_global_vars()
  local globals = {
      mapleader = " ",
      do_filetype_lua = 1,
      did_load_filetypes = 0,
      loaded_ruby_provider = 0,
      ts_compiler = 'gcc'
  }

  for key, value in pairs(globals) do
      vim.g[key] = value
  end
end

-------------------
-- Plugin Management
-------------------

-- Ensure lazy.nvim is installed
local function ensure_lazy()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({
          "git",
          "clone",
          "--filter=blob:none",
          "https://github.com/folke/lazy.nvim.git",
          "--branch=stable",
          lazypath,
      })
  end
  vim.opt.rtp:prepend(lazypath)
end

-- Plugin specifications
local plugins = {
  -- Theme
  {
      "ellisonleao/gruvbox.nvim",
      priority = 1000,
      config = function()
          require("gruvbox").setup({
              contrast = "hard",
              transparent_mode = false,
              italic = {
                  strings = true,
                  comments = true,
                  operators = false,
                  folds = true,
              },
              bold = true,
          })
          vim.cmd.colorscheme('gruvbox')
      end,
  },

  -- LSP Configuration
  {
      'VonHeikemen/lsp-zero.nvim',
      branch = 'v2.x',
      dependencies = {
          {'neovim/nvim-lspconfig'},
          {'williamboman/mason.nvim'},
          {'williamboman/mason-lspconfig.nvim'},
          {'hrsh7th/nvim-cmp'},
          {'hrsh7th/cmp-nvim-lsp'},
          {'hrsh7th/cmp-buffer'},
          {'hrsh7th/cmp-path'},
          {'saadparwaiz1/cmp_luasnip'},
          {'hrsh7th/cmp-nvim-lua'},
          {'L3MON4D3/LuaSnip'},
          {'rafamadriz/friendly-snippets'},
      },
      config = function()
          local lsp = require('lsp-zero').preset({})
          
          -- Configure autocompletion
          local cmp = require('cmp')
          local cmp_action = require('lsp-zero').cmp_action()
          
          cmp.setup({
              sources = {
                  {name = 'nvim_lsp', priority = 1000},
                  {name = 'luasnip', priority = 750},
                  {name = 'buffer', priority = 500},
                  {name = 'path', priority = 250},
              },
              mapping = {
                  ['<CR>'] = cmp.mapping.confirm({select = false}),
                  ['<Tab>'] = cmp_action.tab_complete(),
                  ['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
                  ['<C-Space>'] = cmp.mapping.complete(),
              },
              snippet = {
                  expand = function(args)
                      require('luasnip').lsp_expand(args.body)
                  end,
              },
              window = {
                  completion = cmp.config.window.bordered(),
                  documentation = cmp.config.window.bordered(),
              },
          })

          -- Configure LSP
          lsp.on_attach(function(client, bufnr)
              lsp.default_keymaps({buffer = bufnr})
              
              -- Enhanced LSP keybindings
              local opts = {buffer = bufnr}
              vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
              vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
              vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
              vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
          end)

          lsp.setup()
      end
  },

  -- ESLint Integration
  {
      'MunifTanjim/eslint.nvim',
      dependencies = {
          'neovim/nvim-lspconfig',
          'jose-elias-alvarez/null-ls.nvim',
      },
      config = function()
          require('eslint').setup({
              bin = 'eslint',
              code_actions = {
                  enable = true,
                  apply_on_save = {
                      enable = true,
                      types = { "directive", "problem", "suggestion", "layout" },
                  },
              },
              diagnostics = {
                  enable = true,
                  report_unused_disable_directives = false,
                  run_on = "type",
              },
          })
      end
  },

  -- Enhanced Syntax Highlighting
  {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
          require("nvim-treesitter.configs").setup({
              ensure_installed = {
                  "lua", "vim", "vimdoc", "typescript", 
                  "javascript", "tsx", "json", "html", 
                  "css", "yaml",
              },
              sync_install = false,
              auto_install = true,
              highlight = {
                  enable = true,
                  additional_vim_regex_highlighting = false,
              },
              indent = { enable = true },
              incremental_selection = {
                  enable = true,
                  keymaps = {
                      init_selection = "<CR>",
                      node_incremental = "<CR>",
                      node_decremental = "<BS>",
                      scope_incremental = "<TAB>",
                  },
              },
          })
      end,
  },

  -- File Explorer
  {
      "nvim-neo-tree/neo-tree.nvim",
      dependencies = {
          "nvim-lua/plenary.nvim",
          "nvim-tree/nvim-web-devicons",
          "MunifTanjim/nui.nvim",
      },
      config = function()
          vim.keymap.set('n', '<F3>', ':Neotree toggle<CR>')
      end
  },

  -- Status Line
  {
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      config = function()
          require('lualine').setup({
              options = {
                  theme = 'gruvbox',
                  icons_enabled = true,
                  component_separators = '|',
                  section_separators = '',
              }
          })
      end
  },

  -- Enhanced TypeScript Support
  {
      "pmizio/typescript-tools.nvim",
      dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
      config = function()
          require("typescript-tools").setup({
              settings = {
                  -- Enhanced IntelliSense
                  complete_function_calls = true,
                  include_completions_with_insert_text = true,
              },
              on_attach = function(client, bufnr)
                  local opts = { buffer = bufnr }
                  vim.keymap.set("n", "<leader>rf", ":TSToolsRenameFile<CR>", opts)
                  vim.keymap.set("n", "<leader>oi", ":TSToolsOrganizeImports<CR>", opts)
                  vim.keymap.set("n", "<leader>ru", ":TSToolsRemoveUnused<CR>", opts)
              end,
          })
      end,
  },

  -- Git Integration
  {
      'lewis6991/gitsigns.nvim',
      config = function()
          require('gitsigns').setup({
              signs = {
                  add = { text = '│' },
                  change = { text = '│' },
                  delete = { text = '_' },
                  topdelete = { text = '‾' },
                  changedelete = { text = '~' },
              },
              current_line_blame = true,
          })
      end
  },
}

-- Autocommands for specific behaviors
local function setup_autocommands()
  local augroup = vim.api.nvim_create_augroup("CustomSettings", { clear = true })

  -- Ensure Unix line endings
  vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      pattern = "*",
      callback = function()
          vim.opt.fileformat = "unix"
      end,
  })

  -- TypeScript/JavaScript specific settings
  vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      pattern = {"typescript", "typescriptreact", "javascript", "javascriptreact"},
      callback = function()
          vim.opt_local.formatprg = "prettier --parser typescript"
      end,
  })

  -- Format on save
  vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      pattern = {"*.ts", "*.tsx", "*.js", "*.jsx"},
      callback = function()
          vim.lsp.buf.format({ async = false })
      end,
  })
end

-------------------
-- Initialization
-------------------

local function init()
  setup_vim_options()
  setup_global_vars()
  ensure_lazy()
  require("lazy").setup(plugins)
  setup_autocommands()
end

-- Start initialization
init()