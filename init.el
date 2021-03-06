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
      dribble-dir "~/.emacs.d/dribble/"
      load-prefer-newer t)

(if (file-exists-p custom-file)
    (load custom-file))

(defun try-open-dribble-file (&optional m)
  (let* ((n (or m 0))
	 (df (concat dribble-dir (number-to-string n))))
    (if (file-exists-p df)
	(try-open-dribble-file (1+ n))
      (open-dribble-file df))))

(try-open-dribble-file 0)

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
(upstream "define-word")
;; (upstream "geiser")
;; (upstream "geiser/build/elisp/geiser-load")
;; (upstream "magit")  ; something about libgit2 bindings not existing
;; (upstream "forge")
(upstream "fira-code-emacs")
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

(require 'fira-code)
(add-hook 'prog-mode-hook 'fira-code-mode)
(defun load-fira-mono ()
  (interactive)
  (set-face-attribute 'default nil
		      :family "Fira Mono"
		      :foundry "CTDB"
		      :slant 'normal
		      :weight 'normal
		      :height 154
		      :width 'normal))
(load-fira-mono)
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
	 ("C-c f f" . 'counsel-faces)
	 ("C-c f r" . 'load-fira-mono))
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
  (setf treemacs-indentation 1
	treemacs-width 30))

(use-package ace-window
  :ensure t
  :bind (("C-c o" . 'ace-window))
  :config
  (setf aw-scope 'frame))

(defun define-word-display-definition (message)
  (display-message-or-buffer message "*Definition*"))

(use-package define-word
  :bind (("C-c d d" . 'define-word-at-point)
	 ("C-c d w" . 'define-word))
  :config
  (setf define-word-limit 20
	define-word-displayfn-alist
	'((wordnik . define-word-display-definition)
	  (openthesaurus . define-word-display-definition)
	  (webster . define-word-display-definition))))
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
;;; Database Interface

(upstream "edbi-sqlite")
(use-package edbi :ensure t)
(use-package edbi-sqlite)

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
  (add-hook 'org-mode-hook 'auto-fill-mode)
  (add-hook 'org-mode-hook 'flyspell-mode)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((shell . t)
     (ledger . t)
     (R . t)))
  (setf
   org-latex-pdf-process
   (list "latexmk -f -bibtex -pdf %f")
   org-clock-in-switch-to-state nil
   org-clock-out-remove-zero-time-clocks t
   org-adapt-indentation nil
   org-ellipsis "…"
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
  :init (pdf-tools-install)
  :config (add-hook 'pdf-view-mode-hook (lambda () (linum-mode -1))))

(use-package org-pdfview :ensure t)

(use-package calfw :ensure t)
(use-package calfw-org :ensure t
  :bind (("C-c C" . 'cfw:open-org-calendar)))

(use-package org-mru-clock :ensure t)

(use-package bibretrieve :ensure t)
(use-package reftex :ensure t)
(add-hook 'latex-mode-hook
	  'turn-on-reftex)
(use-package org-ref :ensure t
  :config
  (setf org-ref-bibliography-notes "~/Documents/research/notes.org"
	org-ref-default-bibliography '("~/Documents/research/master.bib")
	org-ref-pdf-directory "~/Documents/research/bibtex-pdfs/"))

(defun org-mode-reftex-setup ()
  (load-library "reftex")
  (and (buffer-file-name) (file-exists-p (buffer-file-name))
       (progn
	 ;;enable auto-revert-mode to update reftex when bibtex file changes on disk
	 (global-auto-revert-mode t)
	 (reftex-parse-all)
	 ;;add a custom reftex cite format to insert links
	 (reftex-set-cite-format
	  '((?b . "[[bib:%l][%l-bib]]")
	    (?n . "[[notes:%l][%l-notes]]")
	    (?p . "[[papers:%l][%l-paper]]")
	    (?t . "%t")
	    (?h . "** %t\n:PROPERTIES:\n:Custom_ID: %l\n:END:\n[[papers:%l][%l-paper]]")))))
  (define-key org-mode-map (kbd "C-c )") 'reftex-citation)
  (define-key org-mode-map (kbd "C-c (") 'org-mode-reftex-search))

(add-hook 'org-mode-hook 'org-mode-reftex-setup)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Comms
(use-package eww
  :config
  (add-hook 'eww-mode-hook (lambda () (linum-mode -1))))

(use-package erc
  :ensure t
  :config
  (setf erc-hide-list '("JOIN" "PART" "QUIT")
	erc-prompt-for-nickserv-password nil
	erc-fill-column 90))

(use-package offlineimap :ensure t)

(add-to-list 'load-path "/home/jas/Repos/mu/mu4e")

(use-package mu4e
  :bind (;("C-c m" . 'mu4e)
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
	;; mu4e-bookmarks
	;; '(("flag:unread AND NOT flag:trashed date:7d..now" "Recent unread messages" 114)
	;;   ("flag:unread AND NOT flag:trashed" "Unread messages" 117)
	;;   ("date:today..now" "Today's messages" 116)
	;;   ("date:7d..now" "Last 7 days" 119)
	;;   ("mime:image/*" "Messages with images" 112))
	mu4e-headers-results-limit 500
	mu4e-view-prefer-html t
	mu4e-view-show-addresses t
	mu4e-view-show-images t))

(use-package notmuch :ensure t
  :bind ("C-c m" . 'notmuch))

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
	  "https://feeds.feedburner.com/steveklabnik/words"
	  "https://fivethirtyeight.com/politics/feed/"
	  "http://feeds.feedburner.com/realclearpolitics/qlMj"
	  "https://feedpress.me/drudgereportfeed"
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

(use-package flymake-rust :ensure t)
(use-package racer :ensure t
  :config
  (setf racer-rust-src-path "/home/jas/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src"))
(use-package cargo :ensure t)
(use-package rust-mode :ensure t
  :config
  (add-hook 'rust-mode-hook 'flymake-mode)
  (add-hook 'rust-mode-hook 'racer-mode)
  (add-hook 'rust-mode-hook 'cargo-minor-mode))

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
  (delight 'emacs-lisp-mode "Elisp" t)
  (add-hook 'emacs-lisp-mode-hook 'paredit-mode))

(use-package racket-mode
  :delight "λ"
  :config
  (add-hook 'racket-mode-hook 'geiser-mode)
  (add-hook 'racket-mode-hook 'paredit-mode))
;;; upstreaming didn't work?
(use-package geiser :ensure t
  :config
  (add-hook 'geiser-repl-mode-hook 'paredit-mode))

(use-package flymake
  :ensure t
  :bind (:map flymake-mode-map
	 ("C-c ! n" . 'flymake-goto-next-error)
	 ("C-c ! p" . 'flymake-goto-prev-error)
	 ("C-c ! l" . 'flymake-show-diagnostics-buffer)
	 ;; ("C-c ! !" . 'flymake-che)
	 ))
(use-package flymake-racket
  :ensure t
  :commands (flymake-racket-add-hook)
  :init
  (add-hook 'scheme-mode-hook #'flymake-racket-add-hook)
  (add-hook 'racket-mode-hook #'flymake-racket-add-hook)
  (add-hook 'racket-mode-hook #'flymake-mode-on))


(use-package ess :ensure t)

;;; init.el ends here
(load "~/.emacs.d/personal.el")
