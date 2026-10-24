"========================================
" PLUGINS (lazy.nvim: lua/plugins.lua)
"========================================
let mapleader = ","
let g:loaded_netrw = 1                    " nvim-tree を使うので netrw は無効
let g:loaded_netrwPlugin = 1
let g:wildfire_objects = ["i'", 'i"', 'i)', 'i]', 'i}', 'it', 'ii', 'ip', 'i>']
lua require('plugins')

augroup vimrc
  autocmd!
augroup END

"========================================
" BASE
"========================================
set scrolloff=5                           " スクロール時の余白
set textwidth=0                           " 自動折り返ししない
set noswapfile
set formatoptions=lmoq                    " テキスト整形（マルチバイト対応）
set whichwrap=b,s,h,l,<,>,[,]             " 行頭・行末で前後の行へ移動
set shada='50,<1000,s100,\"50
set modelines=0
set nrformats=alpha                       " <C-a>/<C-x> は10進数とアルファベットのみ
set clipboard=unnamed                     " システムのクリップボードを使う
set shortmess+=I                          " 起動画面を出さない
set mouse=a

set termguicolors
colorscheme cyberdream
let $TODAY = strftime('%Y%m%d')

command! Ev edit $MYVIMRC
command! Rv source $MYVIMRC

" :CD でカレントファイルのディレクトリへ lcd（! で pwd 表示なし）
command! -nargs=? -complete=dir -bang CD call s:ChangeCurrentDir('<args>', '<bang>')
function! s:ChangeCurrentDir(directory, bang)
  if a:directory == ''
    lcd %:p:h
  else
    execute 'lcd' . a:directory
  endif
  if a:bang == ''
    pwd
  endif
endfunction

"========================================
" FILETYPE
"========================================
autocmd vimrc BufNewFile,BufRead *.twig set syntax=html
let g:html_indent_inctags = "html,body,head,tbody"

"========================================
" COMPLETION
"========================================
set wildchar=<tab>
set wildmode=list:full
set complete+=k                           " 辞書ファイルも補完対象
" コマンドラインの <C-p>/<C-n> は入力済みの文字で履歴を絞り込む
cnoremap <C-p> <Up>
cnoremap <Up>  <C-p>
cnoremap <C-n> <Down>
cnoremap <Down> <C-n>

"========================================
" SEARCH
"========================================
set ignorecase
set smartcase                             " 大文字を含むときは区別する
nmap <ESC><ESC> :nohlsearch<CR><ESC>
nnoremap <C-j> :nohlsearch<CR><ESC>

"========================================
" TAGS
"========================================
set tags=./tags;,tags,./*/tags            " 上位ディレクトリへ遡って探す
set notagbsearch
nnoremap t  <Nop>
nnoremap T  <C-]>
nnoremap tt :<C-u>pop<CR>
nnoremap tj :<C-u>tag<CR>
nnoremap tl :<C-u>tags<CR>

"========================================
" VIEW
"========================================
set showmatch
set number
set list
set listchars=tab:>.,trail:_,extends:>,precedes:<
set display=uhex                          " 印字不可能文字を16進数で表示
set foldmethod=marker
set cursorline
set statusline=%F%m%r%h%w

" 全角スペースを可視化
highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=darkgray
match ZenkakuSpace /　/

"========================================
" EDIT
"========================================
set expandtab
set virtualedit+=block                    " 矩形選択で文字がない所にも移動

inoremap jj <Esc>
inoremap <C-j> <Esc>
vnoremap <C-j> <Esc>

nnoremap ; :
nnoremap Y y$
nnoremap <Space>w :w<CR>
nnoremap <Space>q :q!<CR>
nnoremap ` :qa!<CR>
nnoremap <Space>s /
nnoremap <Space>S :%s!
nnoremap <silent> <Space>e :e!<CR>
nnoremap <silent> <Space>cd :CD<CR>
command! Pt set paste!

" 行末の空白を削除
function! s:remove_dust()
  let cursor = getpos(".")
  %s/\s\+$//ge
  call setpos(".", cursor)
endfunction
command! Rd call s:remove_dust()
nnoremap <silent> <Space>r :Rd<CR>

" 日時の挿入
inoremap <expr> ,df strftime('%Y/%m/%d %H:%M:%S')
inoremap <expr> ,dd strftime('%Y/%m/%d (%a)')
inoremap <expr> ,dt strftime('%H:%M:%S')

inoreabbrev dk ========================================
inoreabbrev dj ------------------------------

" ファイルパスをヤンク（相対 / 絶対）
nnoremap yr :let @*=expand("%")<CR>
nnoremap yp :let @*=expand("%:p")<CR>

" quickfix を q / ESC で閉じる
autocmd vimrc FileType qf nnoremap <buffer> q :ccl<CR>
autocmd vimrc FileType qf nnoremap <buffer> <ESC> :ccl<CR>

map <leader>h :set ft=html<CR>
map <leader>p :set ft=php<CR>

"========================================
" BUFFER / WINDOW / TAB
"========================================
nnoremap <C-n> :bn<CR>
nnoremap <C-p> :bp<CR>
nnoremap <C-w><C-w> :wincmd =<CR>
nnoremap <BS> <C-w>h
nnoremap <C-h> <C-w>h
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <Space>t :tabnew<CR>
nnoremap <Space>n gt
nnoremap <Space>p gT

"========================================
" INDENT
"========================================
set smartindent
set cindent
set tabstop=2 shiftwidth=2 softtabstop=0

autocmd vimrc FileType css,html,javascript,ruby,haml,vim,yaml,scala
      \ setlocal sw=2 sts=2 ts=2 et
autocmd vimrc FileType apache,aspvbs,c,cpp,cs,diff,eruby,java,perl,php,python,sh,sql,vb,wsh,xhtml,xml,zsh
      \ setlocal sw=4 sts=4 ts=4 et
autocmd vimrc FileType go setlocal sw=4 sts=4 ts=4 noet nolist

"========================================
" MOVE
"========================================
nnoremap <Space>h ^
nnoremap <Space>l $
nnoremap ( %
nnoremap ) %
vnoremap v $h

" 前回終了時のカーソル位置に戻る
autocmd vimrc BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif

"========================================
" ENCODING
"========================================
set fileformats=unix,dos,mac
set fileencodings=utf-8,iso-2022-jp,euc-jp,sjis
autocmd vimrc FileType css,html,xml,java,scala setlocal fileencoding=utf-8
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc

" 文字コードを指定して開き直す
command! Cp932 edit ++enc=cp932
command! Eucjp edit ++enc=euc-jp
command! Iso2022jp edit ++enc=iso-2022-jp
command! Utf8 edit ++enc=utf-8
command! Jis Iso2022jp
command! Sjis Cp932

"========================================
" PLUGIN SETTINGS
"========================================
" NERDTree 互換（nvim-tree: lua/plugins.lua）
nnoremap <silent> <Leader>N :CD<CR>:NERDTree<CR>
nnoremap <silent> <Leader>n :NERDTreeToggle<CR>
nnoremap <silent> <C-e> :NERDTreeToggle<CR>

" コメント（Neovim 組み込みの gc）
nmap <Leader>x gcc
xmap <Leader>x gc
nmap <Leader>c<Space> gcc
xmap <Leader>c<Space> gc

" 診断（LSP）
nnoremap <silent> <Leader>e :lua vim.diagnostic.open_float()<CR>

" easy-align / alignta
vmap E <Plug>(EasyAlign)
vmap <Space> <Plug>(EasyAlign)
vmap a :Alignta

" operator-replace
map R <Plug>(operator-replace)

" quickhl
nmap <Space>m <Plug>(quickhl-manual-this)
xmap <Space>m <Plug>(quickhl-manual-this)
nmap <Space>M <Plug>(quickhl-manual-reset)
xmap <Space>M <Plug>(quickhl-manual-reset)
