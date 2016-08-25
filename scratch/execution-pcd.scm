; Execution-pcd - A pcd, whose operations are execution monad operations
;  That is operations on the pcd as an monadic operation. 
; 
; Developed for guile scheme v 1.8.7

(load "a-jp.scm")
(load "a-pcd.scm")
(load "c-execution.scm")
(load "c-execution-store.scm")


; PCD[[pcd]] : (Val ->T(Val)) -> (Val -> T(Val)') -> (Val -> T(Val)")
;  If the PCD matches the current joinpoint, the function/procedure joinpoints need the arguments copied for the advice behaviour's
;  use. For this, we create a copy of the environment and a copy of the advice argument/values to it. Once the advice is
;  computed, the environment is reverted to the original (rho'). Note also that 'return value' is not resolved here (but in advice
;  itself).
;  If the PCD match fails, then just compute what was supposed to be executed next (T(Val)'), do nothing to the environment.
;
;  This differs from Wand04 in that the success continuation is a continuation, not an environment to computation. This
;  method ensures the store/environment relationship remains consistent given subsequent imperative operations in the advice. It
;  is available because the environment is considered part of the monadic store, not a global. Both the success and failure
;  computations are continuations.
;
; TODO: ... I'm not totally sure the idea of advice weaving works on a continuation (kappa)?  will it extract the present 
; computation (chi) from the next-computation/continuation (chi/kappa)?  if not, the success computation will need to change to NOT 
; have the next computation . How? how doescontinuation happen?  OR is the seperation from the current computation from the next 
; already done BEFORE here!?! In any case Wand04 doesn't explain this well.  Note: I'm not sure it makes sense to 'call a chi'...
; can't take no arguments!!!
; ==> I'm thinking that the latter is true ... none of these are "continutations"!!!
(define e-pcd
   (lambda (pcd kappa kappa')
      (lambda (v)
         (lambda (jp rho s)
            (let ((al (match-pcd pcd jp)))
               (cond
                  ((pcd-al? al) ((seq-e
                     ; create a new environment
                     (e-cpenv '()) 
                     (lambda (rho') (seq-e 
                        ; populate the advice arguments with values
                        (e-al rho al) 
                        (lambda (_) (seq-e 
                           ; apply the advice (the advice body, plus the jp itself, plus the continuation)
                           (kappa v)
                           (lambda (r) (seq-e
                              ; revert to the previous environment
                              (e-setenv rho')
                              ; return the value
                              (lambda (_) (return-e r))
                  ))))))) jp rho s))
                  ; fail (i.e continue as per normal: the jp itself plus the continuation)...
                  (else ((kappa' v) jp rho s))
))))))


; e-al : ArgList -> ( JP -> Env -> Sto ) -> ( Env' x Env' x Sto' )                                i.e. ArgList -> T(Val)
;  Add the argument list to "the" environment.
(define e-al
   (lambda (rho' al)
      (lambda (jp rho s)
         ((seq-e 
            (e-rho+al->rho rho al)
            (lambda (rho') (e-setenv rho'))
         ) jp rho s)
)))

; e-rho+al->rho : Env' -> ArgList -> ( JP -> Env -> Sto ) -> ( Env" x Env x Sto' )                i.e. Env' -> ArgList -> T(Val)
;  Add the argument list to "an" environment.
;  Env" is a new resultant environment. Env' is the initial environment of which the argument list is added to. Neither Env' or 
;  Env" are the monadic (current) Env. Hence this operation is about building new environments without effecting the current one.
(define e-rho+al->rho
   (lambda (rho' al)
      (lambda (jp rho s)
         (cond
            ((empty-al? al) ((return-e 1) jp rho s))
            (else ((seq-e 
               ; create a new location for the argument symbol
               ; TODO: replace "1" with size, which should come from the typeinfo (but in the ArgList case is undefined because JP
               ;  doesn't have it
               (e-decl (al->sym al) 1 (al->ti al)) 
               (lambda (_) (seq-e
                  ; Store the argument value bound to the symbol
                  (e-setref (al->sym al) (al->v al))
                  (e-rho+al->rho rho' (al->al al))
            ))) jp rho s))
))))



; Testing...
; test-advice-body01: Val -> ( JP -> Env -> Sto ) -> ( Val' x Env x Sto )                         i.e. Val -> T(Val)
; Return t-value is always 1
(define test-advice-body01
   (lambda (v)
      (lambda (jp rho s)
         (begin
            (display "I am a (pretend) advice body.\n")
            ((return-e 1) jp rho s) 
))))

; test-continuation01: Val -> ( JP -> Env -> Sto ) -> ( Val' x Env x Sto )                        i.e. Val -> T(Val)
; Return t-value is always 0
(define test-continuation01
   (lambda (v)
      (lambda (jp rho s)
         (begin
            (display "I am a (pretend) continuation.\n")
            ((return-e 2) jp rho s) 
))))


(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))

(define jp1 ((new-call-jp 'pcall 'myProc (list 1 2 3)) (display "")))
(define jp2 ((new-mcall-jp 'pcall 'myObj 'myProc (list 4 5 6)) (display "")))
(display "jp1: ") (display jp1) (newline)
(display "jp2: ") (display jp2) (newline)


(define pcd01  (list 'pcall 'myProc))
(define al01   (match-pcd pcd01 jp1))
(display "al01: ") (display al01) (newline)                 ; (empty-al)
(define tval01 (((e-pcd pcd01 test-advice-body01 test-continuation01) 0) jp1 rho s))
(display "val01: ") (display (tval->val tval01)) (newline)  ; 1

(define pcd02  (list 'fcall 'myProc))
(define al02   (match-pcd pcd02 jp1))
(display "al02: ") (display al02) (newline)                 ; (empty-al)

(define pcd03  (list 'foo 'myProc))
(define al03   (match-pcd pcd03 jp1))
(display "al03: ") (display al03) (newline)                 ; #<unspecified>
(define tval03 (((e-pcd pcd03 test-advice-body01 test-continuation01) 0) jp1 rho s))
(display "val03: ") (display (tval->val tval03)) (newline)  ; 0

(define pcd04  (list 'pcall 'bar))
(define al04   (match-pcd pcd04 jp1))
(display "al04: ") (display al04) (newline)                 ; #<unspecified>

(define pcd05  (list 'args (list 'v1 'v2 'v3)))
(define al05   (match-pcd pcd05 jp1))
(display "al05: ") (display al05) (newline)                 ; (extend-al v1 1 (extend-al v2 2 (extend-al v3 3 (empty-al))))

(define pcd06  (list 'args (list 'v1 'v2)))
(define al06   (match-pcd pcd06 jp1))
(display "al06: ") (display al06) (newline)                 ; #<unspecified>

(define pcd07  (list 'args (list 'v1 'v2 'v3 'v4)))
(define al07   (match-pcd pcd07 jp1))
(display "al07: ") (display al07) (newline)                 ; #<unspecified>

(define pcd08  (list 'and (list 'pcall 'myProc) (list 'args (list 'v1 'v2 'v3))))
(define al08   (match-pcd pcd08 jp1))
(display "al08: ") (display al08)  (newline)                ; (extend-al v1 1 (extend-al v2 2 (extend-al v3 3 (empty-al))))

(define pcd09  (list 'and (list 'foo 'myProc) (list 'args (list 'v1 'v2 'v3))))
(define al09   (match-pcd pcd09 jp1))
(display "al09: ") (display al09) (newline)                 ; #<unspecified>

(define pcd10  (list 'and (list 'pcall 'myProc) (list 'args (list 'v1 'v2))))
(define al10   (match-pcd pcd10 jp1))
(display "al10: ") (display al10) (newline)                 ; #<unspecified>

(define pcd11  (list 'obj 'myObj))
(define al11   (match-pcd pcd11 jp2))
(display "al11: ") (display al11) (newline)                 ; (empty-al)

(define pcd12  (list 'and (list 'and (list 'obj 'myObj) (list 'pcall 'myProc)) (list 'args (list 'v1 'v2 'v3))))
(define al12   (match-pcd pcd12 jp2))
(display "al12: ") (display al12) (newline)                 ; (extend-al v1 4 (extend-al v2 5 (extend-al v3 6 (empty-al))))









;(let ((jp0 (list 'jp)) ; hack for ease of reading results
;      (jp1 ((new-call-jp 'pcall 'myProc (list 1 2 3)) '<invalid>))
;     )
;     (let ((s0 (empty-store))
;          )
;          (let ((env1 (empty-env))
;                (env2 (extend-env 'd 6 (extend-env 'y 8 (extend-env 'x 7 (extend-env 'y 14 (empty-env))))))
;                (pcd1 (list 'and (list 'pcall 'myPro) (list 'args (list 'v1 'v2 'v3))))
;                (pcd2 (list 'and (list 'pcall 'myProc) (list 'args (list 'v1 'v2 'v3))))
;               )
;               (let ((s1 (tval->sto ((e-copy-env env1) jp0 s0)))
;                     (s2 (tval->sto ((e-copy-env env2) jp0 s0)))
; TODO: need to mimic the apply operation of the shape Exp -> (Env -> T(Val))
; This mimics the apply operation of the shape Val* -> (T(Val))
;                     (val1 (tval->val ((e-pcd pcd1 (test-apply-env-e 'HACK) (return-e 10)) jp1 s0)))
;                     (val2 (tval->val ((e-pcd pcd2 (test-apply-env-e 'HACK) (return-e 10)) jp1 s0)))
;                     ; pretend the advice counter is also in the  store
;                     (val3 (tval->val ((seq-e (e-named-alloc 'adviceI 0) (lambda (x) (e-pcd pcd1 (test-apply-env-e 'HACK) (return-;e 10)))) jp1 s0 )))
;                     (val4 (tval->val ((seq-e (e-named-alloc 'adviceI 0) (lambda (x) (e-pcd pcd2 (test-apply-env-e 'HACK) (return-e 10)))) jp1 s0 )))
;                    )
;                    (begin 
;                       (display "jp0: ")  (display jp0) (newline)
;                       (display "s0: ")   (display s0) (newline)
;                       (display "env1: ") (display env1) (newline)
;                       (display "s1: ")   (display s1) (newline) ; (empty-env)
;                       (display "env2: ") (display env2) (newline)
;                       (display "s2: ")   (display s2) (newline) ; (extend-env d 6 (extend-env y 8 (extend-env x 7 (extend-env y 14 (empty-env)))))
;                       (display "val1: ") (display val1) (newline) ; 10
;                       (display "val2: ") (display val2) (newline) ;
;                       (display "s2: ") (display s2) (newline) ; (extend-env d 6 (extend-env y 8 (extend-env x 7 (extend-env y 14 (empty-env)))))
;                       (display "val3: ") (display val3) (newline) ; 10
;                       (display "val4: ") (display val4) (newline) 
;)))))

