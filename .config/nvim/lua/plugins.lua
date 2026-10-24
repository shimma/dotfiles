-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath })
  if vim.v.shell_error ~= 0 then
    error('Failed to clone lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

--------------------------------
-- nvim-tree (NERDTree互換)
--------------------------------
local function nvim_tree_on_attach(bufnr)
  local api = require('nvim-tree.api')
  api.config.mappings.default_on_attach(bufnr)
  pcall(vim.keymap.del, 'n', 'm', { buffer = bufnr }) -- ma/mm/md 用に空ける

  local function map(lhs, fn, desc)
    vim.keymap.set('n', lhs, fn, { buffer = bufnr, silent = true, nowait = true, desc = 'nerdtree: ' .. desc })
  end
  local function keep_focus(fn)
    return function() fn(); api.tree.focus() end
  end
  local function node_dir()
    local node = api.tree.get_node_under_cursor()
    if node.type == 'directory' then return node.absolute_path end
    return vim.fn.fnamemodify(node.absolute_path, ':h')
  end

  map('o',    api.node.open.edit, 'Open')
  map('<CR>', api.node.open.edit, 'Open')
  map('go',   api.node.open.preview, 'Preview')
  map('t',    api.node.open.tab, 'Open in new tab')
  map('i',    api.node.open.horizontal, 'Open in split')
  map('gi',   keep_focus(api.node.open.horizontal), 'Preview in split')
  map('s',    api.node.open.vertical, 'Open in vsplit')
  map('gs',   keep_focus(api.node.open.vertical), 'Preview in vsplit')
  map('O',    api.tree.expand_all, 'Expand all')
  map('x',    api.node.navigate.parent_close, 'Close parent')
  map('X',    api.tree.collapse_all, 'Collapse all')
  map('p',    api.node.navigate.parent, 'Go to parent')
  map('P',    function() vim.cmd('normal! gg') end, 'Go to root')
  map('K',    api.node.navigate.sibling.first, 'First sibling')
  map('J',    api.node.navigate.sibling.last, 'Last sibling')
  map('C',    api.tree.change_root_to_node, 'Change root to node')
  map('u',    api.tree.change_root_to_parent, 'Root up')
  map('r',    api.tree.reload, 'Refresh')
  map('R',    api.tree.reload, 'Refresh')
  map('I',    api.tree.toggle_hidden_filter, 'Toggle hidden')
  map('q',    api.tree.close, 'Close')
  map('?',    api.tree.toggle_help, 'Help')
  map('cd',   function() vim.cmd.cd(node_dir()) end, 'cd to node')
  map('CD',   function() api.tree.change_root(vim.fn.getcwd()) end, 'Root to cwd')
  -- NERDTree の m メニュー相当
  map('ma',   api.fs.create, 'Add')
  map('mm',   api.fs.rename_full, 'Move/Rename')
  map('md',   api.fs.remove, 'Delete')
  map('mc',   api.fs.copy.node, 'Copy')
  map('mp',   api.fs.paste, 'Paste')
  -- 旧 nerdtree_plugin/call_finder.vim
  map('fd', function()
    vim.system({ 'open', api.tree.get_node_under_cursor().absolute_path })
  end, 'Call Finder')
  -- 旧 nerdtree_plugin/toggle_width.vim
  map('w', function()
    local maxi = 0
    for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
      maxi = math.max(maxi, vim.fn.strdisplaywidth(line))
    end
    api.tree.resize({ absolute = maxi == vim.fn.winwidth(0) and 22 or maxi })
  end, 'Toggle window width')
end

local function nvim_tree_config(_, opts)
  require('nvim-tree').setup(opts)
  local api = require('nvim-tree.api')

  local function open(o)
    local path = o.args ~= '' and vim.fn.fnamemodify(o.args, ':p') or vim.fn.getcwd()
    api.tree.open({ path = path })
    api.tree.change_root(path)
  end
  vim.api.nvim_create_user_command('NERDTree', open, { nargs = '?', complete = 'dir' })
  vim.api.nvim_create_user_command('NERDTreeToggle', function() api.tree.toggle() end, {})
  vim.api.nvim_create_user_command('NERDTreeFind', function() api.tree.find_file({ open = true, focus = true }) end, {})
  vim.api.nvim_create_user_command('NERDTreeFocus', function() api.tree.focus() end, {})
  vim.api.nvim_create_user_command('NERDTreeClose', function() api.tree.close() end, {})

  -- ツリーだけ残ったら終了
  vim.api.nvim_create_autocmd('BufEnter', {
    nested = true,
    callback = function()
      if #vim.api.nvim_list_wins() == 1 and vim.bo.filetype == 'NvimTree' then
        vim.cmd('quit')
      end
    end,
  })
end

--------------------------------
-- LSP (syntastic の代わり)
--------------------------------
local function lsp_config()
  local servers = {
    gopls = 'gopls',
    intelephense = 'intelephense',
    ruby_lsp = 'ruby-lsp',
    bashls = 'bash-language-server',
  }
  for name, bin in pairs(servers) do
    if vim.fn.executable(bin) == 1 then
      vim.lsp.enable(name)
    end
  end
  vim.diagnostic.config({
    virtual_text = true,
    severity_sort = true,
    float = { border = 'rounded' },
  })
end

require('lazy').setup({
  spec = {
    { 'folke/tokyonight.nvim', lazy = false, priority = 1000 },
    { 'gcmt/wildfire.vim' },
    { 'h1mesuke/vim-alignta', cmd = 'Alignta' },
    { 'junegunn/vim-easy-align' },
    { 'kana/vim-niceblock' },
    { 'kana/vim-operator-replace', dependencies = { 'kana/vim-operator-user' } },
    { 'rhysd/clever-f.vim' },
    { 't9md/vim-quickhl' },
    { 'kylechui/nvim-surround', version = '*', event = 'VeryLazy', opts = {} },
    { 'neovim/nvim-lspconfig', config = lsp_config },
    {
      'nvim-tree/nvim-tree.lua',
      lazy = false,
      config = nvim_tree_config,
      opts = {
        on_attach = nvim_tree_on_attach,
        view = { width = 22 },
        git = { enable = false },
        filters = { dotfiles = true, git_ignored = false },
        renderer = {
          icons = {
            show = { file = false, folder = false, folder_arrow = true, git = false },
            glyphs = { folder = { arrow_closed = '▸', arrow_open = '▾' } },
          },
        },
      },
    },
  },
  install = { colorscheme = { 'tokyonight', 'habamax' } },
  rocks = { enabled = false },
  change_detection = { notify = false },
})
