;
; Semantic algebras...
;   Domain ae in AssignmentExpr = AssignmentExprKind x Expr
;    (Domain k_ae in AssignmentExprKind in Kind)
;    (Domain id in Id)
;    (Domain E in Expr)
;    (Domain v in Val)
;
; Abstract syntax...
;  ae in AssignmentExpr
;
;  Val                 ::= Loc
;  AssignmentExprKind  ::= 'ae-= | 'ae-+= | 'ae--=
;  AssignmentExpr      ::= < k_ae E_lhs E_rhs >
;
; Valuation functions...
;  AssignmentExpr[[k_ae E_lhs E-rhs]] = () -> AssignmentExpr
;
; Developed for guile scheme v 1.8.7


(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-execution-store.scm")
(load "c-Identifier.scm")


; Construction operations ...

; make-=-ae : Expr -> Expr -> AssignmentExpr
(define make-=-ae
   (lambda (E_lhs E_rhs)
      (cond 
         ; The check that E_lhs and E_rhs are expressions (at this point we dont test any stronger than this)
         ((and (E? E_lhs) (E? E_rhs)) (list 'ae-= E_lhs E_rhs))
         ; else error  (& requires E to be an Expression)
         (else (display "Error: In make-=-ae, either or both sides are not expressions!" ))
)))

; make-+=-ae : Expr -> Expr -> AssignmentExpr
(define make-+=-ae
   (lambda (E_lhs E_rhs)
      (cond 
         ; The check that E_lhs and E_rhs are expressions (at this point we dont test any stronger than this)
         ((and (E? E_lhs) (E? E_rhs)) (list 'ae-+= E_lhs E_rhs))
         ; else error  (& requires E to be an Expression)
         (else (display "Error: In make-+=-ae, either or both sides are not expressions!" ))
)))

; make--=-ae : Expr -> Expr -> AssignmentExpr
(define make--=-ae
   (lambda (E_lhs E_rhs)
      (cond 
         ; The check that E_lhs and E_rhs are expressions (at this point we dont test any stronger than this)
         ((and (E? E_lhs) (E? E_rhs)) (list 'ae--= E_lhs E_rhs))
         ; else error  (& requires E to be an Expression)
         (else (display "Error: In make--=-ae, either or both sides are not expressions!" ))
)))


; Other operations ...

; "Apply"
; e-ae : AssignmentExpr -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )             ; i.e. AssignmentExpr -> T(Val)
(define e-ae
   (lambda (ae)
      (lambda (jp zeta rho s)
         ((seq-e
            (e-E (ae->E_rhs ae))
            (lambda (v_rhs) (seq-e
               (cond
                  ((=-ae? ae)   (return-e v_rhs))
                  ((or (+=-ae? ae) (-=-ae? ae))
                     (seq-e
                        (e-E (ae->E_lhs ae))
                        (lambda (v_lhs) (return-e (+ v_lhs v_rhs)))
                  ))
               )
               (lambda (v)
                  (cond
                     ((or (+=-ae? ae) (-=-ae? ae) (=-ae? ae))
                        ;(display "e-ae, v: ")(display v)(newline)
                        (cond 
                           ; if Id, take symbol and set value at the storage location it refers to
                           ((id? (ae->E_lhs ae))    (e-id-lhs (ae->E_lhs ae) v))
                           ; if *-operator, execute the addressing, and set value at that location
                           ((uo? (ae->E_lhs ae))    (e-uo-lhs (ae->E_lhs ae) v))
                           ; if array ref [], execute the addressing, and set value at that location
                           ((ar? (ae->E_lhs ae))    (e-ar-lhs (ae->E_lhs ae) v))
                           ; if struct ref ./->, execute the addressing, and set value at that location
                           ((sr? (ae->E_lhs ae))    (e-sr-lhs (ae->E_lhs ae) v))
                           ; Error ... not sure this will happen...
                           (else 
                              (return-e (begin 
                                 (display "Error: Assignment (=/...) has LHS expression of type not yet implemented!!!")))
                           )
                     ))
                     (else 
                        (return-e (begin (display "Error: Assignment operator ")(display ae)
                           (display " doesn't exist or not yet implemented!\n")))
                     )
         ))))) jp zeta rho s)
)))


; Predicate operations...

; ae? : Any -> Bool
(define ae?
   (lambda (ae)
      (cond 
         ((and (has-kind? ae) (eqv? (ae->kind ae) 'ae-=)) #t)
         ((and (has-kind? ae) (eqv? (ae->kind ae) 'ae-+=)) #t)
         ((and (has-kind? ae) (eqv? (ae->kind ae) 'ae--=)) #t)
         (else #f)
)))

; =-ae? : Any -> Bool
(define =-ae?
   (lambda (ae)
      (cond 
         ((and (has-kind? ae) (eqv? (ae->kind ae) 'ae-=)) #t)
         (else #f)
)))

; +=-ae? : Any -> Bool
(define +=-ae?
   (lambda (ae)
      (cond 
         ((and (has-kind? ae) (eqv? (ae->kind ae) 'ae-+=)) #t)
         (else #f)
)))

; -=-ae? : Any -> Bool
(define -=-ae?
   (lambda (ae)
      (cond 
         ((and (has-kind? ae) (eqv? (ae->kind ae) 'ae--=)) #t)
         (else #f)
)))


; Extraction operations...

; ae->kind : AssignmentExpr -> Kind
(define ae->kind
   (lambda (ae)
      (car ae)
))

; ae->E_lhs : AssignmentExpr -> Expr
(define ae->E_lhs
   (lambda (ae)
      (cadr ae)
))

; ae->E_rhs : AssignmentExpr -> Expr
(define ae->E_rhs
   (lambda (ae)
      (caddr ae)
))


; Valuation functions ...

; AssignmentExpr[[k_ae E]] = () -> AssignmentExpr
(define ast->ae
   (lambda (py_ast_var)
      ; First - work out what type of expression this is...
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "Assignment" node_type)
                 ; Second - valuate the code
                 (let ((k_ou  (python-eval (string-append py_ast_var ".op.encode('ascii')") #t))
                       (E_lhs (ast->E (string-append py_ast_var ".children()[0][1]")))
                       (E_rhs (ast->E (string-append py_ast_var ".children()[1][1]")))
                      )
                      (cond
                         ((string=? "=" k_ou) (make-=-ae E_lhs E_rhs))
                         ((string=? "+=" k_ou) (make-+=-ae E_lhs E_rhs))
                         ((string=? "-=" k_ou) (make--=-ae E_lhs E_rhs))
                         ; else error (not fail!) - unary operator not yet implemented!!!
                         (else 
                            (display "Error: \"")(display k_ou)(display "\" \"AssignmentExpr\" not yet implemented")(newline)
                            (exit)
                         )
              )))
              (else 
                 (display "Error: \"")(display node_type)(display "\" wrong for ast->ae, was expecting \"AssignmentExpr\"")(newline)
                 (exit)
              )
))))

; AssignmentExprApply[[ae]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )    ; i.e () -> T(Val)
(define ast->e-ae
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-ae (ast->ae py_ast_var)) jp zeta rho s)
)))


