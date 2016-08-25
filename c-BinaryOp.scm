;
; Semantic algebras...
;   Domain bo in BinaryOp = UnaryOpKind x Expr
;    (Domain k_bo in UnaryOpKind in Kind)
;    (Domain id in Id)
;    (Domain E in Expr)
;    (Domain v in Val)
;
; Abstract syntax...
;  bo in BinaryOp
;
;  UnaryOpKind  ::= 'bo-* | 'bo-/ | 'bo-+ | 'bo-- | 'bo-< | 'bo-> | 'bo-<= | 'bo->=
;  BinaryOp      ::= < k_bo E_1 E_2 >
;
; Valuation functions...
;  BinaryOp[[k_bo E_1 E_2]]       = () -> BinaryOp
;
; Developed for guile scheme v 1.8.7


(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-execution-store.scm")
(load "c-Identifier.scm")


; Construction operations ...

; make-*-bo : Id -> BinaryOp
(define make-*-bo
   (lambda (E_1 E_2)
      (list 'bo-* E_1 E_2)
))

; make-/-bo : Id -> BinaryOp
(define make-/-bo
   (lambda (E_1 E_2)
      (list 'bo-/ E_1 E_2)
))

; make-+-bo : Id -> BinaryOp
(define make-+-bo
   (lambda (E_1 E_2)
      (list 'bo-+ E_1 E_2)
))

; make---bo : Id -> BinaryOp
(define make---bo
   (lambda (E_1 E_2)
      (list 'bo-- E_1 E_2)
))

; make-<-bo : Id -> BinaryOp
(define make-<-bo
   (lambda (E_1 E_2)
      (list 'bo-< E_1 E_2)
))

; make->-bo : Id -> BinaryOp
(define make->-bo
   (lambda (E_1 E_2)
      (list 'bo-> E_1 E_2)
))

; make-<=-bo : Id -> BinaryOp
(define make-<=-bo
   (lambda (E_1 E_2)
      (list 'bo-<= E_1 E_2)
))

; make->=-bo : Id -> BinaryOp
(define make->=-bo
   (lambda (E_1 E_2)
      (list 'bo->= E_1 E_2)
))


; Other operations ...

; "Apply"
; e-bo : BinaryOp -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )             ; i.e. BinaryOp -> T(Val)
(define e-bo
   (lambda (bo)
      (lambda (jp zeta rho s)
         ((seq-e
            (e-E (bo->E_1 bo))
            (lambda (v_1) (seq-e
               (e-E (bo->E_2 bo))
               (lambda (v_2) 
                  (cond
                     ((*-bo? bo)     (return-e (*  v_1 v_2)))
                     ((/-bo? bo)     (return-e (/  v_1 v_2)))
                     ((+-bo? bo)     
                        (cond
                           ; TODO - hack such that char can be treated as an int... proper type casting/converstion needed
                           ((and (char? v_1) (char? v_2))   (return-e (integer->char (+ (char->integer v_1) (char->integer v_2)))))
                           ((char? v_1)   (return-e (integer->char (+ (char->integer v_1) v_2))))
                           (else    (return-e (+ v_1 v_2)))
                     ))
                     ((--bo? bo)     (return-e (-  v_1 v_2)))
                     ((<-bo? bo)     (return-e (<  v_1 v_2)))
                     ((>-bo? bo)     (return-e (>  v_1 v_2)))
                     ((<=-bo? bo)    (return-e (<= v_1 v_2)))
                     ((>=-bo? bo)    (return-e (>= v_1 v_2)))
                     (else (return-e (display "Fail: Unknown binary operator: ")(display (bo->kind bo))(newline)))
         ))))) jp zeta rho s)
)))


; Predicate operations...

; bo? : Any -> Bool
(define bo?
   (lambda (bo)
      (cond 
         ((and (has-kind? bo) (eqv? (bo->kind bo) 'bo-*))  #t)
         ((and (has-kind? bo) (eqv? (bo->kind bo) 'bo-/))  #t)
         ((and (has-kind? bo) (eqv? (bo->kind bo) 'bo-+))  #t)
         ((and (has-kind? bo) (eqv? (bo->kind bo) 'bo--))  #t)
         ((and (has-kind? bo) (eqv? (bo->kind bo) 'bo-<))  #t)
         ((and (has-kind? bo) (eqv? (bo->kind bo) 'bo->))  #t)
         ((and (has-kind? bo) (eqv? (bo->kind bo) 'bo-<=)) #t)
         ((and (has-kind? bo) (eqv? (bo->kind bo) 'bo->=)) #t)
         (else #f)
)))

; *-bo? : Any -> Bool
(define *-bo?
   (lambda (bo)
      (cond 
         ((and (has-kind? bo) (eqv? (bo->kind bo) 'bo-*)) #t)
         (else #f)
)))


; /-bo? : Any -> Bool
(define /-bo?
   (lambda (bo)
      (cond 
         ((and (has-kind? bo) (eqv? (bo->kind bo) 'bo-/)) #t)
         (else #f)
)))

; +-bo? : Any -> Bool
(define +-bo?
   (lambda (bo)
      (cond 
         ((and (has-kind? bo) (eqv? (bo->kind bo) 'bo-+)) #t)
         (else #f)
)))

; --bo? : Any -> Bool
(define --bo?
   (lambda (bo)
      (cond 
         ((and (has-kind? bo) (eqv? (bo->kind bo) 'bo--)) #t)
         (else #f)
)))

; <-bo? : Any -> Bool
(define <-bo?
   (lambda (bo)
      (cond 
         ((and (has-kind? bo) (eqv? (bo->kind bo) 'bo-<)) #t)
         (else #f)
)))

; >-bo? : Any -> Bool
(define >-bo?
   (lambda (bo)
      (cond 
         ((and (has-kind? bo) (eqv? (bo->kind bo) 'bo->)) #t)
         (else #f)
)))

; <=-bo? : Any -> Bool
(define <=-bo?
   (lambda (bo)
      (cond 
         ((and (has-kind? bo) (eqv? (bo->kind bo) 'bo-<=)) #t)
         (else #f)
)))

; >=-bo? : Any -> Bool
(define >=-bo?
   (lambda (bo)
      (cond 
         ((and (has-kind? bo) (eqv? (bo->kind bo) 'bo->=)) #t)
         (else #f)
)))


; Extraction operations...

; bo->kind : BinaryOp -> Kind
(define bo->kind
   (lambda (bo)
      (car bo)
))

; bo->E_1 : BinaryOp -> Expr
(define bo->E_1
   (lambda (bo)
      (cadr bo)
))

; bo->E_2 : BinaryOp -> Expr
(define bo->E_2
   (lambda (bo)
      (caddr bo)
))


; Valuation functions ...

; BinaryOp[[k_bo E_1 E_2]] = () -> BinaryOp
(define ast->bo
   (lambda (py_ast_var)
      ; First - work out what type of expression this is...
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "BinaryOp" node_type)
                 ; Second - valuate the code
                 (let ((k_ou (python-eval (string-append py_ast_var ".op.encode('ascii')") #t))
                       (E_1    (ast->E (string-append py_ast_var ".children()[0][1]")))
                       (E_2    (ast->E (string-append py_ast_var ".children()[1][1]")))
                      )
                      (cond
                         ((string=? "*" k_ou)  (make-*-bo E_1 E_2))
                         ((string=? "/" k_ou)  (make-/-bo E_1 E_2))
                         ((string=? "+" k_ou)  (make-+-bo E_1 E_2))
                         ((string=? "-" k_ou)  (make---bo E_1 E_2))
                         ((string=? "<" k_ou)  (make-<-bo E_1 E_2))
                         ((string=? ">" k_ou)  (make->-bo E_1 E_2))
                         ((string=? "<=" k_ou) (make-<=-bo E_1 E_2))
                         ((string=? ">=" k_ou) (make->=-bo E_1 E_2))
                         ; else error (not fail!) - binary operator not yet implemented!!!
                         (else 
                            (display "Error: \"")(display k_ou)(display "\" \"BinaryOp\" not yet implemented")(newline)
                            (exit)
                         )
              )))
              (else 
                 (display "Error: \"")(display node_type)(display "\" wrong for ast->bo, was expecting \"BinaryOp\"")(newline)
                 (exit)
              )
))))

; BinaryOpApply[[bo]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )    ; i.e () -> T(Val)
(define ast->e-bo
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-bo (ast->bo py_ast_var)) jp zeta rho s)
)))


