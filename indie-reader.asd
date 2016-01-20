;;;; indie-reader.asd

(defpackage :indie-reader-system
  (:use :cl :asdf))

(in-package indie-reader-system)

(asdf:defsystem #:indie-reader
  :description "Slightly combed COM.INFORMATIMAGO CL reader"
  :author "Alexandr Popolitov <popolit@gmail.com>"
  :license "MIT"
  :serial t
  :version "0.1"
  :depends-on (#:defmacro-enhance #:com.informatimago.common-lisp.lisp-reader
		  #:fare-quasiquote)
  :components ((:file "package")
               (:file "indie-reader")
	       (:file "install-indie-reader")
	       ))

(defsystem :indie-reader-tests
  :description "Tests for INDIE-READER."
  :licence "MIT"
  :serial t
  :depends-on (:indie-reader :fiveam :iterate)
  :components ((:file "tests")))

(defmethod perform ((op test-op) (sys (eql (find-system :indie-reader))))
  (load-system :indie-reader-tests)
  (funcall (intern "RUN-TESTS" :indie-reader-tests)))
