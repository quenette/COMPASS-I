#!/usr/bin/guile -s
!#

(use-modules (guiletap))
(load "../c-Type_Denotable.scm")
(load "../c-IdentifierType.scm")


; tests ...
(plan 20)
(is-ok  1 "(tyde? (make-tyob-tyde (make-single-it 'void)))"           #t (tyde? (make-tyob-tyde (make-single-it 'void))))
(is-ok  2 "(it? (make-tyob-tyde (make-single-it 'void)))"             #t (it? (make-tyob-tyde (make-single-it 'void))))
(is-ok  3 "(tyde? (make-tyob-tyde (make-double-it 'unsigned 'int)))"  #t (tyde? (make-tyob-tyde (make-double-it 'unsigned 'int))))
(is-ok  4 "(it? (make-tyob-tyde (make-double-it 'unsigned 'int)))"    #t (it? (make-tyob-tyde (make-double-it 'unsigned 'int))))

(is-ok  5 "(void-tyde? ... 'void)))"                        #t (void-tyde? (make-tyob-tyde (make-single-it 'void))))
(is-ok  6 "(char-tyde? ... 'char)))"                        #t (char-tyde? (make-tyob-tyde (make-single-it 'char))))
(is-ok  7 "(short-tyde? ... 'short)))"                      #t (short-tyde? (make-tyob-tyde (make-single-it 'short))))
(is-ok  8 "(int-tyde? ... 'int)))"                          #t (int-tyde? (make-tyob-tyde (make-single-it 'int))))
(is-ok  9 "(long-tyde? ... 'long)))"                        #t (long-tyde? (make-tyob-tyde (make-single-it 'long))))
(is-ok 10 "(float-tyde? ... 'float)))"                      #t (float-tyde? (make-tyob-tyde (make-single-it 'float))))
(is-ok 11 "(double-tyde? ... 'double)))"                    #t (double-tyde? (make-tyob-tyde (make-single-it 'double))))
(is-ok 12 "(long-double-tyde? ... 'long 'double)))"         #t (long-double-tyde? (make-tyob-tyde (make-double-it 'long 'double))))

(is-ok 13 "(signed-tyde? ...'signed)))"                     #t (signed-tyde? (make-tyob-tyde (make-single-it 'signed))))
(is-ok 14 "(unsigned-tyde? ... 'unsigned)))"                #t (unsigned-tyde? (make-tyob-tyde (make-single-it 'unsigned))))

(is-ok 15 "(unsigned-char-tyde? ... 'unsigned 'int)))"      #t (unsigned-char-tyde? (make-tyob-tyde (make-double-it 'unsigned 'char))))
(is-ok 16 "(unsigned-short-tyde? ... 'unsigned 'short)))"   #t (unsigned-short-tyde? (make-tyob-tyde (make-double-it 'unsigned 'short))))
(is-ok 17 "(unsigned-int-tyde? ... 'unsigned 'int)))"       #t (unsigned-int-tyde? (make-tyob-tyde (make-double-it 'unsigned 'int))))
(is-ok 18 "(unsigned-long-tyde? ... 'unsigned 'long)))"     #t (unsigned-long-tyde? (make-tyob-tyde (make-double-it 'unsigned 'long))))


(is-ok 19 "(tyde? (make-ptr-tyda ... 'void)))"              #t (tyde? (make-tyob-tyde (make-ptr-tyda (make-single-it 'void)))))
(is-ok 20 "(ptr-tyde? (make-ptr-tyda ... 'void)))"          #t (ptr-tyde? (make-tyob-tyde (make-ptr-tyda (make-single-it 'void)))))

