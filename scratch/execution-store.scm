; Execution-store - A store, whose operations are execution monad operations
;  That is operations on the store as an monadic operation. To be used as 'the' store in the execution monad.
;  This implementation uses a environment (i.e. Env). Where a variable name is not important, a unique one is provided.
;  Where a variable name is provided, it must a StoRef.
; 
; Developed for guile scheme v 1.8.7

(load "jp.scm")
(load "execution.scm")
(load "env.scm")
(load "storef.scm")


; Constructors ...

; empty-store : () -> Sto
(define empty-store
   (lambda ()
      (empty-env)
))


; not sure if I'll use this...
; e-alloc-jpns : Val -> JP -> Sto -> (StoRef x Sto)
(define e-alloc-jpns
   (lambda (v)
      (lambda (jp s)
         ((e-named-alloc (new-storef jp (unique-storef-var s)) v) jp s)
)))

; e-alloc : Val -> JP -> Sto -> (StoRef x Sto)
(define e-alloc
   (lambda (v)
      (lambda (jp s)
         ((e-named-alloc (unique-storef-var s) v) jp s)
)))

; e-named-alloc : StoRef -> Val -> JP -> Sto -> (StoRef x Sto)
(define e-named-alloc
   (lambda (r v)
      (lambda (jp s)
         (let ((new-s (extend-env r v s)))
            `(,(apply-env new-s r) . ,new-s)
))))

; e-deref : StoRef -> JP -> Sto -> (Val x Sto)
(define e-deref
   (lambda (r)
      (lambda (jp s)
         `(,(apply-env s r) . ,s)
)))

; e-setref : StoRef -> Val -> JP -> Sto -> (Val x Sto)
(define e-setref
   (lambda (r v)
      (lambda (jp s)
         `(,v . ,(extend-env r v s))
)))


; Other methods...

; unique-storef-var: Sto -> Var
; Note this assumes a very naive model for reference name creation (EOPLv3 ch4) ... just use the current count which here is 
; approximated to the amount of entries in the environment (will be >= count).
(define unique-storef-var
   (lambda (e)
      (env-length e)
))




; Testing...
(let ((jp1 ((new-call-jp 'pcall "myProc" (list 1 2 3)) "myJP"))
     )
     (let ((s1 (empty-store))
          )
          (let ((e1 (e-alloc 5))
                (e2 (e-alloc-jpns 9))
               )
               (let ((seq1 ((seq-e e1 return-e) jp1 s1))
                     (seq2 ((seq-e e1 (lambda (x) e2)) jp1 s1))
                     (seq3 ((seq-e e1 (lambda (x) (seq-e e2 (lambda (y) (e-deref 0))))) jp1 s1))
                     (seq4 ((seq-e e1 (lambda (x) (seq-e e2 (lambda (y) (e-deref `(,jp1 . 1)))))) jp1 s1))
                     (seq5 ((seq-e e1 (lambda (x) (seq-e e2 (lambda (y) (seq-e (e-setref 0 11) (lambda (z) (e-deref 0)) ) )))) jp1 s1))
                    )
                    (begin 
                       (display "jp1: ") (display jp1) (display "\n")
                       (display "s1: ") (display s1) (display "\n")
                       (display "(e1 jp1 s1): ") (display (e1 jp1 s1)) (display "\n")
                       (display "seq1: ") (display seq1) (display "\n")
                       (display "seq2: ") (display seq2) (display "\n")
                       (display "seq5: ") (display seq5) (display "\n")
                       (display "tval->val( seq3 ) [i.e 0]: ") (display (tval->val seq3)) (display "\n") ; 5
                       (display "tval->val( seq4 ) [i.e.(jp1 . 1)]: ") (display (tval->val seq4)) (display "\n") ; 9
                       (display "tval->val( seq5 ) [i.e. 0]: ") (display (tval->val seq5)) (display "\n") ; 11
)))))


