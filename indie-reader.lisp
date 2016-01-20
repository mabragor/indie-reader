;;;; indie-reader.lisp

;;; "indie-reader" goes here. Hacks and glory await!

(in-package #:com.informatimago.common-lisp.lisp-reader.reader)

;; Add ,. (the destructive splicing) -- which is part of the standard
(defun reader-macro-comma (stream ch)
  "Standard , macro reader."
  (declare (ignore ch))
  (format t "hello~%")
  (list (let ((char (peek-char nil stream t nil t)))
	  (cond ((char= #\@ char) (read-char stream t nil t) 'splice)
		((char= #\. char) (read-char stream t nil t) 'dsplice) ; destructive-splice
		(t 'unquote)))
	(read stream t nil t)))


;;; Utility functions and macros to substitute the current reader with this one
;;; They are only used in the next file, however.

;; Already here we substitute lisp reader with Zach's one

(defmacro intern-function-to-cl (name)
  `(setf (symbol-function ',(intern (string name) "CL-USER"))
	 #',name))

(defmacro intern-functions-to-cl (&rest names)
  `(progn ,@(mapcar (lambda (x) `(intern-function-to-cl ,x)) names)))

;; (defmacro intern-symbol-to-cl (name)
;;   `(setf ,(intern (string name) "CL-USER")
;; 	 ,name))

(defmacro intern-symbol-to-cl (name)
  `(progn (unintern ',name "CL-USER")
	  ;; (shadowing-import ',name "CL-USER")
	  (setf ,(intern (string name) "CL-USER") ,name)
	  (shadowing-import ',(intern (string name) "CL-USER") ,*package*)))

  ;; `(progn (setf ,(intern (string name) "CL-USER") ,name)
  ;; 	  (shadowing-import ',(intern (string name) "CL-USER") ,*package*)))

(defmacro intern-symbols-to-cl (&rest names)
  `(progn ,@(mapcar (lambda (x) `(intern-symbol-to-cl ,x)) names)))


