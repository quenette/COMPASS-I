#!/usr/bin/guile -s
!#

(use-modules (guiletap))
(load "../c-PtrDecl.scm")
(load "../c-DenDecl.scm")


; tests ...
(plan 15)


(define td1 (make-it-td (make-id "test") (make-single-it 'int)))
(define od1 (make-td-od td1 (display "")))
(define dd1 (make-od-dd od1))
(define pd1 (make-pd dd1))
(is-ok  1 "pd1 - pd?"                #t         (pd? pd1))
(is-ok  2 "pd1 - sym"                "test"     (pd->sym pd1))
(is-ok  3 "pd1 - it"                 #t         (int-it? (pd->it pd1)))

(define od2 (make-pd-od pd1 (display "")))
(define dd2 (make-od-dd od2))
(define pd2 (make-pd dd2))
(is-ok  4 "pd2 - pd?"                #t         (pd? pd2))
(is-ok  5 "pd2 - sym"                "test"     (pd->sym pd2))
(is-ok  6 "pd2 - it"                 #t         (int-it? (pd->it pd2)))


(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pd', 't/scripts/test-c-pointer.py' )")
(python-eval "t = pyc.main_eg()")

(define pd3 (ast->pd "t.ext[1].children()[0][1]"))
(is-ok  7 "pd3 - pd?"                #t         (pd? pd3))
(is-ok  8 "pd3 - sym"                "b"        (pd->sym pd3))
(is-ok  9 "pd3 - it"                 #t         (int-it? (pd->it pd3)))

(define pd4 (ast->pd "t.ext[2].children()[0][1]"))
(is-ok 10 "pd4 - pd?"                #t         (pd? pd4))
(is-ok 11 "pd4 - sym"                "c"        (pd->sym pd4))
(is-ok 12 "pd4 - it"                 #t         (int-it? (pd->it pd4)))

(define pd5 (ast->pd "t.ext[3].children()[0][1]"))
(is-ok 13 "pd5 - pd?"                #t         (pd? pd5))
(is-ok 14 "pd5 - sym"                "d"        (pd->sym pd5))
(is-ok 15 "pd5 - it"                 #t         (int-it? (pd->it pd5)))

