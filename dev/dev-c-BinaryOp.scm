(load "../c-BinaryOp.scm")
(load "../c-Expression.scm")
(load "../c-all-expressions.scm")

(define bo1 (make-*-bo (make-id "test_1") (make-id "test_2")))
(display bo1) (newline)
(display (bo? bo1)) (newline) ; #t
(display (*-bo? bo1)) (newline) ; #t

(define bo2 (make-/-bo (make-id "test_1") (make-id "test_2")))
(display bo2) (newline)
(display (bo? bo2)) (newline) ; #t
(display (/-bo? bo2)) (newline) ; #t

(define bo3 (make-+-bo (make-id "test_1") (make-id "test_2")))
(display bo3) (newline)
(display (bo? bo3)) (newline) ; #t
(display (+-bo? bo3)) (newline) ; #t

(define bo4 (make---bo (make-id "test_1") (make-id "test_2")))
(display bo4) (newline)
(display (bo? bo4)) (newline) ; #t
(display (--bo? bo4)) (newline) ; #t

(define bo5 (make-<-bo (make-id "test_1") (make-id "test_2")))
(display bo5) (newline)
(display (bo? bo5)) (newline) ; #t
(display (<-bo? bo5)) (newline) ; #t

(define bo6 (make->-bo (make-id "test_1") (make-id "test_2")))
(display bo6) (newline)
(display (bo? bo6)) (newline) ; #t
(display (>-bo? bo6)) (newline) ; #t

(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-binary.py' )")
(python-eval "t = pyc.main_eg()")

(display (ast->bo "t.ext[0].children()[1][1]"))(newline) ; (* (constant (int) 3) (constant (int) 4))

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())

(define tval1 ((ast->e-bo "t.ext[0].children()[1][1]") jp1 zeta1 rho s))
(display "\"")(display (tval->val tval1))(display "\"")(newline) ; 12
(define tval2 ((ast->e-bo "t.ext[1].children()[1][1]") jp1 zeta1 rho s))
(display "\"")(display (tval->val tval2))(display "\"")(newline) ; 3/4   - TODO:  deal with int and float typing in expressions
(define tval3 ((ast->e-bo "t.ext[2].children()[1][1]") jp1 zeta1 rho s))
(display "\"")(display (tval->val tval3))(display "\"")(newline) ; 7
(define tval4 ((ast->e-bo "t.ext[3].children()[1][1]") jp1 zeta1 rho s))
(display "\"")(display (tval->val tval4))(display "\"")(newline) ; 1
(define tval5 ((ast->e-bo "t.ext[4].children()[1][1]") jp1 zeta1 rho s))
(display "\"")(display (tval->val tval5))(display "\"")(newline) ; #t
(define tval6 ((ast->e-bo "t.ext[5].children()[1][1]") jp1 zeta1 rho s))
(display "\"")(display (tval->val tval6))(display "\"")(newline) ; #f

