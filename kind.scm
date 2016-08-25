;
; Semantic algebras...
;   Domain k in Kind 
;
; Abstract syntax...
;  k in Kind
;
;  Kind     ::= ...  (defined by all the other algebras)
;
; Developed for guile scheme v 1.8.7


(load "error.scm")


; Construction operations ...
; None

; Predicate operations...

; has-kind? : Any -> Bool
(define has-kind?
   (lambda (k)
      (cond 
         ((and (list? k) (> (length k) 0) (symbol? (car k))) #t)
         (else #f)
)))


; Extractors for the data type...
; None


; Valuation functions ...
; None

