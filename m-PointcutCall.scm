;
; Semantic algebras...
;   Domain pc in PointcutCall 
;    (Domain k_pc in Kind)
;    (Domain id in Id)
;    (Domain el in ExprList)
;
; Abstract syntax...
;  pc in PointcutCall
;
;  Kind              ::= 'pointcut-call-imperative | 'pointcut-call-add | 'pointcut-call-last
;  PointcutCall      ::= < k_pc id_o id_pname el >
;
; Valuation functions...
;  PointcutCall[[k_pc id_o id_pname el]] = () -> PointcutCall
;
; Developed for guile scheme v 1.8.7


(load "error.scm")
(load "kind.scm")
(load "c-Declaration.scm")
(load "c-ExprList.scm")
(load "a-jp.scm")
(load "a-weave.scm")
(load "m-advices.scm")
(load "m-motions.scm")

; Construction operations ...

; make-pc-imperative : Id x ExprList -> PointcutCall
(define make-pc-imperative
   (lambda (id_o id_pname el)
      (list 'pointcut-call-imperative id_o id_pname el) 
))

; make-pc-add : Id x ExprList -> PointcutCall
(define make-pc-add
   (lambda (id_o id_pname el)
      (list 'pointcut-call-add id_o id_pname el) 
))

; make-pc-sub : Id x ExprList -> PointcutCall
(define make-pc-sub
   (lambda (id_o id_pname el)
      (list 'pointcut-call-sub id_o id_pname el) 
))

; make-pc-first : Id x ExprList -> PointcutCall
(define make-pc-first
   (lambda (id_o id_pname el)
      (list 'pointcut-call-first id_o id_pname el) 
))

; make-pc-last : Id x ExprList -> PointcutCall
(define make-pc-last
   (lambda (id_o id_pname el)
      (list 'pointcut-call-last id_o id_pname el) 
))

; make-pc-min : Id x ExprList -> PointcutCall
(define make-pc-min
   (lambda (id_o id_pname el)
      (list 'pointcut-call-min id_o id_pname el) 
))

; make-pc-max : Id x ExprList -> PointcutCall
(define make-pc-max
   (lambda (id_o id_pname el)
      (list 'pointcut-call-max id_o id_pname el) 
))


; Other operations ...

; "Apply"
; e-pc : PointcutCall -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )        ; i.e. PointcutCall -> T(Val)
(define e-pc
   (lambda (pc)
      (lambda (jp zeta rho s)
         ; Evaluate the function arguments
         ((seq-e
            ;(e-E*->v* (el->E* (pc->el pc)) '())   ... deprecated
            (e-el (pc->el pc))
            ; Then the "function call joinpoint"...
            (lambda (v*) (seq-e
               (let ((pcd (list 'ac (pc->sym_pname pc))))
                  (cond
                     ((imperative-pc? pc) (return-e 0))   ; effectively do nothing
                     ((add-pc? pc)        (appendm (list 'motion '() (e-adv-around pcd "ac-+" e-ac-+) pcd "ac-+" '() '() '())))
                     ((sub-pc? pc)        (appendm (list 'motion '() (e-adv-around pcd "ac--" e-ac--) pcd "ac--" '() '() '())))
                     ((first-pc? pc)      (appendm (list 'motion '() (e-adv-around pcd "ac-first" e-ac-first) pcd "ac-first" '() '() '())))
                     ((last-pc? pc)       (appendm (list 'motion '() (e-adv-around pcd "ac-last" e-ac-last) pcd "ac-last" '() '() '())))
                     ((min-pc? pc)        (appendm (list 'motion '() (e-adv-around pcd "ac-min" e-ac-min) pcd "ac-min" '() '() '())))
                     ((max-pc? pc)        (appendm (list 'motion '() (e-adv-around pcd "ac-max" e-ac-max) pcd "ac-max" '() '() '())))
               ))
               (lambda (x) 
                  (cond
                     ((eqv? (pc->sym_o pc) '<invalid>)
                        (e-jp-chi 
                           (new-call-jp (pc->sym_pname pc) v*)
                           (return-e 'pc-undefined)  ; i.e. result when no advice
                     ))
                     (else 
                        (seq-e
                           (e-apply-env (pc->sym_o pc))
                           (lambda (l_o)
                              (seq-e
                                 (e-deref (pc->sym_o pc))
                                 (lambda (v_o)
                                    (e-jp-chi
                                       (new-mcall-jp l_o (pc->sym_pname pc) (append (list v_o) v*))
                                       (return-e 'pc-undefined)  ;  i.e. result when no advice
                     ))))))
         ))))) jp zeta rho s)
)))


; Predicate operations...

; pc? : Any -> Bool
(define pc?
   (lambda (pc)
      (cond 
         ((and (has-kind? pc) (eqv? (pc->kind pc) 'pointcut-call-imperative)) #t)
         ((and (has-kind? pc) (eqv? (pc->kind pc) 'pointcut-call-add)) #t)
         ((and (has-kind? pc) (eqv? (pc->kind pc) 'pointcut-call-sub)) #t)
         ((and (has-kind? pc) (eqv? (pc->kind pc) 'pointcut-call-first)) #t)
         ((and (has-kind? pc) (eqv? (pc->kind pc) 'pointcut-call-last)) #t)
         ((and (has-kind? pc) (eqv? (pc->kind pc) 'pointcut-call-min)) #t)
         ((and (has-kind? pc) (eqv? (pc->kind pc) 'pointcut-call-max)) #t)
         (else #f)
)))

; imperative-pc? : Any -> Bool
(define imperative-pc?
   (lambda (pc)
      (cond
          ((and (pc? pc) (eqv? (pc->kind pc) 'pointcut-call-imperative)) #t)
          (else #f)
)))

; add-pc? : Any -> Bool
(define add-pc?
   (lambda (pc)
      (cond
          ((and (pc? pc) (eqv? (pc->kind pc) 'pointcut-call-add)) #t)
          (else #f)
)))

; sub-pc? : Any -> Bool
(define sub-pc?
   (lambda (pc)
      (cond
          ((and (pc? pc) (eqv? (pc->kind pc) 'pointcut-call-sub)) #t)
          (else #f)
)))

; first-pc? : Any -> Bool
(define first-pc?
   (lambda (pc)
      (cond
          ((and (pc? pc) (eqv? (pc->kind pc) 'pointcut-call-first)) #t)
          (else #f)
)))

; last-pc? : Any -> Bool
(define last-pc?
   (lambda (pc)
      (cond
          ((and (pc? pc) (eqv? (pc->kind pc) 'pointcut-call-last)) #t)
          (else #f)
)))

; min-pc? : Any -> Bool
(define min-pc?
   (lambda (pc)
      (cond
          ((and (pc? pc) (eqv? (pc->kind pc) 'pointcut-call-min)) #t)
          (else #f)
)))

; max-pc? : Any -> Bool
(define max-pc?
   (lambda (pc)
      (cond
          ((and (pc? pc) (eqv? (pc->kind pc) 'pointcut-call-max)) #t)
          (else #f)
)))


; Extractors for the data type...

; pc->kind : PointcutCall -> Kind
(define pc->kind
   (lambda (pc)
      (car pc)
))

; pc->id_o : PointcutCall -> Id
(define pc->id_o
   (lambda (pc)
      (cadr pc)
))

; pc->id_pname : PointcutCall -> Id
(define pc->id_pname
   (lambda (pc)
      (caddr pc)
))

; pc->el : PointcutCall -> ExprList
(define pc->el
   (lambda (pc)
      (cadddr pc)
))

; pc->sym_o : PointcutCall -> Sym
(define pc->sym_o
   (lambda (pc)
      (id->sym (pc->id_o pc))
))

; pc->sym_pname : PointcutCall -> Sym
(define pc->sym_pname
   (lambda (pc)
      (id->sym (pc->id_pname pc))
))


; Valuation functions ...

; PointcutCall[[pc]] = () -> PointcutCall
(define ast->pc
   (lambda (py_ast_var)
      ; First - ensure the ast node is a PointcutCall  (this is more of an exception [cCing failure] than a bottom [semantic failure])
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "PointcutCall" node_type)
                 ; Second - valuate the code
                 (let ((count        (python-eval (string-append "len(" py_ast_var ".children())") #t))
                       (advice_comb  (python-eval (string-append py_ast_var ".advice_comb.encode('ascii')") #t))
                      )
                      (cond
                         ((eqv? count 3)  ; i.e. pointcut( o, id, el )
                            (cond
                               ((string=? advice_comb "imperative")
                                  (make-pc-imperative 
                                     (ast->id  (string-append py_ast_var ".children()[2][1]")) 
                                     (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                     (ast->el  (string-append py_ast_var ".children()[1][1]"))
                               ))
                               ((string=? advice_comb "add")
                                  (make-pc-add 
                                     (ast->id  (string-append py_ast_var ".children()[2][1]")) 
                                     (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                     (ast->el  (string-append py_ast_var ".children()[1][1]"))
                               ))
                               ((string=? advice_comb "sub")
                                  (make-pc-sub 
                                     (ast->id  (string-append py_ast_var ".children()[2][1]")) 
                                     (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                     (ast->el  (string-append py_ast_var ".children()[1][1]"))
                               ))
                               ((string=? advice_comb "first")
                                  (make-pc-first 
                                     (ast->id  (string-append py_ast_var ".children()[2][1]")) 
                                     (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                     (ast->el  (string-append py_ast_var ".children()[1][1]"))
                               ))
                               ((string=? advice_comb "last")
                                  (make-pc-last 
                                     (ast->id  (string-append py_ast_var ".children()[2][1]")) 
                                     (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                     (ast->el  (string-append py_ast_var ".children()[1][1]"))
                               ))
                               ((string=? advice_comb "min")
                                  (make-pc-min 
                                     (ast->id  (string-append py_ast_var ".children()[2][1]")) 
                                     (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                     (ast->el  (string-append py_ast_var ".children()[1][1]"))
                               ))
                               ((string=? advice_comb "max")
                                  (make-pc-max 
                                     (ast->id  (string-append py_ast_var ".children()[2][1]")) 
                                     (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                     (ast->el  (string-append py_ast_var ".children()[1][1]"))
                               ))
                               (else 
                                  (display "Error: AST node type \"")(display node_type)
                                  (display "\" advice combinator \"")(display advice_comb)
                                  (display "\" not yet implemented!")(newline)
                               )
                         ))
                         ((eqv? count 2)
                            (let ((is-el?  (python-eval (string-append "type(" py_ast_var 
                                               ".children()[1][1]" ").__name__ == 'ExprList'" ) #t)))
                               (cond
                                  (is-el?  ; i.e pointcut( id; el )
                                     (cond
                                        ((string=? advice_comb "imperative")
                                           (make-pc-imperative 
                                              (make-id  '<invalid>)
                                              (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                              (ast->el  (string-append py_ast_var ".children()[1][1]"))
                                        ))
                                        ((string=? advice_comb "add")
                                           (make-pc-add 
                                              (make-id  '<invalid>)
                                              (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                              (ast->el  (string-append py_ast_var ".children()[1][1]"))
                                        ))
                                        ((string=? advice_comb "sub")
                                           (make-pc-sub 
                                              (make-id  '<invalid>)
                                              (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                              (ast->el  (string-append py_ast_var ".children()[1][1]"))
                                        ))
                                        ((string=? advice_comb "first")
                                           (make-pc-first 
                                              (make-id  '<invalid>)
                                              (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                              (ast->el  (string-append py_ast_var ".children()[1][1]"))
                                        ))
                                        ((string=? advice_comb "last")
                                           (make-pc-last 
                                              (make-id  '<invalid>)
                                              (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                              (ast->el  (string-append py_ast_var ".children()[1][1]"))
                                        ))
                                        ((string=? advice_comb "min")
                                           (make-pc-min 
                                              (make-id  '<invalid>)
                                              (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                              (ast->el  (string-append py_ast_var ".children()[1][1]"))
                                        ))
                                        ((string=? advice_comb "max")
                                           (make-pc-max 
                                              (make-id  '<invalid>)
                                              (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                              (ast->el  (string-append py_ast_var ".children()[1][1]"))
                                        ))
                                        (else 
                                           (display "Error: AST node type \"")(display node_type)
                                           (display "\" advice combinator \"")(display advice_comb)
                                           (display "\" not yet implemented!")(newline)
                                        )
                                  ))
                                  (else   ; i.e. pointcut ( o, id )
                                     (cond
                                        ((string=? advice_comb "imperative")
                                           (make-pc-imperative 
                                              (ast->id  (string-append py_ast_var ".children()[1][1]")) 
                                              (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                              (make-el  '())
                                        ))
                                        ((string=? advice_comb "add")
                                           (make-pc-add 
                                              (ast->id  (string-append py_ast_var ".children()[1][1]")) 
                                              (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                              (make-el  '())
                                        ))
                                        ((string=? advice_comb "sub")
                                           (make-pc-sub 
                                              (ast->id  (string-append py_ast_var ".children()[1][1]")) 
                                              (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                              (make-el  '())
                                        ))
                                        ((string=? advice_comb "first")
                                           (make-pc-first 
                                              (ast->id  (string-append py_ast_var ".children()[1][1]")) 
                                              (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                              (make-el  '())
                                        ))
                                        ((string=? advice_comb "last")
                                           (make-pc-last 
                                              (ast->id  (string-append py_ast_var ".children()[1][1]")) 
                                              (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                              (make-el  '())
                                        ))
                                        ((string=? advice_comb "min")
                                           (make-pc-min 
                                              (ast->id  (string-append py_ast_var ".children()[1][1]")) 
                                              (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                              (make-el  '())
                                        ))
                                        ((string=? advice_comb "max")
                                           (make-pc-max 
                                              (ast->id  (string-append py_ast_var ".children()[1][1]")) 
                                              (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                              (make-el  '())
                                        ))
                                        (else 
                                           (display "Error: AST node type \"")(display node_type)
                                           (display "\" advice combinator \"")(display advice_comb)
                                           (display "\" not yet implemented!")(newline)
                                        )
                                  ))
                         )))
                         ((eqv? count 1)
                            (cond
                               ((string=? advice_comb "imperative")
                                  (make-pc-imperative 
                                     (make-id  '<invalid>)
                                     (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                     (make-el  '())
                               ))
                               ((string=? advice_comb "add")
                                  (make-pc-add 
                                     (make-id  '<invalid>)
                                     (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                     (make-el  '())
                               ))
                               ((string=? advice_comb "sub")
                                  (make-pc-sub 
                                     (make-id  '<invalid>)
                                     (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                     (make-el  '())
                               ))
                               ((string=? advice_comb "first")
                                  (make-pc-first 
                                     (make-id  '<invalid>)
                                     (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                     (make-el  '())
                               ))
                               ((string=? advice_comb "last")
                                  (make-pc-last 
                                     (make-id  '<invalid>)
                                     (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                     (make-el  '())
                               ))
                               ((string=? advice_comb "min")
                                  (make-pc-min 
                                     (make-id  '<invalid>)
                                     (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                     (make-el  '())
                               ))
                               ((string=? advice_comb "max")
                                  (make-pc-max 
                                     (make-id  '<invalid>)
                                     (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                     (make-el  '())
                               ))
                               (else 
                                  (display "Error: AST node type \"")(display node_type)
                                  (display "\" advice combinator \"")(display advice_comb)
                                  (display "\" not yet implemented!")(newline)
                               )
                         ))
                         ; Else error
                         (else 
                            (display "Error: AST node type \"")(display node_type)
                            (display "\" has more than 2 children.")(newline)
                         )
              )))
              ; Else error
              (else (display "Error: AST node type \"")(display node_type)(display "\" is not an PointcutCall node.")(newline))
))))

; PointcutCallApply[[pc]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )    ; i.e () -> T(Val)
(define ast->e-pc
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-pc (ast->pc py_ast_var)) jp zeta rho s)
)))


