; Motion
;
; Semantic algebras...
;   Domain m in Mot
;   Domain ra in MotRelAttr
;   Domain pname_|m in MotRelMot
;   Domain |p in MotRelPosition
;   Domain |pc in MotRelConstraint
;
; Abstract syntax...
;
;  MotRelAttr ::= first | always
;  MotRelMot ::= pname_m | <>
;  MotRelPosition ::= first | <>
;  MotRelConstraint ::= always | <>
;
;  Mot   ::= < motion o alpha pcd pname pname_|m |p |pc >
;
; Valuation functions...
;   Motion[[ append  after  o_abody   pname_abody   o_jp   pname_jp ]] : T(Val)
;   Motion[[ alwayslast  before  o_abody   pname_abody   o_jp   pname_jp ]] : T(Val)
;   Motion[[ prepend  after  o_abody   pname_abody   o_jp   pname_jp   pname_rabody ] : T(Val)
;
; Developed for guile scheme v 1.8.7


; Constructors...
; None ... I'm just doing these in line


; Execution monadic operations...
; None.

; Other operations...

; matchm : PCD -> PName_abody -> Mot -> Mot_b
(define matchm
   (lambda (pcd pname m)
      (cond
         ((and (eqpcd? pcd (m->pcd m)) (eq? pname (m->pname m))) m)
         ; else fail
)))

; uniquem? : Mot -> Mot' -> Mot_b
(define uniquem?
   (lambda (m m')
      ;(display ">>>>>>>>>>>>>  \"")(display m)(display "\" \"")(display m')(display "\"\n")
      (cond
         (
            (and (and    (m? m)     (m? m')) (and 
                 (eqpcd? (m->pcd m) (m->pcd m')) (and 
                 (eq?    (m->|p m)  (m->|p m')) 
                 (eq?    (m->|pc m) (m->|pc m'))
            )))
            (display "")  ; i.e fail!
         )
         (else m)
)))


; Predicates for the data type...

; m? Any -> Bool
(define m?
   (lambda (m)
      (and (list? m) (eq? (car m) 'motion))
))


; Extractors for the data type...

; m->k: Mot -> Kind
(define m->k
   (lambda (m)
      (car m)
))

; m->o: Mot -> Obj
(define m->o
   (lambda (m)
      (car (cdr m))
))

; m->alpha: Mot -> Adv
(define m->alpha
   (lambda (m)
      (car (cddr m))
))

; m->pcd: Mot -> PCD
(define m->pcd
   (lambda (m)
      (car (cdddr m))
))

; m->pname: Mot -> PName
(define m->pname
   (lambda (m)
      (car (cdr (cdddr m)))
))

; m->pname_|m: Mot -> MotRelMot
(define m->pname_|m
   (lambda (m)
      (car (cddr (cdddr m)))
))

; m->|p: Mot -> MotRelPosition
(define m->|p
   (lambda (m)
      (car (cdddr (cdddr m)))
))

; m->|pc: Mot -> MotRelConstraint
(define m->|pc
   (lambda (m)
      (car (cdr (cdddr (cdddr m))))
))

