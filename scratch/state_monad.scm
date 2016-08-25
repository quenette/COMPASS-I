
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

(define star_s 
   (lambda (ma sequel)
      (lambda (s) ; <= This function is a MB.
         (let ((p (ma s)))
            (let ((new-a (car p)) (new-s (cdr p)))
               ;(begin (display "ma: ") (display ma) (display "\nnew-a: ") (display new-a) (display "\nnew-s: ") 
               ;       (display new-s) (display "\n") 
                      (let ((mb (sequel new-a))) 
                         ;(begin (display "mb: ") (display mb) (display "\n") 
                                (mb new-s)  
                         ;)
                      )  
               ;)
) ) ) ) )

; star_b (b=begin)
; note new-a replaced with new-s in (mb (sequel ..)) term
(define star_b 
   (lambda (ma sequel)
      (lambda (s) ; <= This function is a MB.
         (let ((p (ma s)))
            (let ((new-a (car p)) (new-s (cdr p)))
               ;(begin (display "ma: ") (display ma) (display "\nnew-a: ") (display new-a) 
               ;       (display "\nnew-s: ") (display new-s) (display "\n") 
                      (let ((mb (sequel new-s))) 
                         ;(begin (display "mb: ") (display mb) (display "\n") 
                                (mb new-s)  
                         ;)
                      )  
               ;)   
) ) ) ) )

(define bind_id (lambda (ma sequel)
   (sequel ma))) ; <= This is a mb.



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


; (reverse) functional composition (note the only difference is the replacement of x with z on the last line (unit of b)). 
; Put v -> (v -> S a) -> (a -> S b) -> S b 
; ...  where v = 1, x = put v, a = function( i + 2 ), y = S a
; expect (6 . 1) as result
(bind_id 
   ((put_s 1) i)
   (lambda (x) (bind_id ((unit_s (lambda (i) (+ i 2))) (cdr x))
                        (lambda (y) (bind_id ((unit_s ((car y) (cdr x))) (cdr y) )
                                             (lambda (z) (bind_id ((unit_s (lambda (i) (+ i 3))) (cdr z))
                                                                     (lambda (q) ((unit_s ((car q) (cdr z))) (cdr q)))
) ) ) ) ) ) ) 
 
; if only it were as simple as ... (the following doesn't work because the store "s" isn't resolved 
;(bind_id 
;   (put_s 1)
;   (lambda (x) (bind_id (unit_s (lambda (i) (+ i 2))) 
;                        (lambda (y) (unit_s ((car y) (car x))) )) ))


; Using Id's bind, put to the store and sequence 1 computation (the computation is done as part of the sequel).
; (note: using Id's bind is highly illustrative and incremental to show what's going on)
; This is NOT the state monad, as we're intentially calling 'S a' with the store value and NOT the result of 'put v'
; Put v -> (v -> S a) -> S a 
; ...  where v = 2, x = put v, a = function( i + 2 ), y = S a
; expect (4 . 2) as the result (result of the only in the sequence)
(begin (display "put v -> (v -> S a) -> S a = ") (display 
(bind_id 
   ((put_s 2) i)
   (lambda (x) (bind_id ((unit_s (lambda (i) (+ i 2))) (cdr x))
                        (lambda (y) ((unit_s ((car y) (cdr x))) (cdr y))) ) ) )
) (display "\n") )


; Sequence two using Id's bind ... ugly!!! but it works.
; Put v -> (v -> S a) -> (v -> S b) -> S b 
; This is NOT the state monad as we're intentially calling 'S a' & 'S b' with the store value and NOT the result of 'put v' & 'S a'
; expect (5 . 2) as the result (result of last in sequence)
(begin (display "put v -> (v -> S a) -> (v -> S b) -> S b = ") (display 
(bind_id 
   ((put_s 2) i)
   (lambda (x) (bind_id ((unit_s (lambda (i) (+ i 2))) (cdr x))
                        (lambda (y) (bind_id ((unit_s ((car y) (cdr x))) (cdr y) )
                                             (lambda (z) (bind_id ((unit_s (lambda (i) (+ i 3))) (cdr z))
                                                                  (lambda (q) ((unit_s ((car q) (cdr x))) (cdr q)))
) ) ) ) ) ) ) 
) (display "\n") )


; As a function with the desired form...
(define compose2idbind
   (lambda (f g)
      (lambda (v)
         (bind_id 
            ((put_s v) i)
            (lambda (x) (bind_id ((unit_s f) (cdr x))
                                 (lambda (y) (bind_id ((unit_s ((car y) (cdr x))) (cdr y) )
                                                      (lambda (z) (bind_id ((unit_s g) (cdr z))
                                                                           (lambda (q) ((unit_s ((car q) (cdr x))) (cdr q)))
) ) ) ) ) ) ) ) ) )

; example
(define (hello a) (display "hello"))
(define (world a) (display "world"))
(define inc (lambda (a) (+ a 1)))
(define dec (lambda (a) (- a 1)))
(begin (display "((compose2idbind inc dec) 5) = ") (display ((compose2idbind inc dec) 5)) (display "\n"))
(begin (display "((compose2idbind hello world) 1) = ") (display ((compose2idbind hello world) 1)) (display "\n"))

; Hence it's better to use 'let' form ...




; Using S's bind, put to the store and sequence 1 computation (the computation is done as part of the sequel).
; S a -> (a -> S b) -> S b 
; expect (4 . ??) as the result of 'a' (2) will be passed to the computation of 'b' with the sequel (+ i 2).  '??' because the
; store isn't actually used in this, so we dont care for its value
(begin (display "S a -> (a -> S b) -> S b = ") (display 
((star_s 
   (unit_s 2)
   (lambda (i) (unit_s (+ i 2)))
 ) i )
) (display "\n") )


; Using S's bind, put to the store and sequence 2 computations (the computation is done as part of the sequel).
; S a -> (a -> S b) -> S b 
; expect (7 . ??) as the result of 'a' (2) will be passed to the computation of 'b' with the sequel (+ i 2). And then this will
; be passed to the sequel (+ i 3).  '??' because the store isn't actually used in this, so we dont care for its value
(begin (display "S a -> (a -> S b) -> (b -> S c) -> S c = ") (display 
((star_s 
   (unit_s 2)
   (lambda (new_a) (star_s (unit_s (+ new_a 2))
      (lambda (new_b) (unit_s (+ new_b 3))) ) )
 ) i )
) (display "\n") )



; Using S's 'begin' bind, put to the store and sequence 1 computation (the computation is done as part of the sequel).
; This is NOT the state monad, as we're intentially calling 'S a' with the store value and NOT the result of 'put v'
; put v -> (v -> S a) -> S a 
; expect (4 . 2) as the result (result of the only in the sequence)
(begin (display "v -> (v -> S a) -> S a (using star_b) = ") (display 
((star_b 
   (put_s 2)
   (lambda (i) (unit_s (+ i 2)))
 ) i )
) (display "\n") )

; Using S's 'begin' bind, put to the store and sequence 2 computations (the computation is done as part of the sequel).
; This is NOT the state monad, as we're intentially calling 'S a' with the store value and NOT the result of 'put v'
; put v -> (v -> S a) -> S a 
; expect (5 . 2) as the result (result of the only in the sequence)
(begin (display "v -> (v -> S a) -> (v -> S b) -> S b  (using star_b) = ") (display 
((star_b 
   (put_s 2)
   (lambda (new_a) (star_b (unit_s (+ new_a 2))
      (lambda (new_b) (unit_s (+ new_b 3))) ) )
 ) i )
) (display "\n") )

; TODO: code here to prove S and begin-S are Monads.  (hoping begin-S is!!!!)


