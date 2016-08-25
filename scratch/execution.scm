; The Execution Monad.
;  Based on Wand04 Execution Monad model.
;  This module only concerns itself with the monad itself and not the monad operations for the store (see execution-store.scm).
;  Also - from an implelementation point of view, view the result of the monadic operations (a T(Val)) as a data type... tval.
;
; Domains:
;  T(A)_b   = JP -> Sto -> (Val x Sto)_b
;
; In a simplified sense, this is the store monad. However, in addition to a store, a joinpoint is required. That is it conceptually
; says - "all computation occurs at a joinpoint (a point in stack/computation space), and hence it needs to be known". This allows
; for example - advice at any joinpoint.
; 
; Developed for guile scheme v 1.8.7


(load "jp.scm")


; Constructors for this data type...

; return : Val -> T(A)_b   = Val -> ( JP -> Sto -> (Val x Sto)_b )
(define return-e
   (lambda (v)
      (lambda (jp s)
         `(,v . ,s)
)))

; seq : "let" v <= E1 in (E2 v)      [Wand04 monadic notation]
;     : T(A)_b -> (v -> T(B)) -> T(B)_b
(define seq-e
   (lambda (e1 e2)
      (lambda (jp s)
         (let ((r1 (e1 jp s)))
            (cond
               ((tval? r1) ((e2 (tval->val r1)) jp (tval->sto r1)))
               ; else Fail
)))))


; Predicates for this data type...

; tval? : T(Val) -> Bool
(define tval?
   (lambda (tval)
      (pair? tval)
))


; Extractors for this data type...

; tval->val : T(Val) -> Val
(define tval->val
   (lambda (tval)
      (car tval)
))

; tval->sto : T(Val) -> Sto
(define tval->sto
   (lambda (tval)
      (cdr tval)
))


; Testing...
(let ((jp1 ((new-call-jp 'pcall "myProc" (list 1 2 3)) "myJP"))
      (s1  0)
      (e1 (return-e 5))
   )
   (let ((r1    (e1 jp1 s1))
         (seq1a (seq-e e1 return-e))
         (seq1b ((seq-e e1 return-e) jp1 s1))
         (seq2  ((seq-e (lambda (jp s) '<unspecified>) return-e) jp1 s1))
         (seq3  ((seq-e e1 (lambda (x) (seq-e (return-e (+ 5 x)) (lambda (y) (return-e (+ 10 y)))))) jp1 s1))
      )
      (begin
         (display "e1 = (return-e 5): ") (display e1) (display "\n")
         (display "r1 = (e1 jp1 s1): ") (display r1) (display "\n")
         (display "seq1a = (seq-e e1 return-e): ") (display seq1a) (display "\n")
         (display "seq1b = (seq1a jp1 s1): ") (display seq1b) (display "\n")
         (display "seq2 = ((seq-e (lambda (jp s) '<unspecified>) return-e) jp1 s1): ") (display seq2) (display "\n")
         (display "seq3 = ((seq-e e1 (lambda (x) (seq-e (return-e (+ 5 x)) (lambda (y) (return-e (+ 10 y)))))) jp1 s1)): ") (display seq3) (display "\n")
)))

