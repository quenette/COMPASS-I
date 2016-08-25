(load "../c-PtrDecl.scm")
(load "../c-DenDecl.scm")

(define td1 (make-it-td (make-id "test") (make-single-it 'int)))
(define od1 (make-td-od td1 (display "")))
(define dd1 (make-od-dd od1))
(define pd1 (make-pd dd1))
(display pd1)(newline)
(display (pd? pd1))(newline)
(display (pd->sym pd1))(newline) ;test
(display (pd->it pd1))(newline) ;(int)

(define od2 (make-pd-od pd1 (display "")))
(define dd2 (make-od-dd od2))
(define pd2 (make-pd dd2))
(display pd2)(newline)
(display (pd? pd2))(newline)
(display (pd->sym pd2))(newline) ;test
(display (pd->it pd2))(newline) ;(int)

(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pd', 't/scripts/test-c-pointer.py' )")
(python-eval "t = pyc.main_eg()")

(define pd3 (ast->pd "t.ext[1].children()[0][1]"))
(display pd3)(newline)
(display (pd? pd3))(newline)
(display (pd->sym pd3))(newline) ;b
(display (pd->it pd3))(newline) ;(int)

(define pd4 (ast->pd "t.ext[2].children()[0][1]"))
(display pd4)(newline)
(display (pd? pd4))(newline)
(display (pd->sym pd4))(newline) ;c
(display (pd->it pd4))(newline) ;(int)

(define pd5 (ast->pd "t.ext[3].children()[0][1]"))
(display pd5)(newline)
(display (pd? pd5))(newline)
(display (pd->sym pd5))(newline) ;d
(display (pd->it pd5))(newline) ;(int)


