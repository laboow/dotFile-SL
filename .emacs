;; **********************************************************************
;; 1. 初期設定
;; 2. ウィンドウ設定
;; 3. カラーリング設定
;; 4. エディター設定
;; 5. バッファ設定
;; 6. ファイル設定
;; 7. モード設定
;; 8. その他の lisp や外部アプリケーションとの連携
;;
;; **********************************************************************

;; ======================================================================
;; 初期設定
;; ======================================================================

(server-start)

;; ロードパス
(setq load-path (cons "~/emacs/site-lisp" load-path))
(setq load-path (cons "~/.emacs.d/mylisp" load-path))

;; C-h をバックスペースに変更
(global-set-key "\C-h" 'delete-backward-char)

;; 起動時にスプラッシュ画面を表示しない
(setq inhibit-startup-message t)

;; ビープ音を消す
(setq visible-bell t)

;; エラーのとき画面をフラッシュさせない
(setq ring-bell-function 'ignore)

;; yes-no を y-n に置き換え
(fset 'yes-or-no-p 'y-or-n-p)

;; フォント設定
;; http://macemacsjp.sourceforge.jp/matsuan/FontSettingJp.html
(add-to-list 'default-frame-alist '(font . "fontset-default"))
(set-face-attribute 'default nil
                    :family "monaco"
                    :height 140)
(set-fontset-font "fontset-default"
                  'japanese-jisx0208
                  '("ヒラギノ丸ゴ pro w4*" . "jisx0208.*"))
(set-fontset-font "fontset-default"
                  'katakana-jisx0201
                  '("ヒラギノ丸ゴ pro w4*" . "jisx0201.*"))
(add-to-list 'face-font-rescale-alist
             `(,(encode-coding-string ".*ヒラギノ丸ゴ pro w4.*" 'emacs-mule) . 1.1))

;; IME on/off に連動してカーソルの色を変える
;; http://d.hatena.ne.jp/samurai20000/20080416/1208299756
(mac-set-input-method-parameter `roman `cursor-color "dim gray")
(mac-set-input-method-parameter `japanese `cursor-color "cyan")

;; ミニバッファ内で C-w で単語削除
(define-key minibuffer-local-completion-map "\C-w" 'backward-kill-word)

;; URL をデフォフトブラウザで開く
(setq browse-url-browser-function 'browse-url-generic)
(setq browse-url-generic-program "open")
(global-set-key "\C-xc" 'browse-url-at-point)


;; ======================================================================
;; ウィンドウ設定
;; ======================================================================

;; カラー設定
(if window-system (progn
                    ;; (setq initial-frame-alist '((width . 110)(height . 60)(top . 30)(left . 10)))
                    (set-background-color "Black")
                    (set-foreground-color "White")
                    (set-cursor-color "Gray")
                    ))

;; ウィンドウサイズ、位置保存設定
;; http://www.bookshelf.jp/soft/meadow_30.html#SEC416
(defun my-window-size-save ()
  (let* ((rlist (frame-parameters (selected-frame)))
         (ilist initial-frame-alist)
         (nCHeight (frame-height))
         (nCWidth (frame-width))
         (tMargin (if (integerp (cdr (assoc 'top rlist)))
                      (cdr (assoc 'top rlist)) 0))
         (lMargin (if (integerp (cdr (assoc 'left rlist)))
                      (cdr (assoc 'left rlist)) 0))
         buf
         (file "~/.emacs.d/.framesize.el"))
    (if (get-file-buffer (expand-file-name file))
        (setq buf (get-file-buffer (expand-file-name file)))
      (setq buf (find-file-noselect file)))
    (set-buffer buf)
    (erase-buffer)
    (insert (concat
             "(delete 'width initial-frame-alist)\n"
             "(delete 'height initial-frame-alist)\n"
             "(delete 'top initial-frame-alist)\n"
             "(delete 'left initial-frame-alist)\n"
             "(setq initial-frame-alist (append (list\n"
             "'(width . " (int-to-string nCWidth) ")\n"
             "'(height . " (int-to-string nCHeight) ")\n"
             "'(top . " (int-to-string tMargin) ")\n"
             "'(left . " (int-to-string lMargin) "))\n"
             "initial-frame-alist))\n"
             ))
    (save-buffer)
    ))

(defun my-window-size-load ()
  (let* ((file "~/.emacs.d/.framesize.el"))
    (if (file-exists-p file)
        (load file))))

(my-window-size-load)

;; Call the function adove at C-x C-c.
(defadvice save-buffers-kill-emacs
  (before save-frame-size activate)
  (my-window-size-save))

;; ウィンドウを透明化する
(add-to-list 'default-frame-alist '(alpha . 88))

;; カレントウィンドウの透明度を変更する
(set-frame-parameter nil 'alpha 85)

;; タイトルバーにファイル名を表示する
(setq frame-title-format (format "emacs@%s : %%f" (system-name)))

;; ツールバーを隠す
(tool-bar-mode -1)

;; 行数を表示する
(require 'linum)
(global-linum-mode)

;; 列数を表示する
(column-number-mode 1)

;; elscreen
(load "elscreen" "ElScreen" t)
  ;; タブ幅を変更
  (setq elscreen-display-tab 17)
  ;; タブ左端の×を非表示
  (setq elscreen-tab-display-kill-screen nil)
  ;; C-q に割り当て
  (elscreen-set-prefix-key "\C-q")
  ;; emacsclient から新しいウィンドウで開く
  (require 'elscreen-server)
  ;; タブの色
  (custom-set-variables)

  (custom-set-faces
  '(elscreen-tab-background-face ((((type x w32 mac) (class color)) (:background "Gray20"))))
  '(elscreen-tab-current-screen-face ((((class color)) (:background "gray50" :foreground "gray10"))))
  '(elscreen-tab-other-screen-face ((((type x w32 mac) (class color)) (:background "Gray30" :foreground "Gray10")))))

;; フルスクリーンの切替
(defun my-toggle-flame-size ()
  (interactive)
  (if (frame-parameter nil 'fullscreen)
      (set-frame-parameter nil 'fullscreen nil)
      (set-frame-parameter nil 'fullscreen 'fullboth)
      (message "Full-screen changed")))
(global-set-key "\C-cm" 'my-toggle-flame-size)

;; 分割した画面を入れ替える
;; source: http://www.bookshelf.jp/soft/meadow_30.html#SEC400
(defun swap-screen()
  "Swap two screen,leaving cursor at current window."
  (interactive)
  (let ((thiswin (selected-window))
        (nextbuf (window-buffer (next-window))))
    (set-window-buffer (next-window) (window-buffer))
    (set-window-buffer thiswin nextbuf)))
(defun swap-screen-with-cursor()
  "Swap two screen,with cursor in same buffer."
  (interactive)
  (let ((thiswin (selected-window))
        (thisbuf (window-buffer)))
    (other-window 1)
    (set-window-buffer thiswin (window-buffer))
    (set-window-buffer (selected-window) thisbuf)))
(global-set-key "\C-qx" 'swap-screen)
(global-set-key "\C-qX" 'swap-screen-with-cursor)


;; ======================================================================
;; カラーリング設定
;; ======================================================================

;; ソースコードカラー
(set-face-foreground 'font-lock-comment-face "#43cd80")


;; ======================================================================
;; エディター設定
;; ======================================================================

;; utf-8
;; http://blogs.da-cha.jp/momokuri.php/2005/09/05/utf_8_localea_la_a_a_ia_a
(if (equal (getenv "LANG") "ja_JP.UTF-8")
    (progn (set-language-environment "Japanese")
           (set-default-coding-systems 'utf-8-unix)
           (set-keyboard-coding-system 'utf-8-unix)
           (if (not window-system) (set-terminal-coding-system 'utf-8-unix)))

  (progn (set-language-environment "Japanese")
         (set-default-coding-systems 'euc-japan-unix)
         (set-keyboard-coding-system 'euc-japan-unix)
         (if (not window-system) (set-terminal-coding-system 'euc-japan-unix)))
  )

;; 1行ずつスクロール
(setq scroll-step 1)

;; マウスホイール
(mouse-wheel-mode 1)

;; マウスでのスクロール加速を無効にする
(setq mouse-wheel-progressive-speed nil)

;; 対応する括弧をハイライト表示
(show-paren-mode 1)

;; 対応する括弧に % でジャンプ
(global-set-key "%" 'match-paren)
(defun match-paren (arg)
  "Go to the matching paren if on a paren; otherwise insert %."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
        (t (self-insert-command (or arg 1)))))

;; 指定行にジャンプ
(global-set-key "\M-g" 'goto-line)

;; C/Migemo+migemo.el
(load "migemo.el")
(setq migemo-command "cmigemo")
(setq migemo-options '("-q" "--emacs" "-i" "\a"))
(setq migemo-dictionary "/usr/local/share/migemo/euc-jp/migemo-dict")
(setq migemo-user-dictionary nil)
(setq migemo-regex-dictionary nil)

;; redo
(require 'redo+)
(setq undo-no-redo t)
(global-set-key "\M-/" 'redo)

;; 全角スペース、タブの強調表示
(defface my-face-b-1 '((t (:background "medium aquamarine"))) nil)
(defface my-face-b-2 '((t (:foreground "Pink" :underline t))) nil)
(defface my-face-u-1 '((t (:foreground "SteelBlue" :underline t))) nil)
(defvar my-face-b-1 'my-face-b-1)
(defvar my-face-b-2 'my-face-b-2)
(defvar my-face-u-1 'my-face-u-1)
(defadvice font-lock-mode (before my-font-lock-mode ())
  (font-lock-add-keywords
   major-mode
   '(
     ("　" 0 my-face-b-1 append)
     ("\t" 0 my-face-b-2 append)
     ("[ ]+$" 0 my-face-u-1 append)
     )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)
(add-hook 'find-file-hooks
          '(lambda ()
             (if font-lock-mode nil
               (font-lock-mode t))) t)

;; リージョンの色づけ
(setq transient-mark-mode t)

;; 行の右端で折り返さない
(setq-default truncate-lines t)

;; 行の折り返しを ON/OFF
(defun toggle-truncate-lines ()
  "折り返し表示をトグル動作します."
  (interactive)
  (if truncate-lines
      (setq truncate-lines nil)
    (setq truncate-lines t))
  (recenter))

(global-set-key "\C-cl" 'toggle-truncate-lines)

;; 選択範囲をインデント
(global-set-key "\C-c\C-i" 'indent-region)

;; インデントつきの改行
(global-set-key "\C-m" 'newline-and-indent)

;; インデントなしの改行
(global-set-key "\C-j" 'newline)

;; タブ設定
(setq-default tab-always-indent t)
(setq-default tab-width 4)
(setq tab-stop-list
      '(4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100))
(setq-default indent-line-function 'indent-relative-maybe)
(setq-default indent-tabs-mode nil)

;; C-cc で範囲指定をコメントアウトする
(global-set-key "\C-c:" 'comment-region)
;; C-cu で範囲指定のコメントアウトを解除する
(global-set-key "\C-c;" 'uncomment-region)

;; 補完機能を使う
(setq partial-completion-mode 1)


;; ======================================================================
;; バッファ設定
;; ======================================================================

;; バッファリストを開いたとき、そのウィンドウをアクティブにする
(global-set-key "\C-x\C-b" 'buffer-menu-other-window)

;; shift + カーソルキーでバッファを移動
(windmove-default-keybindings)

;ミニバッファで M-x 時のインクリメンタル補完
(require 'mcomplete)
;さらによく使うヒストリを優先させる
(load "mcomplete-history")
(turn-on-mcomplete-mode)

;ファイルを開く時に，カーソルキーだけで，ファイルを選択
;カーソル上下で従来のヒストリ。ctrl+P,ctrl+nでファイル名補完
(define-key minibuffer-local-ns-map [up] 'previous-history-element)
(define-key minibuffer-local-ns-map [down] 'next-history-element)
(define-key minibuffer-local-map [down] 'next-history-element)
(define-key minibuffer-local-completion-map [down] 'next-history-element)
(define-key minibuffer-local-must-match-map [down] 'next-history-element)


;; ======================================================================
;; ファイル設定
;; ======================================================================

;; 常にカレントディレクトリから始める
(cd "~")

;; file名の補完で大文字小文字を区別しない
(setq conpletion-ignore-case t)

;; 最近使ったファイルをメニューに表示
(recentf-mode 1)
(setq recentf-max-menu-items 10)
(setq recentf-max-saved-items 20)

;; ファイルを開いたときに、以前編集していた場所に移動
;; Emacsを終了してもファイルを編集してた位置や
;; minibuffer への入力内容を覚えててくれます。
(when (require 'session nil t)
  (setq session-initialize '(de-saveplace session keys menus places)
        session-globals-include '((kill-ring 50)
                                  (session-file-alist 500 t)
                                  (file-name-history 10000)))
;; これがないと file-name-history に500個保存する前に max-string に達する
(setq session-globals-max-string 100000000)
;; デフォルトでは30!
(setq history-length t)
(add-hook 'after-init-hook 'session-initialize))

;; 最終更新日時の自動埋込
(require 'time-stamp)
(add-hook 'before-save-hook 'time-stamp)
(setq time-stamp-active t)
(setq time-stamp-start "Last updated : ")
(setq time-stamp-format "%04y/%02m/%02d-%02H:%02M:%02S")
(setq time-stamp-end " \\|$")

;; バックアップファイルを残さない
(setq make-backup-files nil)

;; 終了時に自動生成されたオートセーブファイルを削除する
(setq delete-auto-save-files t)


;; ======================================================================
;; モード設定
;; ======================================================================

;; html-mode
;; ----------------------------------------------------------------------
(add-hook 'html-mode-hook
          '(lambda ()
             (setq indent-tabs-mode nil)
             (setq tab-width 2)))


;; PSGML
;; ----------------------------------------------------------------------
;; http://sickhack.homelinux.org/linux/emacs/psgml/
;; http://d.hatena.ne.jp/gan2/20080207/1202368037
;; (setq load-path (cons (expand-file-name "~/site-lisp/psgml") load-path))
(autoload 'sgml-mode "psgml" "Major mode to edit SGML files." t)
(autoload 'xml-mode "psgml" "Major mode to edit XML files." t)
(add-to-list 'auto-mode-alist '("\\.\\(htm\\|html\\|shtm\\|shtml\\|xml\\|xhtml\\)\\'" . xml-mode))

;;; カタログファイルの指定
(setq sgml-catalog-files '("CATALOG" "~/.emacs.d/mylisp/dtd/catalog"))
(setq sgml-ecat-files '("ECAT" "~/.emacs.d/mylisp/dtd/ecat"))

;;; DOCTYPE 宣言の設定
(setq sgml-custom-dtd
      '(("HTML 4.01 Strict" 
         "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\"
\"http://www.w3.org/TR/html4/strict.dtd\">")
        ("HTML 4.01 Transitional" 
         "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"
\"http://www.w3.org/TR/html4/loose.dtd\">")
        ("HTML 4.01 Frameset" 
         "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Frameset//EN\"
\"http://www.w3.org/TR/html4/frameset.dtd\">")
        ("XHTML 1.0 Strict" 
         "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"
\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n")
        ("XHTML 1.0 Transitional" 
         "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"
\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n")
        ("XHTML 1.0 Frameset" 
         "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Frameset//EN\"
\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd\">\n")
        ("XHTML 1.1"
         "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\"
\"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">\n")
        ))

;;; hookで変数をsetq
(add-hook 'sgml-mode-hook
          (lambda ()
            (setq tab-width                             2
                  sgml-indent-step                      2
                  sgml-indent-data                      t
                  indent-tabs-mode                      nil
                  sgml-xml-p                            t
                  sgml-always-quote-attributes          t
                  sgml-system-identifiers-are-preferred t
                  sgml-auto-activate-dtd                t
                  sgml-recompile-out-of-date-cdtd       t
                  sgml-auto-insert-required-elements    t
                  sgml-insert-missing-element-comment   t
                  sgml-balanced-tag-edit                t
                  sgml-default-doctype-name             "XHTML 1.1"
                  sgml-ecat-files                       nil
                  sgml-general-insert-case              'lower
                  sgml-entity-insert-case               'lower
                  sgml-normalize-trims                  t
                  sgml-insert-defaulted-attributes      nil
                  sgml-live-element-indicator           t
                  sgml-active-dtd-indicator             t
                  sgml-minimize-attributes              nil
                  sgml-omittag                          nil
                  sgml-omittag-transparent              nil
                  sgml-shorttag                         nil
                  sgml-tag-region-if-active             t
                  sgml-xml-validate-command             "xmllint --noout --valid %s %s"
                  )
            ))

;; これ以下はお好みで

;;; font-lock
(font-lock-mode 1)
(setq font-lock-support-mode 'jit-lock-mode
      jit-lock-stealth-verbose nil
      font-lock-verbose nil)

;;; My original font-lock-keywords
(add-hook 'sgml-mode-hook
          '(lambda ()
             (make-local-variable 'font-lock-defaults)
             (setq sgml-set-face nil
                   font-lock-defaults '(xml-font-lock-keywords-2 nil))
             (turn-on-font-lock)
             ))

(defvar xml-font-lock-keywords-1
  (list
   ;; タグ開始区切子 & タグ終了区切子
   '("<\\|>" 0 font-lock-keyword-face t)
   ;; スラッシュ
   '("\\(/\\)>" 1 font-lock-keyword-face t)
   '("<\\(/\\)" 1 font-lock-keyword-face t)
   ;; 要素名
   '("\\(</?\\)\\([a-zA-Z]+[a-zA-Z0-9-_:]*\\)" 2 font-lock-builtin-face t)
   ;; コメント
   '("\\(<!--\\([^-]\\|-[^-]\\|--[^>]\\)*-->\\)" 1 font-lock-comment-face t)
   ;; 命令処理
   '("\\(<\\?[a-zA-Z]*\\>[^<>]*\\(<[^>]*>[^<>]*\\)*\\?>\\)" 1 font-lock-type-face t)
   ;; DOCTYPE, ENTITY, ATTLIST, NOTATION等々 マーク宣言
   '("\\(<![a-zA-Z]+\\>[^<>]*\\(<[^>]*>[^<>]*\\)*>\\)" 1 font-lock-constant-face t)
   ;; °
   '("\\<\\([a-zA-Z]+[a-zA-Z-_:]*\\)=" 1 font-lock-variable-name-face t)
   ;; 属性値
   '("=?\\(\"[^\"]*\"\\|'[^\']*'\\)" 1 font-lock-string-face t)
   ;; 数値文字参照, 文字実体参照, パラメータ実体参照
   '("\\(&#[0-9]+;\\|&[a-zA-Z]+;\\|%[^'\";]+;\\)" 1 font-lock-reference-face t)
   ;; CDATA 等々 マーク区間 (マーク指定区域)
   '("\\(<!\\[[^\\[]+\\[[^]]+]]>\\)" 1 font-lock-warning-face t)
   ))

(defvar xml-font-lock-keywords-2
  (append
   xml-font-lock-keywords-1
   (list
    ;; SSI
    `(,(concat "\\(<!--#\\(fsize\\|flastmod\\|printenv\\|"
               "include\\|echo\\|config\\|exec\\|set\\|"
               "if\\|elif\\|else\\|endif\\)\\>[ \t\n]+"
               "\\([^-]\\|-[^-]\\|--[^>]\\)*-->\\)")
      1 'bold t)
    ;; php
    '("\\(<\\?\\(php\\|=\\)[^?>]+\\?>\\)" 1 font-lock-function-name-face t)
    ;; eRuby, JSP, ASP
    '("\\(<%\\(=\\)?\\>[^%>]+%>\\)" 1 font-lock-function-name-face t)
    )))


;; javascript用 js2-mode 20080616a版
;; ----------------------------------------------------------------------
;; http://8-p.infoemacs-javascript.html
;; (autoload 'js2-mode "js2" nil t)
;; (setq-default c-basic-offset 4)
;; (setq indent-tabs-mode nil)

;; (when (load "js2" t)
;;   (setq js2-cleanup-whitespace nil
;;         js2-mirror-mode nil
;;         js2-bounce-indent-flag nil)

;;   (defun indent-and-back-to-indentation ()
;;     (interactive)
;;     (indent-for-tab-command)
;;     (let ((point-of-indentation
;;            (save-excursion
;;              (back-to-indentation)
;;              (point))))
;;       (skip-chars-forward "\s " point-of-indentation)))
;;   (define-key js2-mode-map "\C-i" 'indent-and-back-to-indentation)

;;   (define-key js2-mode-map "\C-m" nil)
;;   (add-to-list 'auto-mode-alist (cons "\\.\\(js$\\|as\\|json\\|jsn\\)\\'" 'js2-mode)))

;; js2-mode 用
;; ----------------------------------------------------------------------
;; http://d.hatena.ne.jp/speg03/20091011/1255244329
(autoload 'js2-mode "js2" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

    ; fixing indentation
    ; refer to http://mihai.bazon.net/projects/editing-javascript-with-emacs-js2-mode
(autoload 'espresso-mode "espresso")

(defun my-js2-indent-function ()
  (interactive)
  (save-restriction
    (widen)
    (let* ((inhibit-point-motion-hooks t)
           (parse-status (save-excursion (syntax-ppss (point-at-bol))))
           (offset (- (current-column) (current-indentation)))
           (indentation (espresso--proper-indentation parse-status))
           node)

      (save-excursion

        ;; I like to indent case and labels to half of the tab width
        (back-to-indentation)
        (if (looking-at "case\\s-")
            (setq indentation (+ indentation (/ espresso-indent-level 2))))

        ;; consecurive declarations in a var statement are nice if
        ;; properly aligned, i.e:
        ;;
        ;; var foo = "bar",
        ;;     bar = "foo";
        (setq node (js2-node-at-point))
        (when (and node
                   (= js2-NAME (js2-node-type node))
                   (= js2-VAR (js2-node-type (js2-node-parent node))))
          (setq indentation (+ 4 indentation)))))

    (indent-line-to indentation)
    (when (> offset 0) (forward-char offset))))

(defun my-indent-sexp ()
  (interactive)
  (save-restriction
    (save-excursion
      (widen)
      (let* ((inhibit-point-motion-hooks t)
             (parse-status (syntax-ppss (point)))
             (beg (nth 1 parse-status))
             (end-marker (make-marker))
             (end (progn (goto-char beg) (forward-list) (point)))
             (ovl (make-overlay beg end)))
        (set-marker end-marker end)
        (overlay-put ovl 'face 'highlight)
        (goto-char beg)
        (while (< (point) (marker-position end-marker))
          ;; don't reindent blank lines so we don't set the "buffer
          ;; modified" property for nothing
          (beginning-of-line)
          (unless (looking-at "\\s-*$")
            (indent-according-to-mode))
          (forward-line))
        (run-with-timer 0.5 nil '(lambda(ovl)
                                   (delete-overlay ovl)) ovl)))))

(defun my-js2-mode-hook ()
  (require 'espresso)
  (setq espresso-indent-level 4
        indent-tabs-mode nil
        c-basic-offset 4)
  (c-toggle-auto-state 0)
  (c-toggle-hungry-state 1)
  (set (make-local-variable 'indent-line-function) 'my-js2-indent-function)
  ; (define-key js2-mode-map [(meta control |)] 'cperl-lineup)
  (define-key js2-mode-map "\C-\M-\\"
    '(lambda()
       (interactive)
       (insert "/* -----[ ")
       (save-excursion
         (insert " ]----- */"))
       ))
  (define-key js2-mode-map "\C-m" 'newline-and-indent)
  ; (define-key js2-mode-map [(backspace)] 'c-electric-backspace)
  ; (define-key js2-mode-map [(control d)] 'c-electric-delete-forward)
  (define-key js2-mode-map "\C-\M-q" 'my-indent-sexp)
  (if (featurep 'js2-highlight-vars)
      (js2-highlight-vars-mode))
  (message "My JS2 hook"))

(add-hook 'js2-mode-hook 'my-js2-mode-hook)

;; c-mode 用
;; ----------------------------------------------------------------------
;; http://viz.is-a-geek.com/~viz/cw/index.php?Emacs
;; http://www.jitu.org/~tko/doc-jp/cc-mode.html
(add-hook 'c-mode-common-hook
          '(lambda ()
             (c-set-style "k&r")
             (setq c-basic-offset 4)
             (setq indent-tabs-mode nil)
             (setq tab-width 4s)
             (c-toggle-hungry-state 1)    ;; 連続する空白類をバックスペースキー一発で消すモード
             (define-key c-mode-base-map "\C-cc" 'compile)
             (define-key c-mode-base-map "\C-ce" 'next-error)
           ))

;; shell-mode 用
;; ----------------------------------------------------------------------
;; http://www.namazu.org/~tsuchiya/elisp/
;; バッファでのパスワードを見えなくする
(add-hook 'comint-output-filter-functions
          'comint-watch-for-password-prompt)

;; 各 shell 用の設定
;; http://d.hatena.ne.jp/tomoya/20090601/1243817036

;; eshell
(when (require 'eshell-auto nil t)
   (add-hook 'eshell-mode-hook
             (lambda ()
               (define-key eshell-mode-map (kbd "C-a") 'eshell-bol)
               (define-key eshell-mode-map (kbd "C-r") 'eshell-isearch-backward)))
   (when (require 'pcmpl-auto nil t)
     (when (require 'pcmpl-ssh nil t)
       (add-hook 'eshell-mode-hook 'pcomplete-shell-setup)))

   (setq eshell-cmpl-ignore-case t)     ;; 補完時に大文字小文字を区別しない
   (setq eshell-glob-include-dot-dot nil) ;; ../ を * でマッチさせない
   (setq eshell-ask-to-save-history (quote always)) ;; 確認なしでヒストリ保存
   (setq eshell-history-file-name "~/.zhistory") ;; zsh のヒストリと共有
   (setq eshell-history-size 100000)                ;; ヒストリサイズ
   (setq eshell-hist-ignoredups t))                 ;; ヒストリの重複を無視

;; ansi-color でエスケープシーケンスを fontify する設定
;; http://d.hatena.ne.jp/rubikitch/20081102/1225601754
(autoload 'ansi-color-for-comint-mode-on "ansi-color"
  "Set `ansi-color-for-comint-mode' to t." t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

(when (require 'shell-pop nil t)
  (setq shell-pop-window-height 60)     ;; percentage for shell-buffer window height
  (define-key global-map [(super t)] 'shell-pop))

;; shell-mode 上下でヒストリ補完
;; http://www.hasta-pronto.org/archives/2006/11/02-0230.php
;; +zsh 用
;; http://d.hatena.ne.jp/mooz/20090613/p1
(add-hook 'shell-mode-hook
          '(lambda ()
             (setq comint-input-ring-file-name "~/.zhistory")
             (setq comint-input-ring-size 1024)
             (comint-read-input-ring t)
             (local-set-key "\M-p" 'comint-previous-matching-input-from-input)
             (local-set-key "\M-n" 'comint-next-matching-input-from-input)
             (setq ansi-color-names-vector
                   ["#000000"           ; Black
                    "#ff6565"           ; red
                    "#93d44f"           ; green
                    "#eab93d"           ; yellow
                    "#204a87"           ; blue
                    "#ce5c00"           ; magenta
                    "#89b6e2"           ; cyan
                    "#ffffff"]          ; white
                   )
             (ansi-color-for-comint-mode-on)
             )
          )


;; ======================================================================
;; その他の lisp や 外部アプリケーションとの連携
;; ======================================================================

;; Flymake
;; ----------------------------------------------------------------------
;; http://dev.ariel-networks.com/articles/software-design-200802/elisp-catalog
(require 'flymake)
(global-set-key "\C-cd" 'flymake-display-err-menu-for-current-line)


;; session.el & minibuf-isearch
;; ----------------------------------------------------------------------
;; http://openlab.dino.co.jp/2008/09/26/230919351.html#more-351
;; ミニバッファ履歴リストの最大長：tなら無限
(setq history-length t)
;; session.el
;;   kill-ringやミニバッファで過去に開いたファイルなどの履歴を保存する
(when (require 'session nil t)
  (setq session-initialize '(de-saveplace session keys menus places)
        session-globals-include '((kill-ring 50)
                                  (session-file-alist 500 t)
                                  (file-name-history 10000)))
  (add-hook 'after-init-hook 'session-initialize)
  ;; 前回閉じたときの位置にカーソルを復帰
  (setq session-undo-check -1))
;; minibuf-isearch
;;   minibufでisearchを使えるようにする
(require 'minibuf-isearch nil t)

;; growl messages at file saved
(defun growlnotify-after-save-hook ()
  (shell-command
   (format "growlnotify -t \"Emacs:\" -m \"ファイル %s を保存しました \""
           (buffer-name (current-buffer)))))
(add-hook 'after-save-hook 'growlnotify-after-save-hook)

;; テキスト入力中に補完候補を自動的に表示してくれる auto-complete.el
;; ----------------------------------------------------------------------
;; http://dev.ariel-networks.com/Members/matsuyama/auto-complete
(require 'auto-complete)
(global-auto-complete-mode t)
(define-key ac-complete-mode-map "\C-n" 'ac-next)
(define-key ac-complete-mode-map "\C-p" 'ac-previous)

;; auto-complete.el 用の動的略語展開を利用する
;; http://blog.livedoor.jp/k1LoW/archives/65147035.html
(require 'ac-dabbrev)
(setq ac-sources
      (list ac-source-dabbrev))


;; pulldown.el の設定
;; ----------------------------------------------------------------------
;; http://d.hatena.ne.jp/m2ym/20091105/1257387008
(require 'pulldown)
;; (pulldown-menu '(foo bar hoge))


;; anything.el の設定
;; ----------------------------------------------------------------------
(require 'shell-history)
(require 'anything-config)
(require 'anything)
(require 'anything-match-plugin)
(require 'anything-complete)
(anything-lisp-complete-symbol-set-timer 150)
(setq anything-idle-delay 0.3)
(setq anything-input-idel-delay 0.2)
(setq anything-candidate-number-limit 100)
(setq anything-sources (list anything-c-source-buffers
                             anything-c-source-bookmarks
                             anything-c-source-file-name-history
                             anything-c-source-emacs-commands
                             anything-c-source-emacs-functions
                             anything-c-source-locate))
(define-key anything-map (kbd "C-p") 'anything-previous-line)
(define-key anything-map (kbd "C-n") 'anything-next-line)
(define-key anything-map (kbd "C-v") 'anything-next-source)
(define-key anything-map (kbd "M-v") 'anything-previous-source)
(global-set-key (kbd "C-'") 'anything)

;; shell
(when (require 'shell-history nil t)
  (when (require 'anything-complete nil t)
    (add-hook 'shell-mode-hook
              (lambda ()
                (define-key shell-mode-map (kbd "C-r") 'anything-complete-shell-history)))

    (use-anything-show-completion 'anything-complete-shell-history
                                  '(length anything-c-source-complete-shell-history))))


;; ac-anything.el
;; ----------------------------------------------------------------------
;; auto-complete.el の候補を anything.el で絞り込む
;; http://d.hatena.ne.jp/rubikitch/20090210
(require 'ac-anything)
(define-key ac-complete-mode-map (kbd "C-:") 'ac-complete-with-anything)


;; smart-compile.el の設定
;; ----------------------------------------------------------------------
;; http://homepage.mac.com/zenitani/elisp-j.html#compile
(require 'smart-compile)
(global-set-key "\C-c\C-c" 'smart-compile)


;; sense-region.el
;; ----------------------------------------------------------------------
;; http://taiyaki.org/elisp/sense-region/
(autoload 'sense-region-on "sense-region"
  "System to toggle region and rectangle." t nil)
(sense-region-on)


;; Dynamic Macro 簡単に繰り返し処理を実行してくれる
;; ----------------------------------------------------------------------
;; http://pitecan.com/DynamcMacro/
(defconst *dmacro-key* "\C-t" "繰り返し指定キー")
(global-set-key *dmacro-key* 'dmacro-exec)
(autoload 'dmacro-exec "dmacro" nil t)


;; folding.el の設定（折りたたみ）
;; ----------------------------------------------------------------------
;; http://jigen.aruko.net/2007/01/09/the-fold-which-seems-to-be-vim-in-emacs-foldingel/
(autoload 'folding-mode "folding" "Folding mode" t)
(autoload 'turn-off-folding-mode "folding" "Foliding mode" t)
(autoload 'turn-on-folding-mode "folding" "Folding mode" t)
  ;; @ ~ とかがめんどいので
  (setq folding-mode-prefix-key "\C-c")


;; ;; mozrepl
;; ;; ----------------------------------------------------------------------
;; ;; http://wiki.github.com/bard/mozrepl/emacs-integration
;; (autoload 'moz-minor-mode "moz" "Mozilla Minor and Inferior Mozilla Modes" t)

;; (add-hook 'javascript-mode-hook 'javascript-custom-setup)
;; (defun javascript-custom-setup ()
;;   (moz-minor-mode 1))

;; (add-hook 'espresso-mode-hook 'espresso-custom-setup)
;; (defun espresso-custom-setup ()
;;   (moz-minor-mode 1))
;;     ;; C-c C-s :open a MozRepl interaction buffer and switch to it
;;     ;; C-c C-l :save the current buffer and load it in MozRepl
;;     ;; C-M-x   :send the current function (as recognized by 'c-mark-function') to MozRepl
;;     ;; C-c C-c :send the current function to MozRepl and switch to the interaction buffer
;;     ;; C-c C-r :send the current region to MozRepl
;;     ;; C-c c   :insert the current name of the REPL plus the dot operator (usually 'repl.')


;; espresso-mode
;; ----------------------------------------------------------------------
;; http://d.hatena.ne.jp/CortYuming/20091023/p2
;;
;; C-c C-s :open a MozRepl interaction buffer and switch to it
;; C-c C-l :save the current buffer and load it in MozRepl
;; C-M-x   :send the current function (as recognized by 'c-mark-function') to MozRepl
;; C-c C-c :send the current function to MozRepl and switch to the interaction buffer
;; C-c c   :insert the current name of the REPL plus the dot operator (usually 'repl.')
(setq auto-mode-alist (append '(
                                ("\\.js$" . espresso-mode)
                                ("\\.jsx$" . espresso-mode)
                                ) auto-mode-alist))
;; (add-to-list 'auto-mode-alist '("\\.js\\'" .espresso-mode))
(autoload 'espresso-mode "espresso" nil t)

(autoload 'moz-minor-mode "moz" "Mozilla Minor and Inferior Mozilla Modes" t)

(add-hook 'espresso-mode-hook 'espresso-custom-setup)
(defun espresso-cutom-setup ()
  (moz-minor-mode 1))


;; Firefox の自動リロード化
;; ----------------------------------------------------------------------
;; http://emacs.g.hatena.ne.jp/k1LoW/20090430/1241104830
(defvar moz-use-mozilla t)
(defun moz-send-reload ()
  (interactive)
  (unless (not moz-use-mozilla)
    (comint-send-string (inferior-moz-process)
                        (concat moz-repl-name ".pushenv('printPrompt', 'inputMode'); "
                                moz-repl-name ".setenv('inputMode', 'line'); "
                                moz-repl-name ".setenv('printPrompt', false); undefined; "))
    (comint-send-string (inferior-moz-process)
                        (concat "content.location.reload(true);\n"
                                moz-repl-name ".popenv('inputMode', 'printPrompt'); undefined;\n"))
    ))

(defun reload-moz ()
  (unless (condition-case nil(run-mozilla)
            (error nil))
    (if (string-match "\.\\(css\\|js\\|php\\|html\\|xhtml\\|htm\\|tpl\\|thtml\\|ctp\\|po\\)$" (buffer-file-name))
        (moz-send-reload))))

(add-hook 'after-save-hook 'reload-moz)

(defun moz-switch-host ()
  "Show the inferior mozilla buffer.  Start the process if needed."
  (interactive)
  (if inferior-moz-buffer
      (kill-buffer inferior-moz-buffer))
  (setq moz-repl-host (read-string "Host: " "localhost"))
  (pop-to-buffer (process-buffer (inferior-moz-process)))
  (goto-char (process-mark (inferior-moz-process))))


;; 外部コマンドから emacsclient で起動済みのEmacsにファイルを開かせる
;; ----------------------------------------------------------------------
(server-start)


;; ----------------------------------------------------------------------
;;                          最終更新 '09.11.15
;; ----------------------------------------------------------------------
