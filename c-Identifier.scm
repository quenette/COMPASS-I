;
; Semantic algebras...
;   Domain id in Id 
;    (Domain sym in Sym)
;    (Domain v in Val)
;
; Abstract syntax...
;  id in Id
;
;  Val          ::= sym
;  Kind         ::= 'identifier
;  Id           ::= < 'identifier sym >
;
; Valuation functions...
;  Id[[sym]] = () -> Id
;
; Developed for guile scheme v 1.8.7

(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-execution-store.scm")

; Construction operations ...

; make-id : Sym -> Id
(define make-id
   (lambda (sym)
      (list 'identifier sym) 
))


; Other operations ...

; "Apply" (rhs)
; e-id : Id -> ( JP -> Mot* -> Env -> Sto ) -> ( Loc|Val x Mot* x Env' x Sto' )             ; i.e. Id -> T(Val)
(define e-id
   (lambda (id)
      (lambda (jp zeta rho s)
         ((let ((ti   (type-info (id->sym id) rho)))
            (seq-e
               (e-id->l id)
               (lambda (l) (e-l l ti))
         )) jp zeta rho s)
)))

; e-id->l : Id -> ( JP -> Mot* -> Env -> Sto ) -> ( Loc x Mot* x Env' x Sto' )             ; i.e. Id -> T(Val)
(define e-id->l
   (lambda (id)
      (lambda (jp zeta rho s)
         ((e-apply-env (id->sym id)) jp zeta rho s)
)))


; e-l : Loc -> TypeInfo -> ( JP -> Mot* -> Env -> Sto ) -> ( Loc|Val x Mot* x Env' x Sto' )   ; i.e. Loc -> TypeInfo -> T(Val)
(define e-l
   (lambda (l ti)
      (lambda (jp zeta rho s)
         ((seq-e
            (e-basic-typeinfo? ti)
            (lambda (is_basic)
               (cond
                  (is_basic   (e-apply-s l))
                  (else       (return-e l))
         ))) jp zeta rho s)
)))


; Given a typeinfo, determine whether its a complex type (if a struct or union,...) but not if a pointer, int, ... (used by fc)
(define e-basic-typeinfo?
   (lambda (ti)
      (lambda (jp zeta rho s)
         ((cond
            ((and (td? ti) (it-td? ti) (inbuilt-it? (td->it ti)))  (return-e #t))
            ((pd? ti)  (return-e #t))
            ((and (td? ti) (it-td? ti) (user-it? (td->it ti))) 
               (seq-e
                  (e-get-type (it->tname (td->it ti)))
                  (lambda (ti') (return-e #f))
            ))
            (else (return-e #f))
      ) jp zeta rho s)
)))


; lhs
; e-id-lhs : Id -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )             ; i.e. Id -> T(Val)
(define e-id-lhs
   (lambda (id v)
      (lambda (jp zeta rho s)
         ((let ((ti   (type-info (id->sym id) rho)))
            (seq-e
               (e-apply-env (id->sym id))
               (lambda (l) (e-l-lhs l ti v))
         )) jp zeta rho s)
)))


; e-l-lhs : Loc -> TypeInfo -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )     ; i.e. Loc -> TypeInfo -> T(Val)
(define e-l-lhs
   (lambda (l ti v)
      (lambda (jp zeta rho s)
         ((cond
             ((td? ti)  (e-extend-s l v))
             ((pd? ti)  (e-extend-s l v))
             ((ad? ti)  (return-e (display "Error: In e-l-lhs, Arrays cannot be a lhs identifier!\n")))
             ((st? ti)  (return-e (display "Error: In e-l-lhs, Structs cannot be a lhs identifier!\n")))
             (else (return-e 
                (display "Error: In e-l-lhs, type - ")(display ti)(display " is not a known type or is not implemented!\n")
             ))
         ) jp zeta rho s)
)))



; Predicate operations...

; id? : Any -> Bool
(define id?
   (lambda (id)
      (cond 
         ((and (has-kind? id) (eqv? (id->kind id) 'identifier)) #t)
         (else #f)
)))


; Extractors for the data type...

; id->kind : Id -> Kind
(define id->kind
   (lambda (id)
      (car id)
))

; id->sym : Id -> Symbol
(define id->sym
   (lambda (it)
      (cadr it)
))


; Valuation functions ...

; Id[[sym]] = () -> Id
(define ast->id
   (lambda (py_ast_var)
      ; First - work out what type of expression this is...
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "ID" node_type)
                 ; Second - valuate the code
                 (let ((sym   (python-eval (string-append py_ast_var ".name.encode('ascii')") #t)))
                      (make-id sym)
              ))
              (else 
                 (display "Error: \"")(display node_type)(display "\" wrong for ast->id, was expecting \"ID\"")(newline)
                 (exit)
              )
))))

; IdApply[[id]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )    ; i.e () -> T(Val)
(define ast->e-id
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-id (ast->id py_ast_var)) jp zeta rho s)
)))


