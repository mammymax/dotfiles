;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; load site-lisp directory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq load-path
      (append
       (list (expand-file-name "/usr/share/emacs/site-lisp")) load-path))
(setq load-path
      (append
       (list (expand-file-name "/Users/inohiro/.emacs.d")) load-path))
(setq load-path
      (append
       (list (expand-file-name "/home/inohiro/.emacs.d")) load-path))
;; (setq load-paths
;;      (append
;;       (list (expand-file-name "/Users/inohiro/.emacs.d/js2-mode")) load-path))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; set coding-system to UTF-8
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(set-keyboard-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; emphasize current line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defface hlline-face
  '((((class color)
      (background dark))
     (:background "dark slate gray"))
    (((class color)
      (background light))
     (:background "SkyBlue")) ;; set current line color
    (t
     ()))
  "*Face used by hl-line.")
;;(setq hl-line-face 'hlline-face)
(setq hl-line-face 'underline)  ;; underline
(global-hl-line-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; line number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'linum)
(global-linum-mode)
(setq linum-format "%3d ")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MEMO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; JUMP: M-g g

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Go support
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'go-mode-load )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; n3 mode
;; (https://github.com/kurtjx/n3-mode-for-emacs)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-to-list 'load-path "~/.emacs.d/n3-mode.el")
(autoload 'n3-mode "n3-mode" "Major mode for OWL or N3 files" t)

;; Turn on font lock when in n3 mode
(add-hook 'n3-mode-hook
          'turn-on-font-lock)

(setq auto-mode-alist
      (append
       (list
        '("\\.n3" . n3-mode)
        '("\\.owl" . n3-mode))
       auto-mode-alist))

;; Replace {path} with the full path to n3-mode.el on your system.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; C# support
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(autoload 'csharp-mode "csharp-mode" "Major mode for editing C# code." t)
(setq auto-mode-alist (cons '("\\.cs$" . csharp-mode) auto-mode-alist))

;; NOTE: The version of cc-langs.el that came with my Emacs
;; installation has the function c-filter-op defined only at compile
;; time, but it's needed by csharp-mode at run-time. I hacked
;; cc-langs.el and recompiled it to fix this.

;; Patterns for finding Microsoft C# compiler error messages:
(require 'compile)
(push '("^\\(.*\\)(\\([0-9]+\\),\\([0-9]+\\)): error" 1 2 3 2) compilation-error-regexp-alist)
(push '("^\\(.*\\)(\\([0-9]+\\),\\([0-9]+\\)): warning" 1 2 3 1) compilation-error-regexp-alist)

;; Patterns for defining blocks to hide/show:
(push '(csharp-mode
	"\\(^\\s *#\\s *region\\b\\)\\|{"
	"\\(^\\s *#\\s *endregion\\b\\)\\|}"
	"/[*/]"
	nil
	hs-c-like-adjust-block-beginning)
      hs-special-modes-alist)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ruby-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ruby-electric.el
(require 'ruby-electric)
(add-hook 'ruby-mode-hook '(lambda () (ruby-electric-mode t)))

;; ruby-block.el
(require 'ruby-block)
(ruby-block-mode t)
(setq ruby-block-highlight-toggle t)

;; flymake for ruby
(require 'flymake)
;; Invoke ruby with '-c' to get syntax checking
(defun flymake-ruby-init ()
  (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
         (local-file  (file-relative-name
                       temp-file
                       (file-name-directory buffer-file-name))))
    (list "ruby" (list "-c" local-file))))
(push '(".+\\.rb$" flymake-ruby-init) flymake-allowed-file-name-masks)
(push '("Rakefile$" flymake-ruby-init) flymake-allowed-file-name-masks)
(push '("^\\(.*\\):\\([0-9]+\\): \\(.*\\)$" 1 2 nil 3) flymake-err-line-patterns)
(add-hook
 'ruby-mode-hook
 '(lambda ()
    ;; Don't want flymake mode for ruby regions in rhtml files
    (if (not (null buffer-file-name)) (flymake-mode))
    ;; エラー行で C-c d するとエラーの内容をミニバッファで表示する
    (define-key ruby-mode-map "\C-cd" 'credmp/flymake-display-err-minibuf)))

(defun credmp/flymake-display-err-minibuf ()
  "Displays the error/warning for the current line in the minibuffer"
  (interactive)
  (let* ((line-no             (flymake-current-line-no))
         (line-err-info-list  (nth 0 (flymake-find-err-info flymake-err-info line-no)))
         (count               (length line-err-info-list))
         )
    (while (> count 0)
      (when line-err-info-list
        (let* ((file       (flymake-ler-file (nth (1- count) line-err-info-list)))
               (full-file  (flymake-ler-full-file (nth (1- count) line-err-info-list)))
               (text (flymake-ler-text (nth (1- count) line-err-info-list)))
               (line       (flymake-ler-line (nth (1- count) line-err-info-list))))
          (message "[%s] %s" line text)
          )
        )
      (setq count (1- count)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; js2-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (autoload 'js2-mode "js2-mode/js2-mode" nil t)
(require 'js2-mode)
(add-to-list 'auto-mode-alist '("\\.\\(js\\|json\\)$" . js2-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Show Invisible Characters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (setq whitespace-style
;;       '(tabs tab-mark spaces space-mark))
;; (setq whitespace-space-regexp "\\(\x3000+\\)")
;; (setq whitespace-display-mappings
;;       '((space-mark ?\x3000 [?\□])
;; 	(tab-mark   ?\t   [?\xBB ?\t])
;; 	))

;; (require 'whitespace)
;; (global-whitespace-mode 1)
;; (set-face-foreground 'whitespace-space "LightSlateGray")
;; (set-face-background 'whitespace-space "DarkSlateGray")
;; (set-face-foreground 'whitespace-tab "LightSlateGray")
;; (set-face-background 'whitespace-tab "DarkSlateGray")

;;(global-whitespace-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ocaml Support
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (setq auto-mode-alist
;;      (cons '("\\.ml[iylp]?$" . caml-mode) auto-mode-alist))
;; (autoload 'caml-mode "caml" "Major mode for editing Caml code." t)
;; (autoload 'run-caml "inf-caml" "Run an inferior Caml Process." t)
;; (if window-system(require 'caml-font))
;; (setq inferior-caml-program "/usr/local/bin/ocaml")

