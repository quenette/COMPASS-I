(load "../c-TypeDecl.scm")
 (load "../c-Struct.scm")

(load "../c-store.scm")
(load "../c-env.scm")
(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())

(define td1 (make-it-td (make-id "test1") (make-single-it 'int)))
(display td1)(newline)
(display (td? td1))(newline) ; #t
(display (td->sym td1))(newline) ; test1
(display (it? (td->it td1)))(newline) ; #t
(display (unspecified? (td->st td1)))(newline) ; #t
(display (it-td? td1))(newline) ; #t
(display (st-td? td1))(newline) ; #f
(define tval1 ((e-td->sz td1) jp1 zeta1 rho s))
(display (tval->val tval1))(newline) ; 1

(define st1 (make-st '()))
(define td2 (make-st-td (make-id "test2") st1))
(display td2)(newline)
(display (td? td2))(newline) ; #t
(display (td->sym td2))(newline) ; test2
(display (unspecified? (td->it td2)))(newline) ; #t
(display (st? (td->st td2)))(newline) ; #t
(display (it-td? td2))(newline) ; #f
(display (st-td? td2))(newline) ; #t
(define tval2 ((e-td->sz td2) jp1 zeta1 rho s))
(display (tval->val tval2))(newline) ; 0

(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-type-specifier.py' )")
(python-eval "t = pyc.main_eg()")

(define td3 (ast->td "t.ext[0].children()[0][1]"))
(display td3)(newline)
(display (td? td3))(newline) ;#t
(display (td->sym td3))(newline) ;a
(display (td->it td3))(newline) ;(char)
(display (it? (td->it td3)))(newline) ; #t
(display (unspecified? (td->st td3)))(newline) ; #t
(display (it-td? td3))(newline) ; #t
(display (st-td? td3))(newline) ; #f
(define tval3 ((e-td->sz td1) jp1 zeta1 rho s))
(display (tval->val tval3))(newline) ; 1

(display (ast->td "t.ext[1].children()[0][1]"))(newline)
(display (ast->td "t.ext[2].children()[0][1]"))(newline)
(display (ast->td "t.ext[3].children()[0][1]"))(newline)
(display (ast->td "t.ext[4].children()[0][1]"))(newline)
(display (ast->td "t.ext[5].children()[0][1]"))(newline)
(display (ast->td "t.ext[6].children()[0][1]"))(newline)
(display (ast->td "t.ext[7].children()[0][1]"))(newline)
(display (ast->td "t.ext[8].children()[0][1]"))(newline)
(display (ast->td "t.ext[9].children()[0][1]"))(newline)
(display (ast->td "t.ext[10].children()[0][1]"))(newline)
(display (ast->td "t.ext[11].children()[0][1]"))(newline)
(display (ast->td "t.ext[12].children()[0][1]"))(newline)
(display (ast->td "t.ext[13].children()[0][1]"))(newline)

