(load "../c-Statement.scm")

(define co1 (make-co (make-single-it 'float) "1.5"))
(define re1 (make-re co1))
(display re1) (newline)
(display (S? re1)) (newline)


(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-statement.py' )")
(python-eval "t = pyc.main_eg()")

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(display "\"")(display (ast->S "t.ext[0].children()[1][1].children()[0][1]"))(display "\"")(newline)

(define l1,rho2 (alloc 1 rho))
(define jp1 (display ""))
(define zeta1 '())
(define dd1 (display ""))

(display ((ast->e-S "t.ext[0].children()[1][1].children()[0][1]") jp1 zeta1 (cdr l1,rho2) s))(newline)

(define tval2 ((ast->e-S "t.ext[0].children()[1][1]") jp1 zeta1 (cdr l1,rho2) s))
(display tval2)(newline)

; purposely fail (q undefined) ...    TODO ... fix up erroring such that I can trap errors at a statement level!!!!
;(define rho5 (extend-env 'return-val (car l1,rho2) (cdr l1,rho2) dd1))
;(define tval3 ((ast->e-S "t.ext[2].children()[1][1]") jp1 zeta1 rho5 s))
;(display tval3)(newline)

; empty body ...
(define tval4 ((ast->e-S "t.ext[3].children()[1][1]") jp1 zeta1 (cdr l1,rho2) s))
(display tval4)(newline)

; embedded compound body ... (checking variable scope)
(define tval5 ((ast->e-S "t.ext[4].children()[1][1]") jp1 zeta1 (cdr l1,rho2) s))
(display tval5)(newline)
(display (deref "k" (tval->rho tval5) (tval->s tval5)))(newline)
;(display (C->S* (ast->S "t.ext[4].children()[1][1]")))(newline) 
; produces...
;( (compound ( (decl (type-decl (identifier k) (int)) (constant (int) 4)) ) ( (return (identifier k)) ) ) [missing return here] )

; embedded compound body ... (checking variable scope 2)
(define tval6 ((ast->e-S "t.ext[5].children()[1][1]") jp1 zeta1 (cdr l1,rho2) s))
(display tval6)(newline)
(display (deref "k" (tval->rho tval6) (tval->s tval6)))(newline)
;(display (C->S* (ast->S "t.ext[5].children()[1][1]")))(newline) 
;( (compound ( (decl (type-decl (identifier k) (int)) (constant (int) 4)) ) ( [yes no stmts in inner compound] ) ) [missing return here] )

(define S00 (ast->S "t.ext[0].children()[1][1].children()[0][1]"))
(define S* (list S00))

; note in this test, eoc wont get run because eop in return replaces the continuation
(define tval4_0 (((e-S* S* (lambda (x) (eoc x))) 0) jp1 zeta1 (cdr l1,rho2) s))
(display tval4_0)(newline)

