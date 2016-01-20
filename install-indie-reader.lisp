
(in-package #:com.informatimago.common-lisp.lisp-reader.reader)

;; I want this thing to be read-atomic
(progn (intern-functions-to-cl copy-readtable
			       make-dispatch-macro-character
			       read read-preserving-whitespace
			       read-delimited-list
			       read-from-string
			       readtable-case readtablep
			       set-dispatch-macro-character get-dispatch-macro-character
			       set-macro-character get-macro-character
			       set-syntax-from-char)

       (intern-symbols-to-cl ;; readtable ; a class-name, not a variable
	;; with-standard-io-syntax ; I'm not sure it will work this simple with macros...
	*read-base* *read-default-float-format* *read-eval*
	*read-suppress* *readtable*
	;; ;; KLUDGE for SLIME to work
	;; case syntax-table parse-token
	)

       #+sbcl
       (sb-c:just-setq cl-user::*readtable* (copy-readtable nil))
       #-sbcl
       (setf cl-user::*readtable* (copy-readtable nil))
       
       ;; (fare-quasiquote:enable-quasiquote)
       (set-macro-character #\` (fare-quasiquote::backquote-reader nil) nil)
       (set-macro-character #\, #'fare-quasiquote::read-comma nil)
       (set-dispatch-macro-character #\# #\( #'fare-quasiquote::read-hash-paren)
       (set-dispatch-macro-character #\# #\. #'fare-quasiquote::read-hash-dot)

       ;; (setf swank/sbcl::*shebang-readtable* (swank/sbcl::create-shebang-readtable))
       ;; (setf swank::*default-readtable-alist* (swank::default-readtable-alist))
       )


