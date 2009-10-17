"------------------------------------------------------------------------------
" 初期設定
"
set nocompatible
set shortmess+=I           " 起動時のメッセージを消す
set autoread               " 他で書き換えられたら自動で読み直す
set number
set nowrap
set textwidth=0            " 自動折り返しなし
set backspace=indent,eol,start  " backspace でなんでも消せるように
set formatoptions=lmoq     " テキスト整形オプション、マルチバイト系を追加
set formatoptions+=m       " テキスト挿入中の自動折り返しを日本語に対応させる
let format_allow_over_tw = 1
                           " ぶら下がり可能幅（日本語整形スクリプト）
set hidden                 " 編集中でも他のファイルを開けるようにする
set scrolloff=5
set visualbell t_vb=

"------------------------------------------------------------------------------
" キーマップ
"
nnoremap j gj
nnoremap k gk
" JとKでカーソルキーを中心に保ったままスクロール
nnoremap J gjzz
nnoremap K gkzz
" emacs like key-map
" コマンド入力時
cmap <C-a> <Home>
cmap <C-e> <End>
" 挿入モード
imap <C-a> <Home>
imap <C-e> <End>
imap <C-f> <Right>
imap <C-b> <Left>
imap <C-d> <Del>

"------------------------------------------------------------------------------
" ファイルブラウザ
"   http://www15.ocn.ne.jp/~tusr/vim/vim_text2.html
"
" 開いているファイルのディレクトリをカレントディレクトリにする
autocmd BufEnter * execute ":lcd" . expand("%:p:h")

set browsedir=last         " 前回にファイルブラウザを使ったディレクトリ
set browsedir=buffer       " バッファで開いているファイルのディレクトリ
set browsedir=current      " カレントディレクトリ

"------------------------------------------------------------------------------
" バックアップ & スワップファイル
"
set backupdir=~/vimbackup
set directory=~/vimbackup

"------------------------------------------------------------------------------
" システムのクリップボードとの共有
"    http://d.hatena.ne.jp/akio0911/20080322/1206197733
"
nmap _ :.w !nkf -Ws\|pbcopy<CR><CR>
vmap _ :w !nkf -Ws\|pbcopy<CR><CR>
nmap - :set paste<CR>:r !pbpaste\|nkf -Sw<CR>:set nopaste<CR>

"------------------------------------------------------------------------------
" インデント & タブ
"
"set autoindent
set smartindent
set smarttab
set expandtab

filetype indent on         " ファイルタイプによるインデント
filetype plugin on         " ファイルタイプごとのプラグイン

set tabstop=4 shiftwidth=4 softtabstop=0
" 2spaces soft tab filetype
autocmd FileType html,xhtml,ruby setlocal tabstop=2 softtabstop=2 shiftwidth=2

"------------------------------------------------------------------------------
" C programing
"
set cinoptions=:0,p0,t0
set cinwords=if,else,while,do,for,switch,case
set formatoptions=tcqr
set cindent

"------------------------------------------------------------------------------
" html
"
autocmd! BufRead,BufNewFile *.html set filetype=php

"------------------------------------------------------------------------------
" 補完・履歴
"
set wildmenu               " コマンド補完を強化
set wildchar=<tab>         " コマンド補完を開始するキー
set wildmode=list:full     " リスト表示、最長マッチ
set showcmd                " コマンドをステータス行に表示
set statusline=%<%F\ %r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%4v(ASCII=%03.3b,HEX=%02.2B)\ %l/%L(%P)%m
                           " ステータス行に文字コードと改行文字を表示
set history=1000
set complete+=k            " 補完に辞書ファイルを追加

" Insert mode 補完の設定
"   http://vim-users.jp/2009/05/hack9/
"
set completeopt=menuone
set infercase
set showfulltag
set omnifunc

" neocomplcache との補完関係
"  http://github.com/Shougo/neocomplcache/blob/master/presen/neocomplcache.txt
"
" <TAB> completion.
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
" C-j でオムニ補完（filetypeがVimの時には、Vim commands completionを機動）
inoremap <expr> <C-j> &filetype == 'vim' ? "\<C-x>\<C-v>\<C-p>" : "\<C-x>\<C-o>\<C-p>"
" C-k を押すと行末まで削除
inoremap <C-k> <C-o>D
" C-h で補完を続行しない（一度ポップアップを消去し、ちらつかないように）
inoremap <expr><C-h> pumvisible() ? "\<C-y>\<C-h>" : "\<C-h>"
" C-n で neocomplcache 補完（デバッグや、重すぎて候補が表示されないときに）
inoremap <expr><C-n> pumvisible() ? "\<C-n>" : "\<C-x>\<C-u>\<C-p>"
" C-p で keyword 補完（Vim標準のキーワード補完。比較のために）
inoremap <expr><C-p> pumvisible() ? "\<C-p>" : "\<C-p>\<C-n>"
" 途中で Enter したとき、ポップアップを消して改行し、
" 改行を連続して入力してもインデント部を保持する
inoremap <expr><CR> pumvisible() ? "\<C-y>\<CR>X\<BS>" : "\<CR>X\<BS>"

"------------------------------------------------------------------------------
" 検索
"
set nowrapscan
set ignorecase             " 大文字小文字を無視
set smartcase              " 大文字で始めたら無視しない
set incsearch
vnoremap <silent> // y/<C-R>=escape(@", '\\/.*$^~[]')<CR><CR>
                           " 選択した文字列を検索
vnoremap /r "xy:%s/<C-R>=escape(@x, '\\/.*$^~[]')<CR>//gc<Left><Left><Left>
                           " 選択した文字列を置換

" 検索語が画面の真ん中に来るようにする
"   http://www.kawaz.jp/pukiwiki/?vim
nmap n nzz
nmap N Nzz
nmap * *zz
nmap # #zz
nmap g* g*zz
nmap g# g#zz

" esc 連打で検索ハイライトを消す
set hlsearch
nmap <Esc><Esc> :nohlsearch<CR><Esc>

"------------------------------------------------------------------------------
" エンコード
"
set enc=utf-8
set fenc=utf-8
set fencs=iso-2022-jp,enc-jp,cp932

" 改行文字
set ffs=unix,dos,mac

" デフォルトエンコーディング
set   encoding=utf-8
if has('win32') && has('kaoriya')
  set   ambiwidth=auto
else
  set   ambiwidth=double
endif
if has('iconv')
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'
  if iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'euc-jisx0213,euc-jp'
    let s:enc_jis = 'iso-2022-jp-3'
  endif
  set   fileencodings&
  let &fileencodings = &fileencodings.','.s:enc_jis.',cp932,'.s:enc_euc
  unlet s:enc_euc
  unlet s:enc_jis
endif
if has('win32unix')
  set   termencoding=cp932
elseif !has('macunix')
  set   termencoding=euc-jp
endif

" 文字コードの自動認識
"   http://www.kawaz.jp/pukiwiki/?vim
if &encoding !=# 'utf-8'
  set encoding=japan
  set fileencoding=japan
endif
if has('iconv')
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'
  " iconvがeucJP-msに対応しているかをチェック
  if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'eucjp-ms'
    let s:enc_jis = 'iso-2022-jp-3'
  " iconvがJISX0213に対応しているかをチェック
  elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'euc-jisx0213'
    let s:enc_jis = 'iso-2022-jp-3'
  endif
  " fileencodingsを構築
  if &encoding ==# 'utf-8'
    let s:fileencodings_default = &fileencodings
    let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
    let &fileencodings = &fileencodings .','. s:fileencodings_default
    unlet s:fileencodings_default
  else
    let &fileencodings = &fileencodings .','. s:enc_jis
    set fileencodings+=utf-8,ucs-2le,ucs-2
    if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
      set fileencodings+=cp932
      set fileencodings-=euc-jp
      set fileencodings-=euc-jisx0213
      set fileencodings-=eucjp-ms
      let &encoding = s:enc_euc
      let &fileencoding = s:enc_euc
    else
      let &fileencodings = &fileencodings .','. s:enc_euc
    endif
  endif
  " 定数を処分
  unlet s:enc_euc
  unlet s:enc_jis
endif
" 日本語を含まない場合は fileencoding に encoding を使うようにする
if has('autocmd')
  function! AU_ReCheck_FENC()
    if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
      let &fileencoding=&encoding
    endif
  endfunction
  autocmd BufReadPost * call AU_ReCheck_FENC()
endif
" 改行コードの自動認識
set fileformats=unix,dos,mac
" □とか○の文字があってもカーソル位置がずれないようにする
if exists('&ambiwidth')
  set ambiwidth=double
endif

"==============================================================================
" plugin
"==============================================================================

"------------------------------------------------------------------------------
" surround.vim
"   http://d.hatena.ne.jp/secondlife/20061225/1167032528
"
let g:surround_103 = "_('\r')"  " 103 = g
let g:surround_71 = "_(\"\r\")" "  71 = G

" http://webtech-walker.com/archive/2009/02/08031540.html
"
" 1 : <h1>|</h1>
" 2 : <h2>|</h2>
" 3 : <h3>|</h3>
" 4 : <h4>|</h4>
" 5 : <h5>|</h5>
" 6 : <h6>|</h6>
"
" p : <p>|</p>
" u : <ul>|</ul>
" o : <ol>|</ol>
" l : <li>|</li>
" a : <a href="">|</a>
" A : <a href="|"></a>
" i : <img src="|" alt="" />
" I : <img src="" alt"|" />
" d : <div>|</div>
" D : <div class="section">|</div>

autocmd FileType html let b:surround_49  = "<h1>\r</h1>"
autocmd FileType html let b:surround_50  = "<h2>\r</h2>"
autocmd FileType html let b:surround_51  = "<h3>\r</h3>"
autocmd FileType html let b:surround_52  = "<h4>\r</h4>"
autocmd FileType html let b:surround_53  = "<h5>\r</h5>"
autocmd FileType html let b:surround_54  = "<h6>\r</h6>"

autocmd FileType html let b:surround_112 = "<p>\r</p>"
autocmd FileType html let b:surround_117 = "<ul>\r</ul>"
autocmd FileType html let b:surround_111 = "<ol>\r</ol>"
autocmd FileType html let b:surround_108 = "<li>\r</li>"
autocmd FileType html let b:surround_97  = "<a href=\"\">\r</a>"
autocmd FileType html let b:surround_65  = "<a href=\"\r\"></a>"
autocmd FileType html let b:surround_105 = "<img src=\"\r\" alt=\"\" />"
autocmd FileType html let b:surround_73  = "<img src=\"\" alt=\"\r\" />"
autocmd FileType html let b:surround_100 = "<div>\r</div>"
autocmd FileType html let b:surround_68  = "<div class=\"section\">\r</div>"

"------------------------------------------------------------------------------
" neocomplcache.vim
"   http://github.com/Shougo/neocomplcache/blob/master/presen/neocomplcache.txt
"
let g:AutoComplPop_NotEnableAtStartup = 1
let g:NeoComplCache_EnableAtStartup = 1
let &statusline = '%=%m%y%{"[".(&fenc!=""?&fenc:&enc).",".&ff."]"}%{"[".neocomplcache#keyword_complete#caching_percent("")."%]"} %3l,%3c %3p%%'
let g:NeoComplCache_SmartCase = 1
let g:NeoComplCache_EnableMFU = 1
let g:NeoComplCache_PreviousKeywordCompletion = 1
let g:NeoComplCache_TagsAutoUpdate = 1
let g:NeoComplCache_TryKeywordCompletion = 1
let g:NeoComplCache_SameFileTypeLists['c'] = 'cpp'
let g:NeoComplCache_SameFileTypeLists['cpp'] = 'c'
let g:NeoComplCache_EnableCamelCaseCompletion = 1

" Define dictionary.
let g:NeoComplCache_DictionaryFileTypeLists = {
        \ 'default' : '',
        \ 'vimshell' : $HOME.'/.vimshell_hist',
        \ 'scheme' : $HOME.'/.gosh_completions'
        \ }
" Define keyword.
if !exists('g:NeoComplCache_KeywordPatterns')
    let g:NeoComplCache_KeywordPatterns = {}
endif
let g:NeoComplCache_KeywordPatterns['default'] = '\v\h\w*'

"------------------------------------------------------------------------------
" taglist.vim
"   http://nanasi.jp/articles/vim/taglist_vim.html
"
set tags=tags

" Object-C
"   http://blogger.splhack.org/2009/05/macvim-kaoriya-20090511.html
let tlist_objc_settings='objc;P:protocols;i:interfaces;I:implementat'

"------------------------------------------------------------------------------
" smartchr.vim
"   http://project-p.jp/halt/anubis/blog_show/1068
"
inoremap <expr> = smartchr#one_of(' = ', ' == ', ' === ', '=')

"------------------------------------------------------------------------------
" QuickBuf (qbuf.vim)
"   http://nanasi.jp/articles/vim/qbuf_vim.html
"
let g:qb_hotkey="<F2>"


"==============================================================================
" Print
"==============================================================================
set printoptions=wrap:y,number:y,header:0,left:5mm
set printfont=Osaka:h9:cSHIFTJIS



if has("syntax")
    syntax on
    function! ActivateInvisibleIndicator()
        syntax match InvisibleJISX0208Space "　" display containedin=ALL
        highlight InvisibleJISX0208Space cterm=underline ctermbg=Blue guibg=#222222
        syntax match InvisibleTrailedSpace "[ \t]\+$" display containedin=ALL
        highlight InvisibleTrailedSpace cterm=underline ctermbg=Red guibg=#222222
        syntax match InvisibleTab "\t" display containedin=ALL
        highlight InvisibleTab cterm=underline ctermbg=Cyan guibg=SteelBlue4
    endf

    augroup invisible
        autocmd! invisible
        autocmd BufNew,BufRead * call ActivateInvisibleIndicator()
    augroup END
endif


