;
; TODO: add body and pcall objects
;
; MotionStmt is the advice declaration construct for the AOP example language in compass.
;
; Semantic algebras...
;   Domain ms in MotionStmt 
;    (Domain k in Kind)
;    (Domain id in Id)
;    (Domain |m in Id)
;    (Domain |p in MotRelPosition)
;    (Domain |pc in MotRelConstraint)
;
; Abstract syntax...
;  ms in MotionStmt
;
;  Kind               ::= 'motion-call
;  MotRelAttr         ::= first | always
;  MotionStmt         ::= < 'motion-call id_o_abody id_abody id_o_jp id_jp |m |p |pc >
;
; Valuation functions...
;  MotionStmt[[ms]] = () -> MotionStmt
;
; Developed for guile scheme v 1.8.7


(load "error.scm")
(load "kind.scm")
(load "c-Declaration.scm")
(load "c-Compound.scm")
(load "a-advice.scm")
(load "m-motions.scm")


; Construction operations ...

; make-ms-pcall : Id x Id x Id x MotRelPosition x MotRelConstraint x ??? -> MotionStmt
(define make-ms-pcall
   (lambda (id_abody id_jp id_|m |p |pc advice)
      (list 'motion-call '() id_abody '() id_jp id_|m |p |pc advice )
))

; make-ms-mcall : Id x Id x Id x Id x Id x MotRelPosition x MotRelConstraint x ??? -> MotionStmt
(define make-ms-mcall
   (lambda (id_o_abody id_abody id_o_jp id_jp id_|m |p |pc advice)
      (list 'motion-call id_o_abody id_abody id_o_jp id_jp id_|m |p |pc advice )
))


; Other operations ...

; "Apply"
; e-ms : MotionStmt -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )               ; i.e. MotionStmt -> T(Val)
(define e-ms
   (lambda (ms)
      (lambda (jp zeta rho s)
         ((seq-e
            ; extract the Motion meant by this statement 
            (ms->e-m ms)
            ; Adds this Motion to the abstract machine
            (lambda (m) (appendm m))
         ) jp zeta rho s)
)))


; ms->e-pcd : MotionStmt -> ( JP -> Mot* -> Env -> Sto ) -> ( PCD x Mot* x Env x Sto )                   ; i.e. MotionStmt -> T(Val)
;  An extractor that requires information from the abstraction machine to produce the PCD meant by this advice.
;  A note on this implementation - the args (vals) of the PCD are a list of Decls not just the var name. PCD comparison is based
;  on the length of this list not the contents.
; Note - ultimately this will differ from A->e-pcd in that 'objects' will be handled here but not in advice declarations.
(define ms->e-pcd
   (lambda (ms)
      (lambda (jp zeta rho s)
         ((cond
            ((eqv? (ms->id_o_jp ms) '())
               (return-e
                  (list 'and 
                     (list 'pcall (ms->sym_jp ms)) 
                     (list 'and 
                        (list 'args (D*->sym.ti* (pl->D* (fd->pl (type-info (ms->sym_abody ms) rho)))))
                        (list 'obj '<invalid>)
            ))))
            (else
               (seq-e
                  (e-apply-env (ms->sym_o_jp ms))
                  (lambda (l)
                     (return-e
                        (list 'and 
                           (list 'pcall (ms->sym_jp ms)) 
                           (list 'and 
                              (list 'args (D*->sym.ti* (pl->D* (fd->pl (type-info (ms->sym_abody ms) rho)))))
                              (list 'obj l)
            ))))))
         ) jp zeta rho s)
)))

; ms->e-alpha: MotionStmt -> PCD -> ( JP -> Mot* -> Env -> Sto ) -> ( Adv x Mot* x Env x Sto )_b    ; i.e. MotionStmt -> PCD -> T(Val)_b
;  An extractor that (potentially) requires information from the abstraction machine to produce the Adv meant by this motion stmt.
; Note - ultimately this will differ from A->e-pcd in that 'relative advice' will be handled here but not in advice declarations.
(define ms->e-alpha
   (lambda (ms pcd)
      (lambda (jp zeta rho s)
         (cond
            ((eq? (ms->advice ms) 'after) ((return-e  (e-adv-after pcd (ms->sym_abody ms) (e-applyBody (ms->sym_abody ms)))) jp zeta rho s))
            ((eq? (ms->advice ms) 'before) ((return-e  (e-adv-before pcd (ms->sym_abody ms) (e-applyBody (ms->sym_abody ms)))) jp zeta rho s))
            ((eq? (ms->advice ms) 'around) ((return-e  (e-adv-around pcd (ms->sym_abody ms) (e-applyBody (ms->sym_abody ms)))) jp zeta rho s))
            (else (display "Error: in MotionStmt ms->e-alpha, unrecognised string value: ")(display (ms->advice ms))(newline))
))))


; ms->e-m: MotionStmt -> ( JP -> Mot* -> Env -> Sto ) -> ( Motion x Mot* x Env x Sto )                   ; i.e. MotionStmt -> T(Val)
;  An extractor that requires information from the abstraction machine to produce the Motion meant by this motion statement.
(define ms->e-m
   (lambda (ms)
      (lambda (jp zeta rho s)
         ((seq-e
            (ms->e-pcd ms)
            (lambda (pcd) (seq-e 
               (ms->e-alpha ms pcd)
               (lambda (alpha)
                  (cond
                     ((eqv? (ms->id_o_jp ms) '())
                        (return-e 
                           (list 'motion '() alpha pcd (ms->sym_abody ms) (ms->sym_|m ms) (ms->|p ms) (ms->|pc ms))
                     ))
                     (else
                        (seq-e
                           (e-apply-env (ms->sym_o_jp ms))
                           (lambda (l)
                              (return-e
                                 (list 'motion l alpha pcd (ms->sym_abody ms) (ms->sym_|m ms) (ms->|p ms) (ms->|pc ms))
                     ))))
         )))))  jp zeta rho s)
)))

; Predicate operations...

; ms? : Any -> Bool
(define ms?
   (lambda (ms)
      (cond 
         ((and (has-kind? ms) (eqv? (ms->kind ms) 'motion-call)) #t)
         (else #f)
)))


; Extractors for the data type...

; ms->kind : MotionStmt -> Kind
(define ms->kind
   (lambda (ms)
      (car ms)
))

; ms->id_o_abody : MotionStmt -> Obj
(define ms->id_o_abody
   (lambda (ms)
      (car (cdr ms))
))

; ms->id_abody : MotionStmt -> Id
(define ms->id_abody
   (lambda (ms)
      (car (cddr ms))
))

; ms->id_o_jp : MotionStmt -> Obj
(define ms->id_o_jp
   (lambda (ms)
      (car (cdddr ms))
))

; ms->id_jp : MotionStmt -> Obj
(define ms->id_jp
   (lambda (ms)
      (car (cdr (cdddr ms)))
))

; ms->id_|m : MotionStmt -> Id
(define ms->id_|m
   (lambda (ms)
      (car (cddr (cdddr ms)))
))

; ms->|p : MotionStmt -> MotRelPosition
(define ms->|p
   (lambda (ms)
      (car (cdddr (cdddr ms)))
))

; ms->|pc : MotionStmt -> MotRelConstraint
(define ms->|pc
   (lambda (ms)
      (car (cdr (cdddr (cdddr ms))))
))

; ms->advice : MotionStmt -> MotCallAdvice
(define ms->advice
   (lambda (ms)
      (car (cddr (cdddr (cdddr ms))))
))

; ms->sym_o_abody : MotionStmt -> Sym
(define ms->sym_o_abody
   (lambda (ms)
      (id->sym (ms->id_o_abody ms))
))

; ms->sym_abody : MotionStmt -> Sym
(define ms->sym_abody
   (lambda (ms)
      (id->sym (ms->id_abody ms))
))

; ms->sym_jp : MotionStmt -> Sym
(define ms->sym_jp
   (lambda (ms)
      (id->sym (ms->id_jp ms))
))

; ms->sym_o_jp : MotionStmt -> Sym
(define ms->sym_o_jp
   (lambda (ms)
      (id->sym (ms->id_o_jp ms))
))

; ms->sym_|m : MotionStmt -> Sym
(define ms->sym_|m
   (lambda (ms)
      (id->sym (ms->id_|m ms))
))


(define |p_str->|p
   (lambda (|p_str)
      (cond 
         ((string=? "first" |p_str) 'first)
         ((string=? "" |p_str) '())
         ((string=? "last" |p_str) '())
         ; Error (return unspecified)
         (else (display "Error: in MotionStmt |p_str->|p, unrecognised string value: ")(display |p_str)(newline))
)))

(define |pc_str->|pc
   (lambda (|pc_str)
      (cond 
         ((string=? "always" |pc_str) 'always)
         ((string=? "" |pc_str) '())
         ((string=? "none" |pc_str) '())
         ; Error (return unspecified)
         (else (display "Error: in MotionStmt |pc_str->|pc, unrecognised string value: ")(display |pc_str)(newline))
)))

(define advice_str->advice
   (lambda (advice_str)
      (cond 
         ((string=? "after" advice_str) 'after)
         ((string=? "before" advice_str) 'before)
         ((string=? "around" advice_str) 'around)
         ; Error (return unspecified)
         (else (display "Error: in MotionStmt advice_str->advice, unrecognised string value: ")(display advice_str)(newline))
)))


(define has_|m->pname_|m
   (lambda (has_|m py_ast_var)
      (cond 
         (has_|m (ast->id  (string-append py_ast_var ".children()[2][1]")))
         (else (make-id '()))
)))


; Valuation functions ...

; MotionStmt[[ms]] = () -> MotionStmt
(define ast->ms
   (lambda (py_ast_var)
      ; First - ensure the ast node is a MotionStmt  (this is more of an exception [coding failure] than a bottom [semantic failure])
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "MotionCall" node_type)
                 (let ((|p_str     (python-eval (string-append py_ast_var ".rel_pos.encode('ascii')") #t))
                       (|pc_str    (python-eval (string-append py_ast_var ".pos_constraint.encode('ascii')") #t))
                       (advice_str (python-eval (string-append py_ast_var ".advice.encode('ascii')") #t))
                       (has_|m     (python-eval (string-append py_ast_var ".has_rel_motion") #t))
                       (count      (python-eval (string-append "len(" py_ast_var ".children())") #t))

                    )
                    ; Second - valuate the code
                    ;(python-eval (string-append py_ast_var ".show()"))
                    (cond
                       ((eq? count 2)
                          (make-ms-pcall (ast->id              (string-append py_ast_var ".children()[0][1]")) 
                                         (ast->id              (string-append py_ast_var ".children()[1][1]"))
                                         (has_|m->pname_|m     has_|m py_ast_var) 
                                         (|p_str->|p           |p_str) 
                                         (|pc_str->|pc         |pc_str)
                                         (advice_str->advice   advice_str)
                       ))
                       ((eq? count 4)
                          (make-ms-mcall (ast->id              (string-append py_ast_var ".children()[0][1]")) 
                                         (ast->id              (string-append py_ast_var ".children()[1][1]"))
                                         (ast->id              (string-append py_ast_var ".children()[2][1]"))
                                         (ast->id              (string-append py_ast_var ".children()[3][1]"))
                                         (has_|m->pname_|m     has_|m py_ast_var) 
                                         (|p_str->|p           |p_str) 
                                         (|pc_str->|pc         |pc_str)
                                         (advice_str->advice   advice_str)
                       ))
                       ; else Fail: 
                       (else 
                          (display "Fail: AST node type \"")(display node_type)
                          (display "\" unrecognised number of children.")(newline)
                       )
                    )
              ))
              ; Else error
              (else (display "Error: AST node type \"")(display node_type)(display "\" is not an MotionStmt node.")(newline))
))))

; MotionStmtApply[[ms]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )      ; i.e () -> T(Val)
(define ast->e-ms
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-ms (ast->ms py_ast_var)) jp zeta rho s)
)))


