;
; Semantic algebras...
;   Domain pd in PtrDecl 
;     (Domain dd in DenDecl)
;     (Domain td in TypeDecl)
;
; Abstract syntax...
;  pd in PtrDecl
;
;  Kind             ::= 'ptr-decl
;  PtrDecl          ::= < 'ptr-decl dd >
;
; Valuation functions...
;  PtrDecl[[dd]] = () -> PtrDecl
;
; Developed for guile scheme v 1.8.7


(load "error.scm")
(load "kind.scm")
(load "c-Identifier.scm")


; Construction operations ...

; make-pd : ObjDecl -> PtrDecl
(define make-pd
   (lambda (dd)
      (list 'ptr-decl dd) 
))


; Other operations ...

; "Apply"
; e-pd : PtrDecl -> Exp_b -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )     ; i.e. PtrDecl -> Exp_b -> T(Val)
;  Note: Exp_b because it isn't used when DenType=FuncDecl and an initialiser isna't always given, and hence it may be _b
(define e-pd
   (lambda (pd E is_anon)
      (lambda (jp zeta rho s)
         ((seq-e 
            (cond
               (is_anon   (seq-e (e-pd->sz pd) (lambda (sz) (e-alloc sz))))
               (else      (seq-e (e-pd->sz pd) (lambda (sz) (e-decl (pd->sym pd) sz pd))))
            )
            (lambda (l) (cond
               ((E? E)
                  (seq-e
                     (e-E E)
                     (lambda (v) (e-extend-s l v))
               ))
               (else
                  (e-extend-s l '())
               )
         ))) jp zeta rho s)
)))

; e-pd->sz : PtrDecl -> ( JP -> Mot* -> Env -> Sto ) -> ( Size x Mot* x Env x Sto )     ; i.e. PtrDecl -> T(Val)
(define e-pd->sz
   (lambda (pd)
      (lambda (jp zeta rho s)
         ((return-e 1) jp zeta rho s) ; TODO: implement real size of ptr!!! (not the base type)
)))




; Predicate operations...

; pd? : Any -> Bool
(define pd?
   (lambda (pd)
      (cond 
         ((and (has-kind? pd) (eqv? (pd->kind pd) 'ptr-decl)) #t)
         (else #f)
)))


; Extractors for the data type...

; pd->kind : PtrDecl -> Kind
(define pd->kind
   (lambda (pd)
      (car pd)
))

; pd->dd : PtrDecl -> ObjDecl
(define pd->dd
   (lambda (pd)
      (cadr pd)
))

; pd->id : PtrDecl -> Id
(define pd->id
   (lambda (pd)
      (let ((dd  (pd->dd pd)))
           (cond 
              ((pd? dd) (pd->id dd)) ; recurse
              ((dd? dd) (dd->id dd))
              ; Else error
              (else (display "Error: \"")(display dd)(display "\" is not an PtrDecl.")(newline))
))))

; pd->sym : PtrDecl -> Sym
(define pd->sym
   (lambda (pd)
      (id->sym (pd->id pd))
))

; pd->it : PtrDecl -> IT_b
(define pd->it
   (lambda (pd)
      (let ((dd  (pd->dd pd)))
           (cond 
              ((pd? dd) (pd->it dd)) ; recurse
              ((fd? dd) (display "")) ; fail - pd->it has no anwser in this case
              ((od? dd) (od->it dd))
              ; Else error
              (else (display "Error: \"")(display dd)(display "\" is not an PtrDecl.")(newline))
))))


; Valuation functions ...

; PtrDecl[[dd]] = () -> PtrDecl
(define ast->pd
   (lambda (py_ast_var)
      ; First - ensure the ast node is a PtrDecl (this is more of an exception [coding failure] than a bottom [semantic failure])
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "PtrDecl" node_type)
                 ; Second - valuate the code
                 (make-pd (ast->dd (string-append py_ast_var ".children()[0][1]")))
              )
              ; Else error
              (else (display "Error: AST node type \"")(display node_type)(display "\" is not a PtrDecl node.")(newline))
))))

