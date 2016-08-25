;
; Semantic algebras...
;   Domain ad in ArrayDecl 
;    (Domain td in TypeDecl)
;    (Domain el in ExprList)
;    (Domain c in Count sub Size)
;
; Abstract syntax...
;  ad in ArrayDecl
;
;  Kind              ::= 'array-decl
;  ArrayDecl         ::= < 'array-decl td > | < 'array-decl td c >
;
; Valuation functions...
;  ArrayDecl[[td]] = () -> ArrayDecl
;  ArrayDecl[[td c]] = () -> ArrayDecl
;
; Developed for guile scheme v 1.8.7


(load "error.scm")
(load "kind.scm")
(load "c-Identifier.scm")
(load "c-IdentifierType.scm")


; Construction operations ...

; make-ad : TypeDecl -> ArrayDecl
(define make-ad
   (lambda (td)
      (list 'array-decl td '()) 
))

; make-ad-c : TypeDecl -> Count -> ArrayDecl
(define make-ad-c
   (lambda (td c)
      (list 'array-decl td c) 
))


; Other operations...

; "Apply"
; e-ad : ArrayDecl -> ExprOrList_b -> (JP-> Mot*->Env->Sto) -> ( Val x Mot* x Env' x Sto' )   ; i.e. ArrayDecl -> Exp_b -> T(Val)
;  Note: ExpOrList_b because an initialiser isn't always given
(define e-ad
   (lambda (ad Eel is_anon)
      (lambda (jp zeta rho s)
         ((seq-e
            (cond
               ((ad-count? ad)    (return-e (ad->c ad)))   ; if the count is given, use it
               ((el? Eel)         (return-e (length (el->E* Eel))))   ; if expression list, use its length
               (else              (return-e (display "Error: In e-ad, array has no length information!\n")))
            )
            (lambda (c) (seq-e
                (cond
                   (is_anon   (seq-e (e-td->sz (ad->td ad)) (lambda (sz) (e-allocn sz c))))
                   (else      (seq-e (e-td->sz (ad->td ad)) (lambda (sz) (e-decln (ad->sym ad) sz c ad))))
                )
                (lambda (l) (cond
                   ((el? Eel)
                      (seq-e
                         (e-el Eel)
                         (lambda (v*) (seq-e
                            (e-extend-s* l v* c)
                            (lambda (_) (return-e l))
                   ))))
                   ((has-kind? Eel)
                      (return-e (display "Error: In e-ad, expecting an expression list, got a: ")(display (E->kind Eel))(newline))
                   )
                   (else
                      (seq-e
                         (e-extend-sn l '() c)
                         (lambda (_) (return-e l))
                   ))
         ))))) jp zeta rho s)
)))

; e-ad->sz: ArrayDecl -> (JP-> Mot*->Env->Sto) -> ( Size x Mot* x Env x Sto )   ; i.e. ArrayDecl -> T(Val)
(define e-ad->sz
   (lambda (ad)
      (lambda (jp zeta rho s)
         ((seq-e (e-td->sz (ad->td ad)) (lambda (sz) (return-e (* (ad->c ad) sz)))) jp zeta rho s)
)))



; Predicate operations...

; ad? : Any -> Bool
(define ad?
   (lambda (ad)
      (cond 
         ((and (has-kind? ad) (eqv? (ad->kind ad) 'array-decl)) #t)
         (else #f)
)))

; ad-count? : Any -> Bool
(define ad-count?
   (lambda (ad)
      (cond 
         ((not (eq? (caddr ad) '()))    #t)
         (else #f)
)))


; Extractors for the data type...

; ad->kind : ArrayDecl -> Kind
(define ad->kind
   (lambda (ad)
      (car ad)
))

; ad->td : ArrayDecl -> TypeDecl
(define ad->td
   (lambda (ad)
      (cadr ad)
))

; ad->c : ArrayDecl -> Count_b
(define ad->c
   (lambda (ad)
      (cond
         ((not (eq? (caddr ad) '()))  (caddr ad))
         ; else fail
)))


; ad->sym: ArrayDecl -> Sym
(define ad->sym
   (lambda (ad)
      (td->sym (ad->td ad))
))


; Valuation functions ...

; ArrayDecl[[td]] = () -> ArrayDecl
; ArrayDecl[[td c]] = () -> ArrayDecl
(define ast->ad
   (lambda (py_ast_var)
      ; First - ensure the ast node is a ArrayDecl  (this is more of an exception [coding failure] than a bottom [semantic failure])
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "ArrayDecl" node_type)
                 ; Second - valuate the code
                 (let ((td      (ast->td (string-append py_ast_var ".children()[0][1]")))
                       (count   (python-eval (string-append "len(" py_ast_var ".children())") #t))
                      )
                      (cond
                         ((eq? count 1)   (make-ad td))
                         ((eq? count 2) 
                            (let ((c   (python-eval (string-append "int(" py_ast_var ".children()[1][1].value)") #t)))
                               (make-ad-c td c)
                         ))
                         (else
                            (display "Error: Handling ArrayDecl AST with more than two children  ")
                            (display "is unknown or yet to be implemented")(newline)
                         )
              )))
              ; Else error
              (else (display "Error: AST node type \"")(display node_type)(display "\" is not a ArrayDecl node.")(newline))
))))

