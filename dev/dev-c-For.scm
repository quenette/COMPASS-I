(load "../c-For.scm")
 (load "../c-Statement.scm")

(define co1 (make-co (make-single-it 'float) "1"))
(define co2 (make-co (make-single-it 'int) "2"))
(define co3 (make-co (make-single-it 'long) "3"))
; hack simple statement 
(define co4 (make-co (make-single-it 'float) "1.5"))
(define re1 (make-re co4))
(define fo1 (make-fo co1 co2 co3 re1))
(display fo1) (newline)
(display (fo? fo1)) (newline) ; #t
(display (init-fo? fo1)) (newline) ; #t
(display (cond-fo? fo1)) (newline) ; #t
(display (next-fo? fo1)) (newline) ; #t
(display (EDl? (fo->EDl_init fo1))) (newline) ; #t
(display (E? (fo->E_cond fo1))) (newline) ; #t
(display (Eel? (fo->Eel_next fo1))) (newline) ; #t
(display (S? (fo->S fo1))) (newline) ; #t
(newline)

(display (E? fo1)) (newline) ; #f


(define fo2 (make-fo (display "") co2 co3 re1))
(display fo2) (newline)
(display (fo? fo2)) (newline) ; #t
(display (init-fo? fo2)) (newline) ; #f
(display (cond-fo? fo2)) (newline) ; #t
(display (next-fo? fo2)) (newline) ; #t
(display (E? (fo->E_cond fo2))) (newline) ; #t
(display (Eel? (fo->Eel_next fo2))) (newline) ; #t
(display (S? (fo->S fo2))) (newline) ; #t
(newline)

(define fo3 (make-fo co1 (display "") co3 re1))
(display fo3) (newline)
(display (fo? fo3)) (newline) ; #t
(display (init-fo? fo3)) (newline) ; #t
(display (cond-fo? fo3)) (newline) ; #f
(display (next-fo? fo3)) (newline) ; #t
(display (EDl? (fo->EDl_init fo3))) (newline) ; #t
(display (Eel? (fo->Eel_next fo3))) (newline) ; #t
(display (S? (fo->S fo3))) (newline) ; #t
(newline)

(define fo4 (make-fo co1 co2 (display "") re1))
(display fo4) (newline)
(display (fo? fo4)) (newline) ; #t
(display (init-fo? fo4)) (newline) ; #t
(display (cond-fo? fo4)) (newline) ; #t
(display (next-fo? fo4)) (newline) ; #f
(display (EDl? (fo->EDl_init fo4))) (newline) ; #t
(display (E? (fo->E_cond fo4))) (newline) ; #t
(display (S? (fo->S fo4))) (newline) ; #t
(newline)

(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'for', 't/scripts/test-c-for.py' )")
(python-eval "t = pyc.main_eg()")

(define rho  (make-env 0 100000))
(define zeta1 '())
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))

; Load up local vars needed for the following tests...
(define D5_1 (ast->D "t.ext[0].children()[1][1].children()[0][1]"))
(define tval5_1 ((e-D D5_1 #f) jp1 zeta1 rho s))
(define D5_2 (ast->D "t.ext[0].children()[1][1].children()[1][1]"))
(define tval5_2 ((e-D D5_2 #f) jp1 zeta1 (tval->rho tval5_1) (tval->s tval5_1)))
(define D5_3 (ast->D "t.ext[0].children()[1][1].children()[2][1]"))
(define tval5_3 ((e-D D5_3 #f) jp1 zeta1 (tval->rho tval5_2) (tval->s tval5_2)))
(define tval5 tval5_3)
(display (apply-env "i" (tval->rho tval5))) (newline) ; 100000
(display (apply-env "j" (tval->rho tval5))) (newline) ; 100001
(display (deref "j" (tval->rho tval5) (tval->s tval5))) (newline) ; 0
(display (apply-env "k" (tval->rho tval5))) (newline) ; 100002
(newline)

;(python-eval "t.ext[0].children()[1][1].children()[3][1].show()")
(define fo6 (ast->fo "t.ext[0].children()[1][1].children()[3][1]"))
(display fo6)(newline)
(define tval6 ((e-fo fo6) jp1 zeta1 (tval->rho tval5) (tval->s tval5)))
(display (deref "j" (tval->rho tval6) (tval->s tval6))) (newline) ; 10
(newline)

;;         return 1;
;(display ((ast->e-re "t.ext[0].children()[1][1].children()[0][1]") jp1 zeta1 rho s))(newline) ; ( 1 ...
;
;;         return k;
;(define rho4 (extend-env "k" 0 rho (make-it-td (make-id "k") (make-single-it 'int))))
;(define s2 (setref "k" 2 rho4 s))
;(define l2,rho5 (alloc 1 rho4))
;(display ((ast->e-re "t.ext[1].children()[1][1].children()[2][1]") jp1 zeta1 (cdr l2,rho5) s2))(newline) ; (2 ...

