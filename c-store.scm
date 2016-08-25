; The implementation of a 'Store' using the model of an environment (motivated by Schmidt88). The environment model/code itself is
;  largely motivated from EOPLv3, code in 2.2.3.  The Store provides values at locations, hence representing the use of computer
;  memory. A limitation of this model is that each write to the store increases the size of the store.
; 
;
; Semantic algebras...
;   Domain s in Store
;    (Domain l in Loc)
;    (Domain v in Val)
;
;  Store  ::= < 'empty-s >
;         ::= < 'extend-s l v s >
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

; empty-s : () -> Store
(define empty-s
   (lambda () 
      (list 'empty-s)
))

; extend-s : Loc x Val x Store -> Store
(define extend-s
   (lambda (l v s)
      (list 'extend-s l v s)
))


; Other operations ...

; apply-s : Loc x Store -> Val_b
(define apply-s
   (lambda (search-l s)
      (cond
         ((eqv? (s->kind s) 'empty-s)
            ; Fail - the location doesn't yet have an asssigned value
            (display "Fail: Location \"")(display search-l)(display "\" has no assigned value.")(newline)
         )
         ((eqv? (s->kind s) 'extend-s)
            (let ((saved-l (s->l s))
                  (saved-v (s->v s))
                  (saved-s (s->s s)))
               (if (eqv? search-l saved-l)
                  saved-v
                  (apply-s search-l saved-s)
         )))
         (else (error-invalid-s s))
)))

(define fail-invalid-location
   (lambda (search-loc)
      (error 'apply-s "Fail: Invalid location \"~s\"" search-loc)))

(define error-invalid-s
   (lambda (s)
      (error 'apply-s "Error: \"~s\" is not a Store" s)))


; Predicates for the data type...

; s? : Any -> Bool
(define s?
   (lambda (s)
      (cond
         ((and (has-kind? s) (eqv? (s->kind s) 'empty-s)) #t)
         ((and (has-kind? s) (eqv? (s->kind s) 'extend-s)) #t)
         (else #f)
)))


; Extraction operations...

; s->kind : Store -> Kind
(define s->kind
   (lambda (s)
      (car s)
))

; s->l : Store -> Loc
(define s->l
   (lambda (s)
      (cadr s)
))

; s->v : Store -> Val
(define s->v
   (lambda (s)
      (caddr s)
))

; s->s : Store -> Store
(define s->s
   (lambda (s)
      (cadddr s)
))

