;;;; zacl-tests.asd

(asdf:defsystem #:zacl-tests
  :description "Tests for zacl: AllegroServe served and fetched through the
  compatibility layer, chunking, prepend streams."
  :author "Zach Beane"
  :license "BSD"
  :serial t
  ;; The Quicklisp release of AllegroServe defines the system ZASERVE; no
  ;; system named ASERVE exists any more.
  :depends-on (#:zacl #:fiveam #:zaserve)
  :components ((:file "tests")))
