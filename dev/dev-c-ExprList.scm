(load "../c-ExprList.scm")
(load "../c-all-expressions.scm")

(define  co1 (make-co (make-single-it 'signed) 1))
(define  co2 (make-co (make-single-it 'long) 2))
(define  el1 (make-el (list co1 co2)))
(display el1) (newline) ; (exprlist ((constant (signed) 1) (constant (long) 2)))
(display (el? el1))(newline)  ; #t

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())

(define tval1 ((e-el el1) jp1 zeta1 rho s))
(display (tval->val tval1))(newline)   ;  ( 1 2 )

(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-array.py' )")
(python-eval "t = pyc.main_eg()")

(define el2 (ast->el "t.ext[1].children()[1][1]"))
(display el2)(newline)  ; (exprlist ((constant (int) 1) (constant (int) 2)))
(define tval2 ((e-el el2) jp1 zeta1 rho s))
(display (tval->val tval2))(newline)   ;  ( 1 2 )

