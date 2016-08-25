(load "../c-ObjDecl.scm")
(load "../c-DenDecl.scm")

(define td1 (make-it-td (make-id "test1") (make-single-it 'int)))
(define od1 (make-td-od td1 'test-qu))
(display od1)(newline) ; (type-decl (identifier test1) (int) test-qu)
(display (od? od1))(newline) ; #t
(display (td? od1))(newline) ; #t
(display (od->sym od1))(newline) ; test1
(display (od->it od1))(newline) ; (int)
(display (od->qu od1))(newline) ; 'test-qu

(define td2 (make-it-td (make-id "test2") (make-single-it 'int)))
(define pd1 (make-pd td2))
(define od2 (make-pd-od pd1 'test-qu))
(display od2)(newline) ; (ptr-decl (type-decl (identifier test2) (int)) test-qu)
(display (od? od2))(newline) ; #t
(display (pd? od2))(newline) ; #t
(display (od->sym od2))(newline) ; test2
(display (od->it od2))(newline) ; (int)
(display (od->qu od2))(newline) ; 'test-qu

(define td3 (make-it-td (make-id "test3") (make-single-it 'int)))
(define pd2 (make-pd td3))
(define od3 (make-pd-od pd2 'test-qu))
(display od3)(newline) ; (ptr-decl (type-decl (identifier test3) (int)) test-qu)
(display (od? od3))(newline) ; #t
(display (pd? od3))(newline) ; #t
(display (od->sym od3))(newline) ; test3
(display (od->it od3))(newline) ; (int)
(display (od->qu od3))(newline) ; 'test-qu

(define ad1 (make-ad-c td1 8))
(define od4 (make-ad-od ad1 'test-qu))
(display od4)(newline) ; (array-decl (type-decl (identifier test1) (int)) 8 test-qu)
(display (od? od4))(newline) ; #t
(display (ad? od4))(newline) ; #t
(display (od->sym od4))(newline) ; test1
(display (od->it od4))(newline) ; (int)
(display (od->qu od4))(newline) ; 'test-qu

(python-eval "import imp")
(python-eval "pyc1 = imp.load_source( 'test_td', 't/scripts/test-c-type-specifier.py' )")
(python-eval "pyc2 = imp.load_source( 'test_pd', 't/scripts/test-c-pointer.py' )")
(python-eval "pyc3 = imp.load_source( 'test_ad', 't/scripts/test-c-array.py' )")
(python-eval "t1 = pyc1.main_eg()")
(python-eval "t2 = pyc2.main_eg()")
(python-eval "t3 = pyc3.main_eg()")
(newline)

(define od5 (ast->od "t1.ext[0].children()[0][1]"))
(display od5)(newline) ; (type-decl (identifier a) (char) #<unspecified>)
(display (od? od5))(newline) ; #t
(display (td? od5))(newline) ; #t
(display (od->sym od5))(newline) ; a
(display (od->it od5))(newline) ; (char)
(display (od->qu od5))(newline) ; #<unspecified>

(define od6 (ast->od "t2.ext[1].children()[0][1]"))
(display od6)(newline) ; (ptr-decl (type-decl (identifier b) (int) #<unspecified>) #<unspecified>)
(display (od? od6))(newline) ; #t
(display (pd? od6))(newline) ; #t
(display (od->sym od6))(newline) ; b
(display (od->it od6))(newline) ; (int)
(display (od->qu od6))(newline) ; #<unspecified>

(define od7 (ast->od "t3.ext[0].children()[0][1]"))
(display od7)(newline) ; (array-decl (type-decl (identifier a) (int)) 5 #<unspecified>)
(display (od? od7))(newline) ; #t
(display (ad? od7))(newline) ; #t
(display (od->sym od7))(newline) ; a
(display (od->it od7))(newline) ; (int)
(display (od->qu od7))(newline) ; #<unspecified>

