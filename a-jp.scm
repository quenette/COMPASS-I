; Joinpoints - a point in stack/computation space
;
; This model is heavily motivated by Wand04. A particular note is that we add 'pobj, representing a location in the execution
;  space that is described (in part) by a specific object. Note: its 'pobj' as opposed to 'pclass'. Doing for classes should be
;  possible but we do not consider it here as our interest is not an oo-aop model but feature-aop one. 'wobj/'wclass could also
;  be done
;
; Joinpoints are identifiable and unique in the environment. setjp is both creates/sets a new joinpoint and sequences computation
;  with the new joinpoint, and sets the advice counter to 0 specific to this joinpoint in the environment.
;
; TODO: Type and hence equality of objects may need looking into
;
; Semantic algebras...
;   Domain jp in JP
;     Domain k in JP_Kind in Kind
;     Domain pobj in Loc
;     Domain pname in PName in Sym
;     Domain wname in WName in Sym
;     Domain vs in Val*
;
; Abstract syntax...
;  jp in JP
;
;  JP_Kind  ::= 'pcall | 'ac
;                  'pcall   - a procedure call or a function call
;                  'ac      - an advice combinator on a function call
;  JP       ::= < k o pname wname vs jp >
;                  pname    - if relevant, the name of the procedure being called
;                  wname    - if relevant, the name of the procedure the control flow is currently "within" (Wand04 only)
;                  vs       - if relevant, the list of values for the parameters of the procedure being called
;                  jp       - if relevant, the joinpoint the the control flow is currently within (Wand04 only - for cflow)
;
; Valuation functions...
;  None.
;
; Developed for guile scheme v 1.8.7


; Constructors...

; new-call-jp: (PName -> Val*) -> JP -> JP
(define new-call-jp
   (lambda (pname vs)
      (lambda (jp)
         (list 'pcall '<invalid> pname '<invalid> vs jp)
)))

; new-mcall-jp: (Obj -> PName -> Val*) -> JP -> JP
(define new-mcall-jp
   (lambda (o pname vs)
      (lambda (jp)
         (list 'pcall o pname '<invalid> vs jp)
)))

; new-ac-jp: PName -> JP -> JP
(define new-ac-jp
   (lambda (pname vs)
      (lambda (jp)
         (list 'ac '<invalid> pname '<invalid> vs jp)
)))

; new-mac-jp: (Obj -> PName) -> JP -> JP
(define new-mac-jp
   (lambda (o pname vs)
      (lambda (jp)
         (list 'ac o pname '<invalid> vs jp)
)))


; Execution monadic operations...

; getjp : () -> ( JP -> Mot* -> Env -> Sto ) -> ( JP x Mot* x Env x Sto )                     ; i.e () -> T(Val)
; Return the joinpoint in the monad
(define e-getjp
   (lambda (jp zeta rho s)
      ((return-e jp) jp zeta rho s)
))

; setjp : (JP -> JP) -> T(Val) -> T(Val)
;  is required because JP's aren't part of the monadic-store, hence a change in JP in the sequence is not noticed by the remainder
;  of the sequence. 
(define e-setjp
   (lambda (f chi)
      (lambda (jp zeta rho s)
         (let ((jp'   (f jp)))
              ((seq-e
                 (e-extend-env jp' 0 (display ""))
                 (lambda (_) chi)
              ) jp' zeta rho s)
))))

; jp-chi : AdvList -> (JP -> JP) -> T(Val) -> T(Val)
; "joint-point-computation" (or "enter-join-point" in Wand04) means to execute a computation decorated with as a new join point. 
;   Advices will subsequently be weaved onto the original computation base on this "joinpoint location".
(define e-jp-chi
   (lambda (f chi)
      (lambda (jp zeta rho s)
         ((e-setjp f (e-weave (zeta->gamma zeta) chi)) jp zeta rho s)
)))

; Predicates for the data type...

; jp? Any -> Bool
(define jp?
   (lambda (jp)
      (and (list? jp) (or (pcall-jp? jp) (or (fcall-jp? jp) (obj-jp? jp))))
))

; pcall-jp?: Any -> Bool
(define pcall-jp?
   (lambda (jp)
      (and (list? jp) (eq? (car jp) 'pcall))
))

; ac-jp?: Any -> Bool
(define ac-jp?
   (lambda (jp)
      (and (list? jp) (eq? (car jp) 'ac))
))

; obj-jp?: Any -> Bool
(define obj-jp?
   (lambda (jp)
      (and (list? jp) (not (eq? (car (cdr jp)) '<invalid>)))
))


; Extractors for the data type...

; jp->jpkind: JP -> JP_Kind
(define jp->k
   (lambda (jp)
      (car jp)
))

; jp->pobj: JP -> Loc
(define jp->pobj
   (lambda (jp)
      (car (cdr jp))
))

; jp->name: JP -> PName
(define jp->pname
   (lambda (jp)
      (car (cddr jp))
))

; jp->wname: JP -> PName
(define jp->wname
   (lambda (jp)
      (car (cdddr jp))
))

; jp->vs: JP -> Val*
(define jp->vs
   (lambda (jp)
      (car (cdr (cdddr jp)))
))


; jp->jp: JP -> JP
(define jp->jp
   (lambda (jp)
      (car (cddr (cdddr jp)))
))

