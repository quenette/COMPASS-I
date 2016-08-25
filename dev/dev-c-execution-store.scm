; 
; Developed for guile scheme v 1.8.7

(load "../c-execution-store.scm")

(define jp1 ((new-call-jp "myProc" (list 1 2 3)) "myJP"))
(define zeta1 '())
(define rho1 (make-env 0 100000))
(define s1  (empty-s))

(define e1 (e-alloc 2))
(define r1 (e1 jp1 zeta1 rho1 s1))
(display "e1 val: ") (display (tval->val r1)) (display "\n")   ; = 100000
(display "e1 rho: ") (display (tval->rho r1)) (display "\n")   ; next-l = 100002
(display "e1 s:   ") (display (tval->s r1))   (display "\n")

(define e2 (e-newref "i" 0 '()))
(define r2 (e2 jp1 zeta1 rho1 s1))
(display "e2 val: ") (display (tval->val r2)) (display "\n")   ; = 0
(display "e2 rho: ") (display (tval->rho r2)) (display "\n")   ; i = 0
(display "e2 s:   ") (display (tval->s r2))   (display "\n")

(define e3 (e-decl "j" 2 '()))
(define r3 (e3 jp1 zeta1 rho1 s1))
(display "e3 val: ") (display (tval->val r3)) (display "\n")   ; = 100000
(display "e3 rho: ") (display (tval->rho r3)) (display "\n")   ; next-l = 100002, j = 100000
(display "e3 s:   ") (display (tval->s r3))   (display "\n")

(define e4 (e-decl "k" 1 '()))
(define r4 (e4 jp1 zeta1 rho1 s1))
(display "e4 val: ") (display (tval->val r4)) (display "\n")   ; = 100000
(display "e4 rho: ") (display (tval->rho r4)) (display "\n")   ; next-l = 100001, k = 100000
(display "e4 s:   ") (display (tval->s r4))   (display "\n")

(define r5 ((seq-e e3 (lambda (x) e4)) jp1 zeta1 rho1 s1))
(display "r5 val: ") (display (tval->val r5)) (display "\n")   ; = 100002
(display "r5 rho: ") (display (tval->rho r5)) (display "\n")   ; next-l = 100003, j = 100000, k = 100002
(display "r5 s:   ") (display (tval->s r5))   (display "\n")

(define r6 ((seq-e e1 (lambda (x) (seq-e e2 (lambda (y) (seq-e e3 (lambda (z) e4)))))) jp1 zeta1 rho1 s1))
(display "r6 val: ") (display (tval->val r6)) (display "\n")   ; = 100004
(display "r6 rho: ") (display (tval->rho r6)) (display "\n")   ; next-l = 100005, i = 0, j = 100002, k = 100004
(display "r6 s:   ") (display (tval->s r6))   (display "\n")

(define r7 ((seq-e (e-setref "i" 13) (lambda (x) (seq-e (e-setref "j" 27) (lambda (y) (e-setref "k" 33))))) jp1 (tval->zeta r6) (tval->rho r6) (tval->s r6)))
(display "r7 val: ") (display (tval->val r7)) (display "\n")   ; = 33
(display "r7 rho: ") (display (tval->rho r7)) (display "\n")   ; next-l = 100005, i => 13, j => 27, k => 33
(display "r7 s:   ") (display (tval->s r7))   (display "\n")

(define r8 ((e-deref "i") jp1 (tval->zeta r7) (tval->rho r7) (tval->s r7)))
(display "r8 val: ") (display (tval->val r8)) (display "\n")   ; = 13

(define r9 ((e-deref "j") jp1 (tval->zeta r8) (tval->rho r8) (tval->s r8)))
(display "r9 val: ") (display (tval->val r9)) (display "\n")   ; = 27

(define r10 ((e-deref "k") jp1 (tval->zeta r9) (tval->rho r9) (tval->s r9)))
(display "r10 val: ") (display (tval->val r10)) (display "\n")   ; = 33

(define r11 ((e-cpenv 0) jp1 (tval->zeta r10) (tval->rho r10) (tval->s r10)))
(display "r11 rho: ") (display (tval->rho r11)) (display "\n")   ; same as r7
(display "r11 val: ") (display (tval->val r11)) (display "\n")   ; same as r7

(define r12 ((e-setenv (tval->rho r10)) jp1 (tval->zeta r10) rho1 (tval->s r10)))
(display "r12 rho: ") (display (tval->rho r12)) (display "\n")   ; same as r7
(display "r12 val: ") (display (tval->val r12)) (display "\n")   ; same as r7

(define e13 (e-allocn 2 5))
(define r13 (e13 jp1 zeta1 rho1 s1))
(display "e13 val: ") (display (tval->val r13)) (display "\n")   ; = 100000
(display "e13 rho: ") (display (tval->rho r13)) (display "\n")   ; next-l = 100010
(display "e13 s:   ") (display (tval->s r13))   (display "\n")   ; (empty-s)

(define e14 (e-decln "j" 2 4 '()))
(define r14 (e14 jp1 zeta1 rho1 s1))
(display "e14 val: ") (display (tval->val r14)) (display "\n")   ; = 100000
(display "e14 rho: ") (display (tval->rho r14)) (display "\n")   ; next-l = 100008, j = 100000
(display "e14 s:   ") (display (tval->s r14))   (display "\n")   ; (empty-s)

(define r15' ((e-decln "x" 1 4 '()) jp1 zeta1 rho1 s1))
(define e15 (e-extend-sn 100000 7 4))
(define r15 (e15 jp1 (tval->zeta r15') (tval->rho r15') (tval->s r15')))
(display "e15 val: ") (display (tval->val r15)) (display "\n")   ; 4
(display "e15 rho: ") (display (tval->rho r15)) (display "\n")   ; next-l = 100004, x = 100000
(display "e15 s:   ") (display (tval->s r15))   (display "\n")   ; (extend-s 100003 7 (extend-s 100002 7 (extend-s 100001 7 (extend-s 100000 7 (empty-s)))))

(define r16' ((e-decln "x" 1 4 '()) jp1 zeta1 rho1 s1))
(define e16 (e-extend-s* 100000 (list 7 11 13 21) 4))
(define r16 (e16 jp1 (tval->zeta r16') (tval->rho r16') (tval->s r16')))
(display "e16 val: ") (display (tval->val r16)) (display "\n")   ; 4
(display "e16 rho: ") (display (tval->rho r16)) (display "\n")   ; next-l = 100004, x = 100000
(display "e16 s:   ") (display (tval->s r16))   (display "\n")   ; (extend-s 100003 21 (extend-s 100002 13 (extend-s 100001 11 (extend-s 100000 7 (empty-s)))))



