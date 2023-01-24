;;;; clasp-specific.lisp

(in-package #:zacl)

(defun fstat-size (fd)
  (multiple-value-bind
        (size mtime mode)
      (ext:fstat fd)
    size))

(defun fstat-mtime (fd)
  (multiple-value-bind
        (size mtime mode)
      (ext:fstat fd)
    mtime))

(defun stat-mode (pathname)
  (multiple-value-bind
        (size mtime mode)
      (ext:stat pathname)
    mode))

(defun stat-mtime (pathname)
  (multiple-value-bind
        (size mtime mode)
      (ext:stat pathname)
    mtime))

(defun file-kind (pathname)
  (core:file-kind pathname nil))

(defun stream-unix-fd (stream)
  ;; Only used for input in aserve
  (ext:file-stream-file-descriptor stream))

(defmethod socket-error-identifier ((condition sb-bsd-sockets:socket-error))
  (sb-bsd-sockets::socket-error-symbol condition))

(defmethod socket-error-code ((condition sb-bsd-sockets:socket-error))
  (sb-bsd-sockets::socket-error-errno condition))

#|
(with-open-file (stream "/usr/share/dict/words" :direction :input)
  (stream-unix-fd stream))

(with-open-file (stream "/usr/share/dict/words" :direction :input)
  (fstat-size (stream-unix-fd stream)))

(with-open-file (stream "/usr/share/dict/words" :direction :input)
  (fstat-mtime (stream-unix-fd stream)))

(stat-mode "/usr/share/dict/words")

(file-kind "/usr/share/dict/words")

(stat-mtime "/usr/share/dict/words")
|#




(defclass excl:terminal-simple-stream (t) ())
