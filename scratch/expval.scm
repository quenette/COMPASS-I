; ExpVal data type
;  Resultant values of expressions
;
; Grammars
;
; ExpVal = Int + Bool + Proc
; ExpVal ::= ('int-val     val)
;        ::= ('bool-val    val)
;        ::= ('proc-val    val)
; ExpValKind :: = 'int-val | bool-val | proc-val | call-val
;
; Largely motivated from EOPLv3, code in 3.2.8
;  One particular difference is ???
; 
; Developed for guile scheme v 1.8.7

(load "error.scm")


; Constructors for this data type...

; int-val : Int -> ExpVal
(define int-val
   (lambda (int) 
      (list 'int-val int)
))

; bool-val : Bool -> ExpVal
(define bool-val
   (lambda (bool) 
      (list 'bool-val bool)
))

; proc-val : Proc -> ExpVal
(define proc-val
   (lambda (proc) 
      (list 'proc-val proc)
))


; Predicates for the data type...

; expval? : SchemeVal -> Bool
(define expval?
   (lambda (expval)
      (cond
         ((eqv? (expval->kind expval) 'int-val)
            #t)
         ((eqv? (expval->kind expval) 'bool-val)
            #t)
         ((eqv? (expval->kind expval) 'proc-val)
            #t)
         (else 
            #f)
)))

; int-val? : ExpVal -> Bool
(define int-val?
   (lambda (expval)
      (cond
         ((eqv? (expval->kind expval) 'int-val) 
            #t)
         (else 
            #f)
)))

; bool-val? : ExpVal -> Bool
(define bool-val?
   (lambda (expval)
      (cond
         ((eqv? (expval->kind expval) 'bool-val)
            #t)
         (else 
            #f)
)))

; proc-val? : ExpVal -> Bool
(define proc-val?
   (lambda (expval)
      (cond
         ((eqv? (expval->kind expval) 'proc-val)
            #t)
         (else 
            #f)
)))

; Extractors for the data type...

; expval->kind : ExpVal -> ExpValKind
(define expval->kind
   (lambda (expval)
      (car expval)
))

; expval->int : ExpVal -> Int_b
(define expval->int
   (lambda (expval)
      (cond
         ((int-val? expval) (cadr expval))
         ; Fail with commentry...
         (else (error 'expval->int "Bad extractor 'num: ~s" expval)) 
)))

; expval->bool : ExpVal -> Bool_b
(define expval->bool
   (lambda (expval)
      (cond
         ((bool-val? expval) (cadr expval))
         ; Fail with commentry...
         (else (error 'expval->bool "Bad extractor 'bool: ~s" expval))
)))

; expval->proc : ExpVal -> Proc_b
(define expval->proc
   (lambda (expval)
      (cond
         ((proc-val? expval) (cadr expval))
         ; Fail with commentry...
         (else (error 'expval->proc "Bad extractor 'proc: ~s" expval))
)))



; tests ...
(display "(int-val 5): ") (display (int-val 5)) (display"\n")
(display "(bool-val #t): ") (display (bool-val #t)) (display"\n")
(display "(proc-val 'hack): ") (display (proc-val 'hack)) (display"\n")
(display "(expval? (int-val 5)): ") (display (expval? (int-val 5))) (display"\n")
(display "(expval? (bool-val #t)): ") (display (expval? (bool-val #t))) (display"\n")
(display "(expval? (proc-val 'hack)): ") (display (expval? (proc-val 'hack))) (display"\n")
(display "(expval? (list 1 2)): ") (display (expval? (list 1 2))) (display"\n")
(display "(int-val? (int-val 5)): ") (display (int-val? (int-val 5))) (display"\n")
(display "(bool-val? (bool-val #t)): ") (display (bool-val? (bool-val #t))) (display"\n")
; Delay until proc module...
;(display "(proc-val? (proc-val 'hack)): ") (display (proc-val? (proc-val 'hack))) (display"\n")
(display "(expval->kind (int-val 5)): ") (display (expval->kind (int-val 5))) (display"\n")
(display "(expval->kind (bool-val #t)): ") (display (expval->kind (bool-val #t))) (display"\n")
(display "(expval->kind (proc-val 'hack)): ") (display (expval->kind (proc-val 'hack))) (display"\n")
(display "(expval->int (int-val 5)): ") (display (expval->int (int-val 5))) (display"\n")
(display "(expval->bool (bool-val #t)): ") (display (expval->bool (bool-val #t))) (display"\n")
(display "(expval->proc (proc-val 'hack)): ") (display (expval->proc (proc-val 'hack))) (display"\n")

