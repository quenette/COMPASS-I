(load "../c-ArrayDecl.scm")
(load "../c-TypeDecl.scm")
(load "../c-ExprList.scm")
(load "../c-Expression.scm")
(load "../c-all-expressions.scm")

(define td1 (make-it-td (make-id "i") (make-single-it 'int)))
(define ad1 (make-ad td1))
(display ad1)(newline) ; (array-decl (type-decl (identifier i) (int)) ())
(display (ad? ad1))(newline) ; #t
(display (ad-count? ad1))(newline) ; #f
(display (td? (ad->td ad1)))(newline) ; #t
(display (ad->c ad1))(newline) ; #<unspecified>
(newline)

(define ad2 (make-ad-c td1 8))
(display ad2)(newline) ; (array-decl (type-decl (identifier i) (int)) 8)
(display (ad? ad2))(newline) ; #t
(display (ad-count? ad2))(newline) ; #t
(display (td? (ad->td ad2)))(newline) ; #t
(display (ad->c ad2))(newline) ; 8
(newline)


(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-array.py' )")
(python-eval "t = pyc.main_eg()")

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())


;      int a[5];
(define ad3 (ast->ad "t.ext[0].children()[0][1]"))
(display ad3)(newline) ; (array-decl (type-decl (identifier a) (int)) 5)
(display (ad? ad3))(newline) ; #t
(display (ad-count? ad3))(newline) ; #t
(display (td? (ad->td ad3)))(newline) ; #t
(display (ad->c ad3))(newline) ; 5

(define tval3 ((e-ad ad3 '() #f) jp1 zeta1 rho s))
(display (apply-env "a" (tval->rho tval3)))(newline) ; 100000
(display (apply-env 'next-l (tval->rho tval3)))(newline) ; 100005
(display (apply-s 100000 (tval->s tval3)))(newline) ; ()
(display (apply-s 100001 (tval->s tval3)))(newline) ; ()
(display (apply-s 100002 (tval->s tval3)))(newline) ; ()
(display (apply-s 100003 (tval->s tval3)))(newline) ; ()
(display (apply-s 100004 (tval->s tval3)))(newline) ; ()
(display (apply-s 100005 (tval->s tval3)))(newline) ; #<unspecified>
(newline)


;      int b[] = { 1, 2 };
(define ad4 (ast->ad "t.ext[1].children()[0][1]"))
(display ad4)(newline) ; (array-decl (type-decl (identifier b) (char)) ())
(display (ad? ad4))(newline) ; #t
(display (ad-count? ad4))(newline) ; #f
(display (td? (ad->td ad4)))(newline) ; #t
(display (ad->c ad4))(newline) ; #<unspecified>

(define el1 (ast->el "t.ext[1].children()[1][1]"))
(define tval4 ((e-ad ad4 el1 #f) jp1 zeta1 rho s))
(display (apply-env "b" (tval->rho tval4)))(newline) ; 100000
(display (apply-env 'next-l (tval->rho tval4)))(newline) ; 100002
(display (apply-s 100000 (tval->s tval4)))(newline) ; ()
(display (apply-s 100001 (tval->s tval4)))(newline) ; ()
(display (apply-s 100002 (tval->s tval4)))(newline) ; #<unspecified>
(newline)


;      char c[] = "abcdef";
(define ad5 (ast->ad "t.ext[2].children()[0][1]"))
(display ad5)(newline) ; (array-decl (type-decl (identifier c) (char)) ())
(display (ad? ad5))(newline) ; #t
(display (ad-count? ad5))(newline) ; #f
(display (ad->td ad5))(newline) ; (type-decl (identifier c) (int))
(display (ad->c ad5))(newline) ; #<unspecified>

(define el2 (ast->co "t.ext[2].children()[1][1]")) ; yes it maps to an el in this case
(define tval5 ((e-ad ad5 el2 #f) jp1 zeta1 rho s))
(display (apply-env "c" (tval->rho tval5)))(newline) ; 100000
(display (apply-env 'next-l (tval->rho tval5)))(newline) ; 100007
(display (apply-s 100000 (tval->s tval5)))(newline) ; #\a
(display (apply-s 100001 (tval->s tval5)))(newline) ; #\b
(display (apply-s 100002 (tval->s tval5)))(newline) ; #\c
(display (apply-s 100003 (tval->s tval5)))(newline) ; #\d
(display (apply-s 100004 (tval->s tval5)))(newline) ; #\e
(display (apply-s 100005 (tval->s tval5)))(newline) ; #\f
(display (apply-s 100006 (tval->s tval5)))(newline) ; #\0
(display (apply-s 100007 (tval->s tval5)))(newline) ; #<unspecified>
(newline)


;         *b = 7;
(define tval6_1 ((ast->e-D "t.ext[1]") jp1 zeta1 rho s))
(define tval6_2 ((ast->e-E "t.ext[3].children()[1][1].children()[1][1]") jp1 (tval->zeta tval6_1) (tval->rho tval6_1) (tval->s tval6_1)))
(display (tval->val tval6_1))(newline) ; 100000
(display (apply-s 100000 (tval->s tval6_2)))(newline) ; 7
(newline)

