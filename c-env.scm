; The implementation of an 'Environment' (motivated by Schmidt88). The environment model/code itself is largely motivated from
;  EOPLv3, code in 2.2.3, but with an extra term for type information, and "equal" used rather than "eqv" for identifier
;  comparison.  The Environment provides locations of Identifiers, hence representing the 'Symbol Table'. 
; 
;
; TODO: Test for alloc and deref and set
; TODO: Loc should be Loc | Val as we now use the environment to remember more than just binding locations.
;
; Semantic algebras...
;   Domain rho in Env
;    (Domain sym in Sym+'next-l)
;    (Domain l in Loc)
;    (Domain sz in Size in Loc)
;    (Domain dd in DenDecl)
;
;  Env  ::= < 'empty-env >
;         ::= < 'extend-env sym l rho dd >
;
; Abstract syntax...
;  None
;
; Valuation functions...
;  None
;
; Developed for guile scheme v 1.8.7


(load "error.scm")
(load "kind.scm")


; Construction operations ...

; empty-env : () -> Env
(define empty-env
   (lambda () 
      (list 'empty-env)
))

; make-env : Loc -> Env
;  A new environment with the initial location for functions ('fnext-l) and the heap ('next-l) and 
(define make-env
   (lambda (fnext-l next-l) 
      (extend-env 'fnext-l fnext-l (extend-env 'next-l next-l (empty-env) '()) '())
))

; extend-env : Sym x Loc x Env x DenDecl -> Env'
(define extend-env
   (lambda (sym l rho tyde)
      (list 'extend-env sym l rho tyde)
))

; cp-env : Env -> Env'
(define cp-env
   (lambda (rho)
      (cond
         ((empty-env? rho) (empty-env))
         (else (extend-env (env->sym rho) (env->l rho) (cp-env (env->env rho)) (env->dd rho)))
)))

; Other operations ...

; apply-env : Sym x Env -> Loc_b
(define apply-env
   (lambda (search-sym rho)
      (cond
         ((eqv? (env->kind rho) 'empty-env)
            ; Fail
            (display "Fail: Symbol \"")(display search-sym)(display "\" is has not been declared.")(newline)
         )
         ((eqv? (env->kind rho) 'extend-env)
            (let ((saved-sym (env->sym rho))
                  (saved-l (env->l rho))
                  (saved-env (env->env rho)))
               (if (equal? search-sym saved-sym)
                  saved-l
                  (apply-env search-sym saved-env)
         )))
         (else (error-invalid-env rho))
)))

; type-info : Sym x Env -> DenDecl
(define type-info
   (lambda (search-sym rho)
      (cond
         ((eqv? (env->kind rho) 'empty-env)
            ; Fail
            (display "Fail: Looking up type info, symbol \"")(display search-sym)(display "\" is has not been declared.")(newline)
         )
         ((eqv? (env->kind rho) 'extend-env)
            (let ((saved-sym (env->sym rho))
                  (saved-tyde (env->dd rho))
                  (saved-env (env->env rho)))
               (if (equal? search-sym saved-sym)
                  saved-tyde
                  (type-info search-sym saved-env))))
         (else (error-invalid-env rho))
)))

; alloc : Size x Env -> ( Loc x Env' )
;  An allocation means to save the required space in the store (it doesn't actually affect the store). We model this by keeping
;  track of the next available location in the store. The Sym 'next-l is not avialable to the langauge (there is no mechanism
;  to express it).
;  Note the co-domain (result) is a pair not a list (i.e. use cdr for the 2nd value not cadr)
(define alloc
   (lambda (size-l rho)
      (let ((saved-next-l  (apply-env 'next-l rho)))
           (let ((new-env  (extend-env 'next-l (+ saved-next-l size-l) rho '())))
                `( ,saved-next-l . ,new-env)
))))

; falloc : Size x Env -> ( Loc x Env' )
;  An allocation means to save the required space in the store (it doesn't actually affect the store). We model this by keeping
;  track of the next available location in the store. The Sym 'fnext-l is not avialable to the langauge (there is no mechanism
;  to express it). falloc in particular is for the functions, allowing functions to be in a different address space.
;  note the co-domain (result) is a pair not a list (i.e. use cdr for the 2nd value not cadr)
(define falloc
   (lambda (size-l rho)
      (let ((saved-fnext-l  (apply-env 'fnext-l rho)))
           (let ((new-env  (extend-env 'fnext-l (+ saved-fnext-l size-l) rho '())))
                `( ,saved-fnext-l . ,new-env)
))))

; deref : Sym x Env x Sto -> Val_b
(define deref
   (lambda (sym rho s)
      (apply-s (apply-env sym rho) s)
))

; setref : Sym -> Val -> Env -> Sto -> Sto'
(define setref
   (lambda (id v rho s)
      (extend-s (apply-env id rho) v s)
))

(define fail-undeclared-identifier
   (lambda (sym)
      (error 'apply-env "Fail: undeclared identifier \"~s\"" sym)))

(define error-invalid-env
   (lambda (rho)
      (error 'apply-env "Error: \"~s\" is not an Environment" rho)))


; Predicates for the data type...

; env? : Any -> Bool
(define env?
   (lambda (rho)
      (cond
         ((and (has-kind? rho) (eqv? (env->kind rho) 'empty-env)) #t)
         ((and (has-kind? rho) (eqv? (env->kind rho) 'extend-env)) #t)
         (else #f)
)))

; empty-env? : Env -> Bool
(define empty-env?
   (lambda (rho)
      (cond
         ((eqv? (env->kind rho) 'empty-env)
            #t)
         (else 
            #f)
)))

; Extraction operations...

; env->kind : Env -> Kind
(define env->kind
   (lambda (rho)
      (car rho)
))

; env->sym : Env -> Sym
(define env->sym
   (lambda (rho)
      (cadr rho)
))

; env->l : Env -> Loc
(define env->l
   (lambda (rho)
      (caddr rho)
))

; env->env : Env -> Env'
(define env->env
   (lambda (rho)
      (cadddr rho)
))

; env->dd : Env -> DenDecl
(define env->dd
   (lambda (rho)
      (car (cdr (cdr (cdr (cdr rho)))))
))

