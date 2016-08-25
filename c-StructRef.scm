;
; Semantic algebras...
;   Domain sr in StructRef = StructRefKind x Expr
;    (Domain k_sr in StructRefKind in Kind)
;    (Domain id_m in Id)    ... identifer of member element of reference
;    (Domain mr_st in MemberRef)    ... member-ref of member element of reference. For a struct-ref, it as to be of type struct.
;    (Domain E in Expr)
;    (Domain v in Val)
;
; Abstract syntax...
;  sr in StructRef
;
;  Val          ::= Loc
;  StructRefKind  ::= 'sr-. | 'sr-->
;  StructRef      ::= < k_sr mr_st id_m >
;
; Valuation functions...
;  StructRef[[k_sr mr_st id_m]]       = () -> StructRef
;
; Developed for guile scheme v 1.8.7


(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-execution-store.scm")
(load "c-Identifier.scm")
(load "c-MemberRef.scm")


; Construction operations ...

; make-.-sr : Id -> StructRef
(define make-.-sr
   (lambda (mr_st id_m)
      (cond 
         ; The check that mr_st id_m is and Id is important here ... we dont check in later operations
         ((and (mr? mr_st) (id? id_m))   (list 'sr-. mr_st id_m)) 
         ; else error  (. requires mr_st and id_m to be an Id)
)))

; make-->-sr : Id -> StructRef
(define make-->-sr
   (lambda (mr_st id_m)
      (cond 
         ; The check that mr_st id_m is and Id is important here ... we dont check in later operations
         ((and (mr? mr_st) (id? id_m))   (list 'sr--> mr_st id_m)) 
         ; else error  (. requires mr_st and id_m to be an Id)
)))

; Other operations ...

; "Apply" (rhs)
; e-sr : StructRef -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )             ; i.e. StructRef -> T(Val)
(define e-sr
   (lambda (sr)
      (lambda (jp zeta rho s)
         ;(display "e-sr, sr: ")(display sr)(newline)
         ((seq-e
            (e-sr->l,st sr)
            (lambda (l,st) 
               ;(display "e-sr, l,st (step 1/2): ")(display l,st)(newline)
               (seq-e
                  (e-ti_m (cadr l,st) (sr->id_m sr))
                  (lambda (ti_m) (e-l (car l,st) ti_m))
         ))) jp zeta rho s)
)))

; lhs
; e-sr-lhs : StructRef -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )             ; i.e. StructRef -> T(Val)
(define e-sr-lhs
   (lambda (sr v)
      (lambda (jp zeta rho s)
         ((seq-e
            (e-sr->l,st sr)
            (lambda (l,st) (seq-e
               (e-ti_m (cadr l,st) (sr->id_m sr))
               (lambda (ti_m) (e-l-lhs (car l,st) ti_m v))
         ))) jp zeta rho s)
)))


; The location & structure (type info) meant by this struct ref...
; e-sr->l,st : StructRef -> ( JP -> Mot* -> Env -> Sto ) -> ( (Loc x Struct) x Mot* x Env' x Sto' )    ; i.e. StructRef -> T(Val)
(define e-sr->l,st
   (lambda (sr)
      (lambda (jp zeta rho s)
         ((seq-e
            (cond 
               ((.-sr? sr)    (e-l_st (sr->mr_st sr) '.  e-sr->l,st))
               ((->-sr? sr)   (e-l_st (sr->mr_st sr) '-> e-sr->l,st ))
               (else   (return-e (display "Error: In-sr->l, Unknown reference operator: ")(display (sr->kind sr))(display "!\n")))
            )
            (lambda (l_st) (seq-e
               (e-st_st (sr->mr_st sr) e-sr->l,st)
               (lambda (st_st) (seq-e
                  (e-l_m st_st (sr->id_m sr))
                  (lambda (l_m) (return-e (list (+ l_st l_m) st_st)))
         ))))) jp zeta rho s)
)))

; The offset of the member...
; e-l_m : Struct -> Id -> ( JP -> Mot* -> Env -> Sto ) -> ( Loc x Mot* x Env' x Sto' )       ; i.e. Struct -> Id -> T(Val)
(define e-l_m
   (lambda (st_st id_m)
      (lambda (jp zeta rho s)
         ((e-st->offset st_st (id->sym id_m)) jp zeta rho s)
)))

; The type info of the member...
; e-ti_m : StructRef -> ( JP -> Mot* -> Env -> Sto ) -> ( TypeInfo x Mot* x Env' x Sto' )    ; i.e. StructRef -> T(Val)
(define e-ti_m
   (lambda (st_st id_m)
      (lambda (jp zeta rho s)
         ((return-e (st->ti st_st (id->sym id_m))) jp zeta rho s)
)))

; Given a typeinfo, if its a pointer and/or typedef then extract the underlying td 
(define e-typeinfo->st
   (lambda (ti)
      (lambda (jp zeta rho s)
         ((cond
            ; When struct is used to identify a struct declaration... look up...
            ((and (st? ti) (eq? (st->D* ti) '()))
               (seq-e
                  (e-get-struct (st->sym ti))
                  (lambda (st') (e-typeinfo->st st'))
            ))
            ; If its a struct itself...
            ((and (st? ti))   (return-e ti))
            ; If its a declaration of a struct itself ... recurse on the struct...
            ((and (td? ti) (st-td? ti))   (e-typeinfo->st (td->st ti)))
            ; If its a pointer to a declaration... recurse on the declaration...
            ((and (pd? ti) (td? (pd->dd ti)))   (e-typeinfo->st (pd->dd ti)))
            ; If its a declaration to a user defined type... look up and recurse on the type...
            ((and (td? ti) (it-td? ti) (user-it? (td->it ti))) 
               (seq-e
                  (e-get-type (it->tname (td->it ti)))
                  (lambda (ti') (e-typeinfo->st ti'))
            ))
            (else (display "Error: as far as I can tell, ti = ")(display ti)(display " is not a struct type (or pointer to)\n"))
      ) jp zeta rho s)
)))


; Predicate operations...

; sr? : Any -> Bool
(define sr?
   (lambda (sr)
      (cond 
         ((and (has-kind? sr) (eqv? (sr->kind sr) 'sr-.)) #t)
         ((and (has-kind? sr) (eqv? (sr->kind sr) 'sr-->)) #t)
         (else #f)
)))

; .-sr? : Any -> Bool
(define .-sr?
   (lambda (sr)
      (cond 
         ((and (has-kind? sr) (eqv? (sr->kind sr) 'sr-.)) #t)
         (else #f)
)))

; ->-sr? : Any -> Bool
(define ->-sr?
   (lambda (sr)
      (cond 
         ((and (has-kind? sr) (eqv? (sr->kind sr) 'sr-->)) #t)
         (else #f)
)))


; Extraction operations...

; sr->kind : StructRef -> Kind
(define sr->kind
   (lambda (sr)
      (car sr)
))

; sr->mr_st : StructRef -> MemberRef
(define sr->mr_st
   (lambda (sr)
      (cadr sr)
))

; sr->id_m : StructRef -> Id
(define sr->id_m
   (lambda (sr)
      (caddr sr)
))


; Valuation functions ...

; StructRef[[k_sr mr_st id_m]] = () -> StructRef
(define ast->sr
   (lambda (py_ast_var)
      ; First - work out what type of expression this is...
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "StructRef" node_type)
                 ; Second - valuate the code
                 (let ((k_ou (python-eval (string-append py_ast_var ".type.encode('ascii')") #t))
                       (mr_st    (ast->mr (string-append py_ast_var ".children()[0][1]")))
                       (id_m    (ast->id (string-append py_ast_var ".children()[1][1]")))
                      )
                      (cond
                         ((string=? "." k_ou)  (make-.-sr mr_st id_m))
                         ((string=? "->" k_ou) (make-->-sr mr_st id_m))
                         ; else error (not fail!) - unary operator not yet implemented!!!
                         (else 
                            (display "Error: \"")(display k_ou)(display "\" \"StructRef\" not yet implemented")(newline)
                            (exit)
                         )
              )))
              (else 
                 (display "Error: \"")(display node_type)(display "\" wrong for ast->sr, was expecting \"StructRef\"")(newline)
                 (exit)
              )
))))

; StructRefApply[[sr]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )    ; i.e () -> T(Val)
(define ast->e-sr
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-sr (ast->sr py_ast_var)) jp zeta rho s)
)))


