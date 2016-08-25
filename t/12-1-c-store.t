#!/usr/bin/guile -s
!#

(use-modules (guiletap))
(load "../c-store.scm")


(plan 6)

(define s
   (extend-s 2 6
      (extend-s 0 8
         (extend-s 1 7
            (extend-s 0 14
               (empty-s))))))

(is-ok  1 "(s? s)"                             #t             (s? s))
(is-ok  2 "(s? (list 1 2))"                    #f             (s? (list 1 2)))

(is-ok  3 "(equal? (apply-s 2 s) 6)"          #t             (equal? (apply-s 2 s) 6))
(is-ok  4 "(equal? (apply-s 0 s) 8)"          #t             (equal? (apply-s 0 s) 8))
(is-ok  5 "(equal? (apply-s 1 s) 7)"          #t             (equal? (apply-s 1 s) 7))
(is-ok  6 "(equal? (apply-s 0 s) 14)"         #f             (equal? (apply-s 0 s) 14)) 

