;;;; -*- coding: utf-8 -*-

(asdf:defsystem #:setup-cl+ssl :description
 "The Gendl® setup-cl+ssl Subsystem" :author "Genworks International"
 :license "Affero Gnu Public License (http://www.gnu.org/licenses/)"
 :serial t :version "20230524" :depends-on
 (:cffi #+sbcl :sb-posix) :components
 ((:file "source/setup")))
