; Weave - sequence the advices to transform one computation to an advised (possibly modified) computation.
;
;  Note: its a weave of computation not continuations... implication is that advice cannot do continuation things
;   like jump, if, while, ...
;
; It works by recursion... but leads to monadic sequencing. This model/implementation is similar to Wand04, except that the JP is in the monad and the recursion is depth first such that the advice ordering is maintained. 
;
; Semantic algebras...
;     (Domain alpha in Adv)
;     (Domain gamma in AdvList)
;     (Domain jp in JP)
;     (Domain chi in T(Val))
;
;   weave : AdvList -> JP -> T(Val) -> T(Val)
;
; Valuation functions...
;  None.
;
;
; Developed for guile scheme v 1.8.7


; weave : AdvList -> T(Val) -> T(Val)
;  chi is the a priori computation (although its yet to be executed). Depending on the advices applicable to this joinpoint, this
;   computation may not run, may be wrapped with other execution, or may be executed 'untouched'.
(define e-weave
   (lambda (gamma chi)
      (lambda (jp zeta rho s)
         (cond
            ((eqv? gamma '())    (chi jp zeta rho s))
            (else
               (let ((alpha    (car gamma))
                     (gamma'   (cdr gamma))
                    )
                    ;((alpha (e-weave gamma' chi)) jp rho s)   ; Wand04
                    ((e-weave gamma' (alpha chi)) jp zeta rho s)
))))))


