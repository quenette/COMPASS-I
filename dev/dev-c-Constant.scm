(load "../c-Constant.scm")
(load "../c-Expression.scm")

(display (make-co (make-single-it 'int) "1")) (newline) ; (constant (int) 1)
(display (make-co (make-single-it 'float) "1.5")) (newline) ; (constant (float) 1.5)
(display (make-co (make-single-it 'char) 1)) (newline)
(display (make-co (make-single-it 'char) "'1'")) (newline) ; (constant (char) 1)
(display (make-co (make-double-it 'signed 'char) 1)) (newline) ; (constant (signed char) 1)

(python-eval "import imp")
(python-eval "pyc1 = imp.load_source( 'types', 't/scripts/test-c-type-specifier.py' )")
(python-eval "pyc2 = imp.load_source( 'array', 't/scripts/test-c-array.py' )")
(python-eval "t1 = pyc1.main_eg()")
(python-eval "t2 = pyc2.main_eg()")

(display (ast->co "t1.ext[0].children()[1][1]"))(newline) ; (constant (char) a)

(load "../c-store.scm")
(load "../c-env.scm")
(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())

(define tval1 ((ast->e-co "t1.ext[0].children()[1][1]") jp1 zeta1 rho s))
(display (tval->val tval1))(newline) ; a


(define tval2 ((ast->e-co "t2.ext[2].children()[1][1]") jp1 zeta1 rho s))
(display (tval->val tval2))(newline) ; (a b c d e f )
(display (length (tval->val tval2)))(newline) ; 7   ... i.e. includes the tailing 0

(display (cadr (tval->val tval2))) (newline)

