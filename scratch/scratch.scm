(define (foo a) (+ a a))
(define (bar a) (* a a))
(define (compose2 a f1 f2) ( lambda (v a b) ((a v) (b v)) ) a f1 f2 )
(compose2 2 foo bar)
(define compose2 
   (lambda (v a b) 
      (a v) (b v) ) )
(compose2 2 foo bar)
(define (compose2 a f1 f2) ( lambda (v a b) ((+ a v) (+ b v)) ) )
(compose2 1 2 3)
((lambda (x) (+ x x)) 4)

# does what is expected ...
( (lambda (v a) (a v)) 1 foo)

# Calling 2 procs sequentially
( (lambda (v a b) (a v)) 1 foo bar)
( (lambda (v a b) (a v) (b v)) 1 foo bar)


(define (foo a) (display "hello\n"))
(define (bar a) (display "world\n"))
((lambda (v a b) (a v) (b v)) 1 foo bar)
(define (compose2 a f1 f2) ( (lambda (v a b) (a v) (b v)) 1 foo bar))

(define (add a b) ( (lambda (x y) (+ x y)) a b))

# This works...
(define (apple a) (+ a a)
(apply apple '(1) )



(define x 7)




; unit_s : A -> MA
;        = A -> (Sto -> T(A))
;   Is/returns the value with a store.
;   Takes a value. 
;   The result of this 'action' is the value and the store is passed through.
;   (The result is a pair with the execution result in the first position (car) and the store in the second position (cdr))
(define unit_s (lambda (a) (lambda (s) `(,a . ,s) )) )

; seq_s : A -> MB
;          = A -> (Sto -> T(B))
;   The sequencing action between two store monads - Do nothing, just pass on the value and store for the B computation.
;   Takes a value. 
;   The result of this 'action' is the value and the store is passed through.
;   (The result is a pair with the execution result in the first position (car) and the store in the second position (cdr))
(define seq_s (lambda (a) (lambda (s) `(,a . ,s) )) )

; get_s : T(A)
;   Gets a number from a store.
;   Takes a store. 
;   The result of this 'action' the store (value) and the store passed through.
;   (The result is a pair with the execution result in the first position (car) and the store in the second position (cdr))
(define get_s (lambda (s) `(,s . ,s) ) )

; put_s : A -> T(A)
;   Puts a value into a store.
;   Takes a number (1st arg) to put into a store (second arg). 
;   The result of this 'action' is 1 and a 'new' store with the new value (it doesn't have the effect of changing the original store).
;   (The result is a pair with the execution result in the first position (car) and the store in the second position (cdr))
(define put_s (lambda (a) (lambda (s) `(,1 . ,a) )) )


; Tests ...
; new store...
(define i 5)
; unit the number 8, passing through the store...
((unit_s 8) i)   ; => (8 . 5)
; get the number from the the
(get_s i)   ; => (5 . 5)
; put a number into the store ...
((put_s 3) i)   ; => (1 . 3)
; the binding action of the result of A onto B (seq) ...
((seq_s 4) i)   ; => (1 . 4)


; ... working on this ... 1st tred with id monad...
; example  - action: sequence two computations: 'i + 2' and 'i + 3' with the sequel ops of operational composition 'x;y;' 
; Put v -> (v -> S a) -> S a 
; ...  where v = 1, x = put v, a = function( i + 2 ), y = S a
(bind_id 
   ((put_s 1) i)
   (lambda (x) (bind_id ((unit_s (lambda (i) (+ i 2))) (cdr x))
                        (lambda (y) ((unit_s ((car y) (car x))) (cdr y))) ) ) )

; ... sequence
; Put v -> (v -> S a) -> (a -> S b) -> S b 
; ...  where v = 1, x = put v, a = function( i + 2 ), y = S a
; expect (4 . 1) as the result (result of last in sequence)
(bind_id 
   ((put_s 1) i)
   (lambda (x) (bind_id ((unit_s (lambda (i) (+ i 2))) (cdr x))
                        (lambda (y) (bind_id ((unit_s ((car y) (car x))) (cdr y) )
                                             (lambda (z) (bind_id ((unit_s (lambda (i) (+ i 3))) (cdr z))
                                                                     (lambda (q) ((unit_s ((car q) (car x))) (cdr q)))
) ) ) ) ) ) ) 

; ... functional composition (note the only difference is the replacement of x with z on the last line (unit of b)). 
; Also note - may be in reverse?
; Put v -> (v -> S a) -> (a -> S b) -> S b 
; ...  where v = 1, x = put v, a = function( i + 2 ), y = S a
; expect (6 . 1) as result
(bind_id 
   ((put_s 1) i)
   (lambda (x) (bind_id ((unit_s (lambda (i) (+ i 2))) (cdr x))
                        (lambda (y) (bind_id ((unit_s ((car y) (car x))) (cdr y) )
                                             (lambda (z) (bind_id ((unit_s (lambda (i) (+ i 3))) (cdr z))
                                                                     (lambda (q) ((unit_s ((car q) (car z))) (cdr q)))
) ) ) ) ) ) ) 
 
; if only it were as simple as ... (the following doesn't work because the store "s" isn't resolved 
;(bind_id 
;   (put_s 1)
;   (lambda (x) (bind_id (unit_s (lambda (i) (+ i 2))) 
;                        (lambda (y) (unit_s ((car y) (car x))) )) ))
; Hence it's better to use 'let' form ...


UPTO HERE ... trying to get star_* to work ....
; Sequel → MA → MB or Sequel → (MA → MB)
(define star_s 
   (lambda (sequel)
      (lambda (ma)
         (lambda (s) ; <= This function is a MB.
            (let ((p (ma s)))
               (let ((new-a (car p)) (new-s (cdr p)))
                  (let ((mb (sequel new-a))) (mb new-s))))))))
; ... I think the above is ok

; doesnt work...
(((star_s (lambda (x) ((), (+ x 1)))) (unit_s x)) y)


; Wand 04 pure functional version
(define bind_s
   (lambda (ma)
      (lambda (mb)
         (lambda (s)
            ( (lambda (a . s2) ( (mb a) (s2) )) (ma s) )
))))

(define tmp1
   (lambda (ma)
      (lambda (mb)
         (lambda (s)
            ( ma s )
))))
(define tmp2
   (lambda (ma)
      (lambda (mb)
         (lambda (s)
            ( mb 1 s )
))))


; seq(get,(λn.seq(put(n+1), λd.return n)).
(define i 5)
( ((lambda (n) ( put_s (+ n 1) )) 2 ) i )
( ((lambda (n) (unit_s n)) 2 ) i )

((lambda (n) ( ( ( tmp1 ( put_s (+ n 1) ) ) ( unit_s n ) ) i )) 1) ; => gives (1 . 2) - right
((lambda (n) ( ( ( tmp2 ( put_s (+ n 1) ) ) ( unit_s n ) ) i )) 1) ; => gives (1 . 5) - right? result needs to be a function!?!
; lets try ...
((lambda (n) ( ( ( tmp1 ( put_s (+ n 1) ) ) (lambda (d) ( unit_s n )) ) i )) 1) ; => gives (1 . 2) - right
((lambda (n) ( ( ( tmp2 ( put_s (+ n 1) ) ) (lambda (d) ( unit_s n )) ) i )) 1) ; eeek!!!

((lambda (n) ( ( ( bind_s ( put_s (+ n 1) ) ) (lambda (d) ( unit_s n )) ) i )) 1)

((lambda (n) ( ( ( bind_s ( put_s (+ n 1) ) ) ( unit_s n ) ) i )) 1)







