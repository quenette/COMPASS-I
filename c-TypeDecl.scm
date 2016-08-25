;
; Semantic algebras...
;   Domain td in TypeDecl 
;    (Domain id in Id)
;    (Domain it in IT)
;
; Abstract syntax...
;  td in TypeDecl
;
;  Kind              ::= 'type-decl
;  TypeDecl          ::= < 'type-decl id it > | < 'type-decl id it st >
;
; Valuation functions...
; TypeDecl[[it]] = () -> TypeDecl
; TypeDecl[[id it]] = () -> TypeDecl
; TypeDecl[[id st]] = () -> TypeDecl
;
; Developed for guile scheme v 1.8.7


(load "error.scm")
(load "kind.scm")
(load "c-Identifier.scm")
(load "c-IdentifierType.scm")
(load "c-Struct.scm")


; Construction operations ...

; make-it-td : Id -> IT -> TypeDecl
(define make-it-td
   (lambda (id it)
      (list 'type-decl id it (display "")) 
))

; make-st-td : Id -> StructDecl -> TypeDecl
(define make-st-td
   (lambda (id st)
      (list 'type-decl id (display "") st) 
))


; Other operations...

; "Apply"
; e-td : TypeDecl -> Exp_b -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )         ; i.e. TypeDecl -> Exp_b -> T(Val)
;  Note: Exp_b because an initialiser isn't always given
(define e-td
   (lambda (td E is_anon)
      (lambda (jp zeta rho s)
         ((cond
            ((st-td? td) (e-st (td->st td) (td->sym td) is_anon))
            ((and (it-td? td) (user-it? (td->it td)))  
               (seq-e
                  (e-get-type (it->tname (td->it td)))
                  (lambda (td') 
                      (seq-e
                         (e-td td' E #t)
                         (lambda (l) (cond
                            (is_anon   (return-e l))
                            (else      (e-extend-env (td->sym td) l td))
            ))))))
            ((and (it-td? td) (inbuilt-it? (td->it td)))
               (seq-e 
                  (cond
                     (is_anon   (seq-e (e-td->sz td) (lambda (sz) (e-alloc sz))))
                     (else      (seq-e (e-td->sz td) (lambda (sz) (e-decl (td->sym td) sz td))))
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
            ))))
            (else (return-e (display "Error: In e-td, td must be of struct or identifier type")))
         ) jp zeta rho s)
)))

; e-td->sz : TypeDecl -> ( JP -> Mot* -> Env -> Sto ) -> ( Size x Mot* x Env x Sto )         ; i.e. TypeDecl -> T(Val)
(define e-td->sz
   (lambda (td)
      (lambda (jp zeta rho s)
         ((cond
            ((and (it-td? td) (inbuilt-it? (td->it td)))   (return-e 1)) ; TODO: implement real size of builtin type!!!
            ((and (it-td? td) (user-it? (td->it td)))   
               (seq-e
                  (e-get-type (td->tname td))
                  (lambda (td') (e-td->sz td'))
            ))
            ((st-td? td)  (e-st->sz (td->st td)))
            (else (display "In e-td->sz, expected the TypeDecl to be of either an IdentifierType or StructType type\n"))
         ) jp zeta rho s)
)))


; Predicate operations...

; td? : Any -> Bool
(define td?
   (lambda (td)
      (cond 
         ((and (has-kind? td) (eqv? (td->kind td) 'type-decl)) #t)
         (else #f)
)))

; it-td? : Any -> Bool
(define it-td?
   (lambda (td)
      (cond 
         ((and (has-kind? td) (eqv? (td->kind td) 'type-decl))
            (cond 
               ((and (it? (td->it td)) (unspecified? (td->st td)) ) #t)
               (else #f)
         ))
         (else #f)
)))

; st-td? : Any -> Bool
(define st-td?
   (lambda (td)
      (cond 
         ((and (has-kind? td) (eqv? (td->kind td) 'type-decl))
            (cond 
               ((and (st? (td->st td)) (unspecified? (td->it td)) ) #t)
               (else #f)
         ))
         (else #f)
)))


; Extractors for the data type...

; td->kind : TypeDecl -> Kind
(define td->kind
   (lambda (td)
      (car td)
))

; td->id : TypeDecl -> Id_b    ;note: can't remember why _b
(define td->id
   (lambda (td)
      (cadr td)
))

; td->sym : TypeDecl -> Sym
(define td->sym
   (lambda (td)
      (id->sym (td->id td))
))

; td->it : TypeDecl -> IT_b
(define td->it
   (lambda (td)
      (caddr td)
))

; td->st : TypeDecl -> StructDecl_b
(define td->st
   (lambda (td)
      (cadddr td)
))

; td->tname : TypeDecl -> TName
(define td->tname
   (lambda (td)
      (cond
         ((it-td? td)   (it->tname (td->it td)))
         ((st-td? td)   (string-append "struct " (st->sym (td->st td))))
         (else (display "In td->tname, expected the TypeDecl to be of either an IdentifierType or StructType type\n"))
)))



; Valuation functions ...

; TypeDecl[[it]] = () -> TypeDecl
; TypeDecl[[id it]] = () -> TypeDecl
; TypeDecl[[id st]] = () -> TypeDecl
(define ast->td
   (lambda (py_ast_var)
      ; First - ensure the ast node is a TypeDecl  (this is more of an exception [coding failure] than a bottom [semantic failure])
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "TypeDecl" node_type)
                 ; Second - valuate the code
                 (let ((has_name  (python-eval (string-append "False if " py_ast_var ".declname == None else True") #t)))
                    (let ((name      (cond 
                                        (has_name   (python-eval (string-append py_ast_var ".declname.encode('ascii')") #t))
                                        (else       '())
                          )) 
                          (type_type (python-eval (string-append py_ast_var ".type.__class__.__name__.encode('ascii')") #t))
                         )
                         (cond
                            ((string=? "IdentifierType" type_type)
                               (let ((it   (ast->it (string-append py_ast_var ".type"))))
                                  (make-it-td (make-id name) it)
                            ))
                            ((string=? "Struct" type_type)
                               (let ((st   (ast->st (string-append py_ast_var ".type"))))
                                  ; To note - this variant has no identifier type but does have type info by means of st
                                  (make-st-td (make-id name) st)
                            ))
                            (else 
                               (display "Error: Type declaration type \"")(display type_type)
                               (display "\" is not known or implemented.")(newline)
                            )
              )) ))
              ; Else error
              (else 
(python-eval (string-append py_ast_var ".show()"))
(display "Error: AST node type \"")(display node_type)(display "\" is not a TypeDecl node.")(newline))
))))

