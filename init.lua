-- init.lua
-- Author: YuWhisper
-- Last Modified: 2024-11-01
-- Description: Neovim configuration with LSP support and modern features

-------------------
-- Global Settings
-------------------

-- Core vim options
local function setup_vim_options()
  local options = {
      termguicolors = true,
      background = "dark",
      number = true,
      relativenumber = true,
      mouse = 'a',
      ignorecase = true,
      smartcase = true,
      hlsearch = true,
      wrap = true,
      breakindent = true,
      tabstop = 2,
      shiftwidth = 2,
      expandtab = true,
      signcolumn = "yes",
      smartindent = true,
      autoindent = true,
      cindent = true
  }

  -- Apply options
  for key, value in pairs(options) do
      vim.opt[key] = value
  end

  -- Special handling for clipboard
  vim.opt.clipboard:append("unnamedplus")
end

-- Global variables
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

-- Initialize lazy.nvim
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
local function get_plugins()
  return {
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
                  improved_strings = true,
                  improved_warnings = true,
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
              
              -- Default LSP attachments
              lsp.on_attach(function(client, bufnr)
                  lsp.default_keymaps({buffer = bufnr})
              end)

              -- LSP Setup
              require('lspconfig').ts_ls.setup({
                  settings = {
                      typescript = {
                          inlayHints = {
                              includeInlayParameterNameHints = 'all',
                              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                              includeInlayFunctionParameterTypeHints = true,
                              includeInlayVariableTypeHints = true,
                              includeInlayPropertyDeclarationTypeHints = true,
                              includeInlayFunctionLikeReturnTypeHints = true,
                              includeInlayEnumMemberValueHints = true,
                          }
                      },
                      javascript = {
                          inlayHints = {
                              includeInlayParameterNameHints = 'all',
                              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                              includeInlayFunctionParameterTypeHints = true,
                              includeInlayVariableTypeHints = true,
                              includeInlayPropertyDeclarationTypeHints = true,
                              includeInlayFunctionLikeReturnTypeHints = true,
                              includeInlayEnumMemberValueHints = true,
                          }
                      }
                  }
              })

              lsp.setup()

              -- Completion setup
              local cmp = require('cmp')
              local cmp_action = require('lsp-zero').cmp_action()

              cmp.setup({
                  mapping = {
                      ['<CR>'] = cmp.mapping.confirm({select = false}),
                      ['<Tab>'] = cmp_action.tab_complete(),
                      ['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
                  }
              })
          end
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
                      icons_enabled = true
                  }
              })
          end
      },

      -- Syntax Highlighting
      {
          "nvim-treesitter/nvim-treesitter",
          build = ":TSUpdate",
          config = function()
              require("nvim-treesitter.install").prefer_git = false
              require("nvim-treesitter.install").compilers = { "gcc" }
              vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/treesitter-parser")

              require("nvim-treesitter.configs").setup({
                  ensure_installed = {
                      "lua", "vim", "vimdoc", "typescript", 
                      "javascript", "tsx", "json", "html", 
                      "css", "yaml",
                  },      
                  sync_install = true,
                  auto_install = false,
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

      -- Indentation Guidelines
      {
          "lukas-reineke/indent-blankline.nvim",
          main = "ibl",
          opts = {},
          config = function()
              require("ibl").setup({
                  indent = { char = "│" },
                  scope = {
                      enabled = true,
                      show_start = true,
                      show_end = true,
                  },
              })
          end,
      },

      -- TypeScript Enhanced Support
      {
          "pmizio/typescript-tools.nvim",
          dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
          config = function()
              require("typescript-tools").setup({
                  on_attach = function(client, bufnr)
                      -- Define keymaps for TypeScript-specific features
                      local opts = { buffer = bufnr }
                      vim.keymap.set("n", "<leader>rf", ":TSToolsRenameFile<CR>", opts)
                      vim.keymap.set("n", "<leader>oi", ":TSToolsOrganizeImports<CR>", opts)
                      vim.keymap.set("n", "<leader>ru", ":TSToolsRemoveUnused<CR>", opts)
                  end,
              })
          end,
      },
  }
end

-- File type specific settings
local function setup_filetype_settings()
  vim.api.nvim_create_autocmd("FileType", {
      pattern = {"typescript", "typescriptreact"},
      callback = function()
          vim.opt_local.formatprg = "prettier --parser typescript"
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
  require("lazy").setup(get_plugins())
  setup_filetype_settings()
end

-- Start initialization
init()
