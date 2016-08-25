(load "../c-ArrayRef.scm")
(load "../c-Constant.scm")
(load "../c-Expression.scm")
(load "../c-all-expressions.scm")
(load "../c-AssignmentExpr.scm")

(define co1 (make-co (make-single-it 'int) 1))
(define ar1 (make-ar (make-id "test") co1))
(display ar1) (newline)
(display (ar? ar1)) (newline) ; #t
(display (id? (ar->E_id ar1)))(newline) ; #t
(display (E? (ar->E_c ar1)))(newline) ; #t
(newline)

(python-eval "import imp")
(python-eval "pyc1 = imp.load_source( 'test_pycparser', 't/scripts/test-c-array.py' )")
(python-eval "t1 = pyc1.main_eg()")

;(python-eval "t1.ext[3].children()[1][1].children()[0][1].children()[1][1].show()")
(display (ast->ar "t1.ext[3].children()[1][1].children()[0][1].children()[1][1]"))(newline) ; 
 
(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())
;      int a[5];
(define l1,rho2 (alloc 5 rho))
(define rho3 (extend-env "a" (car l1,rho2) (cdr l1,rho2) (list 'array-decl)))
(define s2 s)
;      int b[] = { 1, 2 };
(define l2,rho4 (alloc 2 rho3))
(define rho5 (extend-env "b" (car l2,rho4) (cdr l2,rho4) (list 'array-decl)))
(define s3 (extend-s (car l2,rho4) 1 s2))
(define s4 (extend-s (+ (car l2,rho4) 1) 2 s3))
;      char c[] = "abcdef";
(define l3,rho6 (alloc 7 rho5))
(define rho7 (extend-env "c" (car l3,rho6) (cdr l3,rho6) (list 'array-decl)))
(define s5  (extend-s (+ (car l3,rho6) 0)               #\a  s4))
(define s6  (extend-s (+ (car l3,rho6) 1)               #\b  s5))
(define s7  (extend-s (+ (car l3,rho6) 2)               #\c  s6))
(define s8  (extend-s (+ (car l3,rho6) 3)               #\d  s7))
(define s9  (extend-s (+ (car l3,rho6) 4)               #\e  s8))
(define s10 (extend-s (+ (car l3,rho6) 5)               #\f  s9))
(define s11 (extend-s (+ (car l3,rho6) 6) (integer->char 0) s10))
;(display rho7)(newline)
;(display s11)(newline)

 
;         char z = c[5];
(define tval1 ((ast->e-ar "t1.ext[3].children()[1][1].children()[0][1].children()[1][1]") jp1 zeta1 rho7 s11))
(display (tval->val tval1))(newline) ; f

;         b[1] = 9;
(define tval2 ((ast->e-ae "t1.ext[3].children()[1][1].children()[2][1]") jp1 zeta1 rho7 s11))
(display (tval->val tval2))(newline) ; 9 
(display (apply-s (+ (car l2,rho4) 1) (tval->s tval2)))(newline) ; 9

