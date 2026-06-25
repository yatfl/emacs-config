;; Basic
(setq inhibit-startup-screen t)
(setq display-line-numbers-type 'visual)
(global-display-line-numbers-mode)
(setq column-number-mode t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq tab-bar-auto-width t)
(setq tab-bar-tab-name-truncated-max-width 20)
(setq tab-bar-close-button-show nil)
(setq tab-bar-new-button-show nil)

(setq set-mark-command-repeat-pop t)

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
(global-set-key (kbd "C-x C-f") 'find-file)
(global-set-key (kbd "C-x C-k") 'magit-status)

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
(global-set-key (kbd "C-x C-SPC") 'imenu)

(global-set-key (kbd "C-x p") 'tab-close)
(global-set-key (kbd "C-x n") 'tab-new)

(global-set-key (kbd "C-S-p") 'tab-previous)
(global-set-key (kbd "C-S-n") 'tab-next)

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
    (markdown-toc-refresh-toc)
    (prettier-js-prettify)
    (message "Buffer formatted and toc refreshed")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; package
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
(require 'use-package)

;; modus
(setq modus-vivendi-palette-overrides
      '((bg-main "#101010")
        (fg-main "#e0e0e0")
        (bg-dim  "#252525")
        (fg-dim  "#a0a0a0")))

;; for package-install-selected-packages / package-autoremove
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(modus-vivendi))
 '(package-selected-packages
   '(company emmet-mode exec-path-from-shell glsl-mode ibuffer-vc magit
	     markdown-toc pinentry rettier-js rainbow-mode
	     transpose-frame xclip yaml-mode)))

;; ibuffer
(global-set-key (kbd "C-x b") 'ibuffer)
(global-set-key (kbd "C-x C-b") 'switch-to-buffer)

(use-package ibuffer-vc
  :ensure t
  :bind (:map ibuffer-mode-map
              ("/ V" . ibuffer-vc-set-filter-groups-by-vc-root)))

(setq ibuffer-expert t)
(setq ibuffer-use-header-line t)
(setq ibuffer-saved-filter-groups
      '(("Default"
         ("Programming" (or (mode . markdown-mode)
                            (mode . c-mode)
                            (mode . c++-mode)
                            (mode . js-mode)
                            (mode . glsl-mode)
                            (mode . emacs-lisp-mode)))
         ("Web" (or     (mode . html-mode)
                        (mode . mhtml-mode)
                        (mode . css-mode)))
         ("Json" (name . "\\.json" ))
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
(setq ido-ignore-buffers '("^ "
                           "\\*Completions\\*"
                           "\\*Shell Command Output\\*"
                           "\\*Messages\\*"
                           "\\*Ibuffer\\*"
                           "Async Shell Command"
                           "^[mM]agit.+"
                           "^\\*EGLOT.+"))

;; multiple cursors
;; (require 'multiple-cursors)
;; (global-set-key (kbd "C-x g") 'mc/edit-lines)
;; (global-set-key (kbd "C-x f") 'mc/mark-next-word-like-this)

;; eglot
(use-package eglot
  :bind (:map eglot-mode-map
              ("C-c C-r" . eglot-rename)
              ("C-c C-o" . eglot-code-actions)
              ("C-c C-h" . eldoc))
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

	      ("C-x p" . tab-close)
	      ("C-x n" . tab-new)
              ("C-S-p" . tab-previous)
              ("C-S-n" . tab-next)))

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
(put 'dired-find-alternate-file 'disabled nil)
