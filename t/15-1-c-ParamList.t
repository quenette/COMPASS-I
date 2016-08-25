#!/usr/bin/guile -s
!#

(use-modules (guiletap))
(load "../c-ParamList.scm")
(load "../c-Declaration.scm")


; tests ...
(plan 12)

; Just one arg ...
(define  td1 (make-it-td (make-id "argc") (make-single-it 'int)))
(define  D1 (make-od-D td1))
(define  pl1 (make-pl (list D1)))
(is-ok  1 "pl? 1"                #t         (pl? pl1))
(is-ok  2 "length 1"             1          (length (pl->D* pl1)))
(is-ok  3 "argc? 1"              "argc"     (id->sym (td->id (D->dd (car (pl->D* pl1))))))


(define  td2 (make-it-td (make-id "argv") (make-single-it 'char)))
(define pd2a (make-pd td2))
(define pd2b (make-pd pd2a))
(define  D2 (make-od-D pd2b))
(define  pl2 (make-pl (list D1 D2)))
(is-ok  4 "pl? 2"                #t         (pl? pl2))
(is-ok  5 "length 2"             2          (length (pl->D* pl2)))
(is-ok  6 "argc? 2"              "argc"     (id->sym (td->id (D->dd (car  (pl->D* pl2))))))
(is-ok  7 "argv? 2"              "argv"     (id->sym (pd->id (D->dd (cadr (pl->D* pl2))))))


(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-func.py' )")
(python-eval "t = pyc.main_eg()")

(define pl3 (ast->pl "t.ext[0].children()[0][1].children()[0][1].children()[0][1]"))
(is-ok  8 "length 3"             1          (length (pl->D* pl3)))
(is-ok  9 "x? 3"                 "x"        (id->sym (td->id (D->dd (car  (pl->D* pl3))))))

(define pl4 (ast->pl "t.ext[1].children()[0][1].children()[0][1].children()[0][1]"))
(is-ok 10 "length 3"             2          (length (pl->D* pl4)))
(is-ok 11 "i? 3"                 "i"        (id->sym (td->id (D->dd (car  (pl->D* pl4))))))
(is-ok 12 "j? 3"                 "j"        (id->sym (pd->id (D->dd (cadr (pl->D* pl4))))))



