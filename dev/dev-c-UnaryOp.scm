(load "../c-UnaryOp.scm")
(load "../c-Expression.scm")
(load "../c-all-expressions.scm")
(load "../c-Typedef.scm")

(define uo1 (make-&-uo (make-id "test")))
(display uo1) (newline)
(display (uo? uo1)) (newline) ; #t
(display (&-uo? uo1)) (newline) ; #t

(python-eval "import imp")
(python-eval "pyc1 = imp.load_source( 'pointer', 't/scripts/test-c-pointer.py' )")
(python-eval "pyc2 = imp.load_source( 'sizeof', 't/scripts/test-c-sizeof.py' )")
(python-eval "t1 = pyc1.main_eg()")
(python-eval "t2 = pyc2.main_eg()")

;      int* b = {{ &a }};
(display (ast->uo "t1.ext[01].children()[1][1]"))(newline) ; (& (identifier a))

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())
;      int a = 3;
(define l1,rho2 (alloc 1 rho))
(define rho3 (extend-env "a" (car l1,rho2) (cdr l1,rho2) (list 'type-decl)))
(define s2 (setref "a" 3 rho3 s))
;      int b = &a;
(define l2,rho4 (alloc 1 rho3))
(define rho5 (extend-env "b" (car l2,rho4) (cdr l2,rho4) (list 'ptr-decl)))
(define s3 (setref "b" (car l1,rho2) rho5 s2))
;      int* e[2] = { 0, 1 };
(define l3,rho6 (alloc 2 rho5))
(define rho7 (extend-env "e" (car l3,rho6) (cdr l3,rho6) (list 'array-decl)))
(define s4 (extend-s (car l3,rho6) 0 s3))
(define s5 (extend-s (+ (car l3,rho6) 1) 1 s4))

;      int* b = {{ &a }};
(define tval1 ((ast->e-uo "t1.ext[01].children()[1][1]") jp1 zeta1 rho7 s5))
(display (tval->val tval1))(newline) ; 100000

;      int* l = {{ &e }};
(define tval2 ((ast->e-uo "t1.ext[11].children()[1][1]") jp1 zeta1 rho7 s5))
(display (tval->val tval2))(newline) ; 100002

;      int* j = {{ *b }};
(define tval3 ((ast->e-uo "t1.ext[9].children()[1][1]") jp1 zeta1 rho7 s5))
(display (tval->val tval3))(newline) ; 3

;      int* k = {{ *e }};
(define tval4 ((ast->e-uo "t1.ext[10].children()[1][1]") jp1 zeta1 rho7 s5))
(display (tval->val tval4))(newline) ; 0

;      int m = {{ *(e+1) }};
(define tval5 ((ast->e-uo "t1.ext[12].children()[1][1]") jp1 zeta1 rho7 s5))
(display (tval->val tval5))(newline) ; 1


;      struct _A { int i; int j; };
(define D10 (ast->D "t2.ext[0]"))
;(display D10)(newline)
(define tval10 ((e-D D10 #f) jp1 zeta1 rho s))

;      typedef struct { int k; int l; int m; } B;
(define ty11 (ast->ty "t2.ext[1]"))
;(display ty11)(newline)
(define tval11 ((e-ty ty11) jp1 zeta1 (tval->rho tval10) (tval->s tval10)))

;      int a = sizeof(int);
(define uo12 (ast->uo "t2.ext[2].children()[1][1]"))
(display uo12)(newline)
(define tval12 ((e-uo uo12) jp1 zeta1 (tval->rho tval11) (tval->s tval11)))
(display (tval->val tval12))(newline) ; 1

;      int b = sizeof(unsigned long);
(define uo13 (ast->uo "t2.ext[3].children()[1][1]"))
(display uo13)(newline)
(define tval13 ((e-uo uo13) jp1 zeta1 (tval->rho tval11) (tval->s tval11)))
(display (tval->val tval13))(newline) ; 1

;      int c = sizeof(struct _A);
(define uo14 (ast->uo "t2.ext[4].children()[1][1]"))
(display uo14)(newline)
(define tval14 ((e-uo uo14) jp1 zeta1 (tval->rho tval11) (tval->s tval11)))
(display (tval->val tval14))(newline) ; 2

;      int d = sizeof(B);
(define uo15 (ast->uo "t2.ext[5].children()[1][1]"))
(display uo15)(newline)
(define tval15 ((e-uo uo15) jp1 zeta1 (tval->rho tval11) (tval->s tval11)))
(display (tval->val tval15))(newline) ; 3



