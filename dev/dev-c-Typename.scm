
(load "../c-Typename.scm")
(load "../c-TypeDecl.scm")


(define td1 (make-it-td '() (make-single-it 'int)))
(define tn1 (make-tn td1))
(display tn1)(newline)
(display (tn? tn1))(newline) ; #t
(display (td? (tn->td tn1)))(newline) ; #t
(display (tn->tname tn1))(newline) ; int

(define td2 (make-it-td '() (make-double-it 'unsigned 'long)))
(define tn2 (make-tn td2))
(display tn2)(newline)
(display (tn? tn2))(newline) ; #t
(display (td? (tn->td tn2)))(newline) ; #t
(display (tn->tname tn2))(newline) ; unsigned long

(define td3 (make-it-td '() (make-user-it "testType")))
(define tn3 (make-tn td3))
(display tn3)(newline)
(display (tn? tn3))(newline) ; #t
(display (td? (tn->td tn3)))(newline) ; #t
(display (tn->tname tn3))(newline) ; testType

(python-eval "import imp")
(python-eval "pyc1 = imp.load_source( 'sizeof', 't/scripts/test-c-sizeof.py' )")
(python-eval "t1 = pyc1.main_eg()")

(load "../c-store.scm")
(load "../c-env.scm")
(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())

;(python-eval "t1.ext[2].children()[1][1].children()[0][1].show()")
(define tval4 ((ast->e-tn "t1.ext[2].children()[1][1].children()[0][1]") jp1 zeta1 rho s))
(display "\"")(display (tval->val tval4))(display "\"")(newline) ; "int"

;(python-eval "t1.ext[3].children()[1][1].children()[0][1].show()")
(define tval5 ((ast->e-tn "t1.ext[3].children()[1][1].children()[0][1]") jp1 zeta1 rho s))
(display "\"")(display (tval->val tval5))(display "\"")(newline) ; "unsigned long"

;(python-eval "t1.ext[4].children()[1][1].children()[0][1].show()")
(define tval6 ((ast->e-tn "t1.ext[4].children()[1][1].children()[0][1]") jp1 zeta1 rho s))
(display "\"")(display (tval->val tval6))(display "\"")(newline) ; "struct _A"

;(python-eval "t1.ext[5].children()[1][1].children()[0][1].show()")
(define tval7 ((ast->e-tn "t1.ext[5].children()[1][1].children()[0][1]") jp1 zeta1 rho s))
(display "\"")(display (tval->val tval7))(display "\"")(newline) ; "B"

