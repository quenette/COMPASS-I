#!/usr/bin/guile -s
!#

(use-modules (guiletap))
(load "../c-Return.scm")


; tests ...
(plan 9)
(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())
(define dd1 (display ""))

(define co1 (make-co (make-single-it 'float) "1.5"))
(define re1 (make-re co1))
(is-ok  1 "re? ..."         #t          (re? re1))
(is-ok  2 "E? ..."          #t          (E? (re->E re1)))
(is-ok  3 "1.5? ..."        1.5         (tval->val ((e-E (re->E re1)) jp1 zeta1 rho s)))


(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-func.py' )")
(python-eval "t = pyc.main_eg()")

(define re2 (ast->re "t.ext[0].children()[1][1].children()[0][1]"))
(is-ok  4 "re? ...2"        #t          (re? re2))
(is-ok  5 "E? ...2"         #t          (E? (re->E re2)))

(define tval1 ((ast->e-re "t.ext[0].children()[1][1].children()[0][1]") jp1 zeta1 rho s))
(is-ok  6 "tval? ...3"      #t          (tval? tval1))
(is-ok  7 "tval = 1? ...3"  1           (tval->val tval1))

(define rho4 (extend-env "k" 0 rho (make-it-td (make-id "k") (make-single-it 'int))))
(define s2 (setref "k" 2 rho4 s))
(define l2,rho5 (alloc 1 rho4))
(define tval2 ((ast->e-re "t.ext[1].children()[1][1].children()[2][1]") jp1 zeta1 (cdr l2,rho5) s2))
(is-ok  8 "tval? ...4"      #t          (tval? tval2))
(is-ok 9 "tval = 2? ...4"  2           (tval->val tval2))

