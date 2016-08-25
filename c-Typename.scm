;
; Semantic algebras...
;   Domain tn in Typename
;    (Domain it in IT)
;    (Domain v in Val)
;
; Abstract syntax...
;  tn in Typename
;
;  Kind     ::= 'typename
;  Typename ::= < 'typename td >
;
; Valuation functions...
;  Typename[[td]]      = () -> Typename
;
; Developed for guile scheme v 1.8.7

(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-execution-store.scm")


; Construction operations ...

; make-tn : TypeDecl -> Typename
(define make-tn
   (lambda (td)
      (list 'typename td) 
))


; Other operations ...

; "Apply"
; e-tn : Typename -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )             ; i.e. Typename -> T(Val)
(define e-tn
   (lambda (tn)
      (lambda (jp zeta rho s)
         ((return-e (tn->tname tn)) jp zeta rho s)
)))



; Predicate operations...

; tn? : Any -> Bool
(define tn?
   (lambda (tn)
      (cond 
         ((and (has-kind? tn) (eqv? (car tn) 'typename)) #t)
         (else #f)
)))


; Extraction operations...

; tn->kind : Typename -> Kind
(define tn->kind
   (lambda (tn)
      (car tn)
))

; tn->td : Typename -> TypeDecl
(define tn->td
   (lambda (tn)
      (cadr tn)
))

; tn->tname : Typename -> TName
(define tn->tname
   (lambda (tn)
      (td->tname (tn->td tn))
))


; Valuation functions ...

; Typename[[td]] = () -> Typename
(define ast->tn
   (lambda (py_ast_var)
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "Typename" node_type)
                 ; Second - valuate the code
                 (make-tn (ast->td (string-append py_ast_var ".children()[0][1]")))
              )
              (else 
                 (display "Error: \"")(display node_type)(display "\" wrong for ast->tn, was expecting \"Typename\"")(newline)
                 (exit)
              )
))))

; TypenameApply[[tn]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )    ; i.e () -> T(Val)
(define ast->e-tn
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-tn (ast->tn py_ast_var)) jp zeta rho s)
)))


