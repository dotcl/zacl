;;;; clasp-specific.lisp

(in-package #:zacl)

(defun fstat-size (fd)
  (multiple-value-bind
        (size mtime mode)
      (core:fstat fd)
    size))

(defun fstat-mtime (fd)
  (multiple-value-bind
        (size mtime mode)
      (core:fstat fd)
    mtime))

(defun stat-mode (pathname)
  (multiple-value-bind
        (size mtime mode)
      (core:stat pathname)
    mode))

(defun stat-mtime (pathname)
  (multiple-value-bind
        (size mtime mode)
      (core:stat pathname)
    mtime))

(defun file-kind (pathname)
  (core::file-kind pathname nil))

(defun stream-unix-fd (stream)
  ;; Only used for input in aserve
  (core::file-stream-fd stream))

(defmethod socket-error-identifier ((condition SB-BSD-SOCKETS:SOCKET-ERROR))
  (SB-BSD-SOCKETS::SOCKET-ERROR-SYMBOL condition))

(defmethod socket-error-code ((condition SB-BSD-SOCKETS:SOCKET-ERROR))
  (SB-BSD-SOCKETS::SOCKET-ERROR-ERRNO condition))

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




