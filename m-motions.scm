; Motions
;
; Semantic algebras...
;   Domain zeta in Mot*
;   Domain zeta_| in |Mot* subset Mot*
;   Domain zeta_c in CMot* subset |Mot*
;
; Abstract syntax...
;
; Valuation functions...
;
; Developed for guile scheme v 1.8.7


; Constructors...


; Execution monadic operations...

; appendm : Mot -> (JP -> Mot* -> Env -> Sto) -> ( Mot* x Mot*' x Env x Sto )                 ; i.e Mot -> T(Val)
(define appendm
   (lambda (m)
      (lambda (jp zeta rho s)
         (let ((zeta'   (append zeta (list m))))
              ((return-e zeta') jp zeta' rho s)
))))

; getm : PCD -> PName_abody -> (JP -> Mot* -> Env -> Sto) -> ( Mot_b x Mot* x Env x Sto )     ; i.e PCD -> PName_abody -> T(Val)_b
(define getm
   (lambda (pcd pname)
      (lambda (jp zeta rho s)
         ((return-e (getm' pcd pname zeta)) jp zeta rho s)
)))



; Other operations...

; getm' : PCD -> PName_abody -> Mot* -> Mot_b
(define getm'
   (lambda (pcd pname zeta)
      (cond
         ((eq? zeta '())  (display ""))
         (else
            (let ((m     (car zeta))
                  (zeta' (cdr zeta)))
                 (let ((m'    (matchm pcd pname m)))
                      (cond
                         ((m? m')  m')
                         (else     (getm' pcd pname zeta'))
)))))))

; uniquezeta? : Mot* -> Mot*_b
(define uniquezeta?
   (lambda (zeta)
      (cond
         ((eq? zeta '())  zeta)
         (else (let ((m  (car zeta)) (zeta'  (cdr zeta)))
            (uniquezeta?' m zeta')
)))))


; uniquezeta?' : Mot -> Mot* -> Mot*_b
(define uniquezeta?'
   (lambda (m zeta)
      (cond
         ((eq? zeta '())  zeta)
         (else (let ((m'  (car zeta)) (zeta'  (cdr zeta)))
            ;(display ">>>>>>>>>>>>>  \"")(display (m->pname m))(display "\" \"")(display (m->pname m'))(display "\"\n")
            (cond
               ((m? (uniquem? m m')) (let ((zeta''   (uniquezeta?' m zeta')))
                    (cond
                       ((zeta? zeta'')  (uniquezeta?' m' zeta'))
                       ; else fail
               )))
               ; else fail
))))))


; zeta->gamma : Mot* -> Adv*_b
(define zeta->gamma
   (lambda (zeta)
      (let ((gamma,zeta_|   (zeta->gamma|<>  zeta zeta '() '())))
           (let ((gamma,zeta_c   (zeta->gamma|m  zeta (cadr gamma,zeta_|) (car gamma,zeta_|) '())))
              (cond
                 ((and (list? gamma,zeta_c) (gamma? (car gamma,zeta_c)) (zeta? (cadr gamma,zeta_c)))
                    (cond
                       ((eq? (uniquezeta? (cadr gamma,zeta_c)) '())  (zeta->gamma|pc zeta (cadr gamma,zeta_c) (car gamma,zeta_c)))
                       ; else fail
                 ; else fail
)))))))


; zeta->gamma|<> : Mot* -> Adv* -> |Mot* -> (Adv*' x |Mot*')
; z - complete zeta (untouched - for resolving relative motions)
; zeta - working zeta
; gamma - accumulating list of advice
; zeta_| - accumulating list of motions with futher properties (givens)
(define zeta->gamma|<>
   (lambda (z zeta  gamma  zeta_|)
      (cond
         ((eq? zeta '())  (list gamma zeta_|))
         (else (let ((m  (car zeta)) (zeta'  (cdr zeta)))
               (let ((pname_|m (m->pname_|m m)))
                    (cond
                       ((eq? pname_|m '()) (let ((|a   (m->|pc m)))
                          (cond
                             ((eq? |a '()) (let ((|a'   (m->|p m))) ; i.e. no relative motion
                                (cond
                                   ((eq? |a' '())
                                      ;(display "last - ")(display gamma)(display " ")(display (m->pname m))(newline)
                                      (zeta->gamma|<>  z zeta' (append gamma (list (m->alpha m))) zeta_|)
                                   ) ; i.e last
                                   ((eq? |a' 'first) 
                                      ;(display "first - ")(display (m->pname m))(display " ")(display gamma)(newline)
                                      (zeta->gamma|<>  z zeta' (append (list (m->alpha m)) gamma) zeta_|)
                                   ) ; i.e first
                                   (else (display "Error: in zeta->gamma|<>, unrecognised |p: ")(display |a')(newline))
                             )))
                             (else (zeta->gamma|<>  z zeta' gamma (append zeta_| (list m))))  ; constraint motion - delay
                      )))
                      (else (zeta->gamma|<>  z zeta' gamma (append zeta_| (list m)))) ; relative motion - delay
)))))))

; zeta->gamma|m : |Mot* -> Adv* -> CMot* -> (Adv*' x CMot*')
; z - complete zeta (untouched - for resolving relative motions)
; zeta_| - working zeta (of motions given a property)
; gamma - accumulating list of advice
; zeta_c - accumulating list of motions with the constraint property
(define zeta->gamma|m
   (lambda (z zeta_|  gamma  zeta_c)
      (cond
         ((eq? zeta_| '())  (list gamma zeta_c))
         (else (let ((m  (car zeta_|)) (zeta_|'  (cdr zeta_|)))
               (let ((|a (m->|pc m)))
                    (cond
                       ((eq? |a '()) (let ((|a'   (m->|p m))   (|m (pname->zeta->m (m->pname_|m m) z))) ; i.e. no constraint
                          (cond
                              ((eq? |m  '())
                                 (display "Error: in zeta->gamma|m, unfound relative motion for: ")(display (m->pname m))(newline) 
                              )
                              ((eq? |a' '())
                                 (zeta->gamma|m z zeta_|' (insert-after-gamma (m->alpha m) (m->alpha |m) gamma) zeta_c)
                              ) ; i.e. last
                              ((eq? |a' 'first)
                                 (zeta->gamma|m z zeta_|' (insert-before-gamma (m->alpha m) (m->alpha |m) gamma) zeta_c)
                              )  ; i.e. first
                              (else (display "Error: in zeta->gamma|m, unrecognised |p: ")(display |a')(newline))
                       )))
                       (else (zeta->gamma|m  z zeta_|' gamma (append zeta_c (list m))))  ; constraint motion - delay
)))))))

; zeta->gamma|pc : CMot* -> Adv* -> Adv*'
; z - complete zeta (untouched - for resolving relative motions)
; zeta_c - working zeta (of motions given the constraint property)
; gamma - accumulating list of advice
(define zeta->gamma|pc
   (lambda (z zeta_c  gamma)
      (cond
         ((eq? zeta_c '())  gamma)
         (else (let ((m  (car zeta_c)) (zeta_c'  (cdr zeta_c)))
            (let ((|a'   (m->|p m)))
               (cond
                  ((eq? |a' '())    (zeta->gamma|pc z zeta_c' (append gamma (list (m->alpha m)))))  ; i.e. always first
                  ((eq? |a' 'first) (zeta->gamma|pc z zeta_c' (append (list (m->alpha m)) gamma)))  ; i.e  always last
                  (else (display "Error: in zeta->gamma|pc, unrecognised |p: ")(display |a')(newline))
)))))))


; Find a named motion in a list of motions, and return it
; pname->zeta->m : PName -> Mot* -> Mot|<>
(define pname->zeta->m
   (lambda (pname zeta)
      (cond
         ((eq? zeta '())
            ; Error (return unspecified)
            (display "Error: in pname->zeta->m, motion with name ")(display pname)(display " not found.")(newline)
            '()
         )
         (else (let ((m  (car zeta)) (zeta' (cdr zeta)))
            (cond
               ((string=? (m->pname m) pname)   m)
               (else (pname->zeta->m pname zeta'))
))))))


; Predicates for the data type...

; zeta? Any -> Bool
(define zeta?
   (lambda (zeta)
      (list? zeta)
))


; Extractors for the data type...

