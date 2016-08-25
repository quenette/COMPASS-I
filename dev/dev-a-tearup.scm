(load "../a-jp.scm")
(load "../c-execution.scm")
(load "../c-execution-store.scm")

(load "../c-FuncCall.scm")
(load "../c-all-expressions.scm")
(load "../c-FuncDef.scm")
(load "../c-Statement.scm")

(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-func2.py' )")
(python-eval "t = pyc.main_eg()")

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))

; Load some functions/procedure code for the tests...
; For the following we dont need a valid jp.
; Do the function declaration for "a", "b", "c" & "d"
; Create chi for call to "a" & "b"
(define jp1 (display ""))
(define zeta1 (display ""))
(define F-a (ast->F "t.ext[0]"))
(define tval1 ((e-F F-a) jp1 zeta1 rho s))
(define fc-a (ast->fc "t.ext[4].children()[1][1].children()[0][1]"))
(define chi-a (e-fc fc-a))
(define F-b (ast->F "t.ext[1]"))
(define tval2 ((e-F F-b) jp1 zeta1 (tval->rho tval1) (tval->s tval1)))
(define fc-b (ast->fc "t.ext[4].children()[1][1].children()[1][1]"))
(define chi-b (e-fc fc-b))
(define F-c (ast->F "t.ext[2]"))
(define tval3 ((e-F F-c) jp1 zeta1 (tval->rho tval2) (tval->s tval2)))
(define F-d (ast->F "t.ext[3]"))
(define tval4 ((e-F F-d) jp1 zeta1 (tval->rho tval3) (tval->s tval3)))
;(define tval (chi-a jp1 zeta1 (tval->rho tval4) (tval->s tval4)))
;(define tval (chi-b jp1 zeta1 (tval->rho tval4) (tval->s tval4)))

; Hack up some test joinpoints and PCDs
(define jp-a   ((new-call-jp (fc->sym fc-a) '()) (display "")))
(define jp-b   ((new-call-jp (fc->sym fc-b) '()) (display "")))
(display "jp-a: ") (display jp-a) (newline)
(display "jp-b: ") (display jp-b) (newline)
(define pcd01  (list 'and (list 'pcall "a") (list 'args '())))
(display "pcd01: ") (display pcd01) (newline)
(define pcd02  (list 'and (list 'pcall "b") (list 'args '())))
(display "pcd02: ") (display pcd02) (newline)

; This is a shortcut to create motions from advice, pretty much as AdviceDecl does but without needing it yet
(define add-advice
   (lambda (sym_body pcd alpha)
      (lambda (jp zeta rho s)
        ((appendm (list 'motion '() alpha pcd sym_body '() '() '())) jp zeta rho s)
)))


(define tearup-e
   (lambda (jp chi)
      ((seq-e
         (e-extend-env jp 0) ; create advice-index (would be done when jp is created)!
         (lambda (_) chi)
) jp zeta1 (tval->rho tval4) (tval->s tval4))))

