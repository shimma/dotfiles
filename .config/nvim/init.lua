--========================================
-- PLUGINS (vim.pack)
--========================================
vim.g.mapleader = ','
vim.g.loaded_netrw = 1                    -- nvim-tree を使うので netrw は無効
vim.g.loaded_netrwPlugin = 1
vim.g.wildfire_objects = { "i'", 'i"', 'i)', 'i]', 'i}', 'it', 'ii', 'ip', 'i>' }

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

local function nvim_tree_config(opts)
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

local gh = function(repo) return 'https://github.com/' .. repo end

vim.pack.add({
  gh('scottmckendry/cyberdream.nvim'),
  gh('gcmt/wildfire.vim'),
  gh('h1mesuke/vim-alignta'),
  gh('junegunn/vim-easy-align'),
  gh('kana/vim-niceblock'),
  gh('kana/vim-operator-user'),
  gh('kana/vim-operator-replace'),
  gh('rhysd/clever-f.vim'),
  gh('t9md/vim-quickhl'),
  { src = gh('kylechui/nvim-surround'), version = vim.version.range('*') },
  gh('neovim/nvim-lspconfig'),
  gh('nvim-tree/nvim-tree.lua'),
})

require('nvim-surround').setup()
lsp_config()
nvim_tree_config({
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
})

local opt = vim.opt
local map = vim.keymap.set
local command = vim.api.nvim_create_user_command
local augroup = vim.api.nvim_create_augroup('vimrc', { clear = true })
local function autocmd(event, pattern, callback)
  vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback })
end

--========================================
-- BASE
--========================================
opt.scrolloff = 5                         -- スクロール時の余白
opt.textwidth = 0                         -- 自動折り返ししない
opt.swapfile = false
opt.formatoptions = 'lmoq'                -- テキスト整形（マルチバイト対応）
opt.whichwrap = 'b,s,h,l,<,>,[,]'         -- 行頭・行末で前後の行へ移動
opt.shada = [['50,<1000,s100,"50]]
opt.modelines = 0
opt.nrformats = 'alpha'                   -- <C-a>/<C-x> は10進数とアルファベットのみ
opt.clipboard = 'unnamed'                 -- システムのクリップボードを使う
opt.shortmess:append('I')                 -- 起動画面を出さない
opt.mouse = 'a'

opt.termguicolors = true
vim.cmd.colorscheme('cyberdream')
vim.env.TODAY = os.date('%Y%m%d')

command('Ev', 'edit $MYVIMRC', {})
command('Rv', 'source $MYVIMRC', {})

-- :CD でカレントファイルのディレクトリへ lcd（! で pwd 表示なし）
command('CD', function(o)
  vim.cmd.lcd(o.args ~= '' and o.args or vim.fn.expand('%:p:h'))
  if not o.bang then
    vim.cmd.pwd()
  end
end, { nargs = '?', complete = 'dir', bang = true })

--========================================
-- FILETYPE
--========================================
autocmd({ 'BufNewFile', 'BufRead' }, '*.twig', function() vim.bo.syntax = 'html' end)
vim.g.html_indent_inctags = 'html,body,head,tbody'

--========================================
-- COMPLETION
--========================================
opt.wildchar = 9                          -- <Tab>
opt.wildmode = 'list:full'
opt.complete:append('k')                  -- 辞書ファイルも補完対象
-- コマンドラインの <C-p>/<C-n> は入力済みの文字で履歴を絞り込む
map('c', '<C-p>', '<Up>')
map('c', '<Up>', '<C-p>')
map('c', '<C-n>', '<Down>')
map('c', '<Down>', '<C-n>')

--========================================
-- SEARCH
--========================================
opt.ignorecase = true
opt.smartcase = true                      -- 大文字を含むときは区別する
map('n', '<Esc><Esc>', '<Cmd>nohlsearch<CR>')
map('n', '<C-j>', '<Cmd>nohlsearch<CR>')

--========================================
-- TAGS
--========================================
opt.tags = './tags;,tags,./*/tags'        -- 上位ディレクトリへ遡って探す
opt.tagbsearch = false
map('n', 't', '<Nop>')
map('n', 'T', '<C-]>')
map('n', 'tt', ':<C-u>pop<CR>')
map('n', 'tj', ':<C-u>tag<CR>')
map('n', 'tl', ':<C-u>tags<CR>')

--========================================
-- VIEW
--========================================
opt.showmatch = true
opt.number = true
opt.list = true
opt.listchars = { tab = '>.', trail = '_', extends = '>', precedes = '<' }
opt.display = 'uhex'                      -- 印字不可能文字を16進数で表示
opt.foldmethod = 'marker'
opt.cursorline = true
opt.statusline = '%F%m%r%h%w'

-- 全角スペースを可視化
vim.api.nvim_set_hl(0, 'ZenkakuSpace', { underline = true, ctermfg = 'lightblue', bg = 'darkgray' })
vim.fn.matchadd('ZenkakuSpace', '　')

--========================================
-- EDIT
--========================================
opt.expandtab = true
opt.virtualedit:append('block')           -- 矩形選択で文字がない所にも移動

map('i', 'jj', '<Esc>')
map('i', '<C-j>', '<Esc>')
map('v', '<C-j>', '<Esc>')

map('n', ';', ':')
map('n', 'Y', 'y$')
map('n', '<Space>w', '<Cmd>w<CR>')
map('n', '<Space>q', '<Cmd>q!<CR>')
map('n', '`', '<Cmd>qa!<CR>')
map('n', '<Space>s', '/')
map('n', '<Space>S', ':%s!')
map('n', '<Space>e', '<Cmd>e!<CR>', { silent = true })
map('n', '<Space>cd', '<Cmd>CD<CR>', { silent = true })
command('Pt', 'set paste!', {})

-- 行末の空白を削除
command('Rd', function()
  local view = vim.fn.winsaveview()
  vim.cmd([[keeppatterns %s/\s\+$//ge]])
  vim.fn.winrestview(view)
end, {})
map('n', '<Space>r', '<Cmd>Rd<CR>', { silent = true })

-- 日時の挿入
map('i', ',df', function() return os.date('%Y/%m/%d %H:%M:%S') end, { expr = true })
map('i', ',dd', function() return os.date('%Y/%m/%d (%a)') end, { expr = true })
map('i', ',dt', function() return os.date('%H:%M:%S') end, { expr = true })

map('ia', 'dk', '========================================')
map('ia', 'dj', '------------------------------')

-- ファイルパスをヤンク（相対 / 絶対）
map('n', 'yr', function() vim.fn.setreg('*', vim.fn.expand('%')) end)
map('n', 'yp', function() vim.fn.setreg('*', vim.fn.expand('%:p')) end)

-- quickfix を q / ESC で閉じる
autocmd('FileType', 'qf', function()
  map('n', 'q', '<Cmd>cclose<CR>', { buffer = true })
  map('n', '<Esc>', '<Cmd>cclose<CR>', { buffer = true })
end)

map('', '<Leader>h', '<Cmd>set ft=html<CR>')
map('', '<Leader>p', '<Cmd>set ft=php<CR>')

--========================================
-- BUFFER / WINDOW / TAB
--========================================
map('n', '<C-n>', '<Cmd>bn<CR>')
map('n', '<C-p>', '<Cmd>bp<CR>')
map('n', '<C-w><C-w>', '<Cmd>wincmd =<CR>')
map('n', '<BS>', '<C-w>h')
map('n', '<C-h>', '<C-w>h')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')
map('n', '<Space>t', '<Cmd>tabnew<CR>')
map('n', '<Space>n', 'gt')
map('n', '<Space>p', 'gT')

--========================================
-- INDENT
--========================================
opt.smartindent = true
opt.cindent = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 0

local function indent(width, extra)
  return function()
    vim.bo.shiftwidth, vim.bo.softtabstop, vim.bo.tabstop = width, width, width
    vim.bo.expandtab = true
    if extra then extra() end
  end
end
autocmd('FileType', { 'css', 'html', 'javascript', 'ruby', 'haml', 'vim', 'yaml', 'scala', 'lua' }, indent(2))
autocmd('FileType', {
  'apache', 'aspvbs', 'c', 'cpp', 'cs', 'diff', 'eruby', 'java', 'perl', 'php',
  'python', 'sh', 'sql', 'vb', 'wsh', 'xhtml', 'xml', 'zsh',
}, indent(4))
autocmd('FileType', 'go', indent(4, function()
  vim.bo.expandtab = false
  vim.wo.list = false
end))

--========================================
-- MOVE
--========================================
map('n', '<Space>h', '^')
map('n', '<Space>l', '$')
map('n', '(', '%')
map('n', ')', '%')
map('v', 'v', '$h')

-- 前回終了時のカーソル位置に戻る
autocmd('BufReadPost', '*', function()
  local line = vim.fn.line([['"]])
  if line > 0 and line <= vim.fn.line('$') then
    vim.cmd([[normal! g`"]])
  end
end)

--========================================
-- ENCODING
--========================================
opt.fileformats = 'unix,dos,mac'
opt.fileencodings = 'utf-8,iso-2022-jp,euc-jp,sjis'
autocmd('FileType', { 'css', 'html', 'xml', 'java', 'scala' }, function() vim.bo.fileencoding = 'utf-8' end)
opt.suffixes = '.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc'

-- 文字コードを指定して開き直す
command('Cp932', 'edit ++enc=cp932', {})
command('Eucjp', 'edit ++enc=euc-jp', {})
command('Iso2022jp', 'edit ++enc=iso-2022-jp', {})
command('Utf8', 'edit ++enc=utf-8', {})
command('Jis', 'Iso2022jp', {})
command('Sjis', 'Cp932', {})

--========================================
-- PLUGIN SETTINGS
--========================================
-- NERDTree 互換（nvim-tree: PLUGINS 参照）
map('n', '<Leader>N', '<Cmd>CD<CR><Cmd>NERDTree<CR>', { silent = true })
map('n', '<Leader>n', '<Cmd>NERDTreeToggle<CR>', { silent = true })
map('n', '<C-e>', '<Cmd>NERDTreeToggle<CR>', { silent = true })

-- コメント（Neovim 組み込みの gc）
map('n', '<Leader>x', 'gcc', { remap = true })
map('x', '<Leader>x', 'gc', { remap = true })
map('n', '<Leader>c<Space>', 'gcc', { remap = true })
map('x', '<Leader>c<Space>', 'gc', { remap = true })

-- 診断（LSP）
map('n', '<Leader>e', vim.diagnostic.open_float, { silent = true })

-- easy-align / alignta
map('v', 'E', '<Plug>(EasyAlign)')
map('v', '<Space>', '<Plug>(EasyAlign)')
map('v', 'a', ':Alignta ')

-- operator-replace
map('', 'R', '<Plug>(operator-replace)')

-- quickhl
map({ 'n', 'x' }, '<Space>m', '<Plug>(quickhl-manual-this)')
map({ 'n', 'x' }, '<Space>M', '<Plug>(quickhl-manual-reset)')
