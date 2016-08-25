#!/usr/bin/guile -env
!#

(use-modules (guiletap))
(load "../a-jp.scm")
(load "../c-env.scm")
(load "../c-store.scm")
(load "../c-execution.scm")


(define jp1  ((new-call-jp "myProc" (list 1 2 3)) "myJP"))
(define zeta1 '())
(define rho1  (empty-env))
(define s1    (empty-s))
(define e1    (return-e 5))

(define r1    (e1 jp1 zeta1 rho1 s1))
(define seq1a (seq-e e1 return-e))
(define seq1b ((seq-e e1 return-e) jp1 zeta1 rho1 s1))
(define seq2  ((seq-e (lambda (jp zeta rho s) (display "")) return-e) jp1 zeta1 rho1 s1))
(define seq3  ((seq-e e1 (lambda (x) (seq-e (return-e (+ 5 x)) (lambda (y) (return-e (+ 10 y)))))) jp1 zeta1 rho1 s1))
(define seq4  ((seq-e (return-e (display "")) return-e) jp1 zeta1 rho1 s1))

(plan 10)

(is-ok  1 "procedure? e1"                            #t             (procedure? e1))

(is-ok  2 "tval? r1"                                 #t             (tval? r1))
(is-ok  3 "val r1"                                   5              (tval->val r1))
(is-ok  4 "rho? r1"                                  #t             (env? (tval->rho r1)))
(is-ok  5 "s? r1"                                    #t             (s? (tval->s r1)))

(is-ok  6 "procedure? seq1a"                         #t             (procedure? seq1a))
(is-ok  7 "val seq1b"                                5              (tval->val seq1b))

(is-ok  8 "unspecified? seq2"                        #t             (unspecified? seq2))

(is-ok  9 "val seq3"                                 20             (tval->val seq3))

(is-ok 10"unspecified? seq4"                         #t             (unspecified? seq4))

