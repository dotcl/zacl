;;;; -*- coding: utf-8 -*-

(asdf:defsystem #:setup-cl+ssl :description
 "The Gendl® setup-cl+ssl Subsystem" :author "Genworks International"
 :license "Affero Gnu Public License (http://www.gnu.org/licenses/)"
 :serial t :version "20220911" :depends-on (:cffi) :components
 ((:file "source/setup")))
