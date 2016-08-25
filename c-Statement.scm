; 
; Semantic algebras...
;   Domain S in Stmt 
;    (Domain tval in T(Val))
;    (Domain kappa in Cont)
;
; Abstract syntax...
;  Not in pycparser abstract syntax
;
;  Stmt ::= re | ...
;
; Valuation functions...
;  Stmt[[S]]     = () -> Stmt
;    (Stmt[[re]]   = () -> Stmt)
;
;  StmtApply[[S]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )
;    (StmtApply[[re]] ...)
;    ...
;
; TODO: return is really a type of jump statment - implement jump statements and other types of jumps
; TODO: function call is really a type of expression statement - implement expression statements
;
; Developed for guile scheme v 1.8.7


(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-execution-store.scm")
(load "c-continuation.scm")
(load "c-Return.scm")
(load "c-Compound.scm")
(load "c-Expression.scm")
(load "c-For.scm")


; Construction operations ...
; None  (use each of the constructors of the non-terminals)


; Other operations ...

; "Apply"
; e-S : Stmt -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )                  ; i.e Stmt -> T(Val)
(define e-S
   (lambda (S)
      (lambda (jp zeta rho s)
         (cond 
            ((re? S) ((e-re S)       jp zeta rho s))
            ((C?  S) ((e-C  S e-eoC) jp zeta rho s))   ; <= not sure this makes sense in the full language (needed for testing)
            ((E?  S) ((e-E  S)       jp zeta rho s))
            ((fo? S) ((e-fo S)       jp zeta rho s))
            ; Else - Error (as opposed to theoretical fail) ...
            (else (display "Error: dont know how to apply statement: \"")(display S)(display "\" in e-S")(newline))
))))


; e-S* :  Stmt* -> ( Val -> T(Val) ) -> Val -> T(Val)
(define e-S*
   (lambda (S* kappa)
      (lambda (v)
         (lambda (jp zeta rho s)
            (cond
               ((eqv? S* '()) ((kappa v) jp zeta rho s))
               (else 
                  (let ((S   (car S*))
                        (S*' (cdr S*))
                       )
                       (cond
                          ((re? S) ((seq-e (e-S S) (lambda (x) (e-eop x))) jp zeta rho s))
                          ((C?  S) ((seq-e 
                                      (e-cpenv 0) 
                                      (lambda (rho') (e-C S (lambda (x) (seq-e 
                                                                           (e-setenv rho') 
                                                                           (lambda (y) ((e-S* S*' kappa) x)) 
                          ))))) jp zeta rho s))
                          (else    ((seq-e (e-S S) (lambda (x) ((e-S* S*' kappa) x))) jp zeta rho s))
))))))))


; Predicate operations...

; S? : Any -> Bool
(define S?
   (lambda (S)
      (cond 
         ((has-kind? S)
            (cond 
               ((re? S) #t)
               ((C?  S) #t)
               ((fo? S) #t)
               ((E?  S) #t)
               (else #f)
         ))
         (else #f)
)))


; Extractors for the data type...

; S->kind : Stmt -> Kind
(define S->kind
   (lambda (S)
      (car S)
))


; Valuation functions ...

; Stmt[[S]] = () -> Stmt
(define ast->S
   (lambda (py_ast_var)
      ; First - work out what type of expression this is...
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "Return" node_type)
                 ; Second - valuate the code
                 (ast->re py_ast_var)
              )
              ((string=? "Compound" node_type)
                 ; Second - valuate the code
                 (ast->C py_ast_var)
              )
              ((string=? "For" node_type)
                 ; Second - valuate the code
                 (ast->fo py_ast_var)
              )
              ; All expressions are also statements...
              (else (let ((res (ast->E' py_ast_var)))
                 (cond
                    ; else fail
                    ((not (list? res)) (display "Statement not yet implemented: \"")
                                       (display node_type)(display "\" in ast->S.")(newline)
                    )
                    ; Expression statement
                    (else res)
              )))
))))

; StmtApply[[S]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )         ; i.e () -> T(Val)
(define ast->e-S
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-S (ast->S py_ast_var)) jp zeta rho s)
)))

