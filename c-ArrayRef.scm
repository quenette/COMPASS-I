;
; Semantic algebras...
;   Domain ar in ArrayRef
;    (Domain id in Id)
;    (Domain E in Expr)
;
; Abstract syntax...
;  ar in ArrayRef
;
;  ArrayRef      ::= < 'array-ref E_id E_c >
;
; Valuation functions...
;  ArrayRef[[Id c]]       = () -> ArrayRef
;
; Developed for guile scheme v 1.8.7


(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-execution-store.scm")
(load "c-Identifier.scm")


; Construction operations ...

; make-ar : Id -> Expr -> ArrayRef
(define make-ar
   (lambda (E_id E_c)
      (cond 
         ; The check that E_c is and Id is important here ... we dont check in later operations
         ((id? E_id) (list 'array-ref E_id E_c)) 
         ((ar? E_id) (list 'array-ref E_id E_c)) 
         ((sr? E_id) (list 'array-ref E_id E_c)) 
         ((*-uo? E_id) (list 'array-ref E_id E_c)) 
         ; else error
         (display "Array-ref requires expression to be an identifier, dereference, arrary ref or struct ref!\n")
)))


; Other operations ...

; "Apply" (rhs)
; e-ar : ArrayRef -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )             ; i.e. ArrayRef -> T(Val)
(define e-ar
   (lambda (ar)
      (lambda (jp zeta rho s)
         ((seq-e
            (e-E (ar->E_c ar))
            (lambda (v_c) (seq-e
               ;(e-apply-env (id->sym (ar->E_id ar)))
               (e-E (ar->E_id ar))
               (lambda (l) (e-apply-s (+ l v_c) ))
         ))) jp zeta rho s)
)))

; lhs
; e-ar-lhs : ArrayRef -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )             ; i.e. ArrayRef -> T(Val)
(define e-ar-lhs
   (lambda (ar v)
      (lambda (jp zeta rho s)
         ((seq-e
            (e-E (ar->E_c ar))
            (lambda (v_c) (seq-e
               ;(e-apply-env (id->sym (ar->E_id ar)))
               (e-E (ar->E_id ar))
               (lambda (l) (e-extend-s (+ l v_c) v))
         ))) jp zeta rho s)
)))


; Predicate operations...

; ar? : Any -> Bool
(define ar?
   (lambda (ar)
      (cond 
         ((and (has-kind? ar) (eqv? (ar->kind ar) 'array-ref)) #t)
         (else #f)
)))


; Extraction operations...

; ar->kind : ArrayRef -> Kind
(define ar->kind
   (lambda (ar)
      (car ar)
))

; ar->E_id : ArrayRef -> Id
(define ar->E_id
   (lambda (ar)
      (cadr ar)
))

; ar->E_c : ArrayRef -> Expr
(define ar->E_c
   (lambda (ar)
      (caddr ar)
))


; Valuation functions ...

; ArrayRef[[k_ar E_c]] = () -> ArrayRef
(define ast->ar
   (lambda (py_ast_var)
      ; First - work out what type of expression this is...
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "ArrayRef" node_type)
                 ; Second - valuate the code
                 (let ((E_id    (ast->E (string-append py_ast_var ".children()[0][1]")))
                       (E_c     (ast->E  (string-append py_ast_var ".children()[1][1]")))
                      )
                      (make-ar E_id E_c)
              ))
              (else 
                 (display "Error: \"")(display node_type)(display "\" wrong for ast->ar, was expecting \"ArrayRef\"")(newline)
                 (exit)
              )
))))

; ArrayRefApply[[ar]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )    ; i.e () -> T(Val)
(define ast->e-ar
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-ar (ast->ar py_ast_var)) jp zeta rho s)
)))


