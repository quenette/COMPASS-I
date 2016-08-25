; The Variational Execution Monad.
;  Based on Wand04 Execution Monad model.
;  This module only concerns itself with the monad itself and not the monad operations for the store (see execution-store.scm).
;  Also - from an implelementation point of view, view the result of the monadic operations (a T(Val)) as a data type... tval. We
;  also dont assume a global environment rho but this is required with the store, hence capturing the fact that execution may
;  change the environment more explicitly. It also helps with code reuse.
;
; In a simplified sense, this is the store monad. However, in addition to a store, a joinpoint is required. That is it conceptually
; says - "all computation occurs at a joinpoint (a point in stack/computation space), and hence it needs to be known". This allows
; for example - advice at any joinpoint.
; 
; A chi represents a computation, although not executed yet, requires no arguments to execute and hence is ready for evaluation and
;  / or sequencing. It may infact be a function which did accept parameters but these have been now filled, hence presents a
;  mechanism to delaying computation.
;
; Domains:
;
; Semantic algebras...
;   Domain chi in T(Val)_b
;   Domain tval in T(Val)Sto_b
;   
;   T(Val)Sto_b = (Val x Mot* x Env x Sto)_b
;   T(Val)_b   = JP -> Mot -> Env -> Sto -> (Val x Mot* x Env' x Sto')_b
;
;   Note: the C language itself only requires that:  T(Val)_b   =  Env -> Sto -> (Val x Env' x Sto')_b
;    The JP is required for my research intests - execution that is also subject current dynamic stack location.
;
; Abstract syntax...
;   None.
;
; Developed for guile scheme v 1.8.7


; Construction operations ...

; return : Val -> T(Val)_b   = Val -> ( JP -> Mot* -> Env -> Sto -> (Val x Mot* x Env' x Sto')_b )
(define return-e
   (lambda (v)
      (lambda (jp zeta rho s)
         `(,v ,zeta ,rho ,s)
)))

; seq : "let" v <= E1 in (E2 v)      [Wand04 monadic notation]
;     : T(Val_A)_b -> (v_A -> T(Val_B)) -> T(Val_B)_b
(define seq-e
   (lambda (e1 e2)
      (lambda (jp zeta rho s)
         (let ((r1 (e1 jp zeta rho s)))
            (cond
               ; The following option I've added - if E1's val is failure, cease to continue and fail
               ((and (tval? r1) (unspecified? (tval->val r1))) (begin (display "Fail: Computation 'yeilded' an unspecifiable value. Aborting!")(newline)))
               ((tval? r1) ((e2 (tval->val r1)) jp (tval->zeta r1) (tval->rho r1) (tval->s r1)))
               ; else Fail!
               (else (begin (display "Error: Computation 'is' an unspecifiable value. Aborting!")(newline)))
)))))


; Predicate operations...

; tval? : T(Val)Sto -> Bool
(define tval?
   (lambda (tval)
      (pair? tval)
))


; Extraction operations...

; tval->val : T(Val)Sto -> Val
(define tval->val
   (lambda (tval)
      (car tval)
))

; tval->zeta : T(Val)Sto -> Mot*
(define tval->zeta
   (lambda (tval)
      (cadr tval)
))

; tval->rho : T(Val)Sto -> Env
(define tval->rho
   (lambda (tval)
      (caddr tval)
))

; tval->s : T(Val)Sto -> Sto
(define tval->s
   (lambda (tval)
      (cadddr tval)
))

