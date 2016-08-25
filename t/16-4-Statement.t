#!/usr/bin/guile -s
!#

(use-modules (guiletap))
(load "../c-Statement.scm")


; tests ...
(plan 12)
(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1   (display ""))
(define zeta1 '())
(define dd1   (display ""))


(define co1 (make-co (make-single-it 'float) "1.5"))
(define S1 (make-re co1))
(is-ok  1 "re? ..."         #t          (S? S1))


(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-statement.py' )")
(python-eval "t = pyc.main_eg()")

(define S2 (ast->S "t.ext[0].children()[1][1].children()[0][1]"))
(is-ok  2 "S? ...2"         #t          (S? S2))


(define l1,rho2 (alloc 1 rho))

; return constant ...
(define tval1 ((ast->e-S "t.ext[0].children()[1][1].children()[0][1]") jp1 zeta1 (cdr l1,rho2) s))
(is-ok  3 "tval? ...3"      #t          (tval? tval1))
(is-ok  4 "tval = 1? ...3"  1           (tval->val tval1))

; compound ...
(define tval2 ((ast->e-S "t.ext[0].children()[1][1]") jp1 zeta1 (cdr l1,rho2) s))
(is-ok  5 "tval? ...4"      #t          (tval? tval2))
(is-ok  6 "tval = 1? ...4"  1           (tval->val tval2))

; failing compound ...
;(define tval3 ((ast->e-S "t.ext[2].children()[1][1]") jp1 zeta1 rho5 s))
;(is-ok  9 "tval = unspecified? ...5"  #t          (unspecified? tval3))
;(is-ok  9 "tval = 1? ...4"  1           (tval->val tval2))  ; TODO: need to redo/rethink erroring! hack to keep test numbers

; empty body ...
(define tval4 ((ast->e-S "t.ext[3].children()[1][1]") jp1 zeta1 (cdr l1,rho2) s))
(is-ok  7 "tval? ...6"                    #t          (tval? tval4))
(is-ok  8 "tval = 0? ...6"                0           (tval->val tval4))

; embedded compound body ... (checking variable scope)
(define tval5 ((ast->e-S "t.ext[4].children()[1][1]") jp1 zeta1 (cdr l1,rho2) s))
(is-ok  9 "tval? ...7"                    #t          (tval? tval5))
(is-ok 10 "tval = 4? ...7"                4           (tval->val tval5))

; embedded compound body ... (checking variable scope 2)
(define tval6 ((ast->e-S "t.ext[5].children()[1][1]") jp1 zeta1 (cdr l1,rho2) s))
(is-ok 11 "tval? ...8"                    #t          (tval? tval6))
(is-ok 12 "tval = 3? ...8"                3           (tval->val tval6))

