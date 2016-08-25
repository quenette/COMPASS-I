; StoRef - the model for the references to locations (where data is written to) in the store.
;  These references are a Var (or identifier) relative to a namespace prescribed to be a joinpoint.
;
; Grammars
;
; StoRef ::= < JP, Var >
; Var ::= SchemeVal   At this point Var can be anything - as this code/project/use develops this may not be true (e.g. Var ::= Sym)
;   Note: Identifiers (Var) can be anything so long as equivalency can be performed and is meaningful
; 
; Developed for guile scheme v 1.8.7


(load "jp.scm")


; Constructors for this data type...

; new-storef : JP -> Var -> StoRef
(define new-storef
   (lambda (jp v)
      `(,jp . ,v)
))


; Predicates for this data type...

; storef? SchemeVal -> Bool
(define storef?
   (lambda (r)
      (and (pair? r) (jp? (storef->jp r)))
))


; Extractors for this data type...

; storef->jp : StoRef -> JP
(define storef->jp
   (lambda (r)
      (car r)
))

; storef->var : StoRef -> Var
(define storef->var
   (lambda (r)
      (cdr r)
))   


; Testing...
(let ((jp1 ((new-call-jp 'pcall "myProc" (list 1 2 3)) "myJP"))
      (jp2 ((new-mcall-jp 'pcall "myObj" "myProc" (list 1 2 3)) "myJP"))
      (jp3 ((new-mcall-jp 'pcall "myObj" "myProc" (list 1 2 3)) "myJP")) ; purposely the same as jp2 - to check comparison
   )
   (let ((r1 (new-storef jp1 'myVar))
         (r2 (new-storef jp2 'myVar))
         (r3 (new-storef jp3 'myVar))
        )
        (begin 
           (display "r1: ") (display r1) (display "\n")
           (display "(storef? r1): ") (display (storef? r1)) (display "\n")
           (display "(storef? '<unspecified>): ") (display (storef? '<unspecified>)) (display "\n")
           (display "(storef->jp r1): ") (display (storef->jp r1)) (display "\n")
           (display "(storef->var r1): ") (display (storef->var r1)) (display "\n")
           (display "r2: ") (display r2) (display "\n")
           (display "r3: ") (display r3) (display "\n")
           (display "(equal? r1 r1): ") (display (equal? r1 r1)) (display "\n")
           (display "(equal? r1 r2): ") (display (equal? r1 r2)) (display "\n")
           (display "(equal? r2 r3): ") (display (equal? r2 r3)) (display "\n")
)))

