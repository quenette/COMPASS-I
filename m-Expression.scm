; 
; Semantic algebras...
;   Domain E in Expr 
;
; Abstract syntax...
;  E in Expr
;
;  Expr ::= pc | ...
;
; Valuation functions...
;  Expr[[E]]          = () -> Expr
;    (PointcutCall[[id el]] = () -> UnaryOp)
;
; Developed for guile scheme v 1.8.7


(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-execution-store.scm")


; Construction operations ...
; None  (use each of the constructors of the non-terminals)


; Other operations ...

; e-fc : Expr -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )             ; i.e. Expr -> T(Val)
(define C-e-E e-E)
(define e-E
   (lambda (E)
      (lambda (jp zeta rho s)
         (cond
            ((pc? E) ((e-pc E) jp zeta rho s))
            (else ((C-e-E E) jp zeta rho s))
))))


; Predicate operations...

; E? : Any -> Bool
(define C-E? E?)
(define E?
   (lambda (E)
      (cond 
         ((has-kind? E)
            (cond 
               ((pc? E) #t)
               ((C-E? E) #t)
               (else #f)
         ))
         (else #f)
)))


; Extractors for the data type...


; Valuation functions ...

; Expr[[E]] = () -> Expr
(define C-ast->E' (copy-tree ast->E'))
(define ast->E'
   (lambda (py_ast_var)
      ; First - work out what type of expression this is...
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "PointcutCall" node_type)
                 ; Second - valuate the code
                 (ast->pc py_ast_var)
              )
              (else (C-ast->E' py_ast_var))
))))

