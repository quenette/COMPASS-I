; tear up for examples
(define (hello a) (display "hello"))
(define (world a) (display "world"))
(define inc (lambda (a) (+ a 1)))
(define dec (lambda (a) (- a 1)))


; Eqn 3
; Imperative composition using 'begin'
; T(Val) -> T(Val) -> Val* -> T(Val)
; \lambda f g . \lambda v . begin (f v) (g v)
(define compose2begin
   (lambda (f g)
      (lambda (v)
         (begin (apply f v) (apply g v)) ) ) )

; example(s)
(display "Eqn 3 example(s)...\n")
(begin (display ((compose2begin inc dec) '(5))) (display "\n"))
(begin (display ((compose2begin hello world) '(1))) (display "\n"))
(display "\n")

; Eqn 4
; Using 'lambda' expression instead of begin
; \lambda f g . \lambda v . (\lambda _ (g v)) (f v)
(define compose2lambda
   (lambda (f g)
      (lambda (v)
         ((lambda (_) (apply g v)) (apply f v)) ) ) )

; example(s)
(display "Eqn 4 example(s)...\n")
(begin (display ((compose2lambda inc dec) '(5))) (display "\n"))
(begin (display ((compose2lambda hello world) '(1))) (display "\n"))
(display "\n")

; Eqn 5
; Using syntactic sugar of 'let' instead
; \lambda f g . \lambda v . let (_ (f v)) (g v)
(define compose2let
   (lambda (f g)
      (lambda (v)
         (let (( _ (apply f v)))
            (apply g v) ) ) ) )

; example(s)
(display "Eqn 5 example(s)...\n")
(begin (display ((compose2let inc dec) '(5))) (display "\n"))
(begin (display ((compose2let hello world) '(1))) (display "\n"))
(display "\n")

; Eqn 6
; T(Val)* -> Val* -> T(Val)
; TODO: I don't know yet how to get this going ... need the y-combinator i think ...
(define composeNy
   (lambda (r)
      (lambda (h)
         (lambda (v)
            (if (null? (cdr h))
               (apply (car h) v)
               (let ((_ (apply (car h) v)))
                  ((r (cdr h)) v) ) ) ) ) ) )
; or simply, using recursive procedure...
; \lambda h . \lambda v . case (cdr h) in
;   <> => ((car h) v)
;   x::j' => let (_ ((car h) v)) ((composeN (cdr h)) v)
(define composeN
      (lambda (h)
         (lambda (v)
            (if (null? (cdr h))
               (apply (car h) v)
               (let ((_ (apply (car h) v)))
                  ((composeN (cdr h)) v) )
) ) ) )

; example(s)
(display "Eqn 6 example(s)...\n")
(begin (display ((composeN (list inc dec)) '(5))) (display "\n"))
(begin (display ((composeN (list hello world)) '(1))) (display "\n"))
(display "\n")

