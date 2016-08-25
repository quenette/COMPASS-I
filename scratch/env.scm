; Environments data type
;  We have to use a queriable environment (and hence not the functional implementation - at least right now this way seems more
;  natural to me).
;
; Grammars
;
; Env ::= ('empty-env)
;     ::= ('extend-env Var Scheme-value Env-exp)
; Var ::= SchemeVal   At this point Var can be anything - as this code/project/use develops this may not be true (e.g. Var ::= Sym)
;   Note: Identifiers (Var) can be anything so long as equivalency can be performed and is meaningful
;
; Largely motivated from EOPLv3, code in 2.2.3
;  Once particular difference is that 'equal' is used in apply for search-var rather than eqv, such that lists/pairs can be Vars.
; 
; Developed for guile scheme v 1.8.7

(load "error.scm")


; Constructors for this data type...

; empty-env : () -> Env
(define empty-env
   (lambda () 
      (list 'empty-env)
))

; extend-env : Var x Schemeval x Env -> Env
(define extend-env
   (lambda (var val env)
      (list 'extend-env var val env)
))

; aextend-env : Var x Schemeval x Env -> Env_b
; This version of extend will only extend the environment IF var isn't already in the environment. If the var is found it will NOT
;  over-ride it. It essentially 'fails' on var already existing but returns with the prior environment for convenience. Motiviated
;  for copying and ensuring the env is the smallest set, and hence to behave like 'alloc'.
(define aextend-env
   (lambda (var val env)
      (aextend-envR var val env env)
))
(define aextend-envR
   (lambda (var val env root-env)
      (cond
         ((eqv? (env->kind env) 'empty-env)
            (extend-env var val root-env))
         ((eqv? (env->kind env) 'extend-env)
            (if (equal? var (env->var env))
               root-env
               (aextend-envR var val (env->env env) root-env)
         ))
         (else (report-invalid-env env))
)))

; merge-env : Env x Env -> Env
; The second environment is added to the first, one entry at a time, starting with the last (i.e. the second env takes precedence)
(define merge-env
   (lambda (env1 env2)
      (cond
         ((eqv? (env->kind env2) 'extend-env) (extend-env (env->var env2) (env->val env2) (merge-env env1 (env->env env2))))
         (else env1)
)))


; Other members for this data type...

; apply-env : Env x Var -> Schemeval
(define apply-env
   (lambda (env search-var)
      (cond
         ((eqv? (env->kind env) 'empty-env)
            (report-no-binding-found search-var))
         ((eqv? (env->kind env) 'extend-env)
            (let ((saved-var (env->var env))
                  (saved-val (env->val env))
                  (saved-env (env->env env)))
               (if (equal? search-var saved-var)
                  saved-val
                  (apply-env saved-env search-var))))
         (else (report-invalid-env env))
)))

; env-length : Env -> Val
(define env-length
   (lambda (env)
      (cond
         ((eqv? (env->kind env) 'empty-env) 0)
         ((eqv? (env->kind env) 'extend-env) (+ 1 (env-length (env->env env))))
)))

(define report-no-binding-found
   (lambda (search-var)
      (error 'apply-env "No binding for ~s" search-var)))

(define report-invalid-env
   (lambda (env)
      (error 'apply-env "Bad environment: ~s" env)))


; Predicates for the data type...

; env? : SchemeVal -> Bool
(define env?
   (lambda (env)
      (cond
         ((eqv? (env->kind env) 'empty-env)
            #t)
         ((eqv? (env->kind env) 'extend-env)
            #t)
         (else 
            #f)
)))

; empty-env? : Env -> Bool
(define empty-env?
   (lambda (env)
      (cond
         ((eqv? (env->kind env) 'empty-env)
            #t)
         (else 
            #f)
)))

; non-empty-env? : Env -> Bool
(define non-empty-env?
   (lambda (env)
      (cond
         ((eqv? (env->kind env) 'extend-env)
            #t)
         (else 
            #f)
)))


; Extractors for the data type...

; env->kind : Env -> EnvKind
(define env->kind
   (lambda (env)
      (car env)
))

; env->var : Env -> Var
(define env->var
   (lambda (env)
      (cadr env)
))

; env->val : Env -> Val
(define env->val
   (lambda (env)
      (caddr env)
))

; env->env : Env -> Env
(define env->env
   (lambda (env)
      (cadddr env)
))


