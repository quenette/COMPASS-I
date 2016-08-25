;
; Semantic algebras...
;   Domain dd in DenDecl
;     (Domain dd_k in DenDecl_Kind in Kind)
;
; Abstract syntax...
;  Not in pycparser's AS
;
;  DenDecl)Kind ::= 'type-decl | 'ptr-decl | 'array-decl | 'func-decl | 'struct
;  DenDecl      ::= od | fd | st
;
; Valuation functions...
;  DenDecl[[dd]] = () -> DenDecl
;
; Developed for guile scheme v 1.8.7

(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-store.scm")
(load "c-env.scm")
(load "c-ObjDecl.scm")
(load "c-FuncDecl.scm")


; Construction operations ...

; make-od-dd : ObjDecl -> DenDecl
(define make-od-dd
   (lambda (od)
      od
))

; make-fd-dd : FuncDecl -> DenDecl
(define make-fd-dd
   (lambda (fd)
      fd
))

; make-st-dd : Struct -> DenDecl
(define make-st-dd
   (lambda (st)
      st
))

; Other operations ...

; "Apply"
; e-dd : DenDecl -> ExprOrList_b -> (JP->Mot*->Env->Sto) -> ( Val x Mot* -> Env' x Sto' )  ; i.e. DenDecl -> ExprOrList_b -> T(Val)
;  Note: ExprOrList_b because an initialiser isn't always given
(define e-dd
   (lambda (dd Eel is_anon)
      (lambda (jp zeta rho s)
         (cond
            ((or (td? dd) (pd? dd) (ad? dd)) ((e-od dd Eel is_anon) jp zeta rho s))
            ((fd? dd) ((e-fd dd) jp zeta rho s))
            ((st? dd) ((e-st dd '() #f) jp zeta rho s))
            ; Else error
            (else 
               (display "Error: Unknown denotable datatype/declaration!!! ")(display dd)(newline)(exit)
            )
))))


; Predicate operations...

; dd? : Any -> Bool
(define dd?
   (lambda (dd)
      (cond 
         ((od? dd) #t)
         ((fd? dd) #t)
         ((st? dd) #t)
         (else #f)
)))


; Extraction operations...

; dd->kind : DenDecl -> Kind
(define dd->kind
   (lambda (dd)
      (car dd)
))

; dd->id : DenDecl -> Id
(define dd->id
   (lambda (dd)
      (cond 
         ((od? dd) (od->id dd))
         ((fd? dd) (of->id (fd->od dd)))
         ((st? dd) (display "Error: In dd->id, structs have no identifiers\n"))
         ; Else error
         (else (display "Error: \"")(display dd)(display "\" is not an DenDecl.")(newline))
)))

; dd->sym : DenDecl -> Sym
(define dd->sym
   (lambda (dd)
      (cond 
         ((od? dd) (od->sym dd))
         ((fd? dd) (od->sym (fd->od dd)))
         ((st? dd) (st->sym dd))
         ; Else error
         (else (display "Error: \"")(display dd)(display "\" is not an DenDecl.")(newline))
)))



; Valuation functions ...

; DenDecl[[dd]] = () -> DenDecl
(define ast->dd
   (lambda (py_ast_var)
      ; First - ensure the ast ndde is a TypeDecl  (this is more of an exception [cdding failure] than a bottom [semantic failure])
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((or (string=? "TypeDecl" node_type) (string=? "PtrDecl" node_type) (string=? "ArrayDecl" node_type))
                 ; Second - valuate the cdde
                 (make-od-dd (ast->od py_ast_var))
              )
              ((string=? "FuncDecl" node_type)
                 ; Second - valuate the cdde
                 (make-fd-dd (ast->fd py_ast_var))
              )
              ((string=? "Struct" node_type)
                 ; Second - valuate the cdde
                 (make-st-dd (ast->st py_ast_var))
              )
              ; Else error
              (else (display "Error: AST ndde type \"")(display ndde_type)(display "\" is not an DenDecl ndde.")(newline))
))))

