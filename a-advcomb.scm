; Advice combinators - 
;  Combinators that reduce the chi and advice-body results to one.
;
; Semantic algebras...
;  None
;
; Abstract syntax...
;  None
;
; Valuation functions...
;  None
;
; Developed for guile scheme v 1.8.7


; Construction operations ...
; None.

; T(Val) operations ...

; ac : Val -> Val^1st -> Val^2nd -> T(Val)
(define e-ac
   (lambda (v v_1st v_2nd)
      (lambda (jp zeta rho s)
         ((e-jp-chi
            (new-ac-jp (jp->pname jp) (list v v_1st v_2nd))
            e-ac-composition
         ) jp zeta rho s)
)))

; The idea here is that the values to be computed are saved on the joinpoint, such that the combinators are T(Val)s and hence need
;  to get their values from somewhere. Hence new extractors to JP are provided here.

; ac-composition : T(Val)
(define e-ac-composition
   (lambda (jp zeta rho s)
      ((return-e (jp->v jp)) jp zeta rho s)
))

; ac-min : T(Val)
(define e-ac-min
   (lambda (jp zeta rho s)
      ((return-e 
         (cond
            ((eqv? (jp->v_1st jp) 'pc-undefined)   (jp->v_2nd jp))
            ((eqv? (jp->v_2nd jp) 'pc-undefined)   (jp->v_1st jp))
            (else (min (jp->v_1st jp) (jp->v_2nd jp)))
      )) jp zeta rho s)
))

; ac-max : T(Val)
(define e-ac-max
   (lambda (jp zeta rho s)
      ((return-e 
         (cond
            ((eqv? (jp->v_1st jp) 'pc-undefined)   (jp->v_2nd jp))
            ((eqv? (jp->v_2nd jp) 'pc-undefined)   (jp->v_1st jp))
            (else (max (jp->v_1st jp) (jp->v_2nd jp)))
      )) jp zeta rho s)
))

; ac-+ : Val -> Val^1st -> Val^2nd -> T(Val)
(define e-ac-+
   (lambda (jp zeta rho s)
      ((return-e 
         (cond
            ((eqv? (jp->v_1st jp) 'pc-undefined)   (jp->v_2nd jp))
            ((eqv? (jp->v_2nd jp) 'pc-undefined)   (jp->v_1st jp))
            (else (+ (jp->v_1st jp) (jp->v_2nd jp)))
      )) jp zeta rho s)
))

; ac-- : Val -> Val^1st -> Val^2nd -> T(Val)
(define e-ac--
   (lambda (jp zeta rho s)
      ((return-e 
         (cond
            ((eqv? (jp->v_1st jp) 'pc-undefined)   (jp->v_2nd jp))
            ((eqv? (jp->v_2nd jp) 'pc-undefined)   (jp->v_1st jp))
            (else (- (jp->v_1st jp) (jp->v_2nd jp)))
      )) jp zeta rho s)
))

; ac-last : Val -> Val^1st -> Val^2nd -> T(Val)
(define e-ac-last
   (lambda (jp zeta rho s)
      ((return-e 
         (cond
            ((eqv? (jp->v_1st jp) 'pc-undefined)   (jp->v_2nd jp))
            ((eqv? (jp->v_2nd jp) 'pc-undefined)   (jp->v_1st jp))
            (else (jp->v_2nd jp))
      )) jp zeta rho s)
))

; ac-first : Val -> Val^1st -> Val^2nd -> T(Val)
(define e-ac-first
   (lambda (jp zeta rho s)
      ((return-e 
         (cond
            ((eqv? (jp->v_1st jp) 'pc-undefined)   (jp->v_2nd jp))
            ((eqv? (jp->v_2nd jp) 'pc-undefined)   (jp->v_1st jp))
            (else (jp->v_1st jp))
      )) jp zeta rho s)
))

; Other operations ...
; None.

; Predicate operations...
; None.

; Extractors for the data type...

; jp->v: JP -> Val
(define jp->v
   (lambda (jp)
      (car (jp->vs jp))
))

; jp->v_1st: JP -> Val
(define jp->v_1st
   (lambda (jp)
      (cadr (jp->vs jp))
))

; jp->v_2nd: JP -> Val
(define jp->v_2nd
   (lambda (jp)
      (caddr (jp->vs jp))
))

