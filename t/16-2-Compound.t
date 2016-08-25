#!/usr/bin/guile -s
!#

(use-modules (guiletap))
(load "../c-Compound.scm")
(load "../c-Statement.scm")


; tests ...
(plan 7)
(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 '())
(define zeta1 '())
(define dd1 (display ""))


(define td1 (make-it-td (make-id "test") (make-single-it 'int)))
(define co1 (make-co (make-single-it 'int) 1))
(define  D1 (make-od-Eel-D td1 co1))
(define co2 (make-co (make-single-it 'float) "1.5"))
(define re1 (make-re co2))
(define  C1 (make-C (list D1) (list re1)))
(is-ok  1 "C? ..."          #t          (C? C1))


(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-func.py' )")
(python-eval "t = pyc.main_eg()")

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))

(define tval1 (((ast->e-C e-eoC) "t.ext[0].children()[1][1]") jp1 zeta1 rho s))
(is-ok  2 "tval? ...2"                   #t          (tval? tval1))
(is-ok  3 "tval = 1? ...2"               1           (tval->val tval1))

(define tval2 (((ast->e-C e-eoC) "t.ext[1].children()[1][1]") jp1 zeta1 rho s))
(is-ok  4 "tval? ...3"                   #t          (tval? tval2))
(is-ok  5 "tval = 2? ...3"               2           (tval->val tval2))

(define tval3 (((ast->e-C e-eoC) "t.ext[2].children()[1][1]") jp1 zeta1 rho s))
(is-ok  6 "tval? ...4"                             #t          (tval? tval3))
(is-ok  7 "tval = 0? ...4"                         0           (tval->val tval3))

