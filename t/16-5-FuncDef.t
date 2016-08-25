#!/usr/bin/guile -s
!#

(use-modules (guiletap))
(load "../c-FuncDef.scm")
(load "../c-DenDecl.scm")
(load "../c-Declaration.scm")
(load "../c-Statement.scm")


; tests ...
(plan 10)

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())

(define td1 (make-it-td (make-id "argc") (make-single-it 'int)))
(define od1 (make-td-od td1 (display "")))
(define dd1a (make-od-dd od1))
(define  D1 (make-od-D dd1a))
(define pl1 (make-pl (list D1)))
(define td2 (make-it-td (make-id "main") (make-single-it 'int)))
(define od4 (make-td-od td2 (display "")))
(define fd1 (make-fd pl1 od4))
(define  D2 (make-fd-D fd1))

(define td3 (make-it-td (make-id "test") (make-single-it 'int)))
(define co1 (make-co (make-single-it 'int) 1))
(define  D3 (make-od-Eel-D td3 co1))
(define co2 (make-co (make-single-it 'float) "1.5"))
(define re1 (make-re co2))
(define  C1 (make-C (list D3) (list re1)))

(define  F1 (make-F D2 C1))
(is-ok  1 "F? 1"                 #t         (F? F1))
(is-ok  2 "main? 1"              "main"     (F->sym F1))


(define tval1_0 ((e-F F1) jp1 zeta1 (car rho,s) (cadr rho,s)))
(display tval1_0)(newline)
(is-ok  3 "'fnext-l 1"            1         (apply-env 'fnext-l (tval->rho tval1_0)))
(is-ok  4 "main 1"                0         (apply-env "main" (tval->rho tval1_0)))
(is-ok  5 "compound? 1"           #t        (C? (tval->val tval1_0)))


(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-func.py' )")
(python-eval "t = pyc.main_eg()")

(define F2 (ast->F "t.ext[1]"))
(display F2) (newline)
(display (F? F2))(newline) ;#t
(display (F->sym F2))(newline) ;b
(is-ok  6 "F? 2"                 #t         (F? F2))
(is-ok  7 "a? 2"                 "b"        (F->sym F2))


(define tval2_0 ((e-F F2) jp1 zeta1 (car rho,s) (cadr rho,s)))
(is-ok  8 "'fnext-l 2"            1         (apply-env 'fnext-l (tval->rho tval2_0)))
(is-ok  9 "b 2"                   0         (apply-env "b" (tval->rho tval2_0)))
(is-ok 10 "compound? 2"           #t        (C? (tval->val tval2_0)))

