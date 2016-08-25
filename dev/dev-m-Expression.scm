(load "../m-MotionStmt.scm")
(load "../m-PointcutCall.scm")
(load "../c-FuncDef.scm")
 (load "../c-Statement.scm")
 (load "../c-FuncCall.scm")
  (load "../a-pcd.scm")
  (load "../a-advice.scm")
  (load "../a-weave.scm")
  (load "../a-advcomb.scm")
  (load "../m-motion.scm")
(load "../m-Expression.scm")

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())


; Load the functions (so they exist are known)...
(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 'pycompasscparser.py' )")
(python-eval "import pycompasscparser")
(python-eval "parser = pycompasscparser.CompassCParser()")
(python-eval "fn = 't/scripts/test-compass-pointcut01.c'")
(python-eval "buf = open( fn, 'rU').read()")
(python-eval "t = parser.parse( buf, fn )")
(define tval_F1 ((ast->e-F "t.ext[0]") jp1 zeta1 (car rho,s) (cadr rho,s)))
(define tval_F2 ((ast->e-F "t.ext[1]") jp1 zeta1 (tval->rho tval_F1) (tval->s tval_F1)))
(define tval_F3 ((ast->e-F "t.ext[2]") jp1 zeta1 (tval->rho tval_F2) (tval->s tval_F2)))
(define tval_F4 ((ast->e-F "t.ext[3]") jp1 zeta1 (tval->rho tval_F3) (tval->s tval_F3)))
(define tval_F5 ((ast->e-F "t.ext[4]") jp1 zeta1 (tval->rho tval_F4) (tval->s tval_F4)))

(define tval_ms1 ((ast->e-ms "t.ext[6].children()[1][1].children()[0][1]") jp1 (tval->zeta tval_F5) (tval->rho tval_F5) (tval->s tval_F5)))
(define tval_ms2 ((ast->e-ms "t.ext[6].children()[1][1].children()[1][1]") jp1 (tval->zeta tval_ms1) (tval->rho tval_ms1) (tval->s tval_ms1)))
(display (tval->zeta tval_ms2))(newline) ;((motion #<unspecified> #<procedure #f (chi)> (and (pcall a) (args ())) d () () ()))
(newline)



; Test that an pc can be created and applied from the AST
(define tval_pc1 ((ast->e-E "t.ext[6].children()[1][1].children()[2][1]") jp1 (tval->zeta tval_ms2) (tval->rho tval_ms2) (tval->s tval_ms2)))


