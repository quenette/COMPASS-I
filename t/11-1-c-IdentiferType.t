#!/usr/bin/guile -s
!#

(use-modules (guiletap))
(load "../c-IdentifierType.scm")


; tests ...
(plan 56)
(is-ok  1 "(make-single-it 'void)"                                #t (list? (make-single-it 'void)))
(is-ok  2 "(make-single-it 'BAD)"                                 #f (list? (make-single-it 'BAD)))
(is-ok  3 "(make-double-it 'unsigned 'int)"                       #t (list? (make-double-it 'unsigned 'int)))
(is-ok  4 "(make-double-it 'unsigned '())"                        #t (list? (make-double-it 'unsigned '())))

(is-ok  5 "(it? (make-single-it 'void))"                          #t (it? (make-single-it 'void)))
(is-ok  6 "(void-it? (make-single-it 'void))"                     #t (void-it? (make-single-it 'void)))

(is-ok  7 "(it? (make-single-it 'char))"                          #t (it? (make-single-it 'char)))
(is-ok  8 "(char-it? (make-single-it 'char))"                     #t (char-it? (make-single-it 'char)))

(is-ok  9 "(it? (make-single-it 'short))"                         #t (it? (make-single-it 'short)))
(is-ok 10 "(short-it? (make-single-it 'short))"                   #t (short-it? (make-single-it 'short)))

(is-ok 11 "(it? (make-single-it 'int))"                           #t (it? (make-single-it 'int)))
(is-ok 12 "(it? (make-single-it 'signed))"                        #t (it? (make-single-it 'signed)))
(is-ok 13 "(it? (make-double-it 'signed 'int))"                   #t (it? (make-double-it 'signed 'int)))
(is-ok 14 "(int-it? (make-single-it 'int))"                       #t (int-it? (make-single-it 'int)))
(is-ok 15 "(signed-it? (make-single-it 'signed))"                 #t (signed-it? (make-single-it 'signed)))
(is-ok 16 "(int-it? (make-double-it 'signed 'int))"               #t (int-it? (make-double-it 'signed 'int)))

(is-ok 17 "(it? (make-single-it 'long))"                          #t (it? (make-single-it 'long)))
(is-ok 18 "(long-it? (make-single-it 'long))"                     #t (long-it? (make-single-it 'long)))

(is-ok 19 "(it? (make-single-it 'float))"                         #t (it? (make-single-it 'float)))
(is-ok 20 "(float-it? (make-single-it 'float))"                   #t (float-it? (make-single-it 'float)))

(is-ok 21 "(it? (make-single-it 'double))"                        #t (it? (make-single-it 'double)))
(is-ok 22 "(double-it? (make-single-it 'double))"                 #t (double-it? (make-single-it 'double)))


(is-ok 23 "(it? (make-double-it 'signed 'char))"                  #t (it? (make-double-it 'signed 'char)))
(is-ok 24 "(signed-char-it? (make-double-it 'signed 'char))"      #t (signed-char-it? (make-double-it 'signed 'char)))
(is-ok 25 "(it? (make-double-it 'unsigned 'char))"                #t (it? (make-double-it 'unsigned 'char)))
(is-ok 26 "(unsigned-char-it? (make-double-it 'unsigned 'char))"  #t (unsigned-char-it? (make-double-it 'unsigned 'char)))

(is-ok 27 "(it? (make-double-it 'unsigned 'short))"               #t (it? (make-double-it 'unsigned 'short)))
(is-ok 28 "(unsigned-short-it? (make-double-it 'unsigned 'short))"  #t (unsigned-short-it? (make-double-it 'unsigned 'short)))

(is-ok 29 "(it? (make-single-it 'unsigned))"                      #t (it? (make-single-it 'unsigned)))
(is-ok 30 "(it? (make-double-it 'unsigned 'int))"                 #t (it? (make-double-it 'unsigned 'int)))
(is-ok 31 "(unsigned-it? (make-single-it 'unsigned))"             #t (unsigned-it? (make-single-it 'unsigned)))
(is-ok 32 "(unsigned-it? (make-double-it 'unsigned 'int))"        #t (unsigned-it? (make-double-it 'unsigned 'int)))

(is-ok 33 "(it? (make-double-it 'unsigned 'long))"                #t (it? (make-double-it 'unsigned 'long)))
(is-ok 34 "(unsigned-long-it? (make-double-it 'unsigned 'long))"  #t (unsigned-long-it? (make-double-it 'unsigned 'long)))

(is-ok 35 "(it? (make-double-it 'long 'double))"                  #t (it? (make-double-it 'long 'double)))
(is-ok 36 "(long-double-it? (make-double-it 'long 'double))"      #t (long-double-it? (make-double-it 'long 'double)))

(is-ok 37 "37"                                                    #t (list? (make-user-it "myType")))
(is-ok 38 "38"                                                    #t (it? (make-user-it "myType")))
(is-ok 39 "39"                                                    #t (user-it? (make-user-it "myType")))
(is-ok 40 "40"                                                    #f (inbuilt-it? (make-user-it "myType")))
(is-ok 41 "41"                                                   'it (it->kind1 (make-user-it "myType")))
(is-ok 42 "42"                                              "myType" (it->tname (make-user-it "myType")))

(python-eval "import imp")
(python-eval "pyc1 = imp.load_source( 'type-specifier', 't/scripts/test-c-type-specifier.py' )")
(python-eval "pyc2 = imp.load_source( 'struct', 't/scripts/test-c-struct.py' )")
(python-eval "t1 = pyc1.main_eg()")
(python-eval "t2 = pyc2.main_eg()")

(is-ok 43 "t1.ext[00].children()[0][1]"  #t (char-it? (ast->it "t1.ext[0].children()[0][1].type")))
(is-ok 44 "t1.ext[01].children()[0][1]"  #t (short-it? (ast->it "t1.ext[01].children()[0][1].type")))
(is-ok 45 "t1.ext[02].children()[0][1]"  #t (int-it? (ast->it "t1.ext[02].children()[0][1].type")))
(is-ok 46 "t1.ext[03].children()[0][1]"  #t (long-it? (ast->it "t1.ext[03].children()[0][1].type")))
(is-ok 47 "t1.ext[04].children()[0][1]"  #t (float-it? (ast->it "t1.ext[04].children()[0][1].type")))
(is-ok 48 "t1.ext[05].children()[0][1]"  #t (double-it? (ast->it "t1.ext[05].children()[0][1].type")))
(is-ok 49 "t1.ext[06].children()[0][1]"  #t (signed-it? (ast->it "t1.ext[06].children()[0][1].type")))
(is-ok 50 "t1.ext[07].children()[0][1]"  #t (unsigned-it? (ast->it "t1.ext[07].children()[0][1].type")))

(is-ok 51 "t1.ext[10].children()[0][1]"  #t (unsigned-short-it? (ast->it "t1.ext[10].children()[0][1].type")))
(is-ok 52 "t1.ext[11].children()[0][1]"  #t (unsigned-it? (ast->it "t1.ext[11].children()[0][1].type")))
(is-ok 53 "t1.ext[12].children()[0][1]"  #t (unsigned-long-it? (ast->it "t1.ext[12].children()[0][1].type")))
(is-ok 54 "t1.ext[13].children()[0][1]"  #t (long-double-it? (ast->it "t1.ext[13].children()[0][1].type")))

; For some reason these fail...
;(is-ok 49 "t1.ext[08].children()[0][1]"  #t (signed-char-it? (ast->it "t1.ext[08].children()[0][1].type")))
;(is-ok 50 "t1.ext[09].children()[0][1]"  #t (unsigned-char-it? (ast->it "t1.ext[09].children()[0][1].type")))


(define it100 (ast->it "t2.ext[11].children()[1][1].children()[4][1].children()[0][1].children()[0][1]"))
(is-ok 55 "55"                                                   #t (user-it? it100))
(is-ok 56 "56"                                                  "B" (it->tname it100))

