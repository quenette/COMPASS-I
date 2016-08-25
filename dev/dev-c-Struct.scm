(load "../c-Struct.scm")
(load "../c-all-expressions.scm")

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())


(define td1 (make-it-td (make-id "a") (make-single-it 'int)))
(define td2 (make-it-td (make-id "b") (make-single-it 'int)))
(define D1 (make-od-D td1))
(define ad1 (make-ad-c td2 2))
(define D2 (make-od-D ad1))
(define  st1 (make-st (list D1 D2)))
(display st1) (newline) ; (struct () ((decl (type-decl (identifier a) (int)) ()) (decl (array-decl (type-decl (identifier b) (int)) 2) ())))
(display (st? st1))(newline)  ; #t
(display (sym-st? st1))(newline)  ; #f
(display (list? (st->D* st1)))(newline)  ; #t
(define tval1 ((e-st->sz st1) jp1 zeta1 rho s))
(display (tval->val tval1))(newline) ; 3
(newline)

(define td3 (make-it-td (make-id "c") (make-single-it 'int)))
(define D3 (make-od-D td3))
(define  st2 (make-sym-st "_Z" (list D3)))
(display st2) (newline) ; (struct _Z ((decl (type-decl (identifier c) (int)) ())))
(display (st? st2))(newline)  ; #t
(display (sym-st? st2))(newline)  ; #t
(display (st->sym st2))(newline)  ; _Z
(display (list? (st->D* st2)))(newline)  ; #t
(define tval2 ((e-st->sz st2) jp1 zeta1 rho s))
(display (tval->val tval2))(newline) ; 1
(newline)


(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-struct.py' )")
(python-eval "t = pyc.main_eg()")


; struct declaration
;      struct _A { int i; int j; };
(define st3 (ast->st "t.ext[0].children()[0][1]"))
(display st3)(newline)
(define tval3 ((e-st st3 '() #f) jp1 zeta1 rho s))
(define tval3_2 ((e-get-struct "_A") jp1 zeta1 (tval->rho tval3) (tval->s tval3)))
(display (eqv? (tval->val tval3_2) st3))(newline) ; #t
(define tval3_3 ((e-get-struct "foo") jp1 zeta1 (tval->rho tval3) (tval->s tval3)))
(display (tval->val tval3_3))(newline) ; #<unspecified>
(define tval3_4 ((e-st->sz st3) jp1 zeta1 (tval->rho tval3) (tval->s tval3)))
(display (tval->val tval3_4))(newline) ; 2
(newline)

;  anonymous struct declaration
;      typedef {{ struct { char z[5]; } }} B;
;(python-eval "t.ext[1].children()[0][1].children()[0][1].show()")
(define st4 (ast->st "t.ext[1].children()[0][1].children()[0][1]"))
(display st4)(newline) ; (struct () ((decl (array-decl (type-decl (identifier z) (char) #<unspecified>) 5 #<unspecified>) ())))
(define tval4 ((e-st st4 '() #f) jp1 zeta1 rho s))
(display (eqv? (tval->val tval4) st4))(newline) ; #t
(display (apply-env 'struct (tval->rho tval4)))(newline) ; #<unspecified>
(display (apply-env "z" (tval->rho tval4)))(newline)   ; #<unspecified>
(define tval4_1 ((e-st->sz st4) jp1 zeta1 (tval->rho tval4) (tval->s tval4)))
(display (tval->val tval4_1))(newline) ; 5
(newline)

; inline anonymous struct instance
; struct { int i; int j[8]; int k; } aa;
(define st5 (ast->st "t.ext[11].children()[1][1].children()[0][1].children()[0][1].children()[0][1]"))
(display st5)(newline) ; (struct () ((decl (type-decl (identifier i) (int) #<unspecified> #<unspecified>) ()) (decl (array-decl (type-decl (identifier j) (int) #<unspecified>) 8 #<unspecified>) ()) (decl (type-decl (identifier k) (int) #<unspecified> #<unspecified>) ())))
(define tval5 ((e-st st5 "aa" #f) jp1 zeta1 (tval->rho tval3) (tval->s tval3)))
(display (apply-env "aa" (tval->rho tval5)))(newline)   ; 100000
(display (apply-env 'next-l (tval->rho tval5)))(newline)   ; 100010
(display (apply-env "i" (tval->rho tval5)))(newline)   ; #<unspecified>
(display (apply-env "j" (tval->rho tval5)))(newline)   ; #<unspecified>
(display (apply-env "k" (tval->rho tval5)))(newline)   ; #<unspecified>
(define tval5_1 ((e-st->sz st5) jp1 zeta1 (tval->rho tval5) (tval->s tval5)))
(display (tval->val tval5_1))(newline) ; 10
(newline)

; inline struct instance and embedd struct
;         struct _BB { int i; int j[8]; struct _CC { float l; float m; } k; } bb;
;(python-eval "t.ext[11].children()[1][1].children()[1][1].children()[0][1].children()[0][1].show()")
(define st6 (ast->st "t.ext[11].children()[1][1].children()[1][1].children()[0][1].children()[0][1]"))
(display st6)(newline) ; 
(define tval6 ((e-st st6 "bb" #f) jp1 zeta1 (tval->rho tval3) (tval->s tval3)))
(display (apply-env "bb" (tval->rho tval6)))(newline)   ; 100000
(display (apply-env 'next-l (tval->rho tval6)))(newline)   ; 100011
(display (apply-env "i" (tval->rho tval6)))(newline)   ; #<unspecified>
(display (apply-env "j" (tval->rho tval6)))(newline)   ; #<unspecified>
(display (apply-env "l" (tval->rho tval6)))(newline)   ; #<unspecified>
(display (apply-env "m" (tval->rho tval6)))(newline)   ; #<unspecified>
(display (apply-env "k" (tval->rho tval6)))(newline)   ; #<unspecified>
(define tval6_1 ((e-st->sz st6) jp1 zeta1 rho s))
(display (tval->val tval6_1))(newline) ; 11
(define tval6_2 ((e-get-struct "_BB") jp1 zeta1 (tval->rho tval6) (tval->s tval6)))
(display (eqv? (tval->val tval6_2) st6))(newline) ; #t
(define tval6_3 ((e-get-struct "_CC") jp1 zeta1 (tval->rho tval6) (tval->s tval6)))
(define tval6_4 ((e-st->sz (tval->val tval6_3)) jp1 zeta1 (tval->rho tval6) (tval->s tval6)))
(display (tval->val tval6_4))(newline) ; 2
(newline)

;         struct _DD { int o; int p[8]; struct { float r; struct _EE { char t; } s; } q; } dd;
;(python-eval "t.ext[11].children()[1][1].children()[2][1].children()[0][1].children()[0][1].show()")
(define st7 (ast->st "t.ext[11].children()[1][1].children()[2][1].children()[0][1].children()[0][1]"))
(display st7)(newline) ; 
(define tval7 ((e-st st7 "dd" #f) jp1 zeta1 (tval->rho tval3) (tval->s tval3)))
(display (apply-env "dd" (tval->rho tval7)))(newline)   ; 100000
(display (apply-env 'next-l (tval->rho tval7)))(newline)   ; 100011
(display (apply-env "o" (tval->rho tval6)))(newline)   ; #<unspecified>
(display (apply-env "p" (tval->rho tval6)))(newline)   ; #<unspecified>
(display (apply-env "q" (tval->rho tval6)))(newline)   ; #<unspecified>
(display (apply-env "r" (tval->rho tval6)))(newline)   ; #<unspecified>
(display (apply-env "s" (tval->rho tval6)))(newline)   ; #<unspecified>
(display (apply-env "t" (tval->rho tval6)))(newline)   ; #<unspecified>
(define tval7_1 ((e-st->sz st7) jp1 zeta1 rho s))
(display (tval->val tval7_1))(newline) ; 11
(define tval7_2 ((e-get-struct "_DD") jp1 zeta1 (tval->rho tval7) (tval->s tval7)))
(display (eqv? (tval->val tval7_2) st7))(newline) ; #t
(define tval7_3 ((e-get-struct "_EE") jp1 zeta1 (tval->rho tval7) (tval->s tval7)))
(define tval7_4 ((e-st->sz (tval->val tval7_3)) jp1 zeta1 (tval->rho tval7) (tval->s tval7)))
(display (tval->val tval7_4))(newline) ; 1
(newline)

;         struct _A a;
;(python-eval "t.ext[11].children()[1][1].children()[3][1].children()[0][1].children()[0][1].show()")
(define st8 (ast->st "t.ext[11].children()[1][1].children()[3][1].children()[0][1].children()[0][1]"))
(display st8)(newline) ; 
(define tval8 ((e-st st8 "a" #f) jp1 zeta1 (tval->rho tval3) (tval->s tval3)))
(display (apply-env "a" (tval->rho tval8)))(newline)   ; 100000
(display (apply-env 'next-l (tval->rho tval8)))(newline)   ; 100002
(display (apply-env "i" (tval->rho tval8)))(newline)   ; #<unspecified>
(display (apply-env "j" (tval->rho tval8)))(newline)   ; #<unspecified>
(define tval8_1 ((e-st->sz st8) jp1 zeta1 (tval->rho tval8) (tval->s tval8)))
(display (tval->val tval8_1))(newline) ; 2
(newline)

;      typedef {{ struct _E { char x[5]; struct _C { int k; int l; } c; int m; struct { int n; int o; } d; int p; } }} E;
(define st9 (ast->st "t.ext[2].children()[0][1].children()[0][1]"))
(display st9)(newline)
(define tval9 ((e-st st9 '() #f) jp1 zeta1 (tval->rho tval3) (tval->s tval3)))
(define tval9_1 ((e-get-struct "_E") jp1 zeta1 (tval->rho tval9) (tval->s tval9)))
(display (eqv? (tval->val tval9_1) st9))(newline) ; #t
(define tval9_2 ((e-st->sz st9) jp1 zeta1 (tval->rho tval9) (tval->s tval9)))
(display (tval->val tval9_2))(newline) ; 11
(newline)


; Ensure declaration of struct in function definition and call...

(load "../c-FuncDef.scm")
(load "../c-Statement.scm")

;      void func1( struct _A a ) {}
(define f10 (ast->F "t.ext[3]"))
(display f10)(newline)
(define tval10 ((e-F f10) jp1 zeta1 (tval->rho tval8) (tval->s tval8)))
(display (apply-env "func1" (tval->rho tval10)))(newline) ; 0
(display (apply-env 'fnext-l (tval->rho tval10)))(newline) ; 1
;         func1( a );
;(python-eval "t.ext[11].children()[1][1].children()[22][1].show()")
(define fc11 (ast->fc "t.ext[11].children()[1][1].children()[22][1]"))
(display fc11)(newline)
(define tval11 ((e-fc fc11) jp1 zeta1 (tval->rho tval10) (tval->s tval10)))
(display (tval->val tval11))(newline) ; 1
(newline)

;      void func2( struct _A* a ) {}
(define f12 (ast->F "t.ext[4]"))
(display f12)(newline)
(define tval12 ((e-F f12) jp1 zeta1 (tval->rho tval8) (tval->s tval8)))
(display (apply-env "func2" (tval->rho tval12)))(newline) ; 0
(display (apply-env 'fnext-l (tval->rho tval12)))(newline) ; 1
;         func2( &a );
;(python-eval "t.ext[11].children()[1][1].children()[23][1].show()")
(define fc13 (ast->fc "t.ext[11].children()[1][1].children()[23][1]"))
(display fc13)(newline)
(define tval13 ((e-fc fc13) jp1 zeta1 (tval->rho tval12) (tval->s tval12)))
(display (tval->val tval13))(newline) ; 1
(newline)


