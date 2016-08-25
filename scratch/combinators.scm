; Combinators

; 'Application combinator' ... applies the function f with the argument x
(define app
   (lambda (f)
      (lambda (x)
         (f x) )) )

; example
((app foo) 3)

; variant
(define app2
   (lambda (f x)
      (f x) ) )
(app2 foo 3)




