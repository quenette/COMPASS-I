(load "../c-FuncCall.scm")
(load "../c-all-expressions.scm")

(load "../c-FuncDef.scm")
(load "../c-Statement.scm")

(define  co1 (make-co (make-single-it 'signed) 1))
(define  co2 (make-co (make-single-it 'long) 2))
(define  el1 (make-el (list co1 co2)))
(define  id1 (make-id "test"))
(define  fc1 (make-fc id1 el1))
(display fc1) (newline)
(display (fc? fc1)) (newline) ; #t
(display (fc->sym fc1)) (newline) ; "test"


(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-func.py' )")
(python-eval "t = pyc.main_eg()")

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))

(define jp1 (display ""))
(define zeta1 '())
; do the function declaration for "c"
(define F1 (ast->F "t.ext[2]"))
(define tval1 ((e-F F1) jp1 zeta1 rho s))
; do the function declaration for "e"
(define F2 (ast->F "t.ext[4]"))
(define tval2 ((e-F F2) jp1 zeta1 (tval->rho tval1) (tval->s tval1)))

; temporarily here... implementation of printf...
(define td1   (make-it-td (make-id "num") (make-single-it 'char)))
(define od1a  (make-td-od td1 (display "")))
(define dd1a  (make-od-dd od1a))
(define pd1   (make-pd dd1a))
(define od1b  (make-td-od pd1 (display "")))
(define dd1b  (make-od-dd od1b))
(define  D1   (make-od-D dd1b))
(define pl1   (make-pl (list D1)))
(define td2   (make-it-td (make-id "printnum") (make-single-it 'int)))
(define od3   (make-td-od td2 (display "")))
(define fd1   (make-fd pl1 od3))
(define tval3 ((e-fd fd1) jp1 zeta1 (tval->rho tval2) (tval->s tval2)))


(define fc2 (ast->fc "t.ext[5].children()[1][1].children()[0][1]"))
(display fc2)(newline)
(display (fc? fc2)) (newline) ; #t
(display (fc->sym fc2)) (newline) ; "c"
(display (tval->val ((e-fc fc2) jp1 zeta1 (tval->rho tval3) (tval->s tval3)))) (newline) ; 1

(define fc3 (ast->fc "t.ext[5].children()[1][1].children()[1][1].children()[0][1]"))
(display fc3)(newline)
(display (fc? fc3)) (newline) ; #t
(display (fc->sym fc3)) (newline) ; "e"
(display (tval->val ((e-fc fc3) jp1 zeta1 (tval->rho tval3) (tval->s tval3)))) (newline) ; 5

