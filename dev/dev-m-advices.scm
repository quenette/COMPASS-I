(load "dev-a-tearup.scm")
(load "../a-advice.scm")
(load "../m-advices.scm")


(define alpha01 (e-adv-after pcd01 "c" (e-applyBody "c")))
(define alpha02 (e-adv-after pcd02 "d" (e-applyBody "d")))
(define alpha03 (e-adv-after pcd01 "b" (e-applyBody "b")))

(define gamma01 (list alpha01 alpha02))
(display "gamma01: ")(display gamma01)(newline)


;insert-before-gamma...
(newline)
(define gamma02 (insert-before-gamma  alpha03  alpha01  gamma01))
(display "gamma02: ")(display gamma02)(newline)  ; 3  1  2
(define gamma03 (insert-before-gamma  alpha03  alpha02  gamma01))
(display "gamma03: ")(display gamma03)(newline)  ; 1  3  2
(define gamma04 (insert-before-gamma  alpha03  alpha03  gamma01))
(display "gamma04: ")(display gamma04)(newline)  ; _b


;insert-after-gamma...
(newline)
(define gamma05 (insert-after-gamma  alpha03  alpha01  gamma01))
(display "gamma05: ")(display gamma05)(newline)  ; 1  3  2
(define gamma06 (insert-after-gamma  alpha03  alpha02  gamma01))
(display "gamma06: ")(display gamma06)(newline)  ; 1  2  3
(define gamma07 (insert-after-gamma  alpha03  alpha03  gamma01))
(display "gamma07: ")(display gamma07)(newline)  ; _b


