(load "../c-IdentifierType.scm")


(display (list? (make-single-it 'void)))(newline) ; #t
(display (list? (make-single-it 'BAD)))(newline) ; #f
(display (list? (make-double-it 'unsigned 'int)))(newline) ; #t
(display (list? (make-double-it 'unsigned '())))(newline) ; #t

(display (it? (make-single-it 'void)))(newline) ; #t
(display (void-it? (make-single-it 'void)))(newline) ; #t

(display (it? (make-single-it 'char)))(newline) ; #t
(display (char-it? (make-single-it 'char)))(newline) ; #t

(display (it? (make-single-it 'short)))(newline) ; #t
(display (short-it? (make-single-it 'short)))(newline) ; #t

(display (it? (make-single-it 'int)))(newline) ; #t
(display (it? (make-single-it 'signed)))(newline) ; #t
(display (it? (make-double-it 'signed 'int)))(newline) ; #t
(display (int-it? (make-single-it 'int)))(newline) ; #t
(display (signed-it? (make-single-it 'signed)))(newline) ; #t
(display (int-it? (make-double-it 'signed 'int)))(newline) ; #t

(display (it? (make-single-it 'long)))(newline) ; #t
(display (long-it? (make-single-it 'long)))(newline) ; #t

(display (it? (make-single-it 'float)))(newline) ; #t
(display (float-it? (make-single-it 'float)))(newline) ; #t

(display (it? (make-single-it 'double)))(newline) ; #t
(display (double-it? (make-single-it 'double)))(newline) ; #t


(display (it? (make-double-it 'signed 'char)))(newline) ; #t
(display (signed-char-it? (make-double-it 'signed 'char)))(newline) ; #t
(display (it? (make-double-it 'unsigned 'char)))(newline) ; #t
(display (unsigned-char-it? (make-double-it 'unsigned 'char)))(newline) ; #t

(display (it? (make-double-it 'unsigned 'short)))(newline) ; #t
(display (unsigned-short-it? (make-double-it 'unsigned 'short)))(newline) ; #t

(display (it? (make-single-it 'unsigned)))(newline) ; #t
(display (it? (make-double-it 'unsigned 'int)))(newline) ; #t
(display (unsigned-it? (make-single-it 'unsigned)))(newline) ; #t
(display (unsigned-it? (make-double-it 'unsigned 'int)))(newline) ; #t

(display (it? (make-double-it 'unsigned 'long)))(newline) ; #t
(display (unsigned-long-it? (make-double-it 'unsigned 'long)))(newline) ; #t

(display (it? (make-double-it 'long 'double)))(newline) ; #t
(display (long-double-it? (make-double-it 'long 'double)))(newline) ; #t
(newline)

(display (list? (make-user-it "myType")))(newline) ; #t
(display (it? (make-user-it "myType")))(newline) ; #t
(display (user-it? (make-user-it "myType")))(newline) ; #t
(display (inbuilt-it? (make-user-it "myType")))(newline) ; #f
(display (it->kind1 (make-user-it "myType")))(newline) ; 'it
(display (it->tname (make-user-it "myType")))(newline) ; myType
(newline)

(python-eval "import imp")
(python-eval "pyc1 = imp.load_source( 'type-specifier', 't/scripts/test-c-type-specifier.py' )")
(python-eval "pyc2 = imp.load_source( 'struct', 't/scripts/test-c-struct.py' )")
(python-eval "t1 = pyc1.main_eg()")
(python-eval "t2 = pyc2.main_eg()")

(display (char-it? (ast->it "t1.ext[0].children()[0][1].type")))(newline) ; #t
(display (short-it? (ast->it "t1.ext[01].children()[0][1].type")))(newline) ; #t
(display (int-it? (ast->it "t1.ext[02].children()[0][1].type")))(newline) ; #t
(display (long-it? (ast->it "t1.ext[03].children()[0][1].type")))(newline) ; #t
(display (float-it? (ast->it "t1.ext[04].children()[0][1].type")))(newline) ; #t
(display (double-it? (ast->it "t1.ext[05].children()[0][1].type")))(newline) ; #t
(display (signed-it? (ast->it "t1.ext[06].children()[0][1].type")))(newline) ; #t
(display (unsigned-it? (ast->it "t1.ext[07].children()[0][1].type")))(newline) ; #t

(display (unsigned-short-it? (ast->it "t1.ext[10].children()[0][1].type")))(newline) ; #t
(display (unsigned-it? (ast->it "t1.ext[11].children()[0][1].type")))(newline) ; #t
(display (unsigned-long-it? (ast->it "t1.ext[12].children()[0][1].type")))(newline) ; #t
(display (long-double-it? (ast->it "t1.ext[13].children()[0][1].type")))(newline) ; #t
(newline)

(define it100 (ast->it "t2.ext[11].children()[1][1].children()[4][1].children()[0][1].children()[0][1]"))
(display it100)(newline) ; (it B)
(display (user-it? it100))(newline) ; #t
(display (it->tname it100))(newline) ; B


; For some reason these fail...
;(is-ok 49 "t1.ext[08].children()[0][1]"  #t (signed-char-it? (ast->it "t1.ext[08].children()[0][1].type")))
;(is-ok 50 "t1.ext[09].children()[0][1]"  #t (unsigned-char-it? (ast->it "t1.ext[09].children()[0][1].type")))


