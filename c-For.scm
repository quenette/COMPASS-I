;
; TODO: seperate EDl into own file, and update For
; TODO: seperate Eel into own file, and update For and Decls
;
; Semantic algebras...
;   Domain fo in For
;   Domain EDl in ExprOrDeclOrList
;   Domain Eel in ExprOrList
;   Domain fo in For
;    (Domain E in Expr)
;    (Domain el in ExprList)
;    (Domain D in Decl)
;    (Domain dl in DeclList)  ; TODO implement
;    (Domain tval in T(Val))
;
; Abstract syntax...
;  fo in For
;
;  ExprDeclList ::= E | el | D | dl
;
;  For      ::= < 'for EDl_init E_cond Eel_next S >
;
; Valuation functions...
;  For[[S]]                           = () -> For
;  For[[EDl_init E_cond Eel_next S]]  = () -> For
;    ... and the various combinations between [[S]] and [[EDl_init E_cond Eel_next S]]
;
; Developed for guile scheme v 1.8.7

(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-execution-store.scm")
(load "c-all-expressions.scm")


; Construction operations ...

; make-fo : ExprOrDeclOrList -> Expr -> ExprOrList -> Statement -> For
(define make-fo
   (lambda (EDl_init E_cond Eel_next S)
      (list 'for EDl_init E_cond Eel_next S)
))


; Other operations ...

; "Apply"
; e-fo : For -> ( JP -> Mot* -> Env -> Sto ) -> ( Val -> Mot* -> Env' -> Sto' )            ; i.e For -> T(Val)
(define e-fo
   (lambda (fo)
      (lambda (jp zeta rho s)
          ((seq-e
             (e-cpenv 0)
             (lambda (rho') (seq-e
                (e-fo-init fo)
                (lambda (v_init) (seq-e
                   (e-fo-body fo v_init)
                    (lambda (v) (seq-e
                       (e-setenv rho')
                       (lambda (_) (return-e v))
          ))))))) jp zeta rho s)
)))

; e-fo-init : For -> ( JP -> Mot* -> Env -> Sto ) -> ( Val -> Mot* -> Env' -> Sto' )            ; i.e For -> T(Val)
(define e-fo-init
   (lambda (fo)
      (lambda (jp zeta rho s)
          ((cond
             ((init-fo? fo) (e-EDl (fo->EDl_init fo)))
             (else (return-e '()))
          ) jp zeta rho s)
)))

; e-fo-body : For -> Val -> ( JP -> Mot* -> Env -> Sto ) -> ( Val -> Mot* -> Env' -> Sto' )     ; i.e For -> Val -> T(Val)
(define e-fo-body
   (lambda (fo v)
      (lambda (jp zeta rho s)
         ((seq-e
            (e-fo-cond fo)
            (lambda (v_cond) 
               ;(display "e-fo-body, v_cond: ")(display v_cond)(newline)
               (cond
                  (v_cond   (seq-e
                     (e-S (fo->S fo))
                     (lambda (v_S) 
                        ;(display "e-fo-body, v_S: ")(display v_S)(newline)
                        (seq-e
                           (e-fo-next fo v_S)
                           (lambda (v_next) 
                              ;(display "e-fo-body, v_next: ")(display v_next)(newline)
                              (e-fo-body fo v_next)
                  )))))
                  (else   (return-e v))
         ))) jp zeta rho s)
)))

; e-EDl : ExprOrDeclOrList -> ( JP -> Mot* -> Env -> Sto ) -> ( Val -> Mot* -> Env' -> Sto' )   ; i.e For -> T(Val)
(define e-EDl
   (lambda (EDl)
      (lambda (jp zeta rho s)
          ((cond
             ((E-EDl? EDl)    (e-E EDl))
             ((el-EDl? EDl)   (e-el EDl))
             ((D-EDl? EDl)    (e-D EDl))
             ((dl-EDl? EDl)   (e-dl EDl))
             (else 
                (return-e (display "In e-EDl, ")(display EDl)
                   (display " is not an expression, declaration, expression list or declaration list!\n"))
             )
          ) jp zeta rho s)
)))

; e-fo-cond : For -> ( JP -> Mot* -> Env -> Sto ) -> ( Val -> Mot* -> Env' -> Sto' )            ; i.e For -> T(Val)
(define e-fo-cond
   (lambda (fo)
      (lambda (jp zeta rho s)
          ((cond
             ((cond-fo? fo) (e-E (fo->E_cond fo)))
             (else (return-e #t))
          ) jp zeta rho s)
)))

; e-fo-next : For -> Val -> ( JP -> Mot* -> Env -> Sto ) -> ( Val -> Mot* -> Env' -> Sto' )     ; i.e For -> Val -> T(Val)
(define e-fo-next
   (lambda (fo v)
      (lambda (jp zeta rho s)
          ((cond
             ((next-fo? fo) (e-Eel (fo->Eel_next fo)))
             (else (return-e v))
          ) jp zeta rho s)
)))

; e-Eel : ExprOrList -> ( JP -> Mot* -> Env -> Sto ) -> ( Val -> Mot* -> Env' -> Sto' )   ; i.e For -> T(Val)
(define e-Eel
   (lambda (Eel)
      (lambda (jp zeta rho s)
          ((cond
             ((E-EDl? Eel)    (e-E Eel))
             ((el-EDl? Eel)   (e-el Eel))
             (else 
                (return-e (display "In e-Eel, ")(display Eel)
                   (display " is not an expression, or expression list!\n"))
             )
          ) jp zeta rho s)
)))



; Predicate operations...

; fo? : Any -> Bool
(define fo?
   (lambda (fo)
      (cond 
         ((and (has-kind? fo) (eqv? (fo->kind fo) 'for)) #t)
         (else #f)
)))

; init-fo? : Any -> Bool
(define init-fo?
   (lambda (fo)
      (cond 
         ((and (has-kind? fo) (eqv? (fo->kind fo) 'for) (EDl? (fo->EDl_init fo))) #t)
         (else #f)
)))

; cond-fo? : Any -> Bool
(define cond-fo?
   (lambda (fo)
      (cond 
         ((and (has-kind? fo) (eqv? (fo->kind fo) 'for) (E? (fo->E_cond fo))) #t)
         (else #f)
)))

; next-fo? : Any -> Bool
(define next-fo?
   (lambda (fo)
      (cond 
         ((and (has-kind? fo) (eqv? (fo->kind fo) 'for) (Eel? (fo->Eel_next fo))) #t)
         (else #f)
)))


; EDl? : Any -> Bool
(define EDl?
   (lambda (EDl)
      (cond 
         ((E-EDl? EDl)   #t)
         ((el-EDl? EDl)  #t)
         ((D-EDl? EDl)   #t)
         ;((dl-EDl? EDl)  #t)   TODO: waiting for DeclList implementation
         (else #f)
)))

; E-EDl? : Any -> Bool
(define E-EDl?
   (lambda (EDl)
      (cond 
         ((and (E? EDl)) #t)
         (else #f)
)))

; el-EDl? : Any -> Bool
(define el-EDl?
   (lambda (EDl)
      (cond 
         ((and (el? EDl)) #t)
         (else #f)
)))

; D-EDl? : Any -> Bool
(define D-EDl?
   (lambda (EDl)
      (cond 
         ((and (D? EDl)) #t)
         (else #f)
)))

; dl-EDl? : Any -> Bool
(define dl-EDl?
   (lambda (EDl)
      (cond 
         ;((and (dl? EDl)) #t)   TODO: waiting for DeclList implementation
         (else #f)
)))

; Eel? : Any -> Bool
(define Eel?
   (lambda (Eel)
      (cond 
         ((E-Eel? Eel)   #t)
         ((el-Eel? Eel)  #t)
         (else #f)
)))

; E-Eel? : Any -> Bool
(define E-Eel?
   (lambda (Eel)
      (cond 
         ((and (E? Eel)) #t)
         (else #f)
)))

; el-Eel? : Any -> Bool
(define el-Eel?
   (lambda (Eel)
      (cond 
         ((and (el? Eel)) #t)
         (else #f)
)))




; Extraction operations...

; fo->kind : For -> Kind
(define fo->kind
   (lambda (fo)
      (car fo)
))


; fo->EDl_init : For -> ExprOrDeclOrList
(define fo->EDl_init
   (lambda (fo)
      (car (cdr fo))
))

; fo->E_cond : For -> Expr
(define fo->E_cond
   (lambda (fo)
      (car (cddr fo))
))

; fo->Eel_next : For -> ExprOrList
(define fo->Eel_next
   (lambda (fo)
      (car (cdddr fo))
))

; fo->S : For -> Statement
(define fo->S
   (lambda (fo)
      (car (cdr (cdddr fo)))
))


; Valuation functions ...

;  For[[S]]                           = () -> For
;  For[[EDl_init E_cond Eel_next S]]  = () -> For
;    ... and the various combinations between [[S]] and [[EDl_init E_cond Eel_next S]]
(define ast->fo
   (lambda (py_ast_var)
      ; First - work out what type of expression this is...
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "For" node_type)
                 ; Second - valuate the code
                 ; TODO these need to handle EDl and Eel ASTs (see TODO above) and the cases where init, cond or next is None
                 ; Just assuming E for each for now
                 (let ((EDl_init    (ast->E (string-append py_ast_var ".init")))
                       (E_cond      (ast->E (string-append py_ast_var ".cond")))
                       (Eel_next    (ast->E (string-append py_ast_var ".next")))
                       (S           (ast->S (string-append py_ast_var ".stmt")))
                      )
                      (make-fo EDl_init E_cond Eel_next S)
))))))

; ForApply[[fo]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )  ; i.e () -> T(Val)
(define ast->e-fo
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-fo (ast->fo py_ast_var)) jp zeta rho s)
)))

