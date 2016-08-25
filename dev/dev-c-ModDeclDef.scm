(load "../c-ModDeclDef.scm")
(load "../c-FuncDef.scm")
(load "../c-DenDecl.scm")
(load "../c-Declaration.scm")
(load "../c-Statement.scm")

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 (display ""))

(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-func.py' )")
(python-eval "t = pyc.main_eg()")

(define mdd1 (ast->mdd "t.ext[1]"))
(display mdd1) (newline)
(display (mdd? mdd1))(newline) ;#t
(define tval1_0 ((e-mdd mdd1) jp1 zeta1 (car rho,s) (cadr rho,s)))
(display tval1_0)(newline)


(python-eval "pyc2 = imp.load_source( 'test_pycparser', 't/scripts/test-c-pointer.py' )")
(python-eval "t2 = pyc2.main_eg()")

(define mdd2 (ast->mdd "t2.ext[0]"))
(display mdd2)(newline)
(display (mdd? mdd2))(newline) ;#t
(define tval2_0 ((e-mdd mdd2) jp1 zeta1 (car rho,s) (cadr rho,s)))
(display tval2_0)(newline)


; TODO: typedef tests...

