#!/usr/bin/guile -s
!#

(use-modules (guiletap))
(load "../error.scm")
(load "../c-type-specifier.scm")


; tests ...
(plan 20)
(is-ok  1 "(make-ts 'void)"                    #t (list? (make-ts 'void)))
(is-ok  2 "(make-ts 'BAD)"                     #f (list? (make-ts 'BAD)))

(is-ok  3 "(ts? (make-ts 'void))"              #t (ts? (make-ts 'void)))
(is-ok  4 "(void-ts? (make-ts 'void))"         #t (void-ts? (make-ts 'void)))

(is-ok  5 "(ts? (make-ts 'char))"              #t (ts? (make-ts 'char)))
(is-ok  6 "(char-ts? (make-ts 'char))"         #t (char-ts? (make-ts 'char)))

(is-ok  7 "(ts? (make-ts 'short))"             #t (ts? (make-ts 'short)))
(is-ok  8 "(short-ts? (make-ts 'short))"       #t (short-ts? (make-ts 'short)))

(is-ok  9 "(ts? (make-ts 'int))"               #t (ts? (make-ts 'int)))
(is-ok 10 "(int-ts? (make-ts 'int))"           #t (int-ts? (make-ts 'int)))

(is-ok 11 "(ts? (make-ts 'long))"              #t (ts? (make-ts 'long)))
(is-ok 12 "(long-ts? (make-ts 'long))"         #t (long-ts? (make-ts 'long)))

(is-ok 13 "(ts? (make-ts 'float))"             #t (ts? (make-ts 'float)))
(is-ok 14 "(float-ts? (make-ts 'float))"       #t (float-ts? (make-ts 'float)))


(is-ok 15 "(ts? (make-ts 'double))"            #t (ts? (make-ts 'double)))
(is-ok 16 "(double-ts? (make-ts 'double))"     #t (double-ts? (make-ts 'double)))

(is-ok 17 "(ts? (make-ts 'signed))"            #t (ts? (make-ts 'signed)))
(is-ok 18 "(signed-ts? (make-ts 'signed))"     #t (signed-ts? (make-ts 'signed)))

(is-ok 19 "(ts? (make-ts 'unsigned))"          #t (ts? (make-ts 'unsigned)))
(is-ok 20 "(unsigned-ts? (make-ts 'unsigned))" #t (unsigned-ts? (make-ts 'unsigned)))


