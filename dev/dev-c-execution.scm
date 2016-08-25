(load "../a-jp.scm")
(load "../c-env.scm")
(load "../c-store.scm")
(load "../c-execution.scm")

(let ((jp1   ((new-call-jp "myProc" (list 1 2 3)) "myJP"))
      (zeta1 '())
      (rho1  (empty-env))
      (s1    (empty-s))
      (e1    (return-e 5))
   )
   (let ((r1    (e1 jp1 zeta1 rho1 s1))
         (seq1a (seq-e e1 return-e))
         (seq1b ((seq-e e1 return-e) jp1 zeta1 rho1 s1))
         (seq2  ((seq-e (lambda (jp zeta rho s) (display "")) return-e) jp1 zeta1 rho1 s1))
         (seq3  ((seq-e e1 (lambda (x) (seq-e (return-e (+ 5 x)) (lambda (y) (return-e (+ 10 y)))))) jp1 zeta1 rho1 s1))
      )
      (begin
         (display "e1: ") (display e1) (display "\n") ;function
         (display "r1: ") (display r1) (display "\n") ; (5 () (empty-env) (empty-s))
         (display "r1->val: ") (display (tval->val r1)) (display "\n") ; 5
         (display "r1->zeta: ") (display (tval->zeta r1)) (display "\n") ; ()
         (display "r1->rho: ") (display (tval->rho r1)) (display "\n") ; (empty-env)
         (display "r1->sto: ") (display (tval->s r1)) (display "\n") ; (empty-s)
         (display "seq1a: ") (display seq1a) (display "\n") ; function
         (display "seq1b: ") (display seq1b) (display "\n") ; (5 () (empty-env) (empty-s))
         (display "seq2: ") (display seq2) (display "\n") ; unspecified
         (display "unspecified?") (display (unspecified? seq2)) (newline) ; #t
         (display "seq3: ") (display seq3) (display "\n") ; (20 () (empty-env) (empty-s))
)))

