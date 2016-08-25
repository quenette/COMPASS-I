(load "../a-jp.scm")
(load "../c-execution.scm")
(load "../c-execution-store.scm")

; testing semantic domain...
(define jp0 (display "")) ; i.e. unspecified.  TODO: not sure we should consider this as ok!?!
(define jp1 ((new-call-jp "myProc" (list 1 2 3)) jp0))
(define jp2 ((new-mcall-jp "myObj" "myProc" (list 1 2 3)) jp0))

(display "jp1: ") (display jp1) (display "\n")
(display "jp2: ") (display jp2) (display "\n")
(display "jp2 k: ") (display (jp->k jp2)) (display "\n")
(display "jp2 pobj: ") (display (jp->pobj jp2)) (display "\n")
(display "jp2 pname: ") (display (jp->pname jp2)) (display "\n")
(display "jp2 wname: ") (display (jp->wname jp2)) (display "\n")
(display "jp2 vs: ") (display (jp->vs jp2)) (display "\n")
(display "jp2 jp: ") (display (jp->jp jp2)) (display "\n")
(display "jp2 pcall? ") (display (pcall-jp? jp2)) (display "\n")
(display "jp2 ac? ") (display (ac-jp? jp2)) (display "\n")
(display "jp2 method? ") (display (obj-jp? jp2)) (display "\n")
(display "jp1 method? ") (display (obj-jp? jp1)) (display "\n")
(display "(jp? jp1) ") (display (jp? jp1)) (display "\n")
(display "(jp? '<unspecified>) ") (display (jp? '<unspecified>)) (display "\n")


; testing monadic operations...
(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define zeta (display ""))

(display "Test 1:\n")
(define tval ((e-setjp (new-call-jp "myProc" (list 1 2 3)) e-getjp ) jp0 zeta rho s))
(display "Result: ") (display (tval->val tval)) (newline)

(display "Test 2:\n")
(define tval ((e-setjp (new-ac-jp "myProc" (list 1 2 3)) e-getjp ) jp0 zeta rho s))
(display "Result: ") (display (tval->val tval)) (newline)

