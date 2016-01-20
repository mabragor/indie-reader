
;; SBCL has type restrictions, imposed on *READTABLE* variable.
;; In order to circumvent this, we need a new, type-restriction-ignoring special operator

(in-package #:sb-c)


;;; If there is a definition in LEXENV-VARS, just set that, otherwise
;;; look at the global information. If the name is for a constant,
;;; then error out.
(def-ir1-translator just-setq ((&whole source &rest things) start next result)
  (let ((len (length things)))
    (when (oddp len)
      (compiler-error "odd number of args to SETQ: ~S" source))
    (if (= len 2)
        (let* ((name (first things))
               (value-form (second things))
               (leaf (or (lexenv-find name vars) (find-free-var name))))
          (etypecase leaf
            (leaf
             (when (constant-p leaf)
               (compiler-error "~S is a constant and thus can't be set." name))
             (when (lambda-var-p leaf)
               (let ((home-lambda (ctran-home-lambda-or-null start)))
                 (when home-lambda
                   (sset-adjoin leaf (lambda-calls-or-closes home-lambda))))
               (when (lambda-var-ignorep leaf)
                 ;; ANSI's definition of "Declaration IGNORE, IGNORABLE"
                 ;; requires that this be a STYLE-WARNING, not a full warning.
                 (compiler-style-warn
                  "~S is being set even though it was declared to be ignored."
                  name)))
	     (just-setq-var start next result leaf value-form))
            (cons
             (aver (eq (car leaf) 'macro))
             ;; FIXME: [Free] type declaration. -- APD, 2002-01-26
             (ir1-convert start next result
                          `(setf ,(cdr leaf) ,(second things))))
            (heap-alien-info
             (ir1-convert start next result
                          `(%set-heap-alien ',leaf ,(second things))))))
        (collect ((sets))
          (do ((thing things (cddr thing)))
              ((endp thing)
               (ir1-convert-progn-body start next result (sets)))
            (sets `(setq ,(first thing) ,(second thing))))))))

;;; This is kind of like REFERENCE-LEAF, but we generate a SET node.
;;; This should only need to be called in SETQ.
(defun just-setq-var (start next result var value)
  (declare (type ctran start next) (type (or lvar null) result)
           (type basic-var var))
  (let ((dest-ctran (make-ctran))
        (dest-lvar (make-lvar))
        (type (or (lexenv-find var type-restrictions)
                  (leaf-type var))))
    (ir1-convert start dest-ctran dest-lvar value)
    (let ((res (make-set :var var :value dest-lvar)))
      (setf (lvar-dest dest-lvar) res)
      (setf (leaf-ever-used var) t)
      (push res (basic-var-sets var))
      (link-node-to-previous-ctran res dest-ctran)
      (use-continuation res next result))))


(export '(just-setq))
