;;;; zacl-tests.asd

(asdf:defsystem #:zacl-tests
  :serial t
  ;; The Quicklisp release of AllegroServe defines the system ZASERVE; no
  ;; system named ASERVE exists any more.
  :depends-on (#:zacl #:fiveam #:zaserve)
  :components ((:file "tests")))
