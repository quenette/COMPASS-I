; Advices
;   Extra operators are needed with motions.
;
; insert-before/after compare the functions only (not the pcd info ... hence this func is dump to pcd logic)
;
; Semantic algebras...
;   Domain gamma in Adv*
;
; Abstract syntax...
;
; Valuation functions...
;
; Developed for guile scheme v 1.8.7


; Constructors...


; Execution monadic operations...
; None.


; Other operations...

; insert-before-gamma : Adv -> Adv_before -> Adv* -> Adv*_b
(define insert-before-gamma
   (lambda (alpha alpha' gamma)
      (insert-before-gamma'  alpha alpha' '() gamma)
))

; insert-before-gamma' : Adv -> Adv_before -> Adv* -> Adv* -> Adv*_b
(define insert-before-gamma'
   (lambda (alpha alpha' gamma_before gamma_after)
      (cond
         ((eq? gamma_after '())  (display ""))  ; i.e fail
         (else (let ((alpha''  (car gamma_after)) (gamma_after'  (cdr gamma_after)))
            (if (eq? alpha'' alpha')
               (append gamma_before (list alpha) (list alpha') gamma_after')
               (insert-before-gamma'  alpha alpha' (append gamma_before (list alpha'')) gamma_after')
))))))


; insert-after-gamma : Adv -> Adv_before -> Adv* -> Adv*_b
(define insert-after-gamma
   (lambda (alpha alpha' gamma)
      (insert-after-gamma'  alpha alpha' '() gamma)
))

; insert-after-gamma' : Adv -> Adv_before -> Adv* -> Adv* -> Adv*_b
(define insert-after-gamma'
   (lambda (alpha alpha' gamma_before gamma_after)
      (cond
         ((eq? gamma_after '())  (display ""))  ; i.e fail
         (else (let ((alpha''  (car gamma_after)) (gamma_after'  (cdr gamma_after)))
            (if (eq? alpha'' alpha')
               (append gamma_before (list alpha') (list alpha) gamma_after')
               (insert-after-gamma'  alpha alpha' (append gamma_before (list alpha'')) gamma_after')
))))))



; Predicates for the data type...
; gamma? : Any -> Bool
(define gamma?
   (lambda (gamma)
      (cond
         ((list? gamma) #t)
         (else #f)
)))

; Extractors for the data type...
; None.

