;
; Semantic algebras...
;   Domain re in Return
;    (Domain E in Expr)
;    (Domain tval in T(Val))
;
; Abstract syntax...
;  re in Return
;
;  Return      ::= < 'return E >
;
; Valuation functions...
;  Return[[k_re E]]           = () -> Return
;  ReturnApply[[k_re E]       = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )
;
; Developed for guile scheme v 1.8.7

(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-execution-store.scm")
(load "c-all-expressions.scm")


; Construction operations ...

; make-re : Expr -> Return
(define make-re
   (lambda (E)
      (list 'return E)
))


; Other operations ...

; "Apply"
; e-re : Return -> ( JP -> Mot* -> Env -> Sto ) -> ( Val -> Mot* -> Env' -> Sto' )            ; i.e Return -> T(Val)
(define e-re
   (lambda (re)
      (lambda (jp zeta rho s)
          ((e-E (re->E re)) jp zeta rho s)
)))

; Predicate operations...

; re? : Any -> Bool
(define re?
   (lambda (re)
      (cond 
         ((and (has-kind? re) (eqv? (re->kind re) 'return)) #t)
         (else #f)
)))


; Extraction operations...

; re->kind : Return -> Kind
(define re->kind
   (lambda (re)
      (car re)
))

; re->E : Return -> Expr
(define re->E
   (lambda (re)
      (cadr re)
))


; Valuation functions ...

; Return[[k_re E]] = () -> Return
(define ast->re
   (lambda (py_ast_var)
      ; First - work out what type of expression this is...
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "Return" node_type)
                 ; Second - valuate the code
                 (let ((E    (ast->E (string-append py_ast_var ".children()[0][1]"))))
                      (make-re E)
))))))

; ReturnApply[[k_re E]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )  ; i.e () -> T(Val)
(define ast->e-re
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-re (ast->re py_ast_var)) jp zeta rho s)
)))

