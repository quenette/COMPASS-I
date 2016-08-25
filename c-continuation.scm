; Continuation.
;   Given the execution monad represents the notion of execution computation, a continuation takes the the value result (of a
;   computation and yeilds the next computation. Continuations are the remaining computations for the given program. A program is
;   is an application of continuations.
; 
; The continuation is a function, and whose co-domain is a T(Val), and hence we dont make a data-type out of it here.
;
; Domains:
;
; Semantic algebras...
;   Domain kappa in Cont
;     (Domain v in Val)
;     (Domain tval in T(Val))
;
;   Cont   = Val -> ( JP -> Mot* -> Env -> Sto ) -> (Val x Mot x Env' x Sto')_b
;          = Val -> T(Val)
;
; Abstract syntax...
;   None.
;
; Developed for guile scheme v 1.8.7

; Construction operations ...
;  None.

; Other operations ...

; e-eoc :  Val -> T(Val)
;   Denotes the "end of computation" (of a program / an application of continuations) and hence there is no continuation past this.
(define e-eoc
   (lambda (v)
      (lambda (jp zeta rho s)
         ; The following line is NOT part of the formal model, but (a) is to indicate completion to the user and (b) requires "begin"
         (display "End of computation. Result = ") (display v) (newline)
         ((return-e v) jp zeta rho s)
)))

; e-eop :  Val -> T(Val)
;   Denotes the "return" or enforced "end of procedure" and hence there is no continuation in the present procedure past this.
(define e-eop
   (lambda (v)
      (lambda (jp zeta rho s)
         ; The following line is NOT part of the formal model, but (a) is to indicate completion to the user and (b) requires "begin"
         (display "Return. Result = ") (display v) (newline)
         ((return-e v) jp zeta rho s)
)))

; e-eoC :  Val -> T(Val)
;   Denotes the "end of a compound (sequence of instructions)" and hence there is no continuation in the present compound past this.
(define e-eoC
   (lambda (v)
      (lambda (jp zeta rho s)
         ; The following line is NOT part of the formal model, but (a) is to indicate completion to the user and (b) requires "begin"
         (display "End of compound. (Result = ") (display v) (display ")") (newline)
         ((return-e v) jp zeta rho s)
)))

; e-eoO :  Val -> T(Val)
;   Denotes the "end of a object construction".
(define e-eoO
   (lambda (v)
      (lambda (jp zeta rho s)
         ; The following line is NOT part of the formal model, but (a) is to indicate completion to the user and (b) requires "begin"
         (display "End of object construction. (Result = ") (display v) (display ")") (newline)
         ((return-e v) jp zeta rho s)
)))

; e-eoM :  Val -> T(Val)
;   Denotes the "end of a module load (sequence of declarations)" and hence there is no continuation in the present module past this.
(define e-eoM
   (lambda (v)
      (lambda (jp zeta rho s)
         ; The following line is NOT part of the formal model, but (a) is to indicate completion to the user and (b) requires "begin"
         (display "End of module load.") (newline)
         ((return-e v) jp zeta rho s)
)))

; Predicate operations...
;  None.


; Extraction operations...
;  None.

