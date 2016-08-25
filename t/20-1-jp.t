#!/usr/bin/guile -s
!#

(use-modules (guiletap))
(load "../c-FuncDef.scm")
(load "../c-DenDecl.scm")
(load "../c-Declaration.scm")
(load "../c-Statement.scm")


; tests ...
(plan 14)

(load "../a-jp.scm")
(load "../c-execution.scm")
(load "../c-execution-store.scm")

; testing semantic domain...
(define jp0 (display "")) ; i.e. unspecified.
(define jp1 ((new-call-jp "myProc" (list 1 2 3)) jp0))
(define jp2 ((new-mcall-jp "myObj" "myProc" (list 1 2 3)) jp0))

(is-ok  1 "new-call-jp k"                 'pcall         (jp->k jp2))
(is-ok  2 "new-call-jp pobj"              "myObj"        (jp->pobj jp2))
(is-ok  3 "new-call-jp pname"             "myProc"       (jp->pname jp2))
(is-ok  4 "new-call-jp wname"             '<invalid>     (jp->wname jp2))
(is-ok  5 "new-call-jp vs"                (list 1 2 3)   (jp->vs jp2))
(is-ok  6 "new-call-jp jp"                (display "")   (jp->jp jp2)) ;i.e. unspecified
(is-ok  7 "new-call-jp pcall?"            #t             (pcall-jp? jp2))
(is-ok  8 "new-call-jp ac?"               #f             (ac-jp? jp2))
(is-ok  9 "new-call-jp method call?"      #t             (obj-jp? jp2))

(is-ok 10 "new-call-jp method call?"      #f             (obj-jp? jp1))
(is-ok 11 "jp? new-call-jp"               #t             (jp? jp1))
(is-ok 12 "jp? '<unspecified>"            #f             (jp? (display "")))


; testing monadic operations...
(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define zeta (display ""))

(define tval ((e-setjp (new-call-jp "myProc" (list 1 2 3)) e-getjp ) jp0 zeta rho s))
(is-ok 13 "Test 1"                       'pcall        (jp->k (tval->val tval)))

(define tval ((e-setjp (new-ac-jp "myProc" (list 1 2 3)) e-getjp ) jp0 zeta rho s))
(is-ok 14 "Test 2"                       'ac           (jp->k (tval->val tval)))

