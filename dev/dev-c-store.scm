(load "../error.scm")
(load "../kind.scm")
(load "../c-store.scm")

(define s
   (extend-s 2 6
      (extend-s 0 8
         (extend-s 1 7
            (extend-s 0 14
               (empty-s))))))
(display s)(newline)
(display (s? s))(newline)
(display (apply-s 2 s))(newline)
(display (apply-s 1 s))(newline)
(display (apply-s 0 s))(newline)

