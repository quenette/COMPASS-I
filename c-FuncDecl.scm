;
; Semantic algebras...
;   Domain fd in FuncDecl 
;    (Domain k in Kind)
;    (Domain pl in ParamList)
;    (Domain od in ObjDecl)
;
; Abstract syntax...
;  fd in FuncDecl
;
;  Kind              ::= 'func-decl
;  FuncDecl          ::= < 'func-decl pl od >
;
; Valuation functions...
;  FuncDecl[[fd]] = () -> FuncDecl
;
; Developed for guile scheme v 1.8.7


(load "error.scm")
(load "kind.scm")
(load "c-TypeDecl.scm")
(load "c-PtrDecl.scm")
(load "c-ParamList.scm")


; Construction operations ...

; make-fd : ParamList x ObjDecl -> FuncDecl
(define make-fd
   (lambda (pl od)
      (list 'func-decl pl od) 
))


; Other operations ...

; "Apply"
; e-fd : FuncDecl -> ( JP -> Mot -> Env -> Sto ) -> ( Val x Mot x Env' x Sto' )               ; i.e. FuncDecl -> T(Val)
;  Note: what does size of a function/procedure mean?  For an interpreter - is there value is knowing what this is? Just use 1
(define e-fd
   (lambda (fd)
      (lambda (jp zeta rho s)
         ((e-fdecl (fd->sym fd) 1 fd) jp zeta rho s)
)))


; Predicate operations...

; fd? : Any -> Bool
(define fd?
   (lambda (fd)
      (cond 
         ((and (has-kind? fd) (eqv? (fd->kind fd) 'func-decl)) #t)
         (else #f)
)))

; void-fd? : FuncDecl -> Bool
(define void-fd?
   (lambda (fd)
;      (void-it? (od->it (fd->od fd)))
      (cond
         ((pd? (fd->od fd))    #f)
         ((void-it? (od->it (fd->od fd)))    #t)
         (else   #f)
)))


; Extractors for the data type...

; fd->kind : FuncDecl -> Kind
(define fd->kind
   (lambda (fd)
      (car fd)
))

; fd->pl : FuncDecl -> ParamList_b
(define fd->pl
   (lambda (fd)
      (cadr fd)
))

; fd->od : FuncDecl -> ObjDecl
(define fd->od
   (lambda (fd)
      (caddr fd)
))

; fd->sym : FuncDecl -> Sym
(define fd->sym
   (lambda (fd)
      (od->sym (fd->od fd))
))


; Valuation functions ...

; FuncDecl[[fd]] = () -> FuncDecl
(define ast->fd
   (lambda (py_ast_var)
      ; First - ensure the ast node is a FuncDecl  (this is more of an exception [coding failure] than a bottom [semantic failure])
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "FuncDecl" node_type)
                 ; Second - valuate the code
                 ; The pycparser AST is a bit funny here. If no args are given, FuncDecl has only one child - the return type. 
                 ; Otherwise it has 2 child, where the return type is the 2nd item (rather than first)
                 (let ((count  (python-eval (string-append "len(" py_ast_var ".children())") #t)))
                      (cond
                         ((= count 1)
                            (make-fd (make-pl '()) (ast->od (string-append py_ast_var ".children()[0][1]")))
                         )
                         ((= count 2)
                            (make-fd (ast->pl (string-append py_ast_var ".children()[0][1]")) 
                                     (ast->od (string-append py_ast_var ".children()[1][1]")))
                         )
                         ; Else error
                         (else (display "Error: FuncDecl AST node has \"")(display count)(display "\" children (not 1 or 2).")(newline))
              )))
              ; Else error
              (else (display "Error: AST node type \"")(display node_type)(display "\" is not an FuncDecl node.")(newline))
))))

