(load "../c-StructRef.scm")
 (load "../c-Declaration.scm")
 (load "../c-all-expressions.scm")
 (load "../c-Statement.scm")
 (load "../c-Typedef.scm")

(define sr1 (make-.-sr (make-id "a") (make-id "b")))
(display sr1) (newline)
(display (sr? sr1)) (newline) ; #t
(display (.-sr? sr1)) (newline) ; #t
(display (->-sr? sr1)) (newline) ; #f
(display (sr->mr_st sr1)) (newline) ; (identifier a)
(display (sr->id_m sr1)) (newline) ; (identifier b)
(newline)

(define sr2 (make-->-sr (make-id "a") (make-id "b")))
(display sr2) (newline)
(display (sr? sr2)) (newline) ; #t
(display (.-sr? sr2)) (newline) ; #f
(display (->-sr? sr2)) (newline) ; #t
(display (sr->mr_st sr2)) (newline) ; (identifier a)
(display (sr->id_m sr2)) (newline) ; (identifier b)
(newline)


(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())

(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-struct.py' )")
(python-eval "t = pyc.main_eg()")

; Test "." ...

;      struct _A { int i; int j; };
(define D1 (ast->D "t.ext[0]"))
(define tval1 ((e-D D1 #f) jp1 zeta1 rho s))
;         struct _A a;
(define D2 (ast->D "t.ext[11].children()[1][1].children()[3][1]"))
(define tval2 ((e-D D2 #f) jp1 zeta1 (tval->rho tval1) (tval->s tval1)))
(display (apply-env "a" (tval->rho tval2)))(newline)   ; 100000
(display (apply-env 'next-l (tval->rho tval2)))(newline)   ; 100002
(display (apply-s 100000 (tval->s tval2)))(newline)   ; '()
(display (apply-s 100001 (tval->s tval2)))(newline)   ; '()
(newline)

;         a.i = 2;
;(python-eval "t.ext[11].children()[1][1].children()[9][1].show()")
(define S3 (ast->S "t.ext[11].children()[1][1].children()[9][1]"))
(display S3)(newline)
(define tval3 ((e-S S3) jp1 zeta1 (tval->rho tval2) (tval->s tval2)))
(display (apply-s 100000 (tval->s tval3)))(newline)   ; 2
(display (apply-s 100001 (tval->s tval3)))(newline)   ; '()
(newline)

;         a.j = a.i * 3;
;(python-eval "t.ext[11].children()[1][1].children()[10][1].show()")
(define S4 (ast->S "t.ext[11].children()[1][1].children()[10][1]"))
(display S4)(newline)
(define tval4 ((e-S S4) jp1 zeta1 (tval->rho tval3) (tval->s tval3)))
(display (apply-s 100000 (tval->s tval4)))(newline)   ; 2
(display (apply-s 100001 (tval->s tval4)))(newline)   ; 6


; Test arrays in struct

;typedef struct { char z[5]; } B;
(define ty5 (ast->ty "t.ext[1]"))
(define tval5 ((e-ty ty5) jp1 zeta1 rho s))

; B b;
(define D6 (ast->D "t.ext[11].children()[1][1].children()[4][1]"))
(define tval6 ((e-D D6 #f) jp1 zeta1 (tval->rho tval5) (tval->s tval5)))
(display (apply-env "b" (tval->rho tval6)))(newline)   ; 100000
(display (apply-env 'next-l (tval->rho tval6)))(newline)   ; 100005
(display (apply-s 100000 (tval->s tval6)))(newline)   ; '()
(display (apply-s 100001 (tval->s tval6)))(newline)   ; '()
(display (apply-s 100002 (tval->s tval6)))(newline)   ; '()
(display (apply-s 100003 (tval->s tval6)))(newline)   ; '()
(display (apply-s 100004 (tval->s tval6)))(newline)   ; '()

;         {{ b.z }} [0] = 'a';
;(python-eval "t.ext[11].children()[1][1].children()[11][1].children()[0][1].children()[0][1].show()")
(define tmp1 (ast->sr "t.ext[11].children()[1][1].children()[11][1].children()[0][1].children()[0][1]"))
(display tmp1)(newline)
(define tmp2 ((e-sr tmp1) jp1 zeta1 (tval->rho tval6) (tval->s tval6)))
(display (tval->val tmp2))(newline)  ; effectively "b.z"  = 100000
(define tmp3 ((e-sr-lhs tmp1 7) jp1 zeta1 (tval->rho tval6) (tval->s tval6)))
(display (tval->val tmp3))(newline)  ; effectively "b.z =" =  #<unspecified>
(display (apply-s 100000 (tval->s tmp3)))(newline)   ; '()     i.e. untouched
(newline)

;         b.z[0] = 'a';
;(python-eval "t.ext[11].children()[1][1].children()[11][1].show()")
(define S8 (ast->S "t.ext[11].children()[1][1].children()[11][1]"))
(display S8)(newline)
(define tval8 ((e-S S8) jp1 zeta1 (tval->rho tval6) (tval->s tval6)))
(display (apply-s 100000 (tval->s tval8)))(newline)   ; a
(display (apply-s 100001 (tval->s tval8)))(newline)   ; '()
(display (apply-s 100002 (tval->s tval8)))(newline)   ; '()
(display (apply-s 100003 (tval->s tval8)))(newline)   ; '()
(display (apply-s 100004 (tval->s tval8)))(newline)   ; '()
(newline)

;         b.z[4] = b.z[0] + 1;
;(python-eval "t.ext[11].children()[1][1].children()[12][1].show()")
(define S9 (ast->S "t.ext[11].children()[1][1].children()[12][1]"))
(display S9)(newline)
(define tval9 ((e-S S9) jp1 zeta1 (tval->rho tval8) (tval->s tval8)))
(display (apply-s 100000 (tval->s tval9)))(newline)   ; a
(display (apply-s 100001 (tval->s tval9)))(newline)   ; '()
(display (apply-s 100002 (tval->s tval9)))(newline)   ; '()
(display (apply-s 100003 (tval->s tval9)))(newline)   ; '()
(display (apply-s 100004 (tval->s tval9)))(newline)   ; b
(newline)


; Test "->" ...

;typedef struct { char x[5]; struct _C { int k; int l; } c; int m; struct { int n; int o; } d; int p; } E;
(define ty10 (ast->ty "t.ext[2]"))
(define tval10 ((e-ty ty10) jp1 zeta1 rho s))


; E eTmp;
;(python-eval "t.ext[11].children()[1][1].children()[6][1].show()")
(define D11 (ast->D "t.ext[11].children()[1][1].children()[6][1]"))
(define tval11 ((e-D D11 #f) jp1 zeta1 (tval->rho tval10) (tval->s tval10)))
(display (apply-env "eTmp" (tval->rho tval11)))(newline)   ; 100000   TODO.... getting wrong answer!!!
(display (apply-env 'next-l (tval->rho tval11)))(newline)   ; 100011
(display (apply-s 100000 (tval->s tval11)))(newline)   ; '()
(display (apply-s 100001 (tval->s tval11)))(newline)   ; '()
(display (apply-s 100002 (tval->s tval11)))(newline)   ; '()
(display (apply-s 100003 (tval->s tval11)))(newline)   ; '()
(display (apply-s 100004 (tval->s tval11)))(newline)   ; '()
(display (apply-s 100005 (tval->s tval11)))(newline)   ; '()
(display (apply-s 100006 (tval->s tval11)))(newline)   ; '()
(display (apply-s 100007 (tval->s tval11)))(newline)   ; '()
(display (apply-s 100008 (tval->s tval11)))(newline)   ; '()
(display (apply-s 100009 (tval->s tval11)))(newline)   ; '()
(display (apply-s 100010 (tval->s tval11)))(newline)   ; '()
; E* e = &eTmp;
(define D12 (ast->D "t.ext[11].children()[1][1].children()[7][1]"))
(define tval12 ((e-D D12 #f) jp1 zeta1 (tval->rho tval11) (tval->s tval11)))
(display (apply-env "e" (tval->rho tval12)))(newline)   ; 100011
(display (apply-env 'next-l (tval->rho tval12)))(newline)   ; 100012
(display (apply-s 100011 (tval->s tval12)))(newline)   ; 100000


;         e->m = 11;
;(python-eval "t.ext[11].children()[1][1].children()[13][1].show()")
(define S13 (ast->S "t.ext[11].children()[1][1].children()[13][1]"))
(display S13)(newline)
(define tval13 ((e-S S13) jp1 zeta1 (tval->rho tval12) (tval->s tval12)))
(display (apply-s 100000 (tval->s tval13)))(newline)   ; '()
(display (apply-s 100001 (tval->s tval13)))(newline)   ; '()
(display (apply-s 100002 (tval->s tval13)))(newline)   ; '()
(display (apply-s 100003 (tval->s tval13)))(newline)   ; '()
(display (apply-s 100004 (tval->s tval13)))(newline)   ; '()
(display (apply-s 100005 (tval->s tval13)))(newline)   ; '()
(display (apply-s 100006 (tval->s tval13)))(newline)   ; '()
(display (apply-s 100007 (tval->s tval13)))(newline)   ; 11
(display (apply-s 100008 (tval->s tval13)))(newline)   ; '()
(display (apply-s 100009 (tval->s tval13)))(newline)   ; '()
(display (apply-s 100010 (tval->s tval13)))(newline)   ; '()
(display (apply-s 100011 (tval->s tval13)))(newline)   ; 100000
(newline)

;         e->p = e->m * 2;
;(python-eval "t.ext[11].children()[1][1].children()[14][1].show()")
(define S14 (ast->S "t.ext[11].children()[1][1].children()[14][1]"))
(display S14)(newline)
(define tval14 ((e-S S14) jp1 zeta1 (tval->rho tval13) (tval->s tval13)))
(display (apply-s 100000 (tval->s tval14)))(newline)   ; '()
(display (apply-s 100001 (tval->s tval14)))(newline)   ; '()
(display (apply-s 100002 (tval->s tval14)))(newline)   ; '()
(display (apply-s 100003 (tval->s tval14)))(newline)   ; '()
(display (apply-s 100004 (tval->s tval14)))(newline)   ; '()
(display (apply-s 100005 (tval->s tval14)))(newline)   ; '()
(display (apply-s 100006 (tval->s tval14)))(newline)   ; '()
(display (apply-s 100007 (tval->s tval14)))(newline)   ; 11
(display (apply-s 100008 (tval->s tval14)))(newline)   ; '()
(display (apply-s 100009 (tval->s tval14)))(newline)   ; '()
(display (apply-s 100010 (tval->s tval14)))(newline)   ; 22
(display (apply-s 100011 (tval->s tval14)))(newline)   ; 100000
(newline)

;         e->x[0] = 'b';
;(python-eval "t.ext[11].children()[1][1].children()[15][1].show()")
(define S15 (ast->S "t.ext[11].children()[1][1].children()[15][1]"))
(display S15)(newline)
(define tval15 ((e-S S15) jp1 zeta1 (tval->rho tval14) (tval->s tval14)))
(display (apply-s 100000 (tval->s tval15)))(newline)   ; b
(display (apply-s 100001 (tval->s tval15)))(newline)   ; '()
(display (apply-s 100002 (tval->s tval15)))(newline)   ; '()
(display (apply-s 100003 (tval->s tval15)))(newline)   ; '()
(display (apply-s 100004 (tval->s tval15)))(newline)   ; '()
(display (apply-s 100005 (tval->s tval15)))(newline)   ; '()
(display (apply-s 100006 (tval->s tval15)))(newline)   ; '()
(display (apply-s 100007 (tval->s tval15)))(newline)   ; 11
(display (apply-s 100008 (tval->s tval15)))(newline)   ; '()
(display (apply-s 100009 (tval->s tval15)))(newline)   ; '()
(display (apply-s 100010 (tval->s tval15)))(newline)   ; 22
(display (apply-s 100011 (tval->s tval15)))(newline)   ; 100000
(newline)

;         e->x[4] = e->x[0] + 1;
;(python-eval "t.ext[11].children()[1][1].children()[16][1].show()")
(define S16 (ast->S "t.ext[11].children()[1][1].children()[16][1]"))
(display S16)(newline)
(define tval16 ((e-S S16) jp1 zeta1 (tval->rho tval15) (tval->s tval15)))
(display (apply-s 100000 (tval->s tval16)))(newline)   ; b
(display (apply-s 100001 (tval->s tval16)))(newline)   ; '()
(display (apply-s 100002 (tval->s tval16)))(newline)   ; '()
(display (apply-s 100003 (tval->s tval16)))(newline)   ; '()
(display (apply-s 100004 (tval->s tval16)))(newline)   ; c
(display (apply-s 100005 (tval->s tval16)))(newline)   ; '()
(display (apply-s 100006 (tval->s tval16)))(newline)   ; '()
(display (apply-s 100007 (tval->s tval16)))(newline)   ; 11
(display (apply-s 100008 (tval->s tval16)))(newline)   ; '()
(display (apply-s 100009 (tval->s tval16)))(newline)   ; '()
(display (apply-s 100010 (tval->s tval16)))(newline)   ; 22
(display (apply-s 100011 (tval->s tval16)))(newline)   ; 100000
(newline)

;         e->c.k = 5;
;(python-eval "t.ext[11].children()[1][1].children()[17][1].show()")
(define S17 (ast->S "t.ext[11].children()[1][1].children()[17][1]"))
(display S17)(newline)
(define tval17 ((e-S S17) jp1 zeta1 (tval->rho tval16) (tval->s tval16)))
(display (apply-s 100000 (tval->s tval17)))(newline)   ; b
(display (apply-s 100001 (tval->s tval17)))(newline)   ; '()
(display (apply-s 100002 (tval->s tval17)))(newline)   ; '()
(display (apply-s 100003 (tval->s tval17)))(newline)   ; '()
(display (apply-s 100004 (tval->s tval17)))(newline)   ; c
(display (apply-s 100005 (tval->s tval17)))(newline)   ; 5
(display (apply-s 100006 (tval->s tval17)))(newline)   ; '()
(display (apply-s 100007 (tval->s tval17)))(newline)   ; 11
(display (apply-s 100008 (tval->s tval17)))(newline)   ; '()
(display (apply-s 100009 (tval->s tval17)))(newline)   ; '()
(display (apply-s 100010 (tval->s tval17)))(newline)   ; 22
(display (apply-s 100011 (tval->s tval17)))(newline)   ; 100000
(newline)

; TODO: rest of "e" tests.

;         e->c.l = e->c.k * 7;
;(python-eval "t.ext[11].children()[1][1].children()[18][1].show()")
(define S18 (ast->S "t.ext[11].children()[1][1].children()[18][1]"))
(display S18)(newline)
(define tval18 ((e-S S18) jp1 zeta1 (tval->rho tval17) (tval->s tval17)))
(display (apply-s 100000 (tval->s tval18)))(newline)   ; b
(display (apply-s 100001 (tval->s tval18)))(newline)   ; '()
(display (apply-s 100002 (tval->s tval18)))(newline)   ; '()
(display (apply-s 100003 (tval->s tval18)))(newline)   ; '()
(display (apply-s 100004 (tval->s tval18)))(newline)   ; c
(display (apply-s 100005 (tval->s tval18)))(newline)   ; 5
(display (apply-s 100006 (tval->s tval18)))(newline)   ; 35
(display (apply-s 100007 (tval->s tval18)))(newline)   ; 11
(display (apply-s 100008 (tval->s tval18)))(newline)   ; '()
(display (apply-s 100009 (tval->s tval18)))(newline)   ; '()
(display (apply-s 100010 (tval->s tval18)))(newline)   ; 22
(display (apply-s 100011 (tval->s tval18)))(newline)   ; 100000
(newline)

;         e->d.n = 13;
;(python-eval "t.ext[11].children()[1][1].children()[19][1].show()")
(define S19 (ast->S "t.ext[11].children()[1][1].children()[19][1]"))
(display S19)(newline)
(define tval19 ((e-S S19) jp1 zeta1 (tval->rho tval18) (tval->s tval18)))
(display (apply-s 100000 (tval->s tval19)))(newline)   ; b
(display (apply-s 100001 (tval->s tval19)))(newline)   ; '()
(display (apply-s 100002 (tval->s tval19)))(newline)   ; '()
(display (apply-s 100003 (tval->s tval19)))(newline)   ; '()
(display (apply-s 100004 (tval->s tval19)))(newline)   ; c
(display (apply-s 100005 (tval->s tval19)))(newline)   ; 5
(display (apply-s 100006 (tval->s tval19)))(newline)   ; 35
(display (apply-s 100007 (tval->s tval19)))(newline)   ; 11
(display (apply-s 100008 (tval->s tval19)))(newline)   ; 13
(display (apply-s 100009 (tval->s tval19)))(newline)   ; '()
(display (apply-s 100010 (tval->s tval19)))(newline)   ; 22
(display (apply-s 100011 (tval->s tval19)))(newline)   ; 100000
(newline)

;         e->d.o = e->d.n * 17;
(define S20 (ast->S "t.ext[11].children()[1][1].children()[20][1]"))
(display S20)(newline)
(define tval20 ((e-S S20) jp1 zeta1 (tval->rho tval19) (tval->s tval19)))
(display (apply-s 100000 (tval->s tval20)))(newline)   ; b
(display (apply-s 100001 (tval->s tval20)))(newline)   ; '()
(display (apply-s 100002 (tval->s tval20)))(newline)   ; '()
(display (apply-s 100003 (tval->s tval20)))(newline)   ; '()
(display (apply-s 100004 (tval->s tval20)))(newline)   ; c
(display (apply-s 100005 (tval->s tval20)))(newline)   ; 5
(display (apply-s 100006 (tval->s tval20)))(newline)   ; 35
(display (apply-s 100007 (tval->s tval20)))(newline)   ; 11
(display (apply-s 100008 (tval->s tval20)))(newline)   ; 13
(display (apply-s 100009 (tval->s tval20)))(newline)   ; 221
(display (apply-s 100010 (tval->s tval20)))(newline)   ; 22
(display (apply-s 100011 (tval->s tval20)))(newline)   ; 100000
(newline)


; Ensure declaration of struct in function definition and call...

(load "../c-FuncDef.scm")
(load "../c-Statement.scm")

;      void func3( struct _A a ) { a.i = a.j * 4; }
(define f21 (ast->F "t.ext[5]"))
(display f21)(newline)
(define tval21 ((e-F f21) jp1 zeta1 (tval->rho tval4) (tval->s tval4)))
(display (apply-env "func3" (tval->rho tval21)))(newline) ; 0
(display (apply-env 'fnext-l (tval->rho tval21)))(newline) ; 1
;         func3( a );
;(python-eval "t.ext[11].children()[1][1].children()[24][1].show()")
(define fc22 (ast->fc "t.ext[11].children()[1][1].children()[24][1]"))
(display fc22)(newline)
(define tval22 ((e-fc fc22) jp1 zeta1 (tval->rho tval21) (tval->s tval21)))
(display (apply-s 100000 (tval->s tval22)))(newline)   ; 24
(display (apply-s 100001 (tval->s tval22)))(newline)   ; 6
(newline)

;      void func4( struct _A* a ) { a->j = a->i * 5; }
(define f23 (ast->F "t.ext[6]"))
(display f23)(newline)
(define tval23 ((e-F f23) jp1 zeta1 (tval->rho tval22) (tval->s tval22)))
(display (apply-env "func4" (tval->rho tval23)))(newline) ; 1
(display (apply-env 'fnext-l (tval->rho tval23)))(newline) ; 2
;         func4( &a );
;(python-eval "t.ext[11].children()[1][1].children()[25][1].show()")
(define fc24 (ast->fc "t.ext[11].children()[1][1].children()[25][1]"))
(display fc24)(newline)
(define tval24 ((e-fc fc24) jp1 zeta1 (tval->rho tval23) (tval->s tval23)))
(display (apply-s 100000 (tval->s tval24)))(newline)   ; 24
(display (apply-s 100001 (tval->s tval24)))(newline)   ; 120
(newline)


;      void func7( B b ) { b.z[1] = b.z[4] + 2; }
(define f25 (ast->F "t.ext[9]"))
(display f25)(newline)
(define tval25 ((e-F f25) jp1 zeta1 (tval->rho tval9) (tval->s tval9)))
(display (apply-env "func7" (tval->rho tval25)))(newline) ; 0
(display (apply-env 'fnext-l (tval->rho tval25)))(newline) ; 1
;         func7( a );
;(python-eval "t.ext[11].children()[1][1].children()[24][1].show()")
(define fc26 (ast->fc "t.ext[11].children()[1][1].children()[28][1]"))
(display fc26)(newline)
(define tval26 ((e-fc fc26) jp1 zeta1 (tval->rho tval25) (tval->s tval25)))
(display (apply-s 100000 (tval->s tval26)))(newline)   ; a
(display (apply-s 100001 (tval->s tval26)))(newline)   ; d
(display (apply-s 100002 (tval->s tval26)))(newline)   ; '()
(display (apply-s 100003 (tval->s tval26)))(newline)   ; '()
(display (apply-s 100004 (tval->s tval26)))(newline)   ; b
(newline)

;      void func8( B* b ) { b->z[2] = b->z[1] + 3; }
(define f27 (ast->F "t.ext[10]"))
(display f27)(newline)
(define tval27 ((e-F f27) jp1 zeta1 (tval->rho tval26) (tval->s tval26)))
(display (apply-env "func8" (tval->rho tval27)))(newline) ; 1
(display (apply-env 'fnext-l (tval->rho tval27)))(newline) ; 2
;         func8( &a );
;(python-eval "t.ext[11].children()[1][1].children()[25][1].show()")
(define fc28 (ast->fc "t.ext[11].children()[1][1].children()[29][1]"))
(display fc28)(newline)
(define tval28 ((e-fc fc28) jp1 zeta1 (tval->rho tval27) (tval->s tval27)))
(display (apply-s 100000 (tval->s tval28)))(newline)   ; a
(display (apply-s 100001 (tval->s tval28)))(newline)   ; d
(display (apply-s 100002 (tval->s tval28)))(newline)   ; g
(display (apply-s 100003 (tval->s tval28)))(newline)   ; '()
(display (apply-s 100004 (tval->s tval28)))(newline)   ; b
(newline)


