;
; Semantic algebras...
;   Domain M in Module
;
; Abstract syntax...
;  Not in pycparser's AS
;
;  Module      ::= < 'module mdd* >
;
; Valuation functions...
;  Module[[M]] = () -> Module
;
; Developed for guile scheme v 1.8.7

(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-ModDeclDef.scm")


; Construction operations ...

; make-M : ModDeclDef* -> Module
(define make-M
   (lambda (mdd*)
      (list 'module mdd*)
))

; Other operations ...

; "Apply"
; e-M : Module -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )                ; i.e. Module -> T(Val)
;  Note: initial value of 0 is given but is replaced by the first mdd and ultimately ignored by e-eoM.
(define e-M
   (lambda (M)
      (lambda (jp zeta rho s)
         (((e-mdd* (M->mdd* M) e-eoM) 0) jp zeta rho s)
)))


; Predicate operations...

; M? : Any -> Bool
(define M?
   (lambda (M)
      (cond 
         ((and (has-kind? M) (eqv? (M->kind M) 'module)) #t)
         (else #f)
)))


; Extraction operations...

; M->kind : Module -> Kind
(define M->kind
   (lambda (M)
      (car M)
))

; M->mdd* : Module -> ModDeclDef*
(define M->mdd*
   (lambda (M)
      (cadr M)
))


; Valuation functions ...

; Module[[M]] = () -> Module
(define ast->M
   (lambda (py_ast_var)
      (let ((m_i  (python-eval (string-append "m_i = iter(" py_ast_var ".ext)"))))
           (make-M (ast->M-mdd* py_ast_var (python-eval "try:\n   mdd = m_i.next()\nexcept StopIteration:\n   mdd = 0\n\n") '()))))
)

; Module[[iter(ModDeclDef)]] = () -> ParamList
(define ast->M-mdd*
   (lambda (py_ast_var p mdd*)
      (let ((py_mdd (python-eval "mdd" #t)))
            (cond
               ; Forthe python iterator, the best way to know if at the end of the list is to catch the except. Once caught, return
               ; a 0, as this is easier to deal with
               ((eqv? py_mdd 0) mdd*)
               (else 
;(python-eval "mdd.show()" #f)
                  (let ((mdd (ast->mdd "mdd")))
;(display mdd)(newline)
                       (append (list mdd) (ast->M-mdd* py_ast_var (python-eval "try:\n   mdd = m_i.next()\nexcept StopIteration:\n   mdd = 0\n\n") mdd*))
))))))

