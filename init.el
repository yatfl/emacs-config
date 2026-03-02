;; Basic
(setq inhibit-startup-screen t)
(setq display-line-numbers-type 'visual)
(global-display-line-numbers-mode)
(setq column-number-mode t)
(menu-bar-mode -1)
(tool-bar-mode -1)

(setq make-backup-files nil)

(setopt use-short-answer t)
(defalias 'yes-or-no-p 'y-or-n-p)

(setq visible-bell nil
      ring-bell-function 'flash-mode-line)
(defun flash-mode-line ()
  (invert-face 'mode-line)
  (run-with-timer 0.1 nil #'invert-face 'mode-line))

(xterm-mouse-mode)

;; Shortcuts
(global-set-key (kbd "C-x f") 'find-file)
(global-set-key (kbd "C-x C-SPC") 'mc--mark-symbol-at-point)

(defun yf/previous-window ()
    (interactive)
    (other-window -1))

(global-set-key (kbd "C-x C-o") 'other-window)
(global-set-key (kbd "C-x o") 'yf/previous-window)
(windmove-default-keybindings)

(global-set-key (kbd "C-x 4") 'transpose-frame)
(global-set-key (kbd "C-x C-4") 'rotate-frame)

(defun yf/nuke-all-buffers ()
  (interactive)
  (mapcar 'kill-buffer (buffer-list))
  (delete-other-windows)
)
(global-set-key (kbd "C-x C-k") 'rgrep)

(global-set-key (kbd "C-x p") 'tab-close)
(global-set-key (kbd "C-x n") 'tab-new)

(global-set-key (kbd "C-x C-p") 'tab-previous)
(global-set-key (kbd "C-x C-n") 'tab-next)

(global-set-key (kbd "C-x C-u") 'undo)

(global-set-key (kbd "C-x d") 'list-directory)
(global-set-key (kbd "C-x C-d") 'dired)

(defun yf/toggle-relative-lines ()
  (interactive)
  (if (eq display-line-numbers 'visual)
      (setq display-line-numbers t)
    (setq display-line-numbers 'visual)))
(global-set-key (kbd "<f5>") 'yf/toggle-relative-lines)

(defun yf/prettier-markdown-toc ()
  (interactive)
  (when (and (fboundp 'prettier-js-prettify)
             (fboundp 'markdown-toc-refresh-toc))
    (prettier-js-prettify)
    (markdown-toc-refresh-toc)
    (message "Buffer formatted and toc refreshed")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Package
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
(require 'use-package)

;; for package-install-selected-packages / package-autoremove
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(company emmet-mode exec-path-from-shell ibuffer-vc magit
	     markdown-toc multiple-cursors pinentry prettier-js
	     rainbow-mode transpose-frame xclip)))

;; modus
(setq modus-vivendi-palette-overrides
      '((bg-main "#1e1e1e")
        (fg-main "#d4d4d4")
        (bg-dim  "#252525")
        (fg-dim  "#a0a0a0")))

(load-theme 'modus-operandi :no-confirm)

;; ibuffer
(global-set-key (kbd "C-x b") 'ibuffer)
(global-set-key (kbd "C-x C-b") 'switch-to-buffer)

(setq ibuffer-expert t)
(setq ibuffer-use-header-line t)
(setq ibuffer-saved-filter-groups
      '(("Default"
         ("Programming" (or (mode . markdown-mode)
			    (mode . c-mode)
                            (mode . c++-mode)
                            (mode . js-mode)
                            (mode . emacs-lisp-mode)))
	 ("Shell" (or (mode . eshell-mode)
		      (name . "terminal")))
         ("Dired" (mode . dired-mode))
         ("Magit" (name . "^magit"))
         ("*" (and (name . "^\\*.*\\*$")
                   (not (name . "eshell"))
		   (not (name . "terminal")))))))

(add-hook 'ibuffer-mode-hook
          (lambda ()
            (ibuffer-switch-to-saved-filter-groups "Default")))

(setq ibuffer-formats
      '((mark modified read-only " "
              (name 30 30 :left :elide)
              " "
              (size 9 -1 :right)
              " "
              (mode 16 16 :left :elide)
              " " filename-and-process)))

;; Pinentry
(setq epg-pinentry-mode 'loopback)
(pinentry-start)

;; ido and fake one too
(require 'ido)
(ido-mode t)
(fido-vertical-mode t)

;; multiple cursors
(require 'multiple-cursors)
(global-set-key (kbd "C-x C-g") 'mc/edit-lines)
(global-set-key (kbd "C-x C-f") 'mc/mark-next-word-like-this)

;; eglot
(use-package eglot
  :bind (:map eglot-mode-map
	      ("C-c r" . eglot-rename)
	      ("C-c o" . eglot-code-actions)
	      ("C-c h" . eldoc))
  :custom
  (eglot-ignored-server-capabilities '(:inlayHintProvider)))

;; company-mode
(require 'company)
(add-hook 'after-init-hook 'global-company-mode)
(setq company-minimum-prefix-length 2)
(setq company-idle-delay 0.2)

;; flymake
(use-package flymake
  :bind (:map prog-mode-map
              ("M-n" . flymake-goto-next-error)
              ("M-p" . flymake-goto-prev-error)))

;; html
(require 'emmet-mode)
(add-hook 'sgml-mode-hook 'emmet-mode)
(add-hook 'css-mode-hook  'emmet-mode)

;; markdown
(use-package markdown-mode
  :bind (:map markdown-mode-map
              ("C-c C-o" . markdown-toc-follow-link-at-point)
              ("C-x p" . tab-previous)
              ("C-x n" . tab-next)))

;; markdown-toc
(require 'dash)
(setq markdown-toc-user-toc-structure-manipulation-fn
      (lambda (toc-structure)
	(-filter (lambda (l)
		   (let ((index (car l)))
		     (<= 1 index)))
		 toc-structure)))

;; C++
(setq c-basic-offset 4)

;; ispell
(setq ispell-local-dictionary "en_GB")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "DejaVuSansM Nerd Font Mono" :foundry "nil" :slant normal :weight regular :height 120 :width normal)))))
