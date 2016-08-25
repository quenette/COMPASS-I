(load "../c-FuncDef.scm")
(load "../c-Statement.scm")
 (load "../c-FuncCall.scm")
(load "../m-MotionStmt.scm")
(load "../m-Statement.scm")

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())


(define co1 (make-co (make-single-it 'float) "1.5"))
(define re1 (make-re co1))
(display re1) (newline)
(display (S? re1)) (newline)

(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-compass-func2.py' )")
(python-eval "t = pyc.main_eg()")
(python-eval "t.show()")

; load "a" and "d" such they exist for the motion line...
(define tval_F1 ((ast->e-F "t.ext[0]") jp1 zeta1 (car rho,s) (cadr rho,s)))
(define tval_F2 ((ast->e-F "t.ext[2]") jp1 zeta1 (tval->rho tval_F1) (tval->s tval_F1)))

; Test S on a MotionAppendAfterCall ...
(define S1 (ast->S "t.ext[4].children()[1][1].children()[0][1]"))
(display S1) (newline) ; (motion-append-after-call #<unspecified> (identifier d) #<unspecified> (identifier a) () () ())
(display (S? S1))(newline) ;#t
(define tval1_1 ((e-S S1) jp1 (tval->zeta tval_F2) (tval->rho tval_F2) (tval->s tval_F2)))
(display (tval->zeta tval1_1))(newline) ; ((motion #<unspecified> #<procedure #f (chi)> (and (pcall a) (args ())) d () () ()))
(newline)

