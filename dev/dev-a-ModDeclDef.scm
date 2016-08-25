(load "../a-ModDeclDef.scm")
(load "../c-FuncDef.scm")
(load "../c-DenDecl.scm")
(load "../c-Declaration.scm")
(load "../c-Statement.scm")
 (load "../c-FuncCall.scm")

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())

(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-aspect-func2.py' )")
(python-eval "t = pyc.main_eg()")
(python-eval "t.show()")

; load "a" and "d" such they exist for the advice line...
(define tval1_0 ((e-mdd (ast->mdd "t.ext[0]")) jp1 zeta1 (car rho,s) (cadr rho,s)))
(define tval1_1 ((e-mdd (ast->mdd "t.ext[3]")) jp1 (tval->zeta tval1_0) (tval->rho tval1_0) (tval->s tval1_0)))

; Test MDD on a AdviceDecl ...
(define mdd1 (ast->mdd "t.ext[4]"))
(display mdd1) (newline)
(display (mdd? mdd1))(newline) ;#t
(define tval1_2 ((e-mdd mdd1) jp1 (tval->zeta tval1_1) (tval->rho tval1_1) (tval->s tval1_1)))
(display (tval->zeta tval1_2))(newline) ; ((motion () #<procedure #f (chi)> (and (pcall a) (args ())) d () () ()))
(newline)

; TODO: add aspect option to compass-c to test a real c program!!!
