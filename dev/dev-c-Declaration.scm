(load "../c-Declaration.scm")
(load "../c-all-expressions.scm")

(define td1 (make-it-td (make-id "test") (make-single-it 'int)))
(define co1 (make-co (make-single-it 'int) 1))
(define D1 (make-od-Eel-D td1 co1))
(display D1)(newline) ; (decl (type-decl (identifier test) (int)) (constant (int) 1))
(display (D? D1))(newline) ; #t
(display (D-init? D1))(newline) ; #t
(display (D->kind D1))(newline) ; decl
(display (D->dd D1))(newline) ; (type-decl (identifier test) (int))
(display (D->Eel D1))(newline) ; (constant (int) 1)

(define D2 (make-od-D td1))
(display D2)(newline) ; (decl (type-decl (identifier test) (int)) ())
(display (D? D2))(newline) ; #t
(display (D-init? D2))(newline) ; #f
(display (D->kind D2))(newline) ; decl
(display (D->dd D2))(newline) ; (type-decl (identifier test) (int))
(display (D->Eel D2))(newline) ; #<unspecified>

(define ad1 (make-ad-c td1 2))
(define  co2 (make-co (make-single-it 'signed) 1))
(define  co3 (make-co (make-single-it 'long) 2))
(define  el1 (make-el (list co2 co3)))
(define D3 (make-od-Eel-D ad1 el1))
(display D3)(newline) ; (decl (array-decl (type-decl (identifier test) (int)) 2) (exprlist ((constant (signed) 1) (constant (long) 2))))
(display (D? D3))(newline) ; #t
(display (D-init? D3))(newline) ; #t
(display (D->kind D3))(newline) ; decl
(display (D->dd D3))(newline) ; (array-decl (type-decl (identifier test) (int)) 2)
(display (D->Eel D3))(newline) ; (exprlist ((constant (signed) 1) (constant (long) 2)))

(define td2 (make-it-td (make-id "argc") (make-single-it 'int)))
(define od1 (make-td-od td2 (display "")))
(define dd1a (make-od-dd od1))
(define  D4 (make-od-D dd1a))
(define pl1 (make-pl (list D4)))
(define td3 (make-it-td (make-id "main") (make-single-it 'int)))
(define od4 (make-td-od td3 (display "")))
(define fd1 (make-fd pl1 od4))
(define  D4 (make-fd-D fd1))
(display D4)(newline) ; (decl (func-decl (paramlist ((decl (type-decl (identifier argc) (int) #<unspecified>) ()))) (type-decl (identifier main) (int) #<unspecified>)) ())
(display (D? D4))(newline) ; #t
(display (D-init? D4))(newline) ; #f
(display (D->kind D4))(newline) ; decl
(display (D->dd D4))(newline) ; (func-decl (paramlist ((decl (type-decl (identifier argc) (int) #<unspecified>) ()))) (type-decl (identifier main) (int) #<unspecified>))
(display (D->Eel D4))(newline) ; #<unspecified>


(define jp1 '())
(define zeta1 '())

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(python-eval "import imp")

; Primitive types...
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-type-specifier.py' )")
(python-eval "t = pyc.main_eg()")

;  No initiatliser...
(define tval14 ((ast->e-od-D "t.ext[14]") jp1 zeta1 (car rho,s)         (cadr rho,s)))
(define tval15 ((ast->e-od-D "t.ext[15]") jp1 zeta1 (tval->rho tval14) (tval->s tval14)))
(define tval16 ((ast->e-od-D "t.ext[16]") jp1 zeta1 (tval->rho tval15) (tval->s tval15)))
(define tval17 ((ast->e-od-D "t.ext[17]") jp1 zeta1 (tval->rho tval16) (tval->s tval16)))
(define tval18 ((ast->e-od-D "t.ext[18]") jp1 zeta1 (tval->rho tval17) (tval->s tval17)))
(define tval19 ((ast->e-od-D "t.ext[19]") jp1 zeta1 (tval->rho tval18) (tval->s tval18)))
(define tval20 ((ast->e-od-D "t.ext[20]") jp1 zeta1 (tval->rho tval19) (tval->s tval19)))
(define tval21 ((ast->e-od-D "t.ext[21]") jp1 zeta1 (tval->rho tval20) (tval->s tval20)))
;(define tval22 ((ast->e-od-D "t.ext[22]") jp1 zeta1 (tval->rho tval21) (tval->s tval21))) ; signed-/unsigned- char not supported by pycparser
;(define tval23 ((ast->e-od-D "t.ext[23]") jp1 zeta1 (tval->rho tval22) (tval->s tval22))) ; signed-/unsigned- char not supported by pycparser
(define tval23 tval21)
(define tval24 ((ast->e-od-D "t.ext[24]") jp1 zeta1 (tval->rho tval23) (tval->s tval23)))
(define tval25 ((ast->e-od-D "t.ext[25]") jp1 zeta1 (tval->rho tval24) (tval->s tval24)))
(define tval26 ((ast->e-od-D "t.ext[26]") jp1 zeta1 (tval->rho tval25) (tval->s tval25)))
(define tval27 ((ast->e-od-D "t.ext[27]") jp1 zeta1 (tval->rho tval26) (tval->s tval26)))

(display tval14)(newline)
(display tval15)(newline)
(display tval16)(newline)
(display tval17)(newline)
(display tval18)(newline)
(display tval19)(newline)
(display tval20)(newline)
(display tval21)(newline)
;(display tval22)(newline) ; signed-/unsigned- char not supported by pycparser
;(display tval23)(newline) ; signed-/unsigned- char not supported by pycparser
(display tval24)(newline)
(display tval25)(newline)
(display tval26)(newline)
(display tval27)(newline)
(newline)

;  With initailiser...
(define tval00 ((ast->e-od-Eel-D "t.ext[00]") jp1 zeta1 (car rho,s)        (cadr rho,s)))
(define tval01 ((ast->e-od-Eel-D "t.ext[01]") jp1 zeta1 (tval->rho tval00) (tval->s tval00)))
(define tval02 ((ast->e-od-Eel-D "t.ext[02]") jp1 zeta1 (tval->rho tval01) (tval->s tval01)))
(define tval03 ((ast->e-od-Eel-D "t.ext[03]") jp1 zeta1 (tval->rho tval02) (tval->s tval02)))
(define tval04 ((ast->e-od-Eel-D "t.ext[04]") jp1 zeta1 (tval->rho tval03) (tval->s tval03)))
(define tval05 ((ast->e-od-Eel-D "t.ext[05]") jp1 zeta1 (tval->rho tval04) (tval->s tval04)))
(define tval06 ((ast->e-od-Eel-D "t.ext[06]") jp1 zeta1 (tval->rho tval05) (tval->s tval05)))
(define tval07 ((ast->e-od-Eel-D "t.ext[07]") jp1 zeta1 (tval->rho tval06) (tval->s tval06)))
;(define tval08 ((ast->e-od-Eel-D "t.ext[08]") jp1 zeta1 (tval->rho tval07) (tval->s tval07))) ; signed-/unsigned- char not supported by pycparser
;(define tval09 ((ast->e-od-Eel-D "t.ext[09]") jp1 zeta1 (tval->rho tval08) (tval->s tval08))) ; signed-/unsigned- char not supported by pycparser
(define tval09 tval07)
(define tval10 ((ast->e-od-Eel-D "t.ext[10]") jp1 zeta1 (tval->rho tval09) (tval->s tval09)))
(define tval11 ((ast->e-od-Eel-D "t.ext[11]") jp1 zeta1 (tval->rho tval10) (tval->s tval10)))
(define tval12 ((ast->e-od-Eel-D "t.ext[12]") jp1 zeta1 (tval->rho tval11) (tval->s tval11)))
(define tval13 ((ast->e-od-Eel-D "t.ext[13]") jp1 zeta1 (tval->rho tval12) (tval->s tval12)))

(display tval00)(newline)
(display tval01)(newline)
(display tval02)(newline)
(display tval03)(newline)
(display tval04)(newline)
(display tval05)(newline)
(display tval06)(newline)
(display tval07)(newline)
;(display tval08)(newline) ; signed-/unsigned- char not supported by pycparser
;(display tval09)(newline) ; signed-/unsigned- char not supported by pycparser
(display tval10)(newline)
(display tval11)(newline)
(display tval12)(newline)
(display tval13)(newline)
(newline)

; Pointers...
(python-eval "pyc2 = imp.load_source( 'test_pycparser', 't/scripts/test-c-pointer.py' )")
(python-eval "t2 = pyc2.main_eg()")
(define tval2_0 ((ast->e-D "t2.ext[0]") jp1 zeta1 (car rho,s) (cadr rho,s)))

;  No initiatliser...
(define tval2_2 ((ast->e-od-D "t2.ext[2]") jp1 zeta1 (tval->rho tval2_0) (tval->s tval2_0)))
(display tval2_2)(newline)
(newline)

;  With initailiser...
(define tval2_1 ((ast->e-od-Eel-D "t2.ext[1]") jp1 zeta1 (tval->rho tval2_2) (tval->s tval2_2)))
(display "*** \"")(display tval2_1)(newline)
(newline)


; Ensure DeclApply[[D]] works...
(define tval3_0 ((ast->e-D "t.ext[14]") jp1 zeta1 (car rho,s) (cadr rho,s)))
(define tval3_1 ((ast->e-D "t.ext[00]") jp1 zeta1 (tval->rho tval3_0) (tval->s tval3_0)))
(define tval3_2 ((ast->e-D "t2.ext[0]") jp1 zeta1 (tval->rho tval3_1) (tval->s tval3_1)))
(define tval3_3 ((ast->e-D "t2.ext[1]") jp1 zeta1 (tval->rho tval3_2) (tval->s tval3_2)))
(define tval3_4 ((ast->e-D "t2.ext[2]") jp1 zeta1 (tval->rho tval3_3) (tval->s tval3_3)))
(display tval3_0)(newline)
(display tval3_1)(newline)
(display tval3_3)(newline)
(display tval3_4)(newline)
(newline)

; Ensure deref works
(display "Dref of \"p\" is \"")(display (deref "p" (tval->rho tval13) (tval->s tval13)))(newline)
(display "Dref of pointer \"b\" is \"")(display (deref "b" (tval->rho tval2_1) (tval->s tval2_1)))(newline)
(newline)


; Arrays
(python-eval "pyc3 = imp.load_source( 'test_ad', 't/scripts/test-c-array.py' )")
(python-eval "t3 = pyc3.main_eg()")

(define D5 (ast->D "t3.ext[0]"))
(display D5)(newline) ; (decl (array-decl (type-decl (identifier a) (int)) 5 #<unspecified>) ()) (constant (int) 2))))
(display (D? D5))(newline) ; #t
(display (D-init? D5))(newline) ; #f
(define tval5 ((e-D D5 #f) jp1 zeta1 rho s))
(display (tval->rho tval5))(newline) ; (extend-env a 100000 (extend-env next-l 100005 (extend-env ...
(display (tval->s   tval5))(newline) ; (extend-s 100004 () (extend-s 100003 () (extend-s 100002 () (extend-s 100001 () (extend-s 100000 () (empty-s))))))
(newline)

(define D6 (ast->D "t3.ext[1]"))
(display D6)(newline) ; (decl (array-decl (type-decl (identifier b) (int)) () #<unspecified>) (exprlist ((constant (int) 1) (constant (int) 2))))
(display (D? D6))(newline) ; #t
(display (D-init? D6))(newline) ; #t
(define tval6 ((e-D D6 #f) jp1 zeta1 rho s))
(display (tval->rho tval6))(newline) ; (extend-env b 100000 (extend-env next-l 100002 (extend-env ...
(display (tval->s   tval6))(newline) ; (extend-s 100001 2 (extend-s 100000 1 (empty-s)))
(newline)

(define D7 (ast->D "t3.ext[2]"))
(display D7)(newline) ; (decl (array-decl (type-decl (identifier c) (char)) () #<unspecified>) (exprlist ((constant (char) a) (constant (char) b) (constant (char) c) (constant (char) d) (constant (char) e) (constant (char) f) (constant (char) ))))
(display (D? D7))(newline) ; #t
(display (D-init? D7))(newline) ; #t
(define tval7 ((e-D D7 #f) jp1 zeta1 rho s))
(display (tval->rho tval7))(newline) ; (extend-env c 100000 (extend-env next-l 100007 (extend-env ...
(display (tval->s   tval7))(newline) ; (extend-s 100006  (extend-s 100005 f (extend-s 100004 e (extend-s 100003 d (extend-s 100002 c (extend-s 100001 b (extend-s 100000 a (empty-s))))))))
(newline)


; Function declarations...
(python-eval "pyc4 = imp.load_source( 'test_c_func', 't/scripts/test-c-func.py' )")(python-eval "import imp")
(python-eval "t4 = pyc4.main_eg()")

(define D8 (ast->D "t4.ext[1].children()[0][1]"))
(display D8)(newline)
(define tval8_0 ((ast->e-D "t4.ext[1].children()[0][1]") jp1 zeta1 (car rho,s) (cadr rho,s)))
(display tval8_0)(newline)
(display (apply-env 'fnext-l (tval->rho tval8_0))) (newline) ;1


(define D00 (ast->od-Eel-D "t.ext[00]"))
(define D01 (ast->od-Eel-D "t.ext[01]"))
(define D02 (ast->od-Eel-D "t.ext[02]"))
(define D03 (ast->od-Eel-D "t.ext[03]"))
(define D04 (ast->od-Eel-D "t.ext[04]"))
(define D05 (ast->od-Eel-D "t.ext[05]"))
(define D06 (ast->od-Eel-D "t.ext[06]"))
(define D07 (ast->od-Eel-D "t.ext[07]"))
(define D10 (ast->od-Eel-D "t.ext[10]"))
(define D11 (ast->od-Eel-D "t.ext[11]"))
(define D12 (ast->od-Eel-D "t.ext[12]"))
(define D13 (ast->od-Eel-D "t.ext[13]"))
(define D* (list D00 D01 D02 D03 D04 D05 D06 D07 D10 D11 D12 D13))

(define tval9_0 (((e-D* D* (lambda (x) (return-e x)) #f) 0) jp1 zeta1 (car rho,s) (cadr rho,s)))
(display tval9_0)(newline)

;TODO: Struct declarations...


