;;;; package-mp.lisp
;;;
;;; Multiprocessing.
;;;

(in-package #:zacl)

(defmacro mp:with-process-lock ((lock-form) &body body)
  (declare (ignorable lock-form))
  `(mp:with-lock (,lock-form) ,@body))

(defmacro mp:without-scheduling (&body body)
  `(progn ,@body))

(defmacro mp:with-timeout ((timeout &body timeout-body) &body body)
  `(handler-case
       (bt:with-timeout (,timeout) ,@body)
     (timeout () ,@timeout-body)))

(defun mp:make-process-lock (&key name)
  (mp:make-recursive-mutex (or name "No Name")))

(defun mp:make-process-run-function-allegro (plist function)
  (mp:process-run-function 
   (or (getf plist :name) "No Name")
   function
   (getf plist :initial-bindings)))

(defun mp:make-process-allegro (function &key name initial-bindings)
  (mp::make-process (or name "No name") function nil initial-bindings))

(defmethod mp:process-keeps-lisp-alive-p (argument))
(defmethod (setf mp:process-keeps-lisp-alive-p) (argument1 argument2))

(defmethod mp:process-property-list (process))
(defmethod (setf mp:process-property-list) (argument1 argument2))


(defparameter *mp-run-reasons* (make-hash-table))

(defun mp:process-add-run-reason (process object)
  (let ((before (gethash process *mp-run-reasons*)))
    (if before
        (setf (gethash process *mp-run-reasons*)
              (cons object before))
        (setf (gethash process *mp-run-reasons*)
              (list object))))
  (unless (mp:process-active-p process)
    (mp:process-enable process)))

(defun mp:process-revoke-run-reason (process object)
  (setf (gethash process *mp-run-reasons*)
        (remove object (gethash process *mp-run-reasons*)))
  (when (null (gethash process *mp-run-reasons*))
    (when (mp:process-active-p process)
      (mp:process-suspend process))))

(defun mp:process-run-reasons (process)
  (gethash process *mp-run-reasons*))

(defun mp:process-allow-schedule ()
  (mp:process-yield))


(defclass mp:process-lock (excl:lockable-object) ())


#|


;;; Gates

(defgeneric mp:make-gate (initial-state))

(defgeneric mp:open-gate (gate))

(defgeneric mp:close-gate (gate))

(defgeneric mp:gate-open-p (gate))


;;; Processes

(defclass mp:process-lock (excl:lockable-object) ())

(defgeneric mp:make-process-allegro (&key name initial-bindings)
  (:method (&key name initial-bindings)
    (make-process name :class 'process
                  :initial-bindings initial-bindings)))

(defgeneric mp:process-thread (process))

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

|#
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

(defgeneric mp:dequeue (queue &key wait empty-queue-result whostate)
  (:method (queue &key wait empty-queue-result whostate)
    (declare (ignore whostate wait))
    (with-lock-held ((lock queue))
      (qpop (queue queue) empty-queue-result))))

(defun mp:wait-for-input-available (stream-or-fds
                                    &key wait-function whostate timeout)
  (declare (ignore stream-or-fds wait-function whostate timeout))
  ;; Only used by aserve cgi
  (error "Not implemented -- MP:WAIT-FOR-INPUT-AVAILABLE"))


