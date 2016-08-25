#!/usr/bin/guile -s
!#

(use-modules (guiletap))
(load "../c-ObjDecl.scm")
(load "../c-DenDecl.scm")


; tests ...
(plan 35)

(define td1 (make-it-td (make-id "test1") (make-single-it 'int)))
(define od1 (make-td-od td1 'test-qu))
(is-ok  1 "od1 - od?"                #t         (od? od1))
(is-ok  2 "od1 - td?"                #t         (td? od1))
(is-ok  3 "od1 - sym"                "test1"    (od->sym od1))
(is-ok  4 "od1 - it"                 #t         (int-it? (od->it od1)))
(is-ok  5 "od1 - qu"                 'test-qu   (od->qu od1))

(define td2 (make-it-td (make-id "test2") (make-single-it 'int)))
(define pd1 (make-pd td2))
(define od2 (make-pd-od pd1 'test-qu))
(is-ok  6 "od2 - od?"                #t         (od? od2))
(is-ok  7 "od2 - pd?"                #t         (pd? od2))
(is-ok  8 "od2 - sym"                "test2"    (od->sym od2))
(is-ok  9 "od2 - it"                 #t         (int-it? (od->it od2)))
(is-ok 10 "od2 - qu"                 'test-qu   (od->qu od2))

(define td3 (make-it-td (make-id "test3") (make-single-it 'int)))
(define pd2 (make-pd td3))
(define od3 (make-pd-od pd2 'test-qu))
(is-ok 11 "od3 - od?"                #t         (od? od3))
(is-ok 12 "od3 - pd?"                #t         (pd? od3))
(is-ok 13 "od3 - sym"                "test3"    (od->sym od3))
(is-ok 14 "od3 - it"                 #t         (int-it? (od->it od3)))
(is-ok 15 "od3 - qu"                 'test-qu   (od->qu od3))

(define ad1 (make-ad-c td1 8))
(define od4 (make-ad-od ad1 'test-qu))
(is-ok 16 "od4 - od?"                #t         (od? od4))
(is-ok 17 "od4 - ad?"                #t         (ad? od4))
(is-ok 18 "od4 - sym"                "test1"    (od->sym od4))
(is-ok 19 "od4 - it"                 #t         (int-it? (od->it od4)))
(is-ok 20 "od4 - qu"                 'test-qu   (od->qu od4))


(python-eval "import imp")
(python-eval "pyc1 = imp.load_source( 'test_td', 't/scripts/test-c-type-specifier.py' )")
(python-eval "pyc2 = imp.load_source( 'test_pd', 't/scripts/test-c-pointer.py' )")
(python-eval "pyc3 = imp.load_source( 'test_ad', 't/scripts/test-c-array.py' )")
(python-eval "t1 = pyc1.main_eg()")
(python-eval "t2 = pyc2.main_eg()")
(python-eval "t3 = pyc3.main_eg()")

(define od5 (ast->od "t1.ext[0].children()[0][1]"))
(is-ok 21 "od5 - od?"                #t         (od? od5))
(is-ok 22 "od5 - td?"                #t         (td? od5))
(is-ok 23 "od5 - sym"                "a"        (od->sym od5))
(is-ok 24 "od5 - it"                 #t         (char-it? (od->it od5)))
(is-ok 25 "od5 - qu"                 #t         (unspecified? (od->qu od5)))

(define od6 (ast->od "t2.ext[1].children()[0][1]"))
(is-ok 26 "od6 - od?"                #t         (od? od6))
(is-ok 27 "od6 - pd?"                #t         (pd? od6))
(is-ok 28 "od6 - sym"                "b"        (od->sym od6))
(is-ok 29 "od6 - it"                 #t         (int-it? (od->it od6)))
(is-ok 30 "od6 - qu"                 #t         (unspecified? (od->qu od6)))

(define od7 (ast->od "t3.ext[0].children()[0][1]"))
(is-ok 31 "od7 - od?"                #t         (od? od7))
(is-ok 32 "od7 - ad?"                #t         (ad? od7))
(is-ok 33 "od7 - sym"                "a"        (od->sym od7))
(is-ok 34 "od7 - it"                 #t         (int-it? (od->it od7)))
(is-ok 35 "od7 - qu"                 #t         (unspecified? (od->qu od7)))

