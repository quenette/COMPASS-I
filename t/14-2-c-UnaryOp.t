#!/usr/bin/guile -s
!#

(use-modules (guiletap))
(load "../c-UnaryOp.scm")
(load "../c-Expression.scm")
(load "../c-all-expressions.scm")

; tests ...
(plan 8)

(is-ok  1 "(uo? (make-&-uo (make-id \"test\")))"        #t          (uo? (make-&-uo (make-id "test"))))
(is-ok  2 "(&-uo? (make-&-uo (make-id \"test\")))"      #t          (&-uo? (make-&-uo (make-id "test"))))
(is-ok  3 "(uo->kind (make-&-uo (make-id \"test\")))"  '&           (uo->kind (make-&-uo (make-id "test"))))


(python-eval "import imp")
(python-eval "pyc1 = imp.load_source( 'test_pycparser', 't/scripts/test-c-pointer.py' )")
(python-eval "t1 = pyc1.main_eg()")

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())
;      int a = 3;
(define l1,rho2 (alloc 1 rho))
(define rho3 (extend-env "a" (car l1,rho2) (cdr l1,rho2) (list 'type-decl)))
(define s2 (setref "a" 3 rho3 s))
;      int b = &a;
(define l2,rho4 (alloc 1 rho3))
(define rho5 (extend-env "b" (car l2,rho4) (cdr l2,rho4) (list 'ptr-decl)))
(define s3 (setref "b" (car l1,rho2) rho5 s2))
;      int* e[2] = { 0, 1 };
(define l3,rho6 (alloc 2 rho5))
(define rho7 (extend-env "e" (car l3,rho6) (cdr l3,rho6) (list 'array-decl)))
(define s4 (extend-s (car l3,rho6) 0 s3))
(define s5 (extend-s (+ (car l3,rho6) 1) 1 s4))


(define tval1 ((ast->e-uo "t1.ext[01].children()[1][1]") jp1 zeta1 rho7 s5))
(is-ok  4 "int* b = &a"   100000  (tval->val tval1))

(define tval2 ((ast->e-uo "t1.ext[11].children()[1][1]") jp1 zeta1 rho7 s5))
(is-ok  5 "int* l = &e;"   100002  (tval->val tval2))

(define tval3 ((ast->e-uo "t1.ext[9].children()[1][1]") jp1 zeta1 rho7 s5))
(is-ok  6 "int* j = *b;"   3  (tval->val tval3))

(define tval4 ((ast->e-uo "t1.ext[10].children()[1][1]") jp1 zeta1 rho7 s5))
(is-ok  7 "int* k = *e;"   0  (tval->val tval4))

(define tval5 ((ast->e-uo "t1.ext[12].children()[1][1]") jp1 zeta1 rho7 s5))
(is-ok  8 "int m = *(e+1);"   1  (tval->val tval5))


