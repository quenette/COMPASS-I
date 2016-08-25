; A PointCut Descriptor (PCD) are a datatype with the following items
;  pcdkind  - the pcd kind: 
;               'pcall for a procedure or function call - in the form (list 'pcall pname), 
;               'ac for the advice combinator on a function call - in the form (list 'ac pname),
;               'args for the parameters of a procedure/function - in the form (list 'args vars),
;               ... and the following combinators for PCDs ...
;               'and - in the form (list 'and pcd1 pcd2) 
;  pname    - the name of the procedure being called
;  vars     - the list of identifiers for the parameters of the procedure being called
;
; This model and the algebra for PCDs is heavily motivated by Wand04. A particular note is that we add 'fcall.
;
; Developed for guile scheme v 1.8.7


(load "a-jp.scm")
(load "a-arglist.scm")


; Constructors for this data type...  (kind of ... actually constructors to ArgLists from PCDs)
; None ... create inline.
; Having said this - constructors would ensure "and" where the terms are flipped actually pass.


; Other operations...

; eqpcd? : PCD -> PCD -> Bool
(define eqpcd?
   (lambda (pcd pcd')
      ; if pcdkind = ...
;(display ">>>>>>>>>>>>>  \"")(display pcd)(display "\" \"")(display pcd')(display "\"\n")
      (cond
         ; 'pcall
         ((and (pcall-pcd? pcd) (pcall-pcd? pcd'))
            (cond
               ((equal? (pcd->pname pcd) (pcd->pname pcd')) #t)
               (else #f)
         ))
         ; 'ac
         ((and (ac-pcd? pcd) (ac-pcd? pcd'))
            (cond
               ((equal? (car (cdr pcd)) (car (cdr pcd'))) #t)
               (else #f)
         ))
         ; 'args
         ((and (args-pcd? pcd) (args-pcd? pcd'))
            (cond
               ((equal? (length (pcd->vars pcd)) (length (pcd->vars pcd'))) #t)
               (else #f)
         ))
         ; 'obj
         ((and (obj-pcd? pcd) (obj-pcd? pcd'))
            (cond
               ((equal? (pcd->obj pcd) (pcd->obj pcd')) #t)
               (else #f)
         ))
         ; 'and
         ((and (and-pcd? pcd) (and-pcd? pcd'))
            (let ((res1 (eqpcd? (pcd->pcd1 pcd) (pcd->pcd1 pcd')))
                  (res2 (eqpcd? (pcd->pcd2 pcd) (pcd->pcd2 pcd'))))
;(display "=============  \"")(display res1)(display "\" \"")(display res2)(display "\"\n")
               (cond
                  ((and res1 res2) #t)
                  (else #f)
         )))
         (else #f)
)))

; match-pcd : PCD x JP -> ArgList
; Note - match-pcd will fail to give the right result when there is an object on the jp but not on the pcd - it will result in an
;  obj match. To compensate always set the obj on the pcd to '<invalid> when there is no obj. 
(define match-pcd
   (lambda (pcd jp)
      ; if pcdkind = ...
      (cond
         ; 'pcall
         ((and (pcall-pcd? pcd) (pcall-jp? jp))
            (cond
               ((equal? (pcd->pname pcd) (jp->pname jp)) (empty-al))
               ; else fail
         ))
         ; 'ac
         ((and (ac-pcd? pcd) (ac-jp? jp))
            (cond
               ((and (equal? (car (cdr pcd)) (jp->pname jp)) (pcall-jp? (jp->jp jp))) (empty-al))
               ; else fail
         ))
         ; 'args
         ((args-pcd? pcd)
            (make-pcd-params (pcd->vars pcd) (jp->vs jp))
         )
         ; 'obj
         ((obj-pcd? pcd)
            (cond
               ((equal? (pcd->obj pcd) (jp->pobj jp)) 
                  ;(display "===>  ")(display (pcd->obj pcd))(display ", ")(display (jp->pobj jp))(newline)
                  (empty-al))
                  ;(else (display "===> XXX  ")(display (pcd->obj pcd))(display ", ")(display (jp->pobj jp))(newline))
         ))
         ; 'and
         ((and-pcd? pcd)
            (let ((res1 (match-pcd (pcd->pcd1 pcd) jp))
                  (res2 (match-pcd (pcd->pcd2 pcd) jp)))
               (cond
                  ((and (pcd-al? res1) (pcd-al? res2)) (merge-al res1 res2))
         )))
         ; there are others ... see Wand04
         ; else fail
)))

; make-pcd-params : Var* -> Val* -> ArgList_b
; Two variants... one where typeinfo matters and one where it doesn't. In the matters case, each element of vars is a (var . ti)
(define make-pcd-params
   (lambda (vars vs)
      (cond
         ((null? vars) (empty-al))
         ((eq? (length vars) (length vs)) 
            (cond
               ; More detailed usage ... the vars are pairs of (val . ti)
               ((pair? (car vars))
                  (extend-al (car (car vars)) (car vs) (make-pcd-params (cdr vars) (cdr vs)) (cdr (car vars)))
               )
               ; else no type info is given, meaning that vars is just a list of val
               (else
                  (extend-al (car vars) (car vs) (make-pcd-params (cdr vars) (cdr vs)) (display ""))
               )
         ))
         ; else fail
)))


; Monad operations...

; PCD[[pcd]] : (T(Val)^rho -> T(Val)) -> T(Val)' -> T(Val)"
;  If the PCD matches the current joinpoint, the function/procedure joinpoints need the arguments copied for the advice's (T(Val))
;  use. The advice needs both the present environment, but also an environment that has a copy of all the arguments to the advice
;  body. Unlike Wand04, we provide a computation to add these argument-copies (T(Val)^rho)to the environment rather than a copy
;  of the present environment plus the copy. (Essentially the same? But more elegant ... the PCD semantic model doesn't allow/
;  encourage inconsistent environments)
;
;  If the PCD match fails, then just compute what was supposed to be executed next (T(Val)'), do nothing to the environment.
;
;  This differs from Wand04 in that the environment is considered part of the monadic store, not a global.
(define e-pcd
   (lambda (pcd k chi)
      (lambda (jp zeta rho s)
         (let ((al (match-pcd pcd jp)))
            (cond
               ((pcd-al? al) 
                  ; apply the advice (the advice body, plus the jp itself, plus the continuation)
                  ;(display "PCD match passed.\n")
                  ((k (e-al->rho al) ) jp zeta rho s)
               )
               (else 
                  ; fail (i.e continue as per normal: the jp itself plus the continuation)...
                  ;(display "PCD match failed.\n")
                  (chi jp zeta rho s)
               )
)))))


; Operations to attempt to support the Wand04 PCD algebra (how two PCD results, which are lists of bindings or a fail, combine)

; pcd-al? : ArgList_b -> Bool
; Idea here is to add the ArgList the ability to for a Fail to be seen as a valid al? call
(define pcd-al?
   (lambda (al)
      (cond
         ((list? al) (al? al))
         (else #f)
)))


; Predicates for the data type...

; Note - because we will compare PCDs where the first terms are lets say 'pcall and the other 'ac,  and the extractors fail for
; 'pcall on an 'ac, the predicates here need to handle "unspecified/bottom" as a false.

; pcall-pcd? : PCD_b -> Bool
(define pcall-pcd?
   (lambda (pcd)
      (cond
         ((list? pcd)   (eq? (car pcd) 'pcall))
         (else #f)
)))

; ac-pcd? : PCD_b -> Bool
(define ac-pcd?
   (lambda (pcd)
      (cond
         ((list? pcd)   (eq? (car pcd) 'ac))
         (else #f)
)))

; args-pcd? : PCD_b -> Bool
(define args-pcd?
   (lambda (pcd)
      (cond
         ((list? pcd)   (eq? (car pcd) 'args))
         (else #f)
)))

; obj-pcd? : PCD_b -> Bool
(define obj-pcd?
   (lambda (pcd)
      (cond
         ((list? pcd)   (eq? (car pcd) 'obj))
         (else #f)
)))

; and-pcd? : PCD_b -> Bool
(define and-pcd?
   (lambda (pcd)
      (cond
         ((list? pcd)   (eq? (car pcd) 'and))
         (else #f)
)))


; Extractors for the data type...

; pcd->pcdkind : PCD -> PCDKind
(define pcd->pcdkind
   (lambda (pcd)
      (car pcd)
))

; pcd->pname : PCD -> PName_b
(define pcd->pname
   (lambda (pcd)
      (cond
         ((pcall-pcd? pcd)  (car (cdr pcd)))
         ; else fail
)))

; pcd->vars : PCD -> Var*_b
(define pcd->vars
   (lambda (pcd)
      (cond
         ((args-pcd? pcd) (car (cdr pcd)))
         ; else fail
)))

; pcd->obj : PCD -> Obj_b   (Val)
(define pcd->obj
   (lambda (pcd)
      (cond
         ((obj-pcd? pcd) (car (cdr pcd)))
         ; else fail
)))

; pcd->pcd1 : PCD -> PCD_b
(define pcd->pcd1
   (lambda (pcd)
      (cond
         ((and-pcd? pcd) (car (cdr pcd)))
         ; else fail
)))

; pcd->pcd2 : PCD -> PCD_b
(define pcd->pcd2
   (lambda (pcd)
      (cond
         ((and-pcd? pcd) (car (cddr pcd)))
         ; else fail
)))

