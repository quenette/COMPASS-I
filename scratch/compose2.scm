(define (foo x) (if (> x 0) (begin (foo (- x 1)) (display "hello\n"))))
(define (bar x) (if (> x 0) (begin (bar (- x 1)) (display "world\n"))))
(define (inc a) (+ a 1))
(define (dec a) (- a 1))

; "compose2" relies on Scheme allowing many bodies to a lambda expression ... in other words this is not purely functional (implies
; a begin - which in turn will provide the result of the last/second expression)...

; "compose2" with only one arg ...
(define compose2a 
   (lambda (v a b) 
      (a v) (b v) ) )

; example
(compose2a 1 foo bar)

; "compose2" with only one arg, explicitly stating begin ...
(define compose2b 
   (lambda (v a b) 
      (begin (a v) (b v)) ) )

; example
(compose2b 1 foo bar)

; "compose2" with vars provided as a list ...
(define compose2l 
   (lambda (v a b) 
      (apply a v) (apply b v) ) )
(compose2l '(1) foo bar)


; Step 2 ... vs "begin"  (we want the same args to be passed to each function ... i.e. an "operator combinator" takes two operations and returns a new operation on the same arg.


; In continuation passing style...
; (note: the following only work because the two args get evaluated before the function k is run (its never run))
; http://www.ccs.neu.edu/home/dherman/research/tutorials/monads-for-schemers.txt
(define (begin2cps cps-exp1 cps-exp2)
   (lambda (k)
      (cps-exp1 (lambda (res1)
         (cps-exp2 (lambda (res2)
             (k res2)))))))
;examples
(begin (display "One\n") (display "Two\n"))
(begin (foo 2) (bar 2))
(begin2cps (display "One\n") (display "Two\n"))
(begin2cps (foo 2) (bar 2))

; "compose2" with only one arg, explicitly stating our cps begin ...
; (note: has side effect that lambda function k is returned rather that the result of the 2nd argument)
(define compose2c
   (lambda (v a b)
      (begin2cps (a v) (b v)) ) )
; example
(compose2c 1 foo bar)

; "compose2" with only one arg, explicitly stating our 'simple' begin ... 
; That is - it relies totally on the evaluation of the functions as arguements ... I dont think order is gaurenteed!!!
(define begin2simple
   (lambda (x y) 
      (if (not (unspecified? y))
         ((lambda (z) (z)) y ) ) ) )
(define compose2d
   (lambda (v a b)
      (begin2simple (a v) (b v)) ) )
(compose2d 1 foo bar)

; BINGO!!!
; "compose2" with only one arg, that takes two functions and returns a single function that composites them. This inturn takes
; the argument.
(define compose2
   (lambda (f g)
      (lambda (v)
         (let (( _ (f v)))
            (g v) ) ) ) )
; example
(define (hello a) (display "hello"))
(define (world a) (display "world"))
(define inc (lambda (a) (+ a 1)))
(define dec (lambda (a) (- a 1)))
(begin (display ((compose2 inc dec) 5)) (display "\n"))
(begin (display ((compose2 hello world) 1)) (display "\n"))


; STEP 3 ... as a monad


