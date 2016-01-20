
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
	  (just-setq-var start next result leaf value-form))
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
