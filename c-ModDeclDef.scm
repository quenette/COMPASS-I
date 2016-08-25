;
; Semantic algebras...
;   Domain mdd in ModDeclDef
;     (Domain mdd_k in ModDeclDef_Kind in Kind)
;
; Abstract syntax...
;  Not in pycparser's AS
;
;  ModDeclDef_Kind ::= 'decl | 'func-def | 'typedef
;  ModDeclDef      ::= D | F | ty
;
; Valuation functions...
;  ModDeclDef[[mdd]] = () -> ModDeclDef
;
; Developed for guile scheme v 1.8.7

(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-Declaration.scm")
(load "c-FuncDef.scm")
(load "c-Typedef.scm")


; Construction operations ...

; make-D-mdd : TD -> ModDeclDef
(define make-D-mdd
   (lambda (D)
      D
))

; make-F-mdd : FD -> ModDeclDef
(define make-F-mdd
   (lambda (F)
      F
))

; make-ty-mdd : Typedef -> ModDeclDef
(define make-ty-mdd
   (lambda (ty)
      ty
))

; Other operations ...

; "Apply"
; e-mdd : ModDeclDef -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )          ; i.e. ModDeclDef -> T(Val)
(define e-mdd
   (lambda (mdd)
      (lambda (jp zeta rho s)
         (cond
            ((D? mdd)  ((e-D mdd #f)  jp zeta rho s))
            ((F? mdd)  ((e-F mdd)  jp zeta rho s))
            ((ty? mdd) ((e-ty mdd) jp zeta rho s))
            ; Else error
            (else 
               (display "Error: Unknown declaration/definition!!! ")(display mdd)(newline)(exit)
            )
))))

; e-mdd* :  ModDeclDef* -> ( Val -> T(Val) ) -> Val -> T(Val)
(define e-mdd*
   (lambda (mdd* kappa)
      (lambda (v)
         (lambda (jp zeta rho s)
            (cond
               ((eqv? mdd* '()) ((kappa v) jp zeta rho s))
               (else 
                  (let ((mdd   (car mdd*))
                        (mdd*' (cdr mdd*)))
                       ((seq-e (e-mdd mdd) (lambda (x) ((e-mdd* mdd*' kappa) x))) jp zeta rho s)
)))))))

; Predicate operations...

; mdd? : Any -> Bool
(define mdd?
   (lambda (mdd)
      (cond 
         ((D? mdd)  #t)
         ((F? mdd)  #t)
         ((ty? mdd) #t)
         (else #f)
)))


; Extraction operations...

; mdd->kind : ModDeclDef -> Kind
(define mdd->kind
   (lambda (mdd)
      (car mdd)
))


; Valuation functions ...

; ModDeclDef[[mdd]] = () -> ModDeclDef
(define ast->mdd
   (lambda (py_ast_var)
      ; First - ensure the ast node is a TypeDecl  (this is more of an exception [coding failure] than a bottom [semantic failure])
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "Decl" node_type)
                 ; Second - valuate the code
                 (make-D-mdd (ast->D py_ast_var))
              )
              ((string=? "FuncDef" node_type)
                 ; Second - valuate the code
                 (make-F-mdd (ast->F py_ast_var))
              )
              ((string=? "Typedef" node_type)
                 ; Second - valuate the code
                 (make-ty-mdd (ast->ty py_ast_var))
              )
              ; Else error
              (else (display "Error: AST node type \"")(display node_type)(display "\" is not an ModDeclDef node.")(newline))
))))

