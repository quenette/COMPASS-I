(load "../c-Expression.scm")
(load "../c-all-expressions.scm")

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))

(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-expression.py' )")
(python-eval "t = pyc.main_eg()")

; add an "a" to the environment, then "&a" (ie. get its location)
(define l1,rho2 (alloc 1 rho))
(define dd1 (display ""))
(define rho3 (extend-env "a" (car l1,rho2) (cdr l1,rho2) dd1))
(define s2 (setref "a" 3 rho3 s))
(define jp1 (display ""))
(define zeta1 '())

(define tval1 ((ast->e-E "t.ext[00].children()[1][1]") jp1 zeta1 rho3 s2))
(display "\"")(display (tval->val tval1))(display "\"")(newline) ; 3
(define tval2 ((ast->e-E "t.ext[01].children()[1][1]") jp1 zeta1 rho3 s2))
(display "\"")(display (tval->val tval2))(display "\"")(newline) ; 100000
(define tval3 ((ast->e-E "t.ext[02].children()[1][1]") jp1 zeta1 rho3 s2))
(display "\"")(display (tval->val tval3))(display "\"")(newline) ; 3
(define tval4 ((ast->e-E "t.ext[03].children()[1][1]") jp1 zeta1 rho3 s2))
(display "\"")(display (tval->val tval4))(display "\"")(newline) ; 5

