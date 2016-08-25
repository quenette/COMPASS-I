;
; Semantic algebras...
;   Domain ty in Typedef
;    (Domain id in Id)
;    (Domain E in Expr)
;
; Abstract syntax...
;  ty in Typedef
;
;  Typedef      ::= < 'typedef td >
;
; Valuation functions...
;  Typedef[[Id c]]       = () -> Typedef
;
; Developed for guile scheme v 1.8.7


(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-execution-store.scm")
(load "c-Identifier.scm")


; Construction operations ...

; make-ty : TypeDecl -> Typedef
(define make-ty
   (lambda (td)
      (list 'typedef td)
))


; Other operations ...

; "Apply" (rhs)
; e-ty : Typedef -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )             ; i.e. Typedef -> T(Val)
(define e-ty
   (lambda (ty)
      (lambda (jp zeta rho s)
         ((e-append-type (ty->td ty)) jp zeta rho s)
)))


(define e-append-type
   (lambda (td)
      (lambda (jp zeta rho s)
         ;(display "types register is: ")(display (apply-env 'types rho))(newline)
         ((cond
            ; Normal behaviour
            ((list? (apply-env 'types rho)) (e-extend-env 'types (append (list td) (apply-env 'types rho)) (display"")))
            ; This is just to jump-start the types list if it doesn't exit yet
            (else (e-extend-env 'types (list td) (display "")))
         ) jp zeta rho s)
)))

(define e-get-type
   (lambda (sym)
      (lambda (jp zeta rho s)
         ((seq-e
            (e-apply-env 'types)
            (lambda (omega) (return-e (omega->td omega sym)))
         ) jp zeta rho s)
)))

(define omega->td
   (lambda (omega sym)
       (cond
          ; If not found, fail...
          ((eq? omega '())   (display ""))
          ; else ...
          ((string=?  (td->sym (car omega)) sym) (car omega))
          (else (omega->td (cdr omega) sym))
       )
))



; Predicate operations...

; ty? : Any -> Bool
(define ty?
   (lambda (ty)
      (cond 
         ((and (has-kind? ty) (eqv? (ty->kind ty) 'typedef)) #t)
         (else #f)
)))


; Extraction operations...

; ty->kind : Typedef -> Kind
(define ty->kind
   (lambda (ty)
      (car ty)
))

; ty->td : Typedef -> TypeDecl
(define ty->td
   (lambda (ty)
      (cadr ty)
))


; Valuation functions ...

; Typedef[[td]] = () -> Typedef
(define ast->ty
   (lambda (py_ast_var)
      ; First - work out what type of expression this is...
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "Typedef" node_type)
                 ; Second - valuate the code
                 (let ((td    (ast->td (string-append py_ast_var ".children()[0][1]"))))
                      (make-ty td)
              ))
              (else 
                 (display "Error: \"")(display node_type)(display "\" wrong for ast->ty, was expecting \"Typedef\"")(newline)
                 (exit)
              )
))))

; TypedefApply[[ty]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )    ; i.e () -> T(Val)
(define ast->e-ty
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-ty (ast->ty py_ast_var)) jp zeta rho s)
)))


