;
; To handle C-strings (i.e. ""), they are expression lists (so all the other machinery works) but are flagged such that the 
; value of the expression list is a string.
;
; Semantic algebras...
;   Domain el in ExprList = Expr*
;    (Domain E in Expr)
;
; Abstract syntax...
;  co in Constant
;
;  Kind      ::= 'exprlist
;  ExprList ::= < 'exprlist E* > | < 'exprlist-str E* >
;
; Valuation functions...
; ExprList[[E*]] = () -> ExprList
; ExprList[[E* str]] = () -> ExprList
;
; Developed for guile scheme v 1.8.7

(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-store.scm")
(load "c-env.scm")


; Construction operations ...

; make-el : Expr* -> ExprList
(define make-el
   (lambda (E*)
      (list 'exprlist E* (display "")) 
))

; make-el : Expr* -> ExprList
(define make-str-el
   (lambda (E* str)
      (list 'exprlist-str E* str) 
))

; Other operations ...

; "Apply"
; e-el : ExprList -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )             ; i.e. ExprList -> T(Val)
(define e-el
   (lambda (el)
      (lambda (jp zeta rho s)
         ((e-E*->v* (el->E* el) '()) jp zeta rho s)
)))

; e-el-str : ExprList -> ( JP -> Mot* -> Env -> Sto ) -> ( String x Mot* x Env' x Sto' )             ; i.e. ExprList -> T(Val)
(define e-el-str
   (lambda (el)
      (lambda (jp zeta rho s)
         ((return-e (el->str el)) jp zeta rho s)
)))


; e-E*->v* : Expr* -> ( JP -> Mot* -> Env -> Sto ) -> ( Val* x Mot x Env x Sto' )                  ; i.e. Expr* -> T(Val)
; Evaluates the expressions to values
(define e-E*->v*
   (lambda (E* v*)
      (lambda (jp zeta rho s)
         ;(display "e-E*->v*, e*: ")(display E*)(newline)
         ;(display "e-E*->v*, v*: ")(display v*)(newline)
         (cond 
            ((eqv? E* '()) ((return-e v*) jp zeta rho s))
            (else
               (let ((E*' (cdr E*)))
                  ((seq-e
                     (cond
                        ; I'm not sure about this, but I think this is what's wanted here... when a C-String is in an element
                        ; list, we want the string rather than the list of characters.
                        ((str-el? (car E*))   (e-el-str (car E*)))
                        (else (e-E (car E*)))
                     )
                     (lambda (v) 
                        ;(display "e-E*->v*, v: ")(display v)(newline)
                        (e-E*->v* E*' (append v* (list v))))
                  ) jp zeta rho s)
))))))


; Predicate operations...

; el? : Any -> Bool
(define el?
   (lambda (el)
      (cond 
         ((and (has-kind? el) (eqv? (el->kind el) 'exprlist)) #t)
         ((and (has-kind? el) (eqv? (el->kind el) 'exprlist-str)) #t)
         (else #f)
)))

; str-el? : Any -> Bool
(define str-el?
   (lambda (el)
      (cond 
         ((and (has-kind? el) (eqv? (el->kind el) 'exprlist-str)) #t)
         (else #f)
)))

; Extraction operations...

; el->kind : ExprList -> Kind
(define el->kind
   (lambda (el)
      (car el)
))

; el->E* : ExprList -> Expr*
(define el->E*
   (lambda (el)
      (cadr el)
))

; el->str : ExprList -> String
(define el->str
   (lambda (el)
      (caddr el)
))


; Valuation functions ...
; ExprList[[E*]] = () -> ExprList
(define ast->el
   (lambda (py_ast_var)
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "ExprList" node_type)
                 ; Second - valuate the code
                 ; In ExprList's case, because expression lists may be embedded in expression lists, and "el_i" is plain text in the
                 ; python code, we need create and use a stack to save "el_i" on embedded expression lists
                 (let ((el_i_stack  (python-eval "try:\n   el_i_stack.append( el_i )\nexcept NameError:\n   el_i_stack = []\n\n")))
                      (let ((el_i  (python-eval (string-append "el_i = iter(" py_ast_var ".children())"))))
                           (let ((E*  (ast->el-E* 
                                         py_ast_var 
                                         (python-eval "try:\n   e = el_i.next()\nexcept StopIteration:\n   e = 0\n\n") 
                                         '())))
                                (let ((el_i'  (python-eval "try:\n   el_i = el_i_stack.pop()\nexcept IndexError:\n   pass\n\n")))
                                     (make-el E*)
              )))))
              ; Else error
              (else (display "Error: AST node type \"")(display node_type)(display "\" is not an ExprList node.")(newline))
))))

; ExprList[[iter(E)]] = () -> ExprList
(define ast->el-E*
   (lambda (py_ast_var e E*)
      (let ((py_E (python-eval "e" #t)))
            (cond
               ; Forthe python iterator, the best way to know if at the end of the list is to catch the except. Once caught, return
               ; a 0, as this is easier to deal with
               ((eqv? py_E 0) E*)
               (else 
                  (let ((E (ast->E "e[1]")))
                       (append (list E) (ast->el-E* py_ast_var (python-eval "try:\n   e = el_i.next()\nexcept StopIteration:\n   e = 0\n\n") E*))
))))))

