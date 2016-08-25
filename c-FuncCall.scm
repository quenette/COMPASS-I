;
; Semantic algebras...
;   Domain fc in FuncCall 
;    (Domain k in Kind)
;    (Domain id in Id)
;    (Domain el in ExprList)
;
; Abstract syntax...
;  fc in FuncCall
;
;  Kind              ::= 'func-call
;  FuncCall          ::= < 'func-call id el >
;
; Valuation functions...
;  FuncCall[[fc]] = () -> FuncCall
;
; Also note: fc is both a STATEMENT and an EXPRESSION!!!  I think this is what I wanted/expected. In either case its cool!
;
; Developed for guile scheme v 1.8.7


(load "error.scm")
(load "kind.scm")
(load "c-Declaration.scm")
(load "c-ExprList.scm")
; TODO: Ideally dont want these include here, but also dont want to maintain two FuncCalls!?!
(load "a-jp.scm")
(load "a-weave.scm")
(load "m-advices.scm")
(load "m-motions.scm")

; Construction operations ...

; make-fc : Id x ExprList -> FuncCall
(define make-fc
   (lambda (id el)
      (list 'func-call id el) 
))


; Other operations ...

; "Apply"
; e-fc : FuncCall -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )             ; i.e. FuncCall -> T(Val)
; Seperation of proc from func is a concept C-thing... not really needed.
(define e-fc
   (lambda (fc)
      (lambda (jp zeta rho s)
         (cond
            ((void-fd? (type-info (fc->sym fc) rho)) ((e-fc-proc fc) jp zeta rho s))
            (else                                    ((e-fc-func fc) jp zeta rho s))
))))

; "Apply" Function (i.e. returns a value)
; e-fc-func : FuncCall -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )        ; i.e. FuncCall -> T(Val)
(define e-fc-func
   (lambda (fc)
      (lambda (jp zeta rho s)
         ; Evaluate the function arguments
         ((seq-e
            ;(e-E*->v* (el->E* (fc->el fc)) '()) ... deprecated
            (e-el (fc->el fc))
            ; Then the "function call joinpoint"...
; TODO... need a way here to "if" only C, then dont do e-jp-chi!!!  Will have the same problem with only doing aspect not motions!
            (lambda (v*) (e-jp-chi 
               (new-call-jp (fc->sym fc) v*)
               (seq-e
                     ; create a copy of the environment
                     (e-cpenv 0) 
                     (lambda (rho') (seq-e 
                        ; populate the function arguments with values
                        (e-fc-v*,D* v* (pl->D* (fd->pl (type-info (fc->sym fc) rho))) 1) 
                        (lambda (v*) (seq-e 
                           ; reserve a location for the return value
;                           (e-decl 'return-val 1 (display "")) 
(return-e 0)
                           (lambda (_) (seq-e
                              ; Do the user defined for inbuilt function
                              (e-fc-body (fc->sym fc) rho')
                              (lambda (v,rho''') (seq-e
                                 ; extract the returned value
;                                 (e-deref 'return-val)
(return-e 0)
                                 (lambda (v) (seq-e
                                    ; revert to the previous environment
                                    (e-setenv (cadr v,rho'''))
                                    ; return the value
                                    (lambda (_) (return-e (car v,rho''')))
               )))))))))))
         ))) jp zeta rho s)
)))

; Role of this operation is to (a) be the in-built functions or else (b) execute the user defined body.
; pass in rho' as this enables (inbuilt?) functions to affect globals, etc. Must return the return value AND updated rho'
; (note: the latter shouldn't be possible for user-defined functions?)
(define e-fc-body
   (lambda (fc-sym rho')
      (lambda (jp zeta rho s)
         (cond
            ; __co_display (Scheme like)
            ((equal? fc-sym "__co_display")  
               ((seq-e 
                  (e-deref "val")
                  (lambda (val)
                     (display val) 
                     (return-e (list 0 rho'))
               )) jp zeta rho s)
            )
            ; __co_newline (Scheme like)
            ((equal? fc-sym "__co_newline")  
               (newline)
               ((return-e (list 0 rho')) jp zeta rho s)
            )
            ; __co_display_nextl
            ((equal? fc-sym "__co_display_nextl")  
               (display (apply-env 'next-l rho))
               ((return-e (list 0 rho')) jp zeta rho s)
            )
            ; __co_display_rho
            ((equal? fc-sym "__co_display_rho")  
               (display rho)
               ((return-e (list 0 rho')) jp zeta rho s)
            )
            ; __co_display_s
            ((equal? fc-sym "__co_display_s")  
               (display s)
               ((return-e (list 0 rho')) jp zeta rho s)
            )
            ; __co_display_loc
            ((equal? fc-sym "__co_display_loc")  
               ((seq-e 
                  (e-deref "loc")
                  (lambda (l)
                     (display (apply-s l s)) 
                     (return-e (list 0 rho'))
               )) jp zeta rho s)
            )
            ; __co_display_jp
            ((equal? fc-sym "__co_display_jp")  
               (display jp)
               ((return-e (list 0 rho')) jp zeta rho s)
            )
            ; __co_display_zeta
            ((equal? fc-sym "__co_display_zeta")  
               (display zeta)
               ((return-e (list 0 rho')) jp zeta rho s)
            )
            ; malloc
            ((equal? fc-sym "malloc")  
               ((seq-e 
                  (e-deref "sz")
                  (lambda (sz) (seq-e
                     ; swap back to original env...
                     (e-cpenv 0) 
                     (lambda (rho'') (seq-e 
                        (e-setenv rho')
                        (lambda (_) (seq-e
                           ; make allocation and initialise to empty (as per arrays - effectively undefined values but traceble)...
                           (e-allocn 1 sz)
                           (lambda (l) (seq-e
                              (e-extend-sn l '() (* 1 sz))
                              (lambda (_) (seq-e
                                 ; swap back to function's env and save the updated original env...
                                 (e-cpenv 0) 
                                 (lambda (rho''') (seq-e
                                    (e-setenv rho'')
                                    (lambda (_) (return-e (list l rho''')))
               ))))))))))))) jp zeta rho s)
            )
            ; memset
            ((equal? fc-sym "memset")  
               ((seq-e 
                  (e-deref "ptr")
                  (lambda (l) (seq-e
                     (e-deref "val")
                     (lambda (v) (seq-e
                        (e-deref "sz")
                        (lambda (sz) (seq-e
                           (e-extend-sn l v sz)
                           (lambda (v') (return-e (list v' rho')))
               ))))))) jp zeta rho s)
            )
            (else
               ((seq-e
                  ; look up the function/procedure
                  (e-deref fc-sym)
                  (lambda (C)
                     ; apply the body of the function/procedure
                     (display "Calling body: \"")(display fc-sym)(display "\"...\n")
                     (seq-e
                       (e-S C)
                       (lambda (v) (return-e (list v rho')))
                ))) jp zeta rho s)
             )
))))


; "Apply" Procedure (i.e. the user does NOT return a value, but we model it to return '() (undefined))
; e-fc-proc : FuncCall -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )        ; i.e. FuncCall -> T(Val)
(define e-fc-proc
   (lambda (fc)
      (lambda (jp zeta rho s)
         ; Evaluate the function arguments
         ((seq-e
            ;(e-E*->v* (el->E* (fc->el fc)) '()) ... deprecated
            (e-el (fc->el fc))
            ; Then the "function call joinpoint"...
; TODO... need a way here to "if" only C, then dont do e-jp-chi!!!  Will have the same problem with only doing aspect not motions!
            (lambda (v*) (e-jp-chi 
               (new-call-jp (fc->sym fc) v*)
               (seq-e
                  ; create a copy of the environment
                  (e-cpenv 0) 
                  (lambda (rho') (seq-e 
                     ; populate the function arguments with values
                     (e-fc-v*,D* v* (pl->D* (fd->pl (type-info (fc->sym fc) rho))) 1) 
                     (lambda (v*) (seq-e 
                        ; Do the user defined for inbuilt function
                        (e-fc-body (fc->sym fc) rho')
                        (lambda (v,rho''') (seq-e
                           ; revert to the previous environment
                           (e-setenv (cadr v,rho'''))
                           ; return the value
                           (lambda (_) (return-e '()))
               )))))))
         ))) jp zeta rho s)
)))



; e-fc-v*,D* : Val* -> Decl* -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )  ; i.e. Val* -> Decl* -> T(Val)
; Copies the argument values/symbols into the environment/store
; If v* and D* are inconsistent, it will error.
; v is the last result (gets ignored)
; will return the last parameter's value
(define e-fc-v*,D*
   (lambda (v* D* v)
      (lambda (jp zeta rho s)
         (cond 
            ((and (eqv? v* '()) (eqv? D* '())) ((return-e v) jp zeta rho s))
            ((eqv? v* '()) ((return-e (display "Error: Incorrect number of arguments to function call")) jp zeta rho s))
            ((eqv? D* '()) ((return-e (display "Error: Incorrect number of arguments to function call")) jp zeta rho s))
            (else
               ;(display "%%%%%\n   ")(display v*)(display ",\n   ")(display D*)(newline)
               ((seq-e 
                  ; create a new location for the function parameter
                  (e-od->sz (D->dd (car D*)))
                  (lambda (sz) (seq-e
                     (e-basic-typeinfo? (D->dd (car D*)))
                     (lambda (is-basic)
                        ;(display "e-fc-v*,D*, sym: ")(display (od->sym (D->dd (car D*))))(newline)
                        ;(display "e-fc-v*,D*, sz: ")(display sz)(newline)
                        ;(display "e-fc-v*,D*, ti: ")(display (D->dd (car D*)))(newline)
                        ;(display "e-fc-v*,D*, is-basic: ")(display is-basic)(newline)
                        ;(display "e-fc-v*,D*, v: ")(display (car v*))(newline)
                        (cond
                           (is-basic
                              (seq-e
                                 (e-decl (od->sym (D->dd (car D*))) sz (D->dd (car D*))) 
                                 (lambda (_) (seq-e
                                    ; Evaluate the expresion and save the result to the parameter
                                    ; TODO: type check evaluated value is compatible with param
                                    (e-setref (od->sym (D->dd (car D*))) (car v*))
                                    ; recurse with remaining parameters
                                    (lambda (v') (e-fc-v*,D* (cdr v*) (cdr D*) v'))
                           ))))
                           (else
                              ; Complex type are pass by reference
                              (e-extend-env (od->sym (D->dd (car D*))) (car v*) (D->dd (car D*)))
                           )
               ))))) jp zeta rho s)
)))))


; e-applyBody: Sym -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env x Sto ) ; i.e. Sym -> T(Val)
; Given a symbol, it extracts this symbol from the store (which should provide a Compound) and executes this Compound. This differs
; from applying a function in that it assumes all the environment/closure is all set up, but differs to a pure Compound in that
; the Compound is obtained from the environment/store. The idea of applyBody is common to functions and aspect advice on functions.
; The result is the result of the Compound.
(define e-applyBody
   (lambda (pname)
      (lambda (jp zeta rho s)
         ((seq-e
            (e-deref pname)
            (lambda (C) (e-S C))
) jp zeta rho s))))



; Predicate operations...

; fc? : Any -> Bool
(define fc?
   (lambda (fc)
      (cond 
         ((and (has-kind? fc) (eqv? (fc->kind fc) 'func-call)) #t)
         (else #f)
)))


; Extractors for the data type...

; fc->kind : FuncCall -> Kind
(define fc->kind
   (lambda (fc)
      (car fc)
))

; fc->id : FuncCall -> Id
(define fc->id
   (lambda (fc)
      (cadr fc)
))

; fc->el : FuncCall -> ExprList
(define fc->el
   (lambda (fc)
      (caddr fc)
))

; fc->sym : FuncCall -> Sym
(define fc->sym
   (lambda (fc)
      (id->sym (fc->id fc))
))


; Valuation functions ...

; FuncCall[[fc]] = () -> FuncCall
(define ast->fc
   (lambda (py_ast_var)
      ; First - ensure the ast node is a FuncCall  (this is more of an exception [cCing failure] than a bottom [semantic failure])
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "FuncCall" node_type)
                 ; Second - valuate the code
                 (let ((count  (python-eval (string-append "len(" py_ast_var ".children())") #t)))
                      (cond
                         ((eqv? count 2)
                            (make-fc (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                     (ast->el  (string-append py_ast_var ".children()[1][1]")))
                         )
                         ((eqv? count 1)
                            (make-fc (ast->id  (string-append py_ast_var ".children()[0][1]")) 
                                     (make-el  '()))
                         )
                         ; Else error
                         (else (display "Error: AST node type \"")(display node_type)(display "\" has more than 2 children.")(newline))
              )))
              ; Else error
              (else (display "Error: AST node type \"")(display node_type)(display "\" is not an FuncCall node.")(newline))
))))

; FuncCallApply[[fc]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )    ; i.e () -> T(Val)
(define ast->e-fc
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-fc (ast->fc py_ast_var)) jp zeta rho s)
)))


