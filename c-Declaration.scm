; Declarations add a new identifier-value pair to the environment-store. It takes Env x Sto and returns a new Env' x Sto'. In the
;  case where there is not initialiser (no initial value), we add '() to the store at the location, thus tracking the entire
;  history of the variable.
;
; Note:
;  Decl[[D]] doesn't use DenDecl[[dd]] because od may be given an expression for a value but fd doesn't. What it means is that the
;  C language doesn't need/use the DenDecl[[dd]] denotation. It does however use ObjDecl[[od] denotation.
;
; Semantic algebras...
;   Domain D in Decl 
;   Domain Eel in ExprOrList
;    (Domain k in Kind)
;    (Domain tval in T(Val))
;    (Domain kappa in Cont)
;    (Domain od in ObjDecl)
;    (Domain dd in DenDecl)
;    (Domain td in TypeDecl)
;    (Domain pd in PtrDecl)
;    (Domain fd in FuncDecl)
;    (Domain st in Struct)
;     (Domain co in Constant)
;
; Abstract syntax...
;  D in Decl
;
;  Kind       ::= 'decl
;  ExprOrList ::= E | el
;  Decl       ::= < 'decl td > | < 'decl td E > | < 'decl pd > | < 'decl pd E > | <'decl ad > | <'decl ad el > | < 'decl fd > |
;                 < 'decl st>
;
; Valuation functions...
;  Decl[[od]]             = () -> Decl
;  Decl[[od Eel]]           = () -> Decl
;  Decl[[fd]]             = () -> Decl
;  Decl[[st]]             = () -> Decl
;  DeclApply[[D]]            = () -> ( JP -> Env -> Sto ) -> ( Val x Env' x Sto' )        ; i.e () -> T(Val)
;
; Developed for guile scheme v 1.8.7


(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-execution-store.scm")
(load "c-TypeDecl.scm")
(load "c-PtrDecl.scm")
(load "c-FuncDecl.scm")
(load "c-ObjDecl.scm")
(load "c-DenDecl.scm")


; Construction operations ...

; make-od-D : ObjDecl -> Decl
(define make-od-D
   (lambda (dd)
      (list 'decl dd '())
))

; make-od-Eel-D : ObjDecl x ExprOrList -> Decl
(define make-od-Eel-D
   (lambda (dd Eel)
      (list 'decl dd Eel)
))

; make-fd-D : FuncDecl -> Decl
(define make-fd-D
   (lambda (fd)
      (list 'decl fd '()) 
))

; make-st-D : Struct -> Decl
(define make-st-D
   (lambda (st)
      (list 'decl st '()) 
))


; Other operations ...

; "Apply"
; e-D : Decl -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )                  ; i.e. Decl -> T(Val)
(define e-D
   (lambda (D is_anon)
      (lambda (jp zeta rho s)
         ((e-dd (D->dd D) (D->Eel D) is_anon) jp zeta rho s)
)))


; e-D* :  Decl* -> ( Val -> T(Val) ) -> Val -> T(Val)
(define e-D*
   (lambda (D* kappa is_anon)
      (lambda (v)
         (lambda (jp zeta rho s)
            (cond
               ((eqv? D* '()) ((kappa v) jp zeta rho s))
               (else ((seq-e (e-D (car D*) is_anon) (lambda (x) ((e-D* (cdr D*) kappa is_anon) x))) jp zeta rho s))
)))))

; D*->sym* : Decl* -> Sym*
; Converts a (parameter) declaration list into a list of symbols
(define D*->sym*
   (lambda (D*)
      (D*->sym*' D* '())
))

; D*->sym*' : Decl* -> Sym* -> Sym*
(define D*->sym*'
   (lambda (D* sym*)
      (cond 
         ((eq? D* '())    sym*)
         (else 
            (let ((D    (car D*))
                  (D*'  (cdr D*))
                 )
                 (D*->sym*' D*' (append sym* (list (dd->sym (D->dd D)))))
         ))
)))

; D*->sym.ti* : Decl* -> (Sym.TypeInfo)*
; Converts a (parameter) declaration list into a list of symbols/type-info pairs
(define D*->sym.ti*
   (lambda (D*)
      (D*->sym.ti*' D* '())
))

; D*->sym.ti*' : Decl* -> (Sym.TypeInfo)* -> (Sym.TypeInfo)*
(define D*->sym.ti*'
   (lambda (D* sym.ti*)
      (cond 
         ((eq? D* '())    sym.ti*)
         (else 
            (let ((D    (car D*))
                  (D*'  (cdr D*))
                 )
                 (D*->sym.ti*' D*' (append sym.ti* (list (cons (dd->sym (D->dd D)) (D->dd D)) )))
         ))
)))


; Predicate operations...

; D? : Any -> Bool
(define D?
   (lambda (D)
      (cond 
         ((and (has-kind? D) (eqv? (D->kind D) 'decl)) #t)
         (else #f)
)))

; D-init? : Decl -> Bool
(define D-init?
   (lambda (D)
      (cond 
         ((not (eqv? (caddr D) '()))  #t)
         ;((eq? (length D) 3) #t)      ... deprecated now that domain has '() for E when E is not set rather than nothing
         (else #f)
)))


; Extractors for the data type...

; D->kind : Decl -> Kind
(define D->kind
   (lambda (D)
      (car D)
))

; D->dd : Decl -> DenDecl
(define D->dd
   (lambda (D)
      (cadr D)
))

; D->Eel : Decl -> Expr_b
(define D->Eel
   (lambda (D)
      (cond
         ((not (eqv? (caddr D) '()))  (caddr D))
         ;((eq? (length D) 3) (caddr D))   ... deprecated now that domain has '() for E when E is not set rather than nothing
         ; else fail ... but we wont be loud about it ... makes it easier to use dd of fd
)))


; Valuation functions ...

; Decl[[D]] = Env x Sto -> Decl
(define ast->D
   (lambda (py_ast_var)
      ; First - ensure the ast node is a Decl  (this is more of an exception [coding failure] than a bottom [semantic failure])
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "Decl" node_type)
                 ; Second - valuate the code
                 (let ((count (python-eval (string-append "len(" py_ast_var ".children())") #t))
                       (kind  (python-eval (string-append py_ast_var ".children()[0][1].__class__.__name__.encode('ascii')") #t))
                      )
                      (cond
                         ((or (string= "TypeDecl" kind) (or (string= "PtrDecl" kind) (string= "ArrayDecl" kind)))  
                            (cond
                               ((= count 1) (ast->od-D py_ast_var))
                               ((= count 2) (ast->od-Eel-D py_ast_var))
                               ; else fail
                         ))
                         ((string= "FuncDecl" kind) 
                            (ast->fd-D py_ast_var)
                         )
                         ((string= "Struct" kind) 
                            (ast->st-D py_ast_var)
                         )
                         ; else error
                         (else (display kind)(display " Not implemented yet!")(newline)(exit))
              )))
              ; Else error
              (else (display "Error: AST node type \"")(display node_type)(display "\" is not an Declaration node.")(newline))
))))

; Decl[[od]] = () -> Decl
(define ast->od-D
   (lambda (py_ast_var)
      ; First - ensure the ast node is a Decl  (this is more of an exception [coding failure] than a bottom [semantic failure])
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "Decl" node_type)
                 ; Second - valuate the code
                 (make-od-D (ast->od (string-append py_ast_var ".children()[0][1]")))
              )
              ; Else error
              (else (display "Error: AST node type \"")(display node_type)(display "\" is not an Declaration node.")(newline))
))))

; Decl[[od Eel]] = () -> Decl
(define ast->od-Eel-D
   (lambda (py_ast_var)
      ; First - ensure the ast node is a Decl  (this is more of an exception [coding failure] than a bottom [semantic failure])
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "Decl" node_type)
                 ; Second - valuate the code
                 (let ((kind  (python-eval (string-append py_ast_var ".children()[0][1].__class__.__name__.encode('ascii')") #t)))
                    (cond
                       ((or (string= "TypeDecl" kind) (string= "PtrDecl" kind))
                          (make-od-Eel-D (ast->od (string-append py_ast_var ".children()[0][1]")) 
                                         (ast->E  (string-append py_ast_var ".children()[1][1]"))
                       ))
                       ((string= "ArrayDecl" kind)
                          (let ((is-el?  (python-eval (string-append "type(" py_ast_var 
                                                        ".children()[1][1]" ").__name__ == 'ExprList'" ) #t))
                                (is-C?   (python-eval (string-append "type(" py_ast_var 
                                                        ".children()[1][1]" ").__name__ == 'Constant'" ) #t))
                               )
                               (cond
                                  (is-el?
                                     (make-od-Eel-D (ast->od (string-append py_ast_var ".children()[0][1]")) 
                                                    (ast->el (string-append py_ast_var ".children()[1][1]"))
                                  ))
                                  (is-C?
                                      ; Note:  When the Constant is a "string", ast->co will return an ExprList!!!
                                      (make-od-Eel-D (ast->od (string-append py_ast_var ".children()[0][1]")) 
                                                     (ast->co  (string-append py_ast_var ".children()[1][1]"))
                                  ))
                                  (else 
                                      (display "Error: Decl of an array where the initialiser is not a string or a Constant ")
                                      (display " is unknown or yet to be implemented")(newline)
                                  )
                       )))
                       (else
                          (display "Error: Decl of kind: ")(display kind)(display ", is unknown or yet to be implemented")(newline)
                       )
              )))
              ; Else error
              (else (display "Error: AST node type \"")(display node_type)(display "\" is not an Declaration node.")(newline))
))))

; Decl[[fd]]() = () -> Decl
(define ast->fd-D
   (lambda (py_ast_var)
      ; First - ensure the ast node is a Decl  (this is more of an exception [coding failure] than a bottom [semantic failure])
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "Decl" node_type)
                 ; Second - valuate the code
                 (make-fd-D (ast->fd (string-append py_ast_var ".children()[0][1]")))
              )
              ; Else error
              (else (display "Error: AST node type \"")(display node_type)(display "\" is not an Declaration node.")(newline))
))))

; Decl[[st]]() = () -> Decl
(define ast->st-D
   (lambda (py_ast_var)
      ; First - ensure the ast node is a Decl  (this is more of an exception [coding failure] than a bottom [semantic failure])
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "Decl" node_type)
                 ; Second - valuate the code
                 (make-st-D (ast->st (string-append py_ast_var ".children()[0][1]")))
              )
              ; Else error
              (else (display "Error: AST node type \"")(display node_type)(display "\" is not an Declaration node.")(newline))
))))


; DeclApply[[D]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )         ; i.e () -> T(Val)
(define ast->e-D
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-D (ast->D py_ast_var) #f) jp zeta rho s)
)))

; DeclApply[[od]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )        ; i.e () -> T(Val)
(define ast->e-od-D
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-D (ast->od-D py_ast_var) #f) jp zeta rho s)
)))


; DeclApply[[od Eel]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )      ; i.e () -> T(Val)
(define ast->e-od-Eel-D
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-D (ast->od-Eel-D py_ast_var) #f) jp zeta rho s)
)))

