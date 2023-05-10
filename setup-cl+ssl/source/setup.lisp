(in-package :cl-user)

#+sbcl (require :sb-posix)


(defun %exe-path% ()
  (let ((directory-pathname
          #+sbcl (make-pathname :name nil :type nil :defaults sb-ext:*core-pathname*)
          #+ccl (make-pathname :name nil :type nil :defaults (first (ccl::command-line-arguments)))
          #+allegro (translate-logical-pathname "sys:")
          #+lispworks (make-pathname :name nil :type nil
                                     :defaults (first system:*line-arguments-list*))))
    (if (eql (first (pathname-directory directory-pathname)) :relative)
        (merge-pathnames directory-pathname
                         #+ccl (ccl:current-directory)
                         #+sbcl (sb-ext:parse-native-namestring (sb-unix:posix-getcwd/))
                         #-(or ccl sbcl) (truename *default-pathname-defaults*))
        directory-pathname)))


(defun setup-cl+ssl (&key openssl-bin)
  (when (and (find-package :cffi) ;; if for some strange reason it's not loaded yet
             (or (find :windows *features*) (find :mswindows *features*)))
        (if (and openssl-bin (not (probe-file openssl-bin)))
            (error "setup-cl+ssl called with ~a which was not found.~%" openssl-bin)
            (let* ((exe-path (%exe-path%))
                   (openssl-likely-locations
                     (list "C:/Program Files/OpenSSL-Win/bin/"
                           (merge-pathnames "openssl-bin/" exe-path)
                           (merge-pathnames "../openssl-bin/" exe-path)
                           (merge-pathnames "../../openssl-bin/" exe-path)))
                   (openssl-bin
                     (or openssl-bin
                         (first (remove nil (mapcar #'probe-file openssl-likely-locations))))))
              (format t "~&exe-path: ~a~%" exe-path)
              (format t "~&openssl-likely-locations: ~a~%~%" openssl-likely-locations)
              (format t "~&openssl-bin: ~a~%~%" openssl-bin)
              
              (if openssl-bin
                  (progn
                    (let ((path #+ccl (ccl:getenv "PATH")
                                #+sbcl (sb-posix:getenv "PATH")
                                #-(or ccl sbcl)
                                (error "need getenv impl for ~a.~%"
                                       (lisp-implementation-type)))
                          (openssl-component (format nil "~a;" openssl-bin)))
                      (unless (search openssl-component path)

                        (format t "~&~%Adding ~a to PATH and cffi:*foreign-library-directories*...~%"
                                openssl-component)
                  
                        #+ccl (ccl:setenv "PATH" (concatenate 'string openssl-component path))
                        #+sbcl (sb-posix:setenv
                                "PATH" (concatenate 'string openssl-component path) 1)
                        #-(or ccl sbcl)
                        (error "Need setenv impl for ~a.~%" (lisp-implementation-type))))
                    (pushnew openssl-bin
                             (symbol-value (read-from-string "cffi:*foreign-library-directories*"))
                             :test #'equalp))
                  (progn
                    (pushnew :no-zacl-cl+ssl *features*)
                    (warn "
Looked for OpenSSL libs and binaries at the likely locations:

~{~a~^,~}

but they were not found, so they were not pushed onto
cffi:*foreign-library-directories* and the keyword :no-zacl-cl+ssl was
pushed onto the common lisp *features* list. subsequent load of
zacl/zaserve may fail on its cl+ssl dependency. You will want to put
the openssl binaries there or configure cffi yourself and hope that it
will find them when needed.

You can also call the function cl-user::setup-cl+ssl
with &key argument :openssl-bin <path to openssl binaries>

"
                          openssl-likely-locations
                          ))))))

  ;;
  ;; For restarting saved images:
  ;; awful hack to get a build with cl+ssl in it to work on multiple Linuxen. 
  ;;
  (when (find-package :cl+ssl) (funcall (read-from-string "cl+ssl::reload")))

  (when (find-package :glisp)
    (let* ((gendl-home (symbol-value (read-from-string "glisp:*gendl-home*")))
           (ffi (when gendl-home
                  (probe-file
                   (merge-pathnames "quicklisp/local-projects/cl+ssl-20220707-git/src/ffi.lisp"
                                    gendl-home)))))
      (when ffi (load ffi)))))


#+sbcl (format t "PATH: ~a~%" (sb-posix:getenv "PATH"))

(setup-cl+ssl)

#+sbcl (format t "PATH: ~a~%" (sb-posix:getenv "PATH"))
