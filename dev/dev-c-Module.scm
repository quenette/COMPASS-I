(load "../c-Module.scm")
(load "../c-DenDecl.scm")
(load "../c-Declaration.scm")
(load "../c-Statement.scm")
(load "../c-FuncCall.scm")

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 (display ""))

(python-eval "import imp")
(python-eval "pyc1 = imp.load_source( 'test_pycparser', 't/scripts/test-c-type-specifier.py' )")
(python-eval "t1 = pyc1.main_eg()")

(define M1 (ast->M "t1"))
(display M1) (newline)
(display (M? M1))(newline) ;#t
(define tval1_0 ((e-M M1) jp1 zeta1 (car rho,s) (cadr rho,s)))
(display tval1_0)(newline)


(python-eval "import imp")
(python-eval "pyc2 = imp.load_source( 'test_pycparser', 't/scripts/test-c-func.py' )")
(python-eval "t2 = pyc2.main_eg()")

(define M2 (ast->M "t2"))
(display M2) (newline)
(display (M? M2))(newline) ;#t
(define tval2_0 ((e-M M2) jp1 zeta1 (car rho,s) (cadr rho,s)))
(display tval2_0)(newline)

