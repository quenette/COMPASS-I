; derived from: https://www.cs.indiana.edu/cgi-pub/c311/lib/exe/fetch.php?media=manymonads.pdf
(define unit_id (lambda (a) 
   a)) ; <= This is a ma.

(define bind_id (lambda (ma sequel)
   (sequel ma))) ; <= This is a mb.

; example 1 - sequence two computations: '(display "One\n")' and '(display "Two\n")'
; (the monad holds no state and the sequel has no effect)
; Id a -> (a -> Id b) -> Id b 
; Id a -> (_ -> Id b) -> Id b    ...  is all that's done here. In fact we don't see the resultant monad '-> Id b' (returns nothing)
(bind_id 
   (unit_id (display "One\n"))
   (lambda (_) (unit_id (display "Two\n")))) 

; example 2 - sequence three computations: '(display "One\n")', '(display "Two\n")' and '(display "Three\n")'
; (the monad holds no state and the sequel has no effect)
; Id a -> (a -> Id b) -> (b -> Id c) -> Id c
; Id a -> (_ -> Id b) -> (_ -> Id c) -> Id b    ...  is all that's done here. In fact we don't see the resultant monad '-> Id c' (returns nothing)
(bind_id 
   (unit_id (display "One\n"))
   (lambda (_) (bind_id (unit_id (display "Two\n")) 
                        (lambda (_) (unit_id (display "Three\n"))))))

; example 3 - sequence two computations: '1' and '2'
; (the monad holds no state and the sequel has no effect)
; Id a -> (a -> Id b) -> Id b 
; Id a -> (_ -> Id b) -> Id b    ...  is all that's done here. We see the resultant monad '-> Id b' (returns 2)
(bind_id 
   (unit_id 1)
   (lambda (_) (unit_id 2))) 

; example 4 - action: sequence two computations: '1' and '2' with the sequel 'x + y'
; (the monad holds no state)
; Id a -> (a -> Id b) -> Id b 
; Id a -> (x -> Id b) -> Id b    ...  where (x -> Id b) = Id (x + y) , Id a -> x , Id b -> y ... returns 3
(bind_id 
   (unit_id 1)
   (lambda (x) (bind_id (unit_id 2) 
                        (lambda (y) (unit_id (+ x y)) )) ))

; example 5 - action: sequence two computations: '1', '2' and '3' with the sequel ops 'x + y' and '.. + z'
; (the monad holds no state)
; Id a -> (a -> Id b) -> (b -> Id c) -> Id c
; Id a -> (x -> Id b) -> (r -> Id c) -> Id c    ...  where (x -> Id y) = Id (x + y) and (r -> Id c) = Id (r + z)... returns 6
(bind_id 
   (unit_id 1)
   (lambda (x) (bind_id (unit_id 2) 
                        (lambda (y) (bind_id (unit_id (+ x y)) 
                                             (lambda (r) (bind_id (unit_id 3) 
                                                                  (lambda (z) (unit_id (+ r z)) )) )) )) ))

; example 6 - action: compose two computations: '1' and 'i + 2' with the sequel ops of functional composition 'y x' (i.e. proper 
; Id monad?) 
; (the monad holds no state)
; Id a -> (a -> Id b) -> Id b 
; Id a -> (x -> Id b) -> Id b    ...  where (x -> Id b) = Id (y x) , Id a -> x , Id b -> i + 2 ... returns 3
(bind_id 
   (unit_id 1)
   (lambda (x) (bind_id (unit_id (lambda (i) (+ i 2))) 
                        (lambda (y) (unit_id (y x)) )) ))

; ... this is a load of crap ...
; example 7 - action: sequence two computations: 'i + 1' and 'i + 2' with the sequel ops of operational composition 'x;y;' 
; Note: we are ignoring the return value of each function and instead using the id-value for the input variable. 1st unit_id
; is actually performing the task of a 'put'. HENCE I'M SURE THIS IS NOT A VALID MONAD (but hey)
; Id a -> (a -> Id b) -> (a -> Id c) -> Id c 
; Id a -> (x -> Id b) -> (x -> Id c) -> Id c    ...  where (x -> Id b) = Id (y x) and (x -> Id b) = Id (z x), 
;                                                       Id a -> x, Id b -> i + 1, Id c -> i + 2 ... returns  ????
(bind_id 
   (unit_id 1)
   (lambda (x) (bind_id (unit_id (lambda (i) (+ i 1))) 
                        (lambda (y) (unit_id (y x)) )) ))

(bind_id 
   (unit_id 1)
   (lambda (x) (bind_id (unit_id (lambda (i) (+ i 1))) 
                        (lambda (y) (bind_id (unit_id (lambda (i) (+ i 2))) 
                                             (lambda (z) (unit_id (y x)) )) ))


