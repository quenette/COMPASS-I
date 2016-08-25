;
; TODO: Tests!!!
; 
; Semantic algebras...
;   Domain E in Expr 
;
; Abstract syntax...
;  E in Expr
;
;  Expr ::= uo | co | id | ...
;
; Valuation functions...
;  Expr[[E]]          = () -> Expr
;    (UnaryOp[[k_uo E]] = () -> UnaryOp)
;    (Constant[[it v]]  = () -> Constant)
;    (Identifier[[sym]] = () -> Identifier)
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
(define e-E
   (lambda (E)
      (lambda (jp zeta rho s)
         (cond
            ((co? E) ((e-co E) jp zeta rho s))
            ((uo? E) ((e-uo E) jp zeta rho s))
            ((id? E) ((e-id E) jp zeta rho s))
            ((fc? E) ((e-fc E) jp zeta rho s))
            ((ae? E) ((e-ae E) jp zeta rho s))
            ((bo? E) ((e-bo E) jp zeta rho s))
            ((ar? E) ((e-ar E) jp zeta rho s))
            ((sr? E) ((e-sr E) jp zeta rho s))
))))


; Predicate operations...

; E? : Any -> Bool
(define E?
   (lambda (E)
      (cond 
         ((has-kind? E)
            (cond 
               ((co? E) #t)
               ((uo? E) #t)
               ((id? E) #t)
               ((fc? E) #t)
               ((ae? E) #t)
               ((bo? E) #t)
               ((ar? E) #t)
               ((sr? E) #t)
               (else #f)
         ))
         (else #f)
)))


; Extractors for the data type...

; E->kind : Expr -> Kind
(define E->kind
   (lambda (E)
      (car E)
))


; Valuation functions ...

; Expr[[E]] = () -> Expr
(define ast->E
   (lambda (py_ast_var)
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t))
            (res (ast->E' py_ast_var))
           )
         (cond
            ; else Fail
            ((not (list? res)) (display "Error: Expression not yet implemented: ")(display node_type)(display " in ast->E.\n"))
            ; expression found
            (else res)
))))


; Expr[[E]] = () -> Expr
(define ast->E'
   (lambda (py_ast_var)
      ; First - work out what type of expression this is...
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "Constant" node_type)
                 ; Second - valuate the code
                 (ast->co py_ast_var)
              )
              ((string=? "UnaryOp" node_type)
                 ; Second - valuate the code
                 (ast->uo py_ast_var)
              )
              ((string=? "ID" node_type)
                 ; Second - valuate the code
                 (ast->id py_ast_var)
              )
              ((string=? "FuncCall" node_type)
                 ; Second - valuate the code
                 (ast->fc py_ast_var)
              )
              ((string=? "Assignment" node_type)
                 ; Second - valuate the code
                 (ast->ae py_ast_var)
              )
              ((string=? "BinaryOp" node_type)
                 ; Second - valuate the code
                 (ast->bo py_ast_var)
              )
              ((string=? "ArrayRef" node_type)
                 ; Second - valuate the code
                 (ast->ar py_ast_var)
              )
              ((string=? "StructRef" node_type)
                 ; Second - valuate the code
                 (ast->sr py_ast_var)
              )
              ((string=? "Typename" node_type)
                 ; Second - valuate the code
                 (ast->tn py_ast_var)
              )
              ; else fail
              (else (display ""))
))))

; ExprApply[[E]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )    ; i.e () -> T(Val)
(define ast->e-E
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-E (ast->E py_ast_var)) jp zeta rho s)
)))

