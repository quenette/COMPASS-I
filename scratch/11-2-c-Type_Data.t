#!/usr/bin/guile -s
!#

(use-modules (guiletap))
(load "../c-Type_Data.scm")
(load "../c-IdentifierType.scm")


; tests ...
(plan 20)
(is-ok  1 "(tyda? (make-it-tyda (make-single-it 'void)))"           #t (tyda? (make-it-tyda (make-single-it 'void))))
(is-ok  2 "(it? (make-it-tyda (make-single-it 'void)))"             #t (it? (make-it-tyda (make-single-it 'void))))
(is-ok  3 "(tyda? (make-it-tyda (make-double-it 'unsigned 'int)))"  #t (tyda? (make-it-tyda (make-double-it 'unsigned 'int))))
(is-ok  4 "(it? (make-it-tyda (make-double-it 'unsigned 'int)))"    #t (it? (make-it-tyda (make-double-it 'unsigned 'int))))

(is-ok  5 "(void-tyda? ... 'void)))"                        #t (void-tyda? (make-it-tyda (make-single-it 'void))))
(is-ok  6 "(char-tyda? ... 'char)))"                        #t (char-tyda? (make-it-tyda (make-single-it 'char))))
(is-ok  7 "(short-tyda? ... 'short)))"                      #t (short-tyda? (make-it-tyda (make-single-it 'short))))
(is-ok  8 "(int-tyda? ... 'int)))"                          #t (int-tyda? (make-it-tyda (make-single-it 'int))))
(is-ok  9 "(long-tyda? ... 'long)))"                        #t (long-tyda? (make-it-tyda (make-single-it 'long))))
(is-ok 10 "(float-tyda? ... 'float)))"                      #t (float-tyda? (make-it-tyda (make-single-it 'float))))
(is-ok 11 "(double-tyda? ... 'double)))"                    #t (double-tyda? (make-it-tyda (make-single-it 'double))))
(is-ok 12 "(long-double-tyda? ... 'long 'double)))"         #t (long-double-tyda? (make-it-tyda (make-double-it 'long 'double))))

(is-ok 13 "(signed-tyda? ...'signed)))"                     #t (signed-tyda? (make-it-tyda (make-single-it 'signed))))
(is-ok 14 "(unsigned-tyda? ... 'unsigned)))"                #t (unsigned-tyda? (make-it-tyda (make-single-it 'unsigned))))

(is-ok 15 "(unsigned-char-tyda? ... 'unsigned 'int)))"      #t (unsigned-char-tyda? (make-it-tyda (make-double-it 'unsigned 'char))))
(is-ok 16 "(unsigned-short-tyda? ... 'unsigned 'short)))"   #t (unsigned-short-tyda? (make-it-tyda (make-double-it 'unsigned 'short))))
(is-ok 17 "(unsigned-int-tyda? ... 'unsigned 'int)))"       #t (unsigned-int-tyda? (make-it-tyda (make-double-it 'unsigned 'int))))
(is-ok 18 "(unsigned-long-tyda? ... 'unsigned 'long)))"     #t (unsigned-long-tyda? (make-it-tyda (make-double-it 'unsigned 'long))))


(is-ok 19 "(tyda? (make-ptr-tyda (make-single-it 'void)))"          #t (tyda? (make-ptr-tyda (make-single-it 'void))))
(is-ok 20 "(ptr-tyda? (make-ptr-tyda (make-single-it 'void)))"      #t (ptr-tyda? (make-ptr-tyda (make-single-it 'void))))

