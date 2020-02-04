;;; custom.el --- Customizations made through the interface
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-revert-use-notify t)
 '(auto-revert-verbose nil)
 '(custom-safe-themes
   '("801a567c87755fe65d0484cb2bded31a4c5bb24fd1fe0ed11e6c02254017acb2" default))
 '(debug-on-error t)
 '(elfeed-feeds
   '("https://www.dancarlin.com/dchh-feedburner.xml" "http://lambda-the-ultimate.org/rss.xml" "https://www.joelonsoftware.com/feed/" "https://planet.lisp.org/rss20.xml" "http://feed.nashownotes.com/rss.xml" "http://musicforprogramming.net/rss.php"))
 '(erc-nick "gebrek")
 '(erc-server "irc.freenode.net")
 '(erc-user-full-name "JA Sonnenberg")
 '(global-auto-revert-mode t)
 '(magithub-clone-default-directory "~/Repos/")
 '(org-agenda-files '("~/org/life.org"))
 '(org-capture-templates
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
     ("N" "Extended Note" entry
      (file+headline "~/Documents/org/life.org" "Notes")
      "* %?
%U
%a" :empty-lines-before 1 :empty-lines-after 1)
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
     ("j" "Journal entry" entry #'org-journal-find-location "* %(format-time-string org-journal-time-format)%^{Title}
%i%?")))
 '(package-selected-packages
   '(edbi notmuch flymake-racket flycheck mu4e forge magithub geiser elisp-mode emms company counsel-bbdb bbdb ox-hugo easy-hugo offlineimap calfw-org calfw org-pdfview pdf-tools org-mru-clock org-journal magit ace-window treemacs which-key ivy hide-mode-line circadian tao-theme paredit diminish delight))
 '(send-mail-function 'smtpmail-send-it))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-drawer ((t (:foreground "#9E9E9E")))))
