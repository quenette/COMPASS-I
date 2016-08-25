; The idea behind this is to abstract out all lhs of struct/...-refs.
;
; TODO: Probably needs to be renamed ... not really a member but the struct. And its not akin to a struct/...-ref either.
;
; Semantic algebras...
;   Domain mr in MemberRef 
;
; Abstract syntax...
;  mr in MemberRef
;
;  MemberRef           ::= id | sr
;
; Valuation functions...
;  MemberRef[[id]] = () -> MemberRef
;  MemberRef[[sr]] = () -> MemberRef
;
; Developed for guile scheme v 1.8.7

(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-execution-store.scm")

; Construction operations ...

; make-id-mr : Id -> MemberRef
(define make-id-mr
   (lambda (id)
      id 
))

; make-sr-mr : StructRef -> MemberRef
(define make-sr-mr
   (lambda (sr)
      sr 
))


; Other operations ...

; The location of the struct...
; e-l_st : Kind_ref -> T(Val) -> MemberRef -> (JP-> Mot*->Env->Sto) -> (Loc x Mot* x Env' x Sto'); i.e. Kind_ref -> T(Val) -> MemberRef -> T(Val)
(define e-l_st
   (lambda (mr_st ref-kind chi-l,st)
      (lambda (jp zeta rho s)
         ((cond 
            ((and (id-mr? mr_st) (eqv? ref-kind '.))    (e-id->l mr_st))
            ((and (id-mr? mr_st) (eqv? ref-kind '->))   (e-deref (id->sym mr_st)))
            ((sr-mr? mr_st) 
               (seq-e
                  (chi-l,st mr_st)
                  (lambda (l,st) (return-e (car l,st)))
            ))
            (else   (return-e (display "Error: In e-l_st, Unknown reference operator: ")(display ref-kind)(display "!\n")))
         ) jp zeta rho s)
)))

; The type info of the struct...
; e-st_st : MemberRef -> T(Val) -> (JP->Mot*->Env->Sto) -> ( Struct x Mot* x Env' x Sto' )  ; i.e. MemberRef -> T(Val) -> T(Val)
(define e-st_st
   (lambda (mr_st chi-l,st)
      (lambda (jp zeta rho s)
         ((cond
            ((id-mr? mr_st)   (e-typeinfo->st (type-info (id->sym mr_st) rho)))
            ((sr-mr? mr_st)
               (seq-e
                  (chi-l,st mr_st)
;                  (e-sr->l,st mr_st)
                  (lambda (l,st_st) (seq-e
                     (e-ti_m (cadr l,st_st) (sr->id_m mr_st))
                     (lambda (ti_m) (e-typeinfo->st ti_m))
            ))))
            (else (return-e (display "Error: In e-st_st, Unknown lhs in reference : ")(display mr_st)(display "!\n")))
         ) jp zeta rho s)
)))


; Predicate operations...

; mr? : Any -> Bool
(define mr?
   (lambda (mr)
      (cond 
         ((id? mr) #t)
         ((sr? mr) #t)
         (else #f)
)))

; id-mr? : Any -> Bool
(define id-mr?
   (lambda (mr)
      (cond 
         ((id? mr)  #t)
         (else #f)
)))

; sr-mr? : Any -> Bool
(define sr-mr?
   (lambda (mr)
      (cond 
         ((sr? mr)  #t)
         (else #f)
)))


; Extractors for the data type...

; mr->kind : MemberRef -> Kind
(define mr->kind
   (lambda (mr)
      (car mr)
))


; Valuation functions ...

; MemberRef[[id]] = () -> MemberRef
; MemberRef[[sr]] = () -> MemberRef
(define ast->mr
   (lambda (py_ast_var)
      ; First - work out what type of expression this is...
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "ID" node_type)
                 ; Second - valuate the code
                 (make-id-mr (ast->id py_ast_var))
              )
              ((string=? "StructRef" node_type)
                 ; Second - valuate the code
                 (make-sr-mr (ast->sr py_ast_var))
              )
              (else 
                 (display "Error: \"")(display node_type)(display "\" wrong for ast->mr, was expecting \"ID\"")(newline)
                 (exit)
              )
))))

; MemberRefApply[[mr]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )    ; i.e () -> T(Val)
(define ast->e-mr
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-mr (ast->mr py_ast_var)) jp zeta rho s)
)))


