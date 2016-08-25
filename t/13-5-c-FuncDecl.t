#!/usr/bin/guile -s
!#

(use-modules (guiletap))
(load "../c-FuncDecl.scm")
(load "../c-DenDecl.scm")
(load "../c-Declaration.scm")


; tests ...
(plan 16)

(define  td1 (make-it-td (make-id "argc") (make-single-it 'int)))
(define  D1 (make-od-D td1))

(define  pl1 (make-pl (list D1)))
(define  td2 (make-it-td (make-id "main") (make-single-it 'int)))
(define  fd1 (make-fd pl1 td2))
(is-ok  1 "fd? 1"                #t         (fd? fd1))
(is-ok  2 "length 1"             1          (length (pl->D* (fd->pl fd1))))
(is-ok  3 "argc? 1"              "argc"     (dd->sym (D->dd (car (pl->D* (fd->pl fd1))))))
(is-ok  4 "main? 1"              "main"     (fd->sym fd1))


(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-func.py' )")
(python-eval "t = pyc.main_eg()")

(define fd2 (ast->fd "t.ext[0].children()[0][1].children()[0][1]"))
(is-ok  5 "fd? 2"                #t         (fd? fd2))
(is-ok  6 "length 2"             1          (length (pl->D* (fd->pl fd2))))
(is-ok  7 "x? 2"                 "x"        (dd->sym (D->dd (car (pl->D* (fd->pl fd2))))))
(is-ok  8 "a? 2"                 "a"        (fd->sym fd2))

(define fd3 (ast->fd "t.ext[1].children()[0][1].children()[0][1]"))
(is-ok  9 "fd? 3"                #t         (fd? fd3))
(is-ok 10 "length 3"             2          (length (pl->D* (fd->pl fd3))))
(is-ok 11 "i? 3"                 "i"        (dd->sym (D->dd (car (pl->D* (fd->pl fd3))))))
(is-ok 12 "j? 3"                 "j"        (dd->sym (D->dd (cadr (pl->D* (fd->pl fd3))))))
(is-ok 13 "b? 3"                 "b"        (fd->sym fd3))

(define fd4 (ast->fd "t.ext[2].children()[0][1].children()[0][1]"))
(is-ok 14 "fd? 4"                #t         (fd? fd4))
(is-ok 15 "length 4"             0          (length (pl->D* (fd->pl fd4))))
(is-ok 16 "c? 4"                 "c"        (fd->sym fd4))

