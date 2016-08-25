;
; Semantic algebras...
;   Domain C in Compound
;    (Domain tval in T(Val))
;    (Domain kappa in Cont)
;    (Domain D in Decl)
;    (Domain S in Stmt)
;
; Abstract syntax...
;  C in Compound
;
;  Kind     ::= 'compound
;  Compound ::= < 'compound D* S* >
;
; Valuation functions...
;  Compound[[D* S*]] = () -> Compound
;     (CompoundApply[[D* S*]] = () -> (JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )        ; i.e () -> T(Val)
;
; Developed for guile scheme v 1.8.7


(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-execution-store.scm")
(load "c-Declaration.scm")


; Construction operations ...

; make-C : Decl* -> Compound
(define make-C
   (lambda (D* S*)
      (list 'compound D* S*) 
))


; Other operations ...

; "Apply"
; e-C : Compound -> ( Val -> T(Val) ) -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot x Env' x Sto' ) ; Compound -> Cont -> T(Val)
;  Note: the default result value (i.e. no D and no S) is 0
(define e-C
   (lambda (C kappa)
      (lambda (jp zeta rho s)
         (((e-D* (C->D* C) (e-S* (C->S* C) kappa) #f) 0) jp zeta rho s)
)))


; Predicate operations...

; C? : Any -> Bool
(define C?
   (lambda (C)
      (cond 
         ((and (has-kind? C) (eqv? (C->kind C) 'compound)) #t)
         (else #f)
)))


; Extraction operations...

; C->kind : Compound -> Kind
(define C->kind
   (lambda (C)
      (car C)
))

; C->D* : Compound -> Decl*
(define C->D*
   (lambda (C)
      (cadr C)
))

; C->S* : Compound -> Stmt*
(define C->S*
   (lambda (C)
      (caddr C)
))


; Valuation functions ...
; Compound[[D* S*]] = () -> Compound
(define ast->C
   (lambda (py_ast_var)
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "Compound" node_type)
                 ; Second - valuate the code
                 ; In Compound's case, because compounds may be embedded in compounds, and "i" is plain text in the python code,
                 ; we need create and use a stack to save "i" on embedded compounds
                 (let ((i_stack  (python-eval "try:\n   i_stack.append( i )\nexcept NameError:\n   i_stack = []\n\n")))
                      (let ((i        (python-eval (string-append "i = iter(" py_ast_var ".children())"))))
                           (let ((DS       (ast->C-D*,S* py_ast_var (python-eval "try:\n   p = i.next()\nexcept StopIteration:\n   p = 0\n\n") '() '()))) 
                                (let ((i'  (python-eval "try:\n   i = i_stack.pop()\nexcept IndexError:\n   pass\n\n")))
                                     (make-C (car DS) (cadr DS)))
))))))))

; Compound[[iter(D|S)]] = () -> ( D* x S* )
(define ast->C-D*,S*
   (lambda (py_ast_var p D* S*)
      (let ((py_D|S (python-eval "p" #t)))
            (cond
               ; Forthe python iterator, the best way to know if at the end of the list is to catch the except. Once caught, return
               ; a 0, as this is easier to deal with
               ((eqv? py_D|S 0) (list D* S*))
               (else 
                  ;(display "===> ")(python-eval "p[1].show()" #t)
                  (let ((node_type (python-eval "p[1].__class__.__name__.encode('ascii')" #t)))
                       (cond
                          ((string=? "Decl" node_type)
                             (let ((D (ast->D "p[1]")))
                                  (let ((D*'   (append D* (list D))))
                                     (ast->C-D*,S* py_ast_var (python-eval "try:\n   p = i.next()\nexcept StopIteration:\n   p = 0\n\n") D*' S*)
                          )))
                          (else 
                             (let ((S (ast->S "p[1]")))
                                  (let ((S*'   (append S* (list S))))
                                     (ast->C-D*,S* py_ast_var (python-eval "try:\n   p = i.next()\nexcept StopIteration:\n   p = 0\n\n") D* S*')
                          )))
)))))))


; CompoundApply[[D* S*]] = ( Val -> T(Val) ) -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' ) ; Cont -> T(Val)
(define ast->e-C
   (lambda (kappa)
      (lambda (py_ast_var)
         (lambda (jp zeta rho s)
            ((e-C (ast->C py_ast_var) kappa) jp zeta rho s)
))))

