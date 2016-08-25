(load "../c-Compound.scm")
(load "../c-Statement.scm")

(define td1 (make-it-td (make-id "test") (make-single-it 'int)))
(define co1 (make-co (make-single-it 'int) 1))
(define  D1 (make-od-Eel-D td1 co1))
(define co2 (make-co (make-single-it 'float) "1.5"))
(define re1 (make-re co2))
(define  C1 (make-C (list D1) (list re1)))
(display C1)(newline)
(display (C? C1))(newline)


(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-func.py' )")
(python-eval "t = pyc.main_eg()")

(display "\"")(display (ast->C "t.ext[0].children()[1][1]"))(display "\"")(newline)
(display "\"")(display (ast->C "t.ext[1].children()[1][1]"))(display "\"")(newline)
(display "\"")(display (ast->C "t.ext[2].children()[1][1]"))(display "\"")(newline)

;(newline)
;(display (C->D* (ast->C "t.ext[1].children()[1][1]")))(newline)
;(display (car (C->D* (ast->C "t.ext[1].children()[1][1]"))))(newline)
;(display (cadr (C->D* (ast->C "t.ext[1].children()[1][1]"))))(newline)
;(display (C->S* (ast->C "t.ext[1].children()[1][1]")))(newline)
;(newline)


; add an 'return-val to the environment, then execute a return statement
(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())

(display "\"")(display (((ast->e-C e-eoC) "t.ext[0].children()[1][1]") jp1 zeta1 rho s))(display "\"")(newline)

(display "\"")(display (((ast->e-C e-eoC) "t.ext[1].children()[1][1]") jp1 zeta1 rho s))(display "\"")(newline)

(define tval3 (((ast->e-C e-eoC) "t.ext[2].children()[1][1]") jp1 zeta1 rho s))
(display "\"")(display tval3)(display "\"")(newline)

