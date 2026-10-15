;;;; package-mp.lisp
;;;
;;; Multiprocessing.
;;;

(in-package #:zacl)

(defmacro mp:with-process-lock ((lock-form) &body body)
  (declare (ignorable lock-form))
  `(with-lock-held (,lock-form) ,@body))

(defun mp:make-process-lock (&key name)
  (make-lock name))

;;; Allegro's without-scheduling keeps every other thread from running
;;; for the body, and AllegroServe leans on it as a critical section
;;; around its shared free lists (the header parse objects in
;;; parse.cl, the client's header-line buffers, the proxy's) in its
;;; non-SMP forms, which are the ones this port compiles.  A plain
;;; progn here let two request threads pop the same parse object and
;;; corrupt each other's header parsing: a few requests in a thousand
;;; answered an empty 400 or died with an array index out of bounds
;;; under thirty concurrent streams.  One lock, held for the body, is
;;; the exclusion the macro promised; the bodies are a push or a pop.
(defvar *scheduling-lock* (bordeaux-threads:make-recursive-lock "zacl without-scheduling"))

(defmacro mp:without-scheduling (&body body)
  `(bordeaux-threads:with-recursive-lock-held (*scheduling-lock*) ,@body))


;;; Gates

(defgeneric mp:make-gate (initial-state))

(defgeneric mp:open-gate (gate))

(defgeneric mp:close-gate (gate))

(defgeneric mp:gate-open-p (gate))


;;; Processes

(defclass mp:process-lock (excl:lockable-object) ())

(defgeneric mp:make-process (&key name initial-bindings)
  (:method (&key name initial-bindings)
    (make-process name :class 'process
                  :initial-bindings initial-bindings)))

(defgeneric mp:process-thread (process)
  (:method ((process process))
    (thread process)))

(defgeneric mp:process-name (process)
  (:method (process)
    (process-name process)))

(def-fake-slot mp:process-keeps-lisp-alive-p process :default-value nil)

(defgeneric mp:process-add-run-reason (process object)
  (:method (process object)
    (add-run-reason process object)))

(defgeneric mp:process-revoke-run-reason (process object)
  (:method (process object)
    (revoke-run-reason process object)))

(defgeneric mp:process-allow-schedule ()
  (:method ()
    (yield (current-process))))

(defgeneric mp:process-kill (process)
  (:method (process)
    (kill process)))

(defgeneric mp:process-preset (process fun &rest args)
  (:method (process fun &rest args)
    (apply #'preset process fun args)))

(defgeneric mp:process-run-function (name-or-plist function &rest arguments)
  (:method ((name string) function &rest arguments)
    (apply #'mp:process-run-function (list :name name) function arguments))
  (:method ((plist list) function &rest arguments)
    (apply #'process-run-function plist
           function arguments)))

(defgeneric mp:process-run-reasons (process)
  (:method (process)
    (run-reasons process)))


;;; Queues

;; FIXME: Timeouts.

(defclass mp:queue ()
  ((queue
    :initarg :queue
    :accessor queue
    :initform (make-queue :simple-queue))
   (lock
    :initform (make-lock)
    :reader lock)))

(defgeneric mp:enqueue (queue thing)
  (:method (queue thing)
    (with-lock-held ((lock queue))
      (qpush (queue queue) thing))))

;;
;; The #-nil and #+nil below used to be #-sbcl and #+sbcl, but that
;; caused an accept error in http-accept-thread. 
;;
(defgeneric mp:dequeue (queue &key wait empty-queue-result whostate)
  (:method (queue &key wait empty-queue-result whostate)
    (declare (ignore whostate #-nil wait))
    (with-lock-held ((lock queue))
      (qpop (queue queue) empty-queue-result #+nil wait))))



(defun mp:wait-for-input-available (stream-or-fds
                                    &key wait-function whostate timeout)
  (declare (ignore stream-or-fds wait-function whostate timeout))
  ;; Only used by aserve cgi
  (error "Not implemented -- MP:WAIT-FOR-INPUT-AVAILABLE"))
