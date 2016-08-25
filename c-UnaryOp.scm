;
; Semantic algebras...
;   Domain uo in UnaryOp = UnaryOpKind x Expr
;    (Domain k_uo in UnaryOpKind in Kind)
;    (Domain id in Id)
;    (Domain E in Expr)
;    (Domain v in Val)
;
; Abstract syntax...
;  uo in UnaryOp
;
;  Val          ::= Loc
;  UnaryOpKind  ::= '& | '* | 'sizeof
;  UnaryOp      ::= < k_uo E >
;
; Valuation functions...
;  UnaryOp[[k_uo E]]       = () -> UnaryOp
;
; Developed for guile scheme v 1.8.7


(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-execution-store.scm")
(load "c-Identifier.scm")
(load "c-Typename.scm")


; Construction operations ...

; make-&-uo : Id -> UnaryOp
(define make-&-uo
   (lambda (E)
      (cond 
         ; The check that E is an Id is important here ... we dont check in later operations
         ((id? E) (list '& E)) 
         ; else error  (& requires E to be an Id)
)))

; make-*-uo : Expr -> UnaryOp
(define make-*-uo
   (lambda (E)
      (list '* E)
))

; make-sizeof-uo : Typename -> UnaryOp
(define make-sizeof-uo
   (lambda (tn)
      (cond 
         ; The check that E is an Typename is important here ... we dont check in later operations
         ((tn? tn) (list 'sizeof tn)) 
         ; else error  (sizeof requires E to be an Typename)
)))

; Other operations ...

; "Apply" (rhs)
; e-uo : UnaryOp -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )             ; i.e. UnaryOp -> T(Val)
(define e-uo
   (lambda (uo)
      (lambda (jp zeta rho s)
         ((cond 
            ((&-uo? uo)  (e-apply-env (id->sym (uo->E uo))) )
            ((*-uo? uo)  
               (seq-e
                  (e-E (uo->E uo))
                  (lambda (v_l)
                     (e-apply-s v_l)
            )))
            ((sizeof-uo? uo) (e-td->sz (tn->td (uo->E uo))))
            ; Else error ... 
            (else ((return-e (display "Error: Unknown UnaryOp: ")(display uo)(display "!!!\n")) jp zeta rho s))
         ) jp zeta rho s)
)))

; lhs
; e-uo-lhs : UnaryOp -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )             ; i.e. UnaryOp -> T(Val)
(define e-uo-lhs
   (lambda (uo v)
      (lambda (jp zeta rho s)
         ((cond 
            ((*-uo? uo)
               (cond
                  ; Basic types, struct and unions cannot be dereferenced on the lhs 
                  ((and  (id? (uo->E uo))  (td? (type-info (id->sym (uo->E uo)) rho)))
                     (display "Error: No lhs for unary operator * on basic types, structs and unions!\n")
                  )
                  (else
                     (seq-e
                        (e-E (uo->E uo))
                        (lambda (l) (e-extend-s l v))
                  ))
            ))
            (else   (display "Error: No lhs for the unary operator: ")(display (uo->kind uo))(display "!\n"))
         ) jp zeta rho s)
)))


; Predicate operations...

; uo? : Any -> Bool
(define uo?
   (lambda (uo)
      (cond 
         ((and (has-kind? uo) (eqv? (uo->kind uo) '&)) #t)
         ((and (has-kind? uo) (eqv? (uo->kind uo) '*)) #t)
         ((and (has-kind? uo) (eqv? (uo->kind uo) 'sizeof)) #t)
         (else #f)
)))

; &-uo? : Any -> Bool
(define &-uo?
   (lambda (uo)
      (cond 
         ((and (has-kind? uo) (eqv? (uo->kind uo) '&)) #t)
         (else #f)
)))

; *-uo? : Any -> Bool
(define *-uo?
   (lambda (uo)
      (cond 
         ((and (has-kind? uo) (eqv? (uo->kind uo) '*)) #t)
         (else #f)
)))

; sizeof-uo? : Any -> Bool
(define sizeof-uo?
   (lambda (uo)
      (cond 
         ((and (has-kind? uo) (eqv? (uo->kind uo) 'sizeof)) #t)
         (else #f)
)))


; Extraction operations...

; uo->kind : UnaryOp -> Kind
(define uo->kind
   (lambda (uo)
      (car uo)
))

; uo->E : UnaryOp -> Expr
(define uo->E
   (lambda (uo)
      (cadr uo)
))


; Valuation functions ...

; UnaryOp[[k_uo E]] = () -> UnaryOp
(define ast->uo
   (lambda (py_ast_var)
      ; First - work out what type of expression this is...
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "UnaryOp" node_type)
                 ; Second - valuate the code
                 (let ((k_ou (python-eval (string-append py_ast_var ".op.encode('ascii')") #t))
                       (E    (ast->E (string-append py_ast_var ".children()[0][1]")))
                      )
                      (cond
                         ((string=? "&" k_ou)      (make-&-uo E))
                         ((string=? "*" k_ou)      (make-*-uo E))
                         ((string=? "sizeof" k_ou) (make-sizeof-uo E))
                         ; else error (not fail!) - unary operator not yet implemented!!!
                         (else 
                            (display "Error: \"")(display k_ou)(display "\" \"UnaryOp\" not yet implemented")(newline)
                            (exit)
                         )
              )))
              (else 
                 (display "Error: \"")(display node_type)(display "\" wrong for ast->uo, was expecting \"UnaryOp\"")(newline)
                 (exit)
              )
))))

; UnaryOpApply[[uo]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )    ; i.e () -> T(Val)
(define ast->e-uo
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-uo (ast->uo py_ast_var)) jp zeta rho s)
)))


