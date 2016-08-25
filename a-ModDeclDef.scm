; This ModDecDef is the module level available declaration construct for the AOP example language in compass. It essentially extends
;  the C one to include advice declarations.
;
; Semantic algebras...
;   Domain mdd in ModDeclDef
;     (Domain mdd_k in ModDeclDef_Kind in Kind)
;
; Abstract syntax...
;  Not in pycparser's AS
;
;  ModDeclDef_Kind ::= 'decl | 'func-def | 'advice-after
;  ModDeclDef      ::= D | F | A
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
(load "a-AdviceDecl.scm")
(load "c-ModDeclDef.scm")


; Construction operations ...

; make-A-mdd : A -> ModDeclDef
(define make-A-mdd
   (lambda (A)
      A
))

; Other operations ...

; "Apply"
; e-mdd : ModDeclDef -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )          ; i.e. ModDeclDef -> T(Val)
(define e-mdd
   (lambda (mdd)
      (lambda (jp zeta rho s)
         (cond
            ((D? mdd) ((e-D mdd) jp zeta rho s))
            ((F? mdd) ((e-F mdd) jp zeta rho s))
            ((A? mdd) ((e-A mdd) jp zeta rho s))
            ; Else error
            (else 
               (display "Error: Unknown declaration/definition!!! ")(display mdd)(newline)(exit)
            )
))))

; Predicate operations...

; mdd? : Any -> Bool
(define mdd?
   (lambda (mdd)
      (cond 
         ((D? mdd) #t)
         ((F? mdd) #t)
         ((A? mdd) #t)
         (else #f)
)))


; Extraction operations...


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
              ((string=? "AdviceAfterCall" node_type)
                 ; Second - valuate the code
                 (make-A-mdd (ast->A py_ast_var))
              )
              ; Else error
              (else (display "Error: AST node type \"")(display node_type)(display "\" is not an ModDeclDef node.")(newline))
))))

