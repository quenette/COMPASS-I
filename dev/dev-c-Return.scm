(load "../c-Return.scm")

(define co1 (make-co (make-single-it 'float) "1.5"))
(define re1 (make-re co1))
(display re1) (newline)
(display (re? re1)) (newline) ; #t


(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-func.py' )")
(python-eval "t = pyc.main_eg()")

;         return 1;
(display (ast->re "t.ext[0].children()[1][1].children()[0][1]"))(newline) ; (return (constant (int) 1))
;         return k;
(display (ast->re "t.ext[1].children()[1][1].children()[2][1]"))(newline) ; (return (identifier k))

; add an 'return-val to the environment, then execute a return statement
(define rho  (make-env 0 100000))
(define zeta1 '())
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))

;         return 1;
(display ((ast->e-re "t.ext[0].children()[1][1].children()[0][1]") jp1 zeta1 rho s))(newline) ; ( 1 ...

;         return k;
(define rho4 (extend-env "k" 0 rho (make-it-td (make-id "k") (make-single-it 'int))))
(define s2 (setref "k" 2 rho4 s))
(define l2,rho5 (alloc 1 rho4))
(display ((ast->e-re "t.ext[1].children()[1][1].children()[2][1]") jp1 zeta1 (cdr l2,rho5) s2))(newline) ; (2 ...

