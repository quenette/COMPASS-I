#!/usr/bin/guile -s
!#

(use-modules (guiletap))
(load "../c-Constant.scm")
(load "../c-IdentifierType.scm")
(load "../c-store.scm")
(load "../c-env.scm")
(load "../c-Expression.scm")

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())

; tests ...
(plan 46)

(is-ok  1 "(co? (make-co (make-single-it 'int) 1))"              #t        (co? (make-co (make-single-it 'int) 1)) )
(is-ok  2 "(co->kind (make-co (make-single-it 'int) 1))"         'constant (co->kind (make-co (make-single-it 'int) 1)))
(is-ok  3 "(it? (co->it (make-co (make-single-it 'int) 1)))"     #t        (it? (co->it (make-co (make-single-it 'int) 1)))) 

(is-ok  4 "(co->val (make-co (make-single-it 'short) 1))"        1         (co->val (make-co (make-single-it 'short) 1)))
(is-ok  5 "(co->val (make-co (make-single-it 'short) \"1\"))"    1         (co->val (make-co (make-single-it 'short) "1")))

(is-ok  6 "(co->val (make-co (make-single-it 'int) 1))"          1         (co->val (make-co (make-single-it 'int) 1)))
(is-ok  7 "(co->val (make-co (make-single-it 'int) \"1\"))"      1         (co->val (make-co (make-single-it 'int) "1")))

(is-ok  8 "(co->val (make-co (make-single-it 'long) 1))"         1         (co->val (make-co (make-single-it 'long) 1)))
(is-ok  9 "(co->val (make-co (make-single-it 'long) \"1\"))"     1         (co->val (make-co (make-single-it 'long) "1")))

(is-ok 10 "(co->val (make-co (make-single-it 'float) 1.5))"      1.5       (co->val (make-co (make-single-it 'float) 1.5)))
(is-ok 11 "(co->val (make-co (make-single-it 'float) \"1.5\"))"  1.5       (co->val (make-co (make-single-it 'float) "1.5")))

(is-ok 12 "(co->val (make-co (make-single-it 'double) 1.5))"     1.5       (co->val (make-co (make-single-it 'double) 1.5)))
(is-ok 13 "(co->val (make-co (make-single-it 'double) \"1.5\"))" 1.5       (co->val (make-co (make-single-it 'double) "1.5")))

(is-ok 14 "(co->val (make-co (make-double-it 'long 'double) 1.5))"     1.5 (co->val (make-co (make-double-it 'long 'double) 1.5)))
(is-ok 15 "(co->val (make-co (make-double-it 'long 'double) \"1.5\"))" 1.5 (co->val (make-co (make-double-it 'long 'double) "1.5")))

(is-ok 16 "(co->val (make-co (make-single-it 'long) 1))"         1         (co->val (make-co (make-single-it 'long) 1)))
(is-ok 17 "(co->val (make-co (make-single-it 'long) \"1\"))"     1         (co->val (make-co (make-single-it 'long) "1")))

(is-ok 18 "(co->val (make-co (make-single-it 'signed) 1))"       1         (co->val (make-co (make-single-it 'signed) 1)))
(is-ok 19 "(co->val (make-co (make-single-it 'signed) \"1\"))"   1         (co->val (make-co (make-single-it 'signed) "1")))

(is-ok 20 "(co->val (make-co (make-single-it 'unsigned) 1))"     1         (co->val (make-co (make-single-it 'unsigned) 1)))
(is-ok 21 "(co->val (make-co (make-single-it 'unsigned) \"1\"))" 1         (co->val (make-co (make-single-it 'unsigned) "1")))

(is-ok 22 "(co->val (make-co (make-double-it 'unsigned 'short) 1))"     1  (co->val (make-co (make-double-it 'unsigned 'short) 1)))
(is-ok 23 "(co->val (make-co (make-double-it 'unsigned 'short) \"1\"))" 1  (co->val (make-co (make-double-it 'unsigned 'short) "1")))

(is-ok 24 "(co->val (make-co (make-double-it 'unsigned 'long) 1))"      1  (co->val (make-co (make-double-it 'unsigned 'long) 1)))
(is-ok 25 "(co->val (make-co (make-double-it 'unsigned 'long) \"1\"))"  1  (co->val (make-co (make-double-it 'unsigned 'long) "1")))

(is-ok 26 "(co->val (make-co (make-single-it 'char) 1))" (integer->char 1) (co->val (make-co (make-single-it 'char) 1)) )
(is-ok 27 "(co->val (make-co (make-single-it 'char) #\a))"       #\a       (co->val (make-co (make-single-it 'char) #\a)) )
(is-ok 28 "(co->val (make-co (make-single-it 'char) \"'a'\"))"   #\a       (co->val (make-co (make-single-it 'char) "'a'")) )

(is-ok 29 "(co->val (make-co (make-double-it 'signed 'char) 1))"     1     (co->val (make-co (make-double-it 'signed 'char) 1)) )
(is-ok 30 "(co->val (make-co (make-double-it 'signed 'char) \"1\"))" 1     (co->val (make-co (make-double-it 'signed 'char) "1")) )

(is-ok 31 "(co->val (make-co (make-double-it 'unsigned 'char) 1))"     1   (co->val (make-co (make-double-it 'unsigned 'char) 1)) )
(is-ok 32 "(co->val (make-co (make-double-it 'unsigned 'char) \"1\"))" 1   (co->val (make-co (make-double-it 'unsigned 'char) "1")) )

(python-eval "import imp")
(python-eval "pyc1 = imp.load_source( 'types', 't/scripts/test-c-type-specifier.py' )")
(python-eval "pyc2 = imp.load_source( 'array', 't/scripts/test-c-array.py' )")
(python-eval "t1 = pyc1.main_eg()")
(python-eval "t2 = pyc2.main_eg()")

(is-ok 33 "t1.ext[00].children()[1][1]"  #\a  (tval->val ((ast->e-co "t1.ext[00].children()[1][1]") jp1 zeta1 rho s)))
(is-ok 34 "t1.ext[01].children()[1][1]"  2    (tval->val ((ast->e-co "t1.ext[01].children()[1][1]") jp1 zeta1 rho s)))
(is-ok 35 "t1.ext[02].children()[1][1]"  3    (tval->val ((ast->e-co "t1.ext[02].children()[1][1]") jp1 zeta1 rho s)))
(is-ok 36 "t1.ext[03].children()[1][1]"  4    (tval->val ((ast->e-co "t1.ext[03].children()[1][1]") jp1 zeta1 rho s)))
(is-ok 37 "t1.ext[04].children()[1][1]"  5.0  (tval->val ((ast->e-co "t1.ext[04].children()[1][1]") jp1 zeta1 rho s)))
(is-ok 38 "t1.ext[05].children()[1][1]"  6.0  (tval->val ((ast->e-co "t1.ext[05].children()[1][1]") jp1 zeta1 rho s)))
(is-ok 39 "t1.ext[06].children()[1][1]"  7    (tval->val ((ast->e-co "t1.ext[06].children()[1][1]") jp1 zeta1 rho s)))
(is-ok 40 "t1.ext[07].children()[1][1]"  8    (tval->val ((ast->e-co "t1.ext[07].children()[1][1]") jp1 zeta1 rho s)))

(is-ok 41 "t1.ext[10].children()[1][1]"  13   (tval->val ((ast->e-co "t1.ext[10].children()[1][1]") jp1 zeta1 rho s)))
(is-ok 42 "t1.ext[11].children()[1][1]"  14   (tval->val ((ast->e-co "t1.ext[11].children()[1][1]") jp1 zeta1 rho s)))
(is-ok 43 "t1.ext[12].children()[1][1]"  15   (tval->val ((ast->e-co "t1.ext[12].children()[1][1]") jp1 zeta1 rho s)))
(is-ok 44 "t1.ext[13].children()[1][1]"  16.0 (tval->val ((ast->e-co "t1.ext[13].children()[1][1]") jp1 zeta1 rho s)))

(define tval2 ((ast->e-co "t2.ext[2].children()[1][1]") jp1 zeta1 rho s))
(is-ok 45 "[1]"  (list #\a #\b #\c #\d #\e #\f (integer->char 0))         (tval->val tval2))
(is-ok 46 "[1]"  7                                                        (length (tval->val tval2)))

