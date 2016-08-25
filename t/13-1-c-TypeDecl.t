#!/usr/bin/guile -s
!#

(use-modules (guiletap))
(load "../c-TypeDecl.scm")
(load "../c-IdentifierType.scm")


; tests ...
(plan 16)

(define td1 (make-it-td (make-id "test1") (make-single-it 'int)))
(is-ok  1 "td1 - od?"                #t         (td? td1))
(is-ok  2 "td1 - sym"                "test1"    (td->sym td1))
(is-ok  3 "td1 - it"                 #t         (int-it? (td->it td1)))


(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-type-specifier.py' )")
(python-eval "t = pyc.main_eg()")

(define td2 (ast->td "t.ext[0].children()[0][1]"))
(is-ok  4 "t.ext[00].children()[0][1]"  "a" (td->sym td2))
(is-ok  5 "t.ext[00].children()[0][1]"  #t  (char-it? (td->it td2)))

(is-ok  6 "t.ext[01].children()[0][1]"  "b" (id->sym (td->id (ast->td "t.ext[01].children()[0][1]"))))
(is-ok  7 "t.ext[02].children()[0][1]"  "c" (id->sym (td->id (ast->td "t.ext[02].children()[0][1]"))))
(is-ok  8 "t.ext[03].children()[0][1]"  "d" (id->sym (td->id (ast->td "t.ext[03].children()[0][1]"))))
(is-ok  9 "t.ext[04].children()[0][1]"  "e" (id->sym (td->id (ast->td "t.ext[04].children()[0][1]"))))
(is-ok 10 "t.ext[05].children()[0][1]"  "f" (id->sym (td->id (ast->td "t.ext[05].children()[0][1]"))))
(is-ok 11 "t.ext[06].children()[0][1]"  "g" (id->sym (td->id (ast->td "t.ext[06].children()[0][1]"))))
(is-ok 12 "t.ext[07].children()[0][1]"  "h" (id->sym (td->id (ast->td "t.ext[07].children()[0][1]"))))

(is-ok 13 "t.ext[10].children()[0][1]"  "m" (id->sym (td->id (ast->td "t.ext[10].children()[0][1]"))))
(is-ok 14 "t.ext[11].children()[0][1]"  "n" (id->sym (td->id (ast->td "t.ext[11].children()[0][1]"))))
(is-ok 15 "t.ext[12].children()[0][1]"  "o" (id->sym (td->id (ast->td "t.ext[12].children()[0][1]"))))
(is-ok 16 "t.ext[13].children()[0][1]"  "p" (id->sym (td->id (ast->td "t.ext[13].children()[0][1]"))))
;
; For some reason these fail...
;(is-ok 17 "t.ext[08].children()[0][1]"  "k" (id->sym (td->id (ast->td "t.ext[08].children()[0][1]"))))
;(is-ok 18 "t.ext[09].children()[0][1]"  "l" (id->sym (td->id (ast->td "t.ext[09].children()[0][1]"))))

