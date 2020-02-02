;;; init.el --- The Special Sauce -*- Mode: Emacs-Lisp -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Commentary:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Default Mode Settings
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode +1)
(global-auto-revert-mode +1)
(show-paren-mode +1)
(electric-pair-mode +1)
(global-linum-mode +1)

(setf mouse-wheel-scroll-amount '(1)
      mouse-wheel-progressive-speed nil
      mouse-wheel-tilt-scroll t
      mouse-wheel-flip-direction t
      overflow-newline-into-fringe t
      indicate-buffer-boundaries 'left
      indicate-empty-lines t
      inhibit-startup-screen t
      dired-listing-switches "-Fal"
      custom-file "~/.emacs.d/custom.el"
      upstream-dir "~/.emacs.d/upstream/"
      load-prefer-newer t)

(if (file-exists-p custom-file)
    (load custom-file))

(open-dribble-file "~/.emacs.d/dribble")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Manually installed packages
(defun upstream (package)
  "Return the path of a package being maintained through git, and
adds it to `load-path'."
  (let ((path (concat upstream-dir package)))
    (add-to-list 'load-path path)
    path))
(upstream "use-package")
(upstream "org-mime")
(upstream "org-journal")
(upstream "swiper")
(upstream "elfeed")
(upstream "emms")
(upstream "bbdb")
(upstream "racket-mode")
;; (upstream "geiser")
;; (upstream "geiser/build/elisp/geiser-load")
;; (upstream "magit")  ; something about libgit2 bindings not existing
;; (upstream "forge")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Start the server, init should only need to be loaded once per
;;; session.
(require 'server)
(if (not (server-running-p))
    (server-start))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Initialize Package Repositories
(require 'package)
(setf package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
	("melpa" . "https://melpa.org/packages/")))
(package-initialize)

(require 'use-package)
(require 'bind-key)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Don't litter the file tree
(defvar my-backup-directory "~/.emacs.d/tmp/")
(setq
 backup-directory-alist `((".*" . ,my-backup-directory))
 auto-save-file-name-transforms `((".*" ,my-backup-directory t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Packages:
(use-package simple)

(use-package delight
  :ensure t
  :config
  (delight 'auto-fill-function " ⏎" t))
(use-package diminish
  :ensure t
  :config
  (diminish 'auto-revert-mode))

(use-package eldoc :diminish)

(use-package paredit
  :ensure t
  :delight " ()")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Rest Thine Eyes
(progn
  (use-package tao-theme :ensure t
    :config
    (setf tao-theme-use-sepia nil
	  tao-theme-use-boxes t)
    (load-theme 'tao-yang))
  (use-package circadian :ensure t
    :init
    (setf calendar-latitude 52.373169
	  calendar-longitude 4.890660
	  circadian-themes '((:sunrise . tao-yang)
			     (:sunset . tao-yin)))))
(circadian-setup)

(set-face-attribute 'default nil
		    :family "Fira Mono"
		    :foundry "CTDB"
		    :slant 'normal
		    :weight 'normal
		    :height 158
		    :width 'normal)
(use-package hide-mode-line :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Improved Interface Modes

;;; Incremental Vertical completYon
(require 'ivy)
(require 'swiper)
(require 'counsel)
(use-package ivy
  :diminish
  :bind (("C-c s" . 'swiper)
	 ("C-c r" . 'ivy-resume)
	 ("C-c f d" . counsel-describe-face)
	 ("C-c f f" . 'counsel-faces))
  :init
  (ivy-mode +1))

;;; Which Key was it Again?
(use-package which-key
  :ensure t
  :delight " 👁"
  :config (which-key-mode +1))

;;; Don't miss the trees for the forest
(use-package treemacs
  :ensure t
  :bind (("C-c t" . treemacs))
  :config
  (setf treemacs-indentation 1))

(use-package ace-window
  :ensure t
  :bind (("C-c o" . 'ace-window))
  :config
  (setf aw-scope 'frame))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; God's own porcelain
(use-package magit
  :ensure t
  :bind (("C-c g g" . 'magit-status)
	 ("C-c g b" . 'magit-blame-popup)
	 ("C-c g c" . 'counsel-git)))

(use-package forge :ensure t)

(use-package magithub :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; The Mother of all Markup

(use-package org
  :ensure t
  :bind (("C-c c" . 'org-capture)
	 ("C-c a" . 'org-agenda)
	 ("C-c l" . 'org-store-link)
	 :map org-mode-map
	 ("C-c ," . 'org-time-stamp-inactive))
  :config
  (add-to-list 'org-mode-hook 'auto-fill-mode)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((shell . t)
     (ledger . t)))
  (setf
   org-clock-in-switch-to-state nil
   org-clock-out-remove-zero-time-clocks t
   org-adapt-indentation nil
   org-capture-templates
   '(("c" "Clock entry" entry
      (file+headline "~/org/life.org" "Clocks")
      "* %?" :clock-in t :clock-keep t)
     ("e" "Event" entry
      (file+headline "~/Documents/org/life.org" "Events")
      "* %?
%^t" :prepend t :empty-lines 1 :empty-lines-before 1 :empty-lines-after 1)
     ("n" "Note" entry
      (file+headline "~/Documents/org/life.org" "Notes")
      "* %?
" :prepend t :empty-lines 1 :empty-lines-before 1 :empty-lines-after 1)
     ("b" "Blog post" entry
      (file "~/Documents/org/blog.org")
      "* %^{Title}
:PROPERTIES:
:EXPORT_FILE_NAME: %^{Export File Name}
:EXPORT_DATE: %U
:END:
%?
" :prepend t :jump-to-captured t :empty-lines 1 :empty-lines-before 1 :empty-lines-after 1)
     ("t" "TODO task" entry
      (file+headline "~/Documents/org/life.org" "Tasks")
      "* TODO %?  :task:" :prepend t :empty-lines 1 :empty-lines-before 1 :empty-lines-after 1)
     ("j" "Journal entry" entry
      (function org-journal-find-location)
      "* %(format-time-string org-journal-time-format)%^{Title}
%i%?"))))

(use-package org-journal
  :ensure t
  :bind (("C-c j" . 'org-journal-new-entry))
  :config
  (setf org-journal-dir "~/Documents/org/journal/"
	org-journal-enable-agenda-integration t
	org-journal-file-format "%Y-%U"
	org-journal-file-header "# -*- Mode: Org-Journal -*-"
	org-journal-file-type 'weekly
	org-journal-follow-mode t))

(use-package org-mru-clock :ensure t
  :config
  (setf org-mru-clock-capture-if-no-match '((".*" . "c"))))

(use-package pdf-tools
  :ensure t
  :init (pdf-tools-install))

(use-package org-pdfview :ensure t)

(use-package calfw :ensure t)
(use-package calfw-org :ensure t
  :bind (("C-c d" . 'cfw:open-org-calendar)))

(use-package org-mru-clock :ensure t)

(use-package reftex :ensure t)
(add-hook 'latex-mode-hook
	  'turn-on-reftex)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Comms
(use-package erc
  :ensure t
  :config
  (setf erc-hide-list '("JOIN" "PART" "QUIT")))

(use-package offlineimap :ensure t)

(use-package mu4e
  :bind (("C-c m" . 'mu4e)
	 :map mu4e-headers-mode-map
	 ("C-c l" . 'org-mu4e-store-and-capture)
	 :map mu4e-view-mode-map
	 ("<tab>" . 'shr-next-link)
	 ("<backtab>" . 'shr-previous-link))
  :config
  (setf user-full-name "Jacob A. Sonnenberg"
	user-mail-address "jacobsonnenberg0@gmail.com"
	user-real-login-name "jas"
	smtpmail-smtp-server "smtp.gmail.com"
	smtpmail-smtp-service 25
	mu4e-attachment-dir "/home/jas/archive"
	mu4e-bookmarks
	'(("flag:unread AND NOT flag:trashed date:7d..now" "Recent unread messages" 114)
	  ("flag:unread AND NOT flag:trashed" "Unread messages" 117)
	  ("date:today..now" "Today's messages" 116)
	  ("date:7d..now" "Last 7 days" 119)
	  ("mime:image/*" "Messages with images" 112))
	mu4e-headers-results-limit 500
	mu4e-view-prefer-html t
	mu4e-view-show-addresses t
	mu4e-view-show-images t))

;; (use-package htmlize :ensure t)
(use-package org-mime)

(use-package elfeed
  :init 
  (use-package emms :ensure t
    :bind (("C-c e p" . 'emms-pause)
	   ("C-c e f" . 'emms-seek-formward)
	   ("C-c e b" . 'emms-seek-backward)
	   ("C-c e s" . 'emms-seek)
	   ("C-c e t" . 'emms-seek-to))
    :config
    (require 'emms-setup)
    (emms-standard)
    (emms-default-players)
    (emms-mode-line -1))
  :config
  (setf elfeed-feeds
	'("http://lambda-the-ultimate.org/rss.xml"
	  "https://www.joelonsoftware.com/feed/"
	  "https://planet.lisp.org/rss20.xml"
	  "http://feed.nashownotes.com/rss.xml"
	  "http://musicforprogramming.net/rss.php"
	  ;;"https://www.gutenberg.org/cache/epub/feeds/today.rss"
	  ;;"http://podcasts.joerogan.net/feed"
	  ;;"http://rss.sciencedirect.com/publication/science/03043975"
	  ;;"https://www.nytimes.com/svc/collections/v1/publish/https://www.nytimes.com/section/world/rss.xml"
	  ))
  (elfeed-update))

(use-package easy-hugo :ensure t
  :bind (("C-c b" . 'easy-hugo))
  :config
  (setf easy-hugo-basedir "/home/jas/hugo/blog/"
	easy-hugo-postdir "content/posts"))

(use-package ox-hugo :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Referencers
(use-package bbdb :ensure t
  :config
  (setf bbdb-check-postcode nil
	bbdb-default-country "Netherlands"
	bbdb-phone-style nil))
(use-package counsel-bbdb :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Language Configuration

(use-package company
  :ensure t
  :diminish
  :init (setf company-idle-delay nil
	      company-tooltip-align-annotations t)
  :bind (:map prog-mode-map
	      ("C-i" . 'company-indent-or-complete-common)
	      ("C-M-i" . 'completion-at-point)))

(global-company-mode)

(use-package elisp-mode
  :config
  (add-to-list 'emacs-lisp-mode-hook 'paredit-mode))

(use-package racket-mode
  :config
  (add-to-list 'racket-mode-hook 'geiser-mode))
;;; upstreaming didn't work?
(use-package geiser :ensure t)

;;; init.el ends here
