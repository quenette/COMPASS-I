;
; Semantic algebras...
;   Domain F in FuncDef 
;    (Domain k in Kind)
;    (Domain D in Decl)
;    (Domain C in Compound)
;
; Abstract syntax...
;  F in FuncDef
;
;  Kind              ::= 'func-def
;  FuncDef           ::= < 'func-def D C >
;
; Valuation functions...
;  FuncDef[[F]] = () -> FuncDef
;
; Developed for guile scheme v 1.8.7


(load "error.scm")
(load "kind.scm")
(load "c-Declaration.scm")
(load "c-Compound.scm")


; Construction operations ...

; make-F : Decl x Compound -> FuncDef
(define make-F
   (lambda (D C)
      (list 'func-def D C) 
))


; Other operations ...

; "ApDy"
; e-F : FuncDef -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )               ; i.e. FuncDef -> T(Val)
(define e-F
; Note... it may be that I need "is_anon" here too for class members
   (lambda (F)
      (lambda (jp zeta rho s)
         ((seq-e (e-D (F->D F) #f) (lambda (x) (e-setref (F->sym F) (F->C F)))) jp zeta rho s)
)))


; Predicate operations...

; F? : Any -> Bool
(define F?
   (lambda (F)
      (cond 
         ((and (has-kind? F) (eqv? (F->kind F) 'func-def)) #t)
         (else #f)
)))

; void-F? : FuncDef -> Bool
(define void-F?
   (lambda (F)
      (void-fd? (D->dd (F->D F)))
))


; Extractors for the data type...

; F->kind : FuncDef -> Kind
(define F->kind
   (lambda (F)
      (car F)
))

; F->D : FuncDef -> Decl
(define F->D
   (lambda (F)
      (cadr F)
))

; F->C : FuncDef -> Compound
(define F->C
   (lambda (F)
      (caddr F)
))

; F->sym : FuncDef -> Sym
(define F->sym
   (lambda (F)
      (dd->sym (D->dd (F->D F)))
))


; Valuation functions ...

; FuncDef[[F]] = () -> FuncDef
(define ast->F
   (lambda (py_ast_var)
      ; First - ensure the ast node is a FuncDef  (this is more of an exception [cCing failure] than a bottom [semantic failure])
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "FuncDef" node_type)
                 ; Second - valuate the code
                 (make-F (ast->D  (string-append py_ast_var ".children()[0][1]")) 
                         (ast->C  (string-append py_ast_var ".children()[1][1]")))
              )
              ; Else error
              (else (display "Error: AST node type \"")(display node_type)(display "\" is not an FuncDef node.")(newline))
))))

; FuncDefApply[[F]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )      ; i.e () -> T(Val)
(define ast->e-F
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-F (ast->F py_ast_var)) jp zeta rho s)
)))


