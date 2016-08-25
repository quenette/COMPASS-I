#!/usr/bin/guile -s
!#

(use-modules (guiletap))
(load "../c-DenDecl.scm")
(load "../c-Declaration.scm")

; tests ...
(plan 30)

(define td1 (make-it-td (make-id "test1") (make-single-it 'int)))
(define od1 (make-td-od td1 (display "")))
(define dd1 (make-od-dd od1))
(is-ok  1 "dd1 - dd?"                #t         (dd? dd1))
(is-ok  2 "dd1 - od?"                #t         (od? dd1))
(is-ok  3 "dd1 - td?"                #t         (td? dd1))
(is-ok  4 "dd1 - sym"                "test1"    (dd->sym dd1))

(define td2 (make-it-td (make-id "test2") (make-single-it 'int)))
(define pd1 (make-pd td2))
(define od2 (make-pd-od pd1 (display "")))
(define dd2 (make-od-dd od2))
(is-ok  5 "dd2 - dd?"                #t         (dd? dd2))
(is-ok  6 "dd2 - od?"                #t         (od? dd2))
(is-ok  7 "dd2 - pd?"                #t         (pd? dd2))
(is-ok  8 "dd2 - sym"                "test2"    (dd->sym dd2))

(define ad1 (make-ad-c td1 8))
(define od3 (make-ad-od ad1 (display "")))
(define dd3 (make-od-dd od3))
(is-ok  9 "dd3 - dd?"                #t         (dd? dd3))
(is-ok 10 "dd3 - od?"                #t         (od? dd3))
(is-ok 11 "dd3 - ad?"                #t         (ad? dd3))
(is-ok 12 "dd3 - sym"                "test1"    (dd->sym dd3))

(define td3 (make-it-td (make-id "argc") (make-single-it 'int)))
(define od4 (make-td-od td3 (display "")))
(define dd4a (make-od-dd od4))
(define  D1 (make-od-D dd4a))
(define pl1 (make-pl (list D1)))
(define td4 (make-it-td (make-id "main") (make-single-it 'int)))
(define od4 (make-td-od td4 (display "")))
(define fd1 (make-fd pl1 od4))
(define dd4 (make-fd-dd fd1))
(is-ok 13 "dd4 - dd?"                #t         (dd? dd4))
(is-ok 14 "dd4 - fd?"                #t         (fd? dd4))
(is-ok 15 "dd4 - sym"                "main"    (dd->sym dd4))


(python-eval "import imp")
(python-eval "pyc1 = imp.load_source( 'test_td', 't/scripts/test-c-type-specifier.py' )")
(python-eval "pyc2 = imp.load_source( 'test_pd', 't/scripts/test-c-pointer.py' )")
(python-eval "pyc3 = imp.load_source( 'test_ad', 't/scripts/test-c-array.py' )")
(python-eval "pyc4 = imp.load_source( 'test_fd', 't/scripts/test-c-func.py' )")
(python-eval "t1 = pyc1.main_eg()")
(python-eval "t2 = pyc2.main_eg()")
(python-eval "t3 = pyc3.main_eg()")
(python-eval "t4 = pyc4.main_eg()")

(define dd5 (ast->dd "t1.ext[0].children()[0][1]"))
(is-ok 16 "dd5 - dd?"                #t         (dd? dd5))
(is-ok 17 "dd5 - od?"                #t         (od? dd5))
(is-ok 18 "dd5 - td?"                #t         (td? dd5))
(is-ok 19 "dd5 - sym"                "a"        (dd->sym dd5))

(define dd6 (ast->dd "t2.ext[1].children()[0][1]"))
(is-ok 20 "dd6 - dd?"                #t         (dd? dd6))
(is-ok 21 "dd6 - od?"                #t         (od? dd6))
(is-ok 22 "dd6 - pd?"                #t         (pd? dd6))
(is-ok 23 "dd6 - sym"                "b"        (dd->sym dd6))

(define dd7 (ast->dd "t3.ext[0].children()[0][1]"))
(is-ok 24 "dd7 - dd?"                #t         (dd? dd7))
(is-ok 25 "dd7 - od?"                #t         (od? dd7))
(is-ok 26 "dd7 - ad?"                #t         (ad? dd7))
(is-ok 27 "dd7 - sym"                "a"        (dd->sym dd7))

(define dd8 (ast->dd "t4.ext[2].children()[0][1].children()[0][1]"))
(is-ok 28 "dd8 - dd?"                #t         (dd? dd8))
(is-ok 29 "dd8 - fd?"                #t         (fd? dd8))
(is-ok 30 "dd8 - sym"                "c"        (dd->sym dd8))

