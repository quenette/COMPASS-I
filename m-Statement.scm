; This Statement is the extended statement construct for the compass. It essentially extends the C one to include motions.
;
; Semantic algebras...
;   Domain S in Stmt 
;    (Domain ms in MotionStmt)
;    (Domain kappa in Cont)
;
; Abstract syntax...
;  Not in pycparser abstract syntax
;
;  Stmt ::= ... | ms
;
; Valuation functions...
;
; Developed for guile scheme v 1.8.7


(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "m-motion.scm")


; Construction operations ...


; Other operations ...

; "Apply"
; e-S : Stmt -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )                  ; i.e Stmt -> T(Val)
(define C-e-S e-S)
(define e-S
   (lambda (S)
      (lambda (jp zeta rho s)
         (cond 
            ((ms? S) ((e-ms S)       jp zeta rho s))
 ;           ((pc? S) ((e-pc S)       jp zeta rho s))
            (else ((C-e-S S) jp zeta rho s))
))))


; Predicate operations...

; S? : Any -> Bool
(define C-S? S?)
(define S?
   (lambda (S)
      (cond 
         ((has-kind? S)
            (cond 
               ((ms? S) #t)
;               ((pc? S) #t)
               (C-S? S)
         ))
         (else #f)
)))


; Extractors for the data type...


; Valuation functions ...

; Stmt[[S]] = () -> Stmt
(define C-ast->S (copy-tree ast->S))
(define ast->S
   (lambda (py_ast_var)
      ; First - work out what type of expression this is...
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "MotionCall" node_type)
                 ; Second - valuate the code
                 (ast->ms py_ast_var)
              )
;              ((string=? "PointcutCall" node_type)
;                 ; Second - valuate the code
;                 (ast->pc py_ast_var)
;              )
              (else (C-ast->S py_ast_var))
))))

