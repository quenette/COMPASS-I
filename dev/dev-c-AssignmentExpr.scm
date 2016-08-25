(load "../c-AssignmentExpr.scm")
(load "../c-Expression.scm")
(load "../c-all-expressions.scm")
(load "../c-DenDecl.scm")

(define ae1 (make-=-ae (make-id "test") (make-co (make-single-it 'int) "7")))
(display ae1) (newline) ; (= (identifier test) (constant (int) 7))
(display (ae? ae1)) (newline) ; #t
(display (=-ae? ae1)) (newline) ; #t

(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-assignment.py' )")
(python-eval "t = pyc.main_eg()")

(display (ast->ae "t.ext[5].children()[1][1].children()[0][1]"))(newline) ; (= (identifier a) (constant (int) 5))
(display (ast->ae "t.ext[5].children()[1][1].children()[1][1]"))(newline) ; (= (identifier b) (identifier a))
(display (ast->ae "t.ext[5].children()[1][1].children()[2][1]"))(newline) ; (= (identifier c) (= (identifier a) (constant (int) 3)))
(display (ast->ae "t.ext[5].children()[1][1].children()[3][1]"))(newline) ; (= (identifier d) (& (identifier a)))
; Can't do the rest ... need * and [] dereference operators implmented.

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())

; add an "a"/... to the environment, set a value to it (11)/.. to ensure the operations below replaces the value.
(define l1,rho2 (alloc 1 rho))  ; allocate space for "a"
(define dd1 (make-it-td (make-id "a") (make-single-it 'int)))         ; type-info for "a"
(define rho3 (extend-env "a" (car l1,rho2) (cdr l1,rho2) dd1))     ; add "a" to the environment
(define s2 (setref "a" 11 rho3 s))                                 ; write a value to "a"

(define l2,rho3 (alloc 1 rho3))
(define dd2 (make-it-td (make-id "b") (make-single-it 'int)))
(define rho4 (extend-env "b" (car l2,rho3) (cdr l2,rho3) dd2))
(define s3 (setref "b" 22 rho4 s2))

(define l3,rho4 (alloc 1 rho4))
(define dd3 (make-pd (make-it-td (make-id "c") (make-single-it 'int))))
(define rho5 (extend-env "c" (car l3,rho4) (cdr l3,rho4) dd3))
(define s4 (setref "c" 33 rho5 s3))

(define l4,rho5 (alloc 1 rho5))
(define dd4 (make-pd (make-it-td (make-id "d") (make-single-it 'int))))
(define rho6 (extend-env "d" (car l4,rho5) (cdr l4,rho5) dd4))
(define s5 (setref "d" 44 rho6 s4))

;         a = 5;
(display (apply-s (car l1,rho2) s5))(newline) ; 11
(define tval1 ((ast->e-ae "t.ext[5].children()[1][1].children()[0][1]") jp1 zeta1 rho6 s5))
(display (tval->val tval1))(newline) ; 5
(display (apply-s (car l1,rho2) (tval->s tval1)))(newline) ; 5

;         b = a;
(display (apply-s (car l2,rho3) s5))(newline) ; 22
(define tval2 ((ast->e-ae "t.ext[5].children()[1][1].children()[1][1]") jp1 zeta1 (tval->rho tval1) (tval->s tval1)))
(display (tval->val tval2))(newline) ; 5
(display (apply-s (car l2,rho3) (tval->s tval2)))(newline) ; 5

;         c = a = 3;
(display (apply-s (car l3,rho4) s5))(newline) ; 33
(define tval3 ((ast->e-ae "t.ext[5].children()[1][1].children()[2][1]") jp1 zeta1 (tval->rho tval2) (tval->s tval2)))
(display (tval->val tval3))(newline) ; 3
(display (apply-s (car l3,rho4) (tval->s tval3)))(newline) ; 3
(display (apply-s (car l1,rho2) (tval->s tval3)))(newline) ; 3

;         d = &a;
(display (apply-s (car l4,rho5) s5))(newline) ; 44
(define tval4 ((ast->e-ae "t.ext[5].children()[1][1].children()[3][1]") jp1 zeta1 (tval->rho tval3) (tval->s tval3)))
(display (tval->val tval4))(newline) ; 100000
(display (apply-s (car l4,rho5) (tval->s tval4)))(newline) ; 100000

;         *d = 7;
(display (apply-s (car l4,rho5) (tval->s tval4)))(newline) ; 100000
(define tval5 ((ast->e-ae "t.ext[5].children()[1][1].children()[4][1]") jp1 zeta1 (tval->rho tval4) (tval->s tval4)))
(display (tval->val tval5))(newline) ; 7
(display (apply-s (car l4,rho5) (tval->s tval5)))(newline) ; 100000   ... i.e. d
(display (apply-s (car l1,rho2) (tval->s tval5)))(newline) ; 7        ... i.e. a



