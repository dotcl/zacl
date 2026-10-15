;;;; package-sys.lisp

(in-package #:zacl)

(defvar sys:*tilde-expand-namestrings* nil)

(define-symbol-macro sys:*current-process* (current-process))

(defun sys::thread-bindstack-index (&rest args)
  (declare (ignore args))
  (error "Not implemented"))

(defun sys:defpatch (&rest args)
  (declare (ignore args)))

(defun sys:command-line-arguments ()
  (command-line-arguments))

(defun sys:reap-os-subprocess (&key pid wait)
  (declare (ignore pid wait))
  (error "Not implemented -- SYS:REAP-OS-SUBPROCESS"))

#+ccl 
(defmacro sys:with-timeout ((timeout &body timeout-body) &body body)
  `(ccl::with-timeout (,timeout ,@timeout-body) ,@body))

#-(or ccl egcl)
(defmacro sys:with-timeout ((timeout &body timeout-body) &body body)
  `(handler-case
       (with-timeout (,timeout) ,@body)
     (timeout () ,@timeout-body)))

;; EGCL has no asynchronous thread interruption yet, so its
;; bordeaux-threads port makes WITH-TIMEOUT signal rather than pretend:
;; the body runs without a deadline here, and the timeout forms never
;; run.  AllegroServe wraps every request read in this macro
;; (with-timeout-local, header-read-timeout), so the alternative is no
;; server at all; the socket's own receive timeout, where one is set, is
;; the backstop.  Revisit when EGCL can interrupt a thread.
#+egcl
(defmacro sys:with-timeout ((timeout &body timeout-body) &body body)
  (declare (ignore timeout timeout-body))
  `(progn ,@body))

(defun sys:gsgc-parameter (kind)
  (declare (ignore kind))
  42)
