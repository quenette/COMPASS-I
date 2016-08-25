;
; Semantic algebras...
;   Domain pl in ParamList = Decl*
;    (Domain D in Decl)
;
; Abstract syntax...
;  co in Constant
;
;  Kind      ::= 'paramlist
;  ParamList ::= < 'paramlist D* >
;
; Valuation functions...
;  ParamList[[D*]] = Env x Sto -> ParamList
;
; Developed for guile scheme v 1.8.7

(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-store.scm")
(load "c-env.scm")


; Construction operations ...

; make-pl : Decl* -> ParamList
(define make-pl
   (lambda (D*)
      (list 'paramlist D*) 
))


; Predicate operations...

; pl? : Any -> Bool
(define pl?
   (lambda (pl)
      (cond 
         ((and (has-kind? pl) (eqv? (pl->kind pl) 'paramlist)) #t)
         (else #f)
)))


; Extraction operations...

; pl->kind : ParamList -> Kind
(define pl->kind
   (lambda (pl)
      (car pl)
))

; pl->D* : ParamList -> Decl*
(define pl->D*
   (lambda (pl)
      (cadr pl)
))


; Valuation functions ...
; ParamList[[D*]] = () -> ParamList
(define ast->pl
   (lambda (py_ast_var)
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "ParamList" node_type)
                 ; Second - valuate the code
                 (let ((i  (python-eval (string-append "i = iter(" py_ast_var ".children())"))))
                      (make-pl (ast->pl-D* py_ast_var (python-eval "try:\n   p = i.next()\nexcept StopIteration:\n   p = 0\n\n") '()))
))))))

; ParamList[[iter(D)]] = () -> ParamList
(define ast->pl-D*
   (lambda (py_ast_var p D*)
      (let ((py_D (python-eval "p" #t)))
            (cond
               ; Forthe python iterator, the best way to know if at the end of the list is to catch the except. Once caught, return
               ; a 0, as this is easier to deal with
               ((eqv? py_D 0) D*)
               (else 
                  (let ((D (ast->D "p[1]")))
                       (append (list D) (ast->pl-D* py_ast_var (python-eval "try:\n   p = i.next()\nexcept StopIteration:\n   p = 0\n\n") D*))
))))))

