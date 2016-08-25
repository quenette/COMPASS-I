#!/usr/bin/guile -env
!#

(use-modules (guiletap))
(load "../c-execution-store.scm")


(define jp1 ((new-call-jp "myProc" (list 1 2 3)) "myJP"))
(define zeta1 '())
(define rho1 (make-env 0 100000))
(define s1  (empty-s))


(plan 73)

(define e1 (e-alloc 2))
(define r1 (e1 jp1 zeta1 rho1 s1))
(is-ok  1 "r1 val: "                       100000             (tval->val r1))
(is-ok  2 "r1 next-l: "                    100002             (apply-env 'next-l (tval->rho r1)))

(define e2 (e-newref "i" 100000 '()))
(define r2 (e2 jp1 zeta1 rho1 s1))
(is-ok  3 "r2 val: "                       100000             (tval->val r2))
(is-ok  4 "r2 i: "                         100000             (apply-env "i" (tval->rho r2)))
(is-ok  5 "r2 next-l: "                    100000             (apply-env 'next-l (tval->rho r2)))

(define e3 (e-decl "j" 2 '()))
(define r3 (e3 jp1 zeta1 rho1 s1))
(is-ok  6 "r3 val: "                       100000             (tval->val r3))
(is-ok  7 "r3 j: "                         100000             (apply-env "j" (tval->rho r3)))
(is-ok  8 "r3 next-l: "                    100002             (apply-env 'next-l (tval->rho r3)))

(define e4 (e-decl "k" 1 '()))
(define r4 (e4 jp1 zeta1 rho1 s1))
(is-ok  9 "r4 val: "                       100000             (tval->val r4))
(is-ok 10 "r4 k: "                         100000             (apply-env "k" (tval->rho r4)))
(is-ok 11 "r4 next-l: "                    100001             (apply-env 'next-l (tval->rho r4)))

(define r5 ((seq-e e3 (lambda (x) e4)) jp1 zeta1 rho1 s1))
(is-ok 12 "r5 val: "                       100002             (tval->val r5))
(is-ok 13 "r5 j: "                         100000             (apply-env "j" (tval->rho r5)))
(is-ok 14 "r5 k: "                         100002             (apply-env "k" (tval->rho r5)))
(is-ok 15 "r5 next-l: "                    100003             (apply-env 'next-l (tval->rho r5)))

(define r6 ((seq-e e1 (lambda (x) (seq-e e2 (lambda (y) (seq-e e3 (lambda (z) e4)))))) jp1 zeta1 rho1 s1))
(is-ok 16 "r6 val: "                       100004             (tval->val r6))
(is-ok 17 "r6 i: "                         100000             (apply-env "i" (tval->rho r6)))
(is-ok 18 "r6 j: "                         100002             (apply-env "j" (tval->rho r6)))
(is-ok 19 "r6 k: "                         100004             (apply-env "k" (tval->rho r6)))
(is-ok 20 "r6 next-l: "                    100005             (apply-env 'next-l (tval->rho r6)))

(define r7 ((seq-e (e-setref "i" 13) (lambda (x) (seq-e (e-setref "j" 27) (lambda (y) (e-setref "k" 33))))) jp1 (tval->zeta r6) (tval->rho r6) (tval->s r6)))
(is-ok 21 "r7 val: "                            33            (tval->val r7))
(is-ok 22 "r7 i: "                              13            (apply-s 100000 (tval->s r7)))
(is-ok 23 "r7 j: "                              27            (apply-s 100002 (tval->s r7)))
(is-ok 24 "r7 k: "                              33            (apply-s 100004 (tval->s r7)))

(define r8 ((e-deref "i") jp1 (tval->zeta r7) (tval->rho r7) (tval->s r7)))
(is-ok 25 "r8 val: "                            13            (tval->val r8))

(define r9 ((e-deref "j") jp1 (tval->zeta r8) (tval->rho r8) (tval->s r8)))
(is-ok 26 "r9 val: "                            27            (tval->val r9))

(define r10 ((e-deref "k") jp1 (tval->zeta r9) (tval->rho r9) (tval->s r9)))
(is-ok 27 "r10 val: "                           33            (tval->val r10))

(define r11 ((e-cpenv 0) jp1 (tval->zeta r10) (tval->rho r10) (tval->s r10)))
(is-ok 28 "r11 rho ... k = 100004"              #t            (equal? (apply-env "k" (tval->rho r11)) 100004))
(is-ok 29 "r11 rho ... j = 100002"              #t            (equal? (apply-env "j" (tval->rho r11)) 100002))
(is-ok 30 "r11 rho ... i = 100000"              #t            (equal? (apply-env "i" (tval->rho r11)) 100000))
(is-ok 31 "r11 rho ... 'next-l = 100005"        #t            (equal? (apply-env 'next-l (tval->rho r11)) 100005)) 
(is-ok 32 "r11 rho ... 'next-l = 100004"        #f            (equal? (apply-env 'next-l (tval->rho r11)) 100004)) 
(is-ok 33 "r11 rho ... 'next-l = 100002"        #f            (equal? (apply-env 'next-l (tval->rho r11)) 100002)) 
(is-ok 34 "r11 rho ... 'next-l = 100000"        #f            (equal? (apply-env 'next-l (tval->rho r11)) 100000)) 
(is-ok 35 "r11 val ... k = 100004"              #t            (equal? (apply-env "k" (tval->val r11)) 100004))
(is-ok 36 "r11 val ... j = 100002"              #t            (equal? (apply-env "j" (tval->val r11)) 100002))
(is-ok 37 "r11 val ... i = 100000"              #t            (equal? (apply-env "i" (tval->val r11)) 100000))
(is-ok 38 "r11 val ... 'next-l = 100005"        #t            (equal? (apply-env 'next-l (tval->val r11)) 100005)) 
(is-ok 39 "r11 val ... 'next-l = 100004"        #f            (equal? (apply-env 'next-l (tval->val r11)) 100004)) 
(is-ok 40 "r11 val ... 'next-l = 100002"        #f            (equal? (apply-env 'next-l (tval->val r11)) 100002)) 
(is-ok 41 "r11 val ... 'next-l = 100000"        #f            (equal? (apply-env 'next-l (tval->val r11)) 100000)) 

(define r12 ((e-setenv (tval->rho r10)) jp1 (tval->zeta r10) rho1 (tval->s r10)))
(is-ok 42 "r12 rho ... k = 100004"              #t            (equal? (apply-env "k" (tval->rho r12)) 100004))
(is-ok 43 "r12 rho ... j = 100002"              #t            (equal? (apply-env "j" (tval->rho r12)) 100002))
(is-ok 44 "r12 rho ... i = 100000"              #t            (equal? (apply-env "i" (tval->rho r12)) 100000))
(is-ok 45 "r12 rho ... 'next-l = 100005"        #t            (equal? (apply-env 'next-l (tval->rho r12)) 100005)) 
(is-ok 46 "r12 rho ... 'next-l = 100004"        #f            (equal? (apply-env 'next-l (tval->rho r12)) 100004)) 
(is-ok 47 "r12 rho ... 'next-l = 100002"        #f            (equal? (apply-env 'next-l (tval->rho r12)) 100002)) 
(is-ok 48 "r12 rho ... 'next-l = 100000"        #f            (equal? (apply-env 'next-l (tval->rho r12)) 100000)) 
(is-ok 49 "r12 val ... k = 100004"              #t            (equal? (apply-env "k" (tval->val r12)) 100004))
(is-ok 50 "r12 val ... j = 100002"              #t            (equal? (apply-env "j" (tval->val r12)) 100002))
(is-ok 51 "r12 val ... i = 100000"              #t            (equal? (apply-env "i" (tval->val r12)) 100000))
(is-ok 52 "r12 val ... 'next-l = 100005"        #t            (equal? (apply-env 'next-l (tval->val r12)) 100005)) 
(is-ok 53 "r12 val ... 'next-l = 100004"        #f            (equal? (apply-env 'next-l (tval->val r12)) 100004)) 
(is-ok 54 "r12 val ... 'next-l = 100002"        #f            (equal? (apply-env 'next-l (tval->val r12)) 100002)) 
(is-ok 55 "r12 val ... 'next-l = 100000"        #f            (equal? (apply-env 'next-l (tval->val r12)) 100000)) 

(define r13 ((e-allocn 2 5) jp1 zeta1 rho1 s1))
(is-ok 56 "r13 val ... 100000"                  #t            (equal? (tval->val r13) 100000))
(is-ok 57 "r13 rho ... 'next-l = 100010"        #t            (equal? (apply-env 'next-l (tval->rho r13)) 100010)) 

(define r14 ((e-decln "j" 2 4 '()) jp1 zeta1 rho1 s1))
(is-ok 58 "r14 rho ... j = 100000"              #t            (equal? (apply-env "j" (tval->rho r14)) 100000))
(is-ok 59 "r14 rho ... 'next-l = 100008"        #t            (equal? (apply-env 'next-l (tval->rho r14)) 100008)) 

(define r15' ((e-decln "x" 1 4 '()) jp1 zeta1 rho1 s1))
(define e15 (e-extend-sn 100000 7 4))
(define r15 (e15 jp1 (tval->zeta r15') (tval->rho r15') (tval->s r15')))
(is-ok 60 "r15 val ... 100000"                  #t            (equal? (tval->val r15) 4))
(is-ok 61 "r15 rho ... x = 100000"              #t            (equal? (apply-env "x" (tval->rho r15)) 100000))
(is-ok 62 "r15 rho ... 'next-l = 100004"        #t            (equal? (apply-env 'next-l (tval->rho r15)) 100004)) 
(is-ok 63 "r15 x[0]"                             7            (apply-s 100000 (tval->s r15)))
(is-ok 64 "r15 x[1]"                             7            (apply-s 100001 (tval->s r15)))
(is-ok 65 "r15 x[2]"                             7            (apply-s 100002 (tval->s r15)))
(is-ok 66 "r15 x[3]"                             7            (apply-s 100003 (tval->s r15)))

(define r16' ((e-decln "x" 1 4 '()) jp1 zeta1 rho1 s1))
(define e16 (e-extend-s* 100000 (list 7 11 13 21) 4))
(define r16 (e16 jp1 (tval->zeta r16') (tval->rho r16') (tval->s r16')))
(is-ok 67 "r16 val ... 100000"                  #t            (equal? (tval->val r16) 4))
(is-ok 68 "r16 rho ... x = 100000"              #t            (equal? (apply-env "x" (tval->rho r16)) 100000))
(is-ok 69 "r16 rho ... 'next-l = 100004"        #t            (equal? (apply-env 'next-l (tval->rho r16)) 100004)) 
(is-ok 70 "r16 x[0]"                             7            (apply-s 100000 (tval->s r16)))
(is-ok 71 "r16 x[1]"                            11            (apply-s 100001 (tval->s r16)))
(is-ok 72 "r16 x[2]"                            13            (apply-s 100002 (tval->s r16)))
(is-ok 73 "r16 x[3]"                            21            (apply-s 100003 (tval->s r16)))



