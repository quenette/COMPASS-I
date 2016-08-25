; AdviceDecl is the advice declaration construct for the AOP example language in compass.
;  At the moment this only implements 'after' combined with 'pcall'
;
; Semantic algebras...
;   Domain A in AdviceDecl 
;    (Domain k in Kind)
;    (Domain id in Id)
;
; Abstract syntax...
;  A in AdviceDecl
;
;  Kind              ::= 'advice-after
;  AdviceDecl         ::= < 'advice-after id_body id_pcall >
;
; Valuation functions...
;  AdviceDecl[[A]] = () -> AdviceDecl
;
; Developed for guile scheme v 1.8.7


(load "error.scm")
(load "kind.scm")
(load "c-Declaration.scm")
(load "c-Compound.scm")
(load "a-advice.scm")
(load "m-motions.scm")


; Construction operations ...

; make-A : Id x Id -> AdviceDecl
(define make-A-after
   (lambda (id_body id_pcall)
      (list 'advice-after id_body id_pcall) 
))


; Other operations ...

; "ApDy"
; e-A : AdviceDecl -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )               ; i.e. AdviceDecl -> T(Val)
(define e-A
   (lambda (A)
      (lambda (jp zeta rho s)
         ((seq-e
            ; extract the Motion meant by this advice 
            (A->e-m A)
            ; Adds this Motion to the abstract machine
            (lambda (m) (appendm m))
         ) jp zeta rho s)
)))


; A->e-pcd : AdviceDecl -> ( JP -> Mot* -> Env -> Sto ) -> ( PCD x Mot* x Env x Sto )                   ; i.e. AdviceDecl -> T(Val)
;  An extractor that requires information from the abstraction machine to produce the PCD meant by this advice.
;  A note on this implementation - the args (vals) of the PCD are a list of Decls not just the var name. PCD comparison is based
;  on the length of this list not the contents.
(define A->e-pcd
   (lambda (A)
      (lambda (jp zeta rho s)
         ((return-e (list 'and 
                      (list 'pcall (A->sym_pcall A)) 
                      (list 'args (D*->sym* (pl->D* (fd->pl (type-info (A->sym_body A) rho)))))
         ))  jp zeta rho s)
)))

; A->e-alpha: AdviceDecl -> PCD -> ( JP -> Mot* -> Env -> Sto ) -> ( Adv x Mot* x Env x Sto )    ; i.e. AdviceDecl -> PCD -> T(Val)
;  An extractor that (potentially) requires information from the abstraction machine to produce the Adv meant by this advice.
(define A->e-alpha
   (lambda (A pcd)
      (lambda (jp zeta rho s)
         ((return-e  (e-adv-after pcd (A->sym_body A) (e-applyBody (A->sym_body A)))) jp zeta rho s)
)))


; A->e-m: AdviceDecl -> ( JP -> Mot* -> Env -> Sto ) -> ( Motion x Mot* x Env x Sto )                   ; i.e. AdviceDecl -> T(Val)
;  An extractor that requires information from the abstraction machine to produce the Motion meant by this advice.
(define A->e-m
   (lambda (A)
      (lambda (jp zeta rho s)
         ((seq-e
            (A->e-pcd A)
            (lambda (pcd) (seq-e 
               (A->e-alpha A pcd)
               (lambda (alpha) (return-e (list 'motion (display "") alpha pcd (A->sym_body A) '() '() '())))
         )))  jp zeta rho s)
)))

; Predicate operations...

; A? : Any -> Bool
(define A?
   (lambda (A)
      (cond 
         ((and (has-kind? A) (eqv? (A->kind A) 'advice-after)) #t)
         (else #f)
)))


; Extractors for the data type...

; A->kind : AdviceDecl -> Kind
(define A->kind
   (lambda (A)
      (car A)
))

; A->id_body : AdviceDecl -> Id
(define A->id_body
   (lambda (A)
      (cadr A)
))

; A->id_pcall : AdviceDecl -> Id
(define A->id_pcall
   (lambda (A)
      (caddr A)
))

; A->sym_body : AdviceDecl -> Sym
(define A->sym_body
   (lambda (A)
      (id->sym (A->id_body A))
))

; A->sym_pcall : AdviceDecl -> Sym
(define A->sym_pcall
   (lambda (A)
      (id->sym (A->id_pcall A))
))


; Valuation functions ...

; AdviceDecl[[A]] = () -> AdviceDecl
(define ast->A
   (lambda (py_ast_var)
      ; First - ensure the ast node is a AdviceDecl  (this is more of an exception [coding failure] than a bottom [semantic failure])
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "AdviceAfterCall" node_type)
                 ; Second - valuate the code
                 (make-A-after (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                               (ast->id  (string-append py_ast_var ".children()[1][1]")))
              )
              ; Else error
              (else (display "Error: AST node type \"")(display node_type)(display "\" is not an AdviceDecl node.")(newline))
))))

; AdviceDeclApply[[A]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )      ; i.e () -> T(Val)
(define ast->e-A
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-A (ast->A py_ast_var)) jp zeta rho s)
)))


