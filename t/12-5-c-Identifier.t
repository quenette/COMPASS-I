#!/usr/bin/guile -s
!#

(use-modules (guiletap))
(load "../c-Identifier.scm")
(load "../c-TypeDecl.scm")
(load "../c-PtrDecl.scm")
(load "../c-ArrayDecl.scm")
(load "../c-Struct.scm")


; tests ...
(plan 6)

(is-ok  1 "(id? (make-id \"test\"))"           #t          (id? (make-id "test")))
(is-ok  2 "(id->kind (make-id \"test\"))"      'identifier (id->kind (make-id "test")))
(is-ok  3 "(id->sym (make-id \"test\"))"       "test"      (id->sym (make-id "test")))

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
(define rho3 (extend-env "a" (car l1,rho2) (cdr l1,rho2) (make-it-td (make-id "a") (make-single-it 'int))))
(define s2 (setref "a" 3 rho3 s))
;      int b = &a;
(define l2,rho4 (alloc 1 rho3))
(define rho5 (extend-env "b" (car l2,rho4) (cdr l2,rho4) (make-pd (make-it-td (make-id "a") (make-single-it 'int)))))
(define s3 (setref "b" (car l1,rho2) rho5 s2))
;      int* e[2] = { 0, 1 };
(define l3,rho6 (alloc 2 rho5))
(define rho7 (extend-env "e" (car l3,rho6) (cdr l3,rho6) (make-ad-c (make-it-td (make-id "e") (make-single-it 'int)) 2)))
(define s4 (extend-s (car l3,rho6) 0 s3))
(define s5 (extend-s (+ (car l3,rho6) 1) 1 s4))

(define tval1 ((ast->e-id "t1.ext[6].children()[1][1]") jp1 zeta1 rho7 s5))
(is-ok 4 "int g = a;"  3  (tval->val tval1))

(define tval2 ((ast->e-id "t1.ext[7].children()[1][1]") jp1 zeta1 rho7 s5))
(is-ok 5 "int** d = &b;"  100000  (tval->val tval2))

(define tval3 ((ast->e-id "t1.ext[8].children()[1][1]") jp1 zeta1 rho7 s5))
(is-ok 6 "int* i = e;"  100002  (tval->val tval3))

