(load "../c-Typedef.scm")
 (load "../c-Declaration.scm")
 (load "../c-Expression.scm")
 (load "../c-all-expressions.scm")

(define td1 (make-it-td (make-id "a") (make-single-it 'int)))
(define td2 (make-it-td (make-id "b") (make-single-it 'int)))
(define D1 (make-od-D td1))
(define ad1 (make-ad-c td2 2))
(define D2 (make-od-D ad1))
(define st1 (make-st (list D1 D2)))
(define td3 (make-st-td (make-id "myStruct") st1))
(define ty1 (make-ty td3))
(display ty1) (newline)
(display (ty? ty1)) (newline) ; #t
(display (td? (ty->td ty1))) (newline) ; #t
(newline)


(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())

(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-struct.py' )")
(python-eval "t = pyc.main_eg()")


;      typedef struct { char z[5]; } B;
(define ty2 (ast->ty "t.ext[1]"))
(display ty2)(newline)
(define tval2 ((e-ty ty2) jp1 zeta1 rho s))
(display (apply-env 'types (tval->rho tval2)))(newline)   ; ((type-decl (identifier B)
(define tval2_2 ((e-get-type "B") jp1 zeta1 (tval->rho tval2) (tval->s tval2)))
(display (tval->val tval2_2))(newline) ; (type-decl (identifier B)
(newline)

;      typedef struct _E { ... } E;
(define ty3 (ast->ty "t.ext[2]"))
(display ty3)(newline)
(define tval3 ((e-ty ty3) jp1 zeta1 (tval->rho tval2) (tval->s tval2)))
(define tval3_2 ((e-get-type "E") jp1 zeta1 (tval->rho tval3) (tval->s tval3)))
(display (tval->val tval3_2))(newline) ; (type-decl (identifier E) ...
(define tval3_3 ((e-get-type "B") jp1 zeta1 (tval->rho tval3) (tval->s tval3)))
(display (tval->val tval3_3))(newline) ; (type-decl (identifier B) ...
(newline)


;         B b;
(define D4 (ast->D "t.ext[11].children()[1][1].children()[4][1]"))
(display D4)(newline)
(define tval4 ((e-D D4 #f) jp1 zeta1 (tval->rho tval2) (tval->s tval2)))
(display (tval->rho tval4))(newline) ; 
(display (apply-env "b" (tval->rho tval4)))(newline)   ; 100000
(display (apply-env 'next-l (tval->rho tval4)))(newline)   ; 100005
(newline)


; Ensure declaration of struct in function definition and call...

(load "../c-FuncDef.scm")
(load "../c-Statement.scm")

;      void func5( B b ) {}
(define f5 (ast->F "t.ext[7]"))
(display f5)(newline)
(define tval5 ((e-F f5) jp1 zeta1 (tval->rho tval4) (tval->s tval4)))
(display (apply-env "func5" (tval->rho tval5)))(newline) ; 0
(display (apply-env 'fnext-l (tval->rho tval5)))(newline) ; 1
;         func5( b );
;(python-eval "t.ext[11].children()[1][1].children()[26][1].show()")
(define fc6 (ast->fc "t.ext[11].children()[1][1].children()[26][1]"))
(display fc6)(newline)
(define tval6 ((e-fc fc6) jp1 zeta1 (tval->rho tval5) (tval->s tval5)))
(display (tval->val tval6))(newline) ; 1
(newline)

;      void func6( B* b ) {}
(define f7 (ast->F "t.ext[8]"))
(display f7)(newline)
(define tval7 ((e-F f7) jp1 zeta1 (tval->rho tval4) (tval->s tval4)))
(display (apply-env "func6" (tval->rho tval7)))(newline) ; 0
(display (apply-env 'fnext-l (tval->rho tval7)))(newline) ; 1
;         func6( &b );
;(python-eval "t.ext[11].children()[1][1].children()[27][1].show()")
(define fc8 (ast->fc "t.ext[11].children()[1][1].children()[27][1]"))
(display fc8)(newline)
(define tval8 ((e-fc fc8) jp1 zeta1 (tval->rho tval7) (tval->s tval7)))
(display (tval->val tval8))(newline) ; 1
(newline)



