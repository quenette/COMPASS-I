(load "../c-Identifier.scm")
(load "../c-TypeDecl.scm")
(load "../c-PtrDecl.scm")
(load "../c-ArrayDecl.scm")
(load "../c-Struct.scm")

(define id1 (make-id "test"))
(display id1) (newline)
(display (id? id1)) (newline) ; #t
;
(python-eval "import imp")
(python-eval "pyc1 = imp.load_source( 'test_pycparser', 't/scripts/test-c-pointer.py' )")
(python-eval "t1 = pyc1.main_eg()")

(display (ast->id "t1.ext[6].children()[1][1]"))(newline) ; (identifier a)

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
;(display rho7)(newline)
;(display s5)(newline)

;      int g = {{ a }};
(python-eval "t1.ext[6].children()[1][1].show()")
(define tval1 ((ast->e-id "t1.ext[6].children()[1][1]") jp1 zeta1 rho7 s5))
(display (tval->val tval1))(newline) ; 3

;      int** d = & {{ b }};
(define tval2 ((ast->e-id "t1.ext[7].children()[1][1]") jp1 zeta1 rho7 s5))
(display (tval->val tval2))(newline) ; 100000

;      int* i = {{ e }};
(define tval3 ((ast->e-id "t1.ext[8].children()[1][1]") jp1 zeta1 rho7 s5))
(display (tval->val tval3))(newline) ; 100002

