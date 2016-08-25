(define (foo x) (if (> x 0) (begin (foo (- x 1)) (display "hello\n"))))
(define (bar x) (if (> x 0) (begin (bar (- x 1)) (display "world\n"))))

; works. for only one arg ...
; note: 'list' is explicitly needed to create a list that copies the symbol/function rather than the text
(define (composeN var funcs) 
        ( (lambda (v fs) 
                  (if (not (null? fs)) ( begin ((car fs) v) (composeN v (cdr fs)) ) 
                  )
          ) var funcs)
)
(composeN 1 (list foo bar))

; works. vars as a list ...
(define (composeN vars funcs) 
        ( (lambda (vs fs) 
                  (if (not (null? fs)) ( begin (apply (car fs) vs) (composeN vs (cdr fs)) ) 
                  )
          ) vars funcs)
)
(composeN '(1) (list foo bar))

