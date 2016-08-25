(load "../c-FuncCall.scm")
(load "../c-all-expressions.scm")

(load "dev-a-tearup.scm")
(load "../a-pcd.scm")
(load "../a-advice.scm")
(load "../a-weave.scm")
(load "../a-advcomb.scm")
(load "../m-motion.scm")

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
(define tval2 ((e-F F2) jp1 (tval->zeta tval1) (tval->rho tval1) (tval->s tval1)))
; do the function declaration for "f"
(define F3 (ast->F "t.ext[6]"))
(define tval3 ((e-F F3) jp1 (tval->zeta tval2) (tval->rho tval2) (tval->s tval2)))
; do the function declaration for "g"
(define F4 (ast->F "t.ext[7]"))
(define tval4 ((e-F F4) jp1 (tval->zeta tval3) (tval->rho tval3) (tval->s tval3)))

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
(define tval5 ((e-fd fd1) jp1 (tval->zeta tval4) (tval->rho tval4) (tval->s tval4)))


; pretend that call advice has been given on c and e...
(define pcd-c  (list 'and (list 'pcall "c") (list 'args '())))
(define pcd-e  (list 'and (list 'pcall "e") (list 'args '("a" "b"))))
(define tval6 ((seq-e
   (add-advice "f" pcd-c (e-adv-after pcd-c "f" (e-applyBody "f")))
   (lambda (x) (add-advice "g" pcd-e (e-adv-before pcd-e "g" (e-applyBody "g"))))
) jp1 (tval->zeta tval5) (tval->rho tval5) (tval->s tval5)))


; Call "c" procedure...
(display "\n")
(define fc2 (ast->fc "t.ext[5].children()[1][1].children()[0][1]"))
(display fc2)(newline)
(display (fc? fc2)) (newline) ; #t
(display (fc->sym fc2)) (newline) ; "c"
(display (tval->val ((e-fc fc2) jp1 (tval->zeta tval6) (tval->rho tval6) (tval->s tval6)))) (newline) ; 1

; Call "e" function, but with the default combination (return from original body) ...
(define fc3 (ast->fc "t.ext[5].children()[1][1].children()[1][1].children()[0][1]"))
(display fc3)(newline)
(display (fc? fc3)) (newline) ; #t
(display (fc->sym fc3)) (newline) ; "e"
(display (tval->val ((e-fc fc3) jp1 (tval->zeta tval6) (tval->rho tval6) (tval->s tval6)))) (newline) ; 5

; Call "e" function, but with the "+" combination (accumulates returns from bodies) ...
; pretend that ac-+ advice has been given on e...
(define pcd-e'  (list 'ac "e"))
(define tval7 
   ((add-advice "ac-+" pcd-e' (e-adv-around pcd-e' "ac-+" e-ac-+))
jp1 (tval->zeta tval6) (tval->rho tval6) (tval->s tval6)))

; Call "e" function ...
(define fc3 (ast->fc "t.ext[5].children()[1][1].children()[1][1].children()[0][1]"))
(display fc3)(newline)
(display (fc? fc3)) (newline) ; #t
(display (fc->sym fc3)) (newline) ; "e"
(display (tval->val ((e-fc fc3) jp1 (tval->zeta tval7) (tval->rho tval7) (tval->s tval7)))) (newline) ; 12


