(load "../c-DenDecl.scm")
(load "../c-Declaration.scm")

(define td1 (make-it-td (make-id "test1") (make-single-it 'int)))
(define od1 (make-td-od td1 (display "")))
(define dd1 (make-od-dd od1))
(display dd1)(newline) ; (type-decl (identifier test1) (int) #<unspecified>)
(display (dd? dd1))(newline) ; #t
(display (od? dd1))(newline) ; #t
(display (td? dd1))(newline) ; #t
(display (dd->sym dd1))(newline) ; test1

(define td2 (make-it-td (make-id "test2") (make-single-it 'int)))
(define pd1 (make-pd td2))
(define od2 (make-pd-od pd1 (display "")))
(define dd2 (make-od-dd od2))
(display dd2)(newline) ; (ptr-decl (type-decl (identifier test2) (int)) #<unspecified>)
(display (dd? dd2))(newline) ; #t
(display (od? dd2))(newline) ; #t
(display (pd? dd2))(newline) ; #t
(display (dd->sym dd2))(newline) ; test2

(define ad1 (make-ad-c td1 8))
(define od3 (make-ad-od ad1 (display "")))
(define dd3 (make-od-dd od3))
(display dd3)(newline) ; (array-decl (type-decl (identifier test1) (int)) 8 #<unspecified>)
(display (dd? dd3))(newline) ; #t
(display (od? dd3))(newline) ; #t
(display (ad? dd3))(newline) ; #t
(display (dd->sym dd3))(newline) ; test1


(define td3 (make-it-td (make-id "argc") (make-single-it 'int)))
(define od4 (make-td-od td3 (display "")))
(define dd4a (make-od-dd od4))
(define  D1 (make-od-D dd4a))
(define pl1 (make-pl (list D1)))
(define td4 (make-it-td (make-id "main") (make-single-it 'int)))
(define od4 (make-td-od td4 (display "")))
(define fd1 (make-fd pl1 od4))
(define dd4 (make-fd-dd fd1))
(display dd4) (newline) ; (func-decl (paramlist ((decl (type-decl (identifier argc) (int) #<unspecified>) ()))) (type-decl (identifier main) (int) #<unspecified>))
(display (dd? dd4))(newline) ; #t
(display (fd? dd4))(newline) ; #t
(display (dd->sym dd4))(newline) ; main

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
(display dd5)(newline) ; (type-decl (identifier a) (char) #<unspecified>)
(display (dd? dd5))(newline) ; #t
(display (td? dd5))(newline) ; #t
(display (dd->sym dd5))(newline) ; a

(define dd6 (ast->dd "t2.ext[1].children()[0][1]"))
(display dd6)(newline) ; (ptr-decl (type-decl (identifier b) (int) #<unspecified>) #<unspecified>)
(display (dd? dd6))(newline) ; #t
(display (pd? dd6))(newline) ; #t
(display (dd->sym dd6))(newline) ; b

(define dd7 (ast->dd "t3.ext[0].children()[0][1]"))
(display dd7)(newline) ; (array-decl (type-decl (identifier a) (int)) 5 #<unspecified>)
(display (dd? dd7))(newline) ; #t
(display (ad? dd7))(newline) ; #t
(display (dd->sym dd7))(newline) ; b

(define dd8 (ast->dd "t4.ext[2].children()[0][1].children()[0][1]"))
(display dd8) (newline) ; (func-decl (paramlist ()) (type-decl (identifier c) (void) #<unspecified>))
(display (dd? dd8))(newline) ; #t
(display (fd? dd8))(newline) ; #t
(display (dd->sym dd8))(newline) ; c

