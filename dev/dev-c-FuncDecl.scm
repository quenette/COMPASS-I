(load "../c-FuncDecl.scm")
(load "../c-DenDecl.scm")
(load "../c-Declaration.scm")

(define td1 (make-it-td (make-id "argc") (make-single-it 'int)))
(define od1 (make-td-od td1 (display "")))
(define dd1a (make-od-dd od1))
(define  D1 (make-od-D dd1a))
(define pl1 (make-pl (list D1)))
(define td2 (make-it-td (make-id "main") (make-single-it 'int)))
(define od4 (make-td-od td2 (display "")))
(define fd1 (make-fd pl1 od4))
(display fd1) (newline)
(display (fd? fd1))(newline) ;#t
(display (fd->sym fd1))(newline) ;main
(display (pl? (fd->pl fd1)))(newline) ; #t
(display (length (pl->D* (fd->pl fd1))))(newline) ; 1
(display (dd->sym (D->dd (car (pl->D* (fd->pl fd1))))))(newline) ; argc


(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-func.py' )")
(python-eval "t = pyc.main_eg()")

(define fd2 (ast->fd "t.ext[0].children()[0][1].children()[0][1]"))
(display fd2) (newline)
(display (fd? fd2))(newline) ;#t
(display (fd->sym fd2))(newline) ;a
(display (pl? (fd->pl fd2)))(newline) ; #t
(display (length (pl->D* (fd->pl fd2))))(newline) ; 1
(display (dd->sym (D->dd (car (pl->D* (fd->pl fd2))))))(newline) ; x

(define fd3 (ast->fd "t.ext[1].children()[0][1].children()[0][1]"))
(display fd3) (newline)
(display (fd? fd3))(newline) ;#t
(display (fd->sym fd3))(newline) ;b
(display (pl? (fd->pl fd3)))(newline) ; #t
(display (length (pl->D* (fd->pl fd3))))(newline) ; 2
(display (dd->sym (D->dd (car (pl->D* (fd->pl fd3))))))(newline) ; i
(display (dd->sym (D->dd (cadr (pl->D* (fd->pl fd3))))))(newline) ; j

(define fd4 (ast->fd "t.ext[2].children()[0][1].children()[0][1]"))
(display fd4) (newline)
(display (fd? fd4))(newline) ;#t
(display (fd->sym fd4))(newline) ;c
(display (pl? (fd->pl fd4)))(newline) ; #t
(display (length (pl->D* (fd->pl fd4))))(newline) ; 0

