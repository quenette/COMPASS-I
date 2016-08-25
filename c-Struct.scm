;
; Semantic algebras...
;   Domain st in Struct = Decl*
;    (Domain D in Decl)
;
; Abstract syntax...
;
;  Kind      ::= 'struct
;  Struct ::= < 'struct sym D* >
;
; Valuation functions...
;  Struct[[D*]] = () -> Struct
;
; Devstoped for guile scheme v 1.8.7

(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-store.scm")
(load "c-env.scm")
(load "c-continuation.scm")


; Construction operations ...

; make-st : Decl* -> Struct
(define make-st
   (lambda (D*)
      (list 'struct '() D*) 
))

; make-sym-st : Sym -> Decl* -> Struct
(define make-sym-st
   (lambda (sym D*)
      (list 'struct sym D*) 
))


; Other operations ...

; "Apply"
; Three cases here and a little different to declarations...
; (a) No symbol is given, meaning this is just a template / type-info
; (b) A symbol is given but it is to be anonymous (e.g. in side a struct itself) where its named elsewhere
; (c) A symbol is given an we're to create the symbol (normal imperative behaviour).
; e-st : Struct -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )             ; i.e. Struct -> T(Val)
(define e-st
   (lambda (st sym_D is_anon)
      (lambda (jp zeta rho s)
         ((seq-e
            (cond
               ((and (sym-st? st) (eq? (st->D* st) '()) (not (eq? sym_D '())))
                  ;(display "In e-st, looking up struct ")(display (st->sym st))(newline)
                  (e-get-struct (st->sym st))
               )
               ((sym-st? st)   
                  ;(display "In e-st, has struct symbol ")(display (st->sym st))(newline)
                  (seq-e
                     (e-append-struct st)
                     (lambda (_) (return-e st))
               ))
               (else
                  ;(display "In e-st, without symbol (anonymous struct)\n")
                  (return-e st)
               )
            )
            (lambda (st') 
               (cond
                  ((unspecified? st') (display "Struct ")(display (st->sym st))(display " is undefined!\n")(newline))
                  ((eq? sym_D '())   (return-e st'))
                  (is_anon 
                     (seq-e
                        (e-apply-env 'next-l)
                        (lambda (l) (seq-e
                           ((e-D* (st->D* st') e-eoO #t) 0)
                           (lambda (_) (return-e l))
                  ))))
                  (else (seq-e
                     (e-decl sym_D 0 st') ; to add symbol but the following D* will allocate the space
                     (lambda (l) (seq-e
                        ((e-D* (st->D* st') e-eoO #t) 0)
                        (lambda (_) (return-e l))
                  )))) 
          ))) jp zeta rho s)
;         ((e-D*->v* (st->D* st) '()) jp zeta rho s)
)))


; Sigma (struct environment) operations ...

; In "struct _A { ...", the struct is a template named _A not a type. Add to the list of struct (templates).
; e-append-struct : TName -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto )             ; i.e. TName -> T(Val)
(define e-append-struct
   (lambda (tname)
      (lambda (jp zeta rho s)
         ;(display "structs register is: ")(display (apply-env 'structs rho))(newline)
         ((cond
            ; Normal behaviour
            ((list? (apply-env 'structs rho)) (e-extend-env 'structs (append (list tname) (apply-env 'structs rho)) (display "")))
            ; This is just to jump-start the structs list if it doesn't exit yet
            (else (e-extend-env 'structs (list tname) (display "")))
         ) jp zeta rho s)
)))

; e-get-struct : TName -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto )             ; i.e. TName -> T(Val)
(define e-get-struct
   (lambda (tname)
      (lambda (jp zeta rho s)
         ((seq-e
            (e-apply-env 'structs)
            (lambda (sigma) (return-e (sigma->ti sigma tname)))
         ) jp zeta rho s)
)))

(define sigma->ti
   (lambda (sigma sym)
       (cond
          ; If not found, fail...
          ((eq? sigma '())   (display ""))
          ; else ...
          ((string=?  (st->sym (car sigma)) sym) (car sigma))
          (else (sigma->ti (cdr sigma) sym))
       )
))


; Size of struct operations ...

; e-st->sz : Struct -> ( JP -> Mot* -> Env -> Sto ) -> ( Size x Mot* x Env x Sto )             ; i.e. Struct -> T(Val)
(define e-st->sz
   (lambda (st)
      (lambda (jp zeta rho s)
         ((seq-e
            (cond
               ; In this case, the struct term is used to identify a previously defined struct ... look it up
               ((eq? (st->D* st) '()) (e-get-struct (st->sym st)))
               ; Else the struct is deemed to be defined here...
               (else                  (return-e st))
            )
            (lambda (st')
               (seq-e 
                  (e-D*->sz* (st->D* st') '())
                  (lambda (sz*) (return-e (sz*->sz sz*)))
         ))) jp zeta rho s)
)))

; e-D*->sz* : Decl* -> Size* -> ( JP -> Mot* -> Env -> Sto ) -> ( Size* x Mot* x Env x Sto )   ; i.e. Decl* -> Size* -> T(Val)
(define e-D*->sz*
   (lambda (D* sz*)
      (lambda (jp zeta rho s)
         ((cond
            ((eqv? D* '())   (return-e sz*))
            (else
               (seq-e
                  (e-od->sz (D->dd (car D*)))
                  (lambda (sz) (e-D*->sz* (cdr D*) (append sz* (list sz))))
            ))
         ) jp zeta rho s)
)))

(define sz*->sz
   (lambda (sz*)
      (cond
         ((eq? sz* '()) 0)
         ((list? (car sz*)) (+ (sz*->sz (car sz*)) (sz*->sz (cdr sz*))))
         (else (+ (car sz*) (sz*->sz (cdr sz*))))
)))


; Member offset operations ...

; e-st->offset : Struct -> ( JP -> Mot* -> Env -> Sto ) -> ( Size x Mot* x Env x Sto )         ; i.e. Struct -> T(Val)
(define e-st->offset
   (lambda (st sym)
      (lambda (jp zeta rho s)
         ((e-D*->offset (st->D* st) sym 0) jp zeta rho s)
)))

; e-D*->offset : Decl* -> Sym -> Size -> (JP->Mot*->Env->Sto) -> ( Size* x Mot* x Env x Sto )  ; i.e. Decl* -> Sym-> Size -> T(Val)
(define e-D*->offset
   (lambda (D* sym offset)
      (lambda (jp zeta rho s)
         ;(display "D*->offset, D*: ")(display D*)(newline)
         ;(display "D*->offset, sym: ")(display sym) (newline)
         ;(display "D*->offset, offset: ")(display offset) (newline)
         ((cond
            ((eqv? D* '())   (return-e (display "Symbol ")(display sym)(display " not a member of this struct\n")))
            (else
               (cond
                  ((string=? (dd->sym (D->dd (car D*))) sym) (return-e offset))
                  (else 
                     (seq-e
                        (e-od->sz (D->dd (car D*)))
                        (lambda (sz) (e-D*->offset (cdr D*) sym (+ offset sz)))
                  ))
            ))
         ) jp zeta rho s)
)))


; Get the type of a member...
(define st->ti
   (lambda (st sym)
      (D*->ti (st->D* st) sym)
))

(define D*->ti
   (lambda (D* sym)
      ;(display "D*->ti: ")(display D*)(newline)
      ;(display "D*->ti: ")(display sym) (newline)
      (cond
         ((eqv? D* '())   (display "Symbol ")(display sym)(display " not a member of this struct\n"))
         ((string=? (dd->sym (D->dd (car D*))) sym)   (D->dd (car D*)))
         (else (D*->ti (cdr D*) sym))
)))

; Predicate operations...

; st? : Any -> Bool
(define st?
   (lambda (st)
      (cond 
         ((and (has-kind? st) (eqv? (st->kind st) 'struct)) #t)
         (else #f)
)))

; Basically - is it a named struct? (else it is an anonymous struct)
; sym-st? : Any -> Bool
(define sym-st?
   (lambda (st)
      (cond
         ((not (eq? (cadr st) '()))      #t)
         (else #f)
)))


; Extraction operations...

; st->kind : Struct -> Kind
(define st->kind
   (lambda (st)
      (car st)
))

; st->sym : Struct -> Sym_b
(define st->sym
   (lambda (st)
      (cond
         ((not (eq? (cadr st) '()))      (cadr st))
         ; Else fail!
)))

; st->D* : Struct -> Decl*
(define st->D*
   (lambda (st)
      (caddr st)
))


; Valuation functions ...
; Struct[[D*]] = () -> Struct
; Struct[[sym D*]] = () -> Struct
(define ast->st
   (lambda (py_ast_var)
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "Struct" node_type)
                 ; Second - valuate the code
                 ; In Struct's case, because structs may be embedded in structs, and "st_i" is plain text in the
                 ; python code, we need create and use a stack to save "st_i" on embedded structs
                 (let ((sym         (python-eval (string-append "\"\" if " py_ast_var ".name == None else " py_ast_var ".name.encode('ascii')") #t))
                       (st_i_stack  (python-eval "try:\n   st_i_stack.append( st_i )\nexcept NameError:\n   st_i_stack = []\n\n"))
                      )
                      (let ((st_i  (python-eval (string-append "st_i = iter(" py_ast_var ".children())"))))
                           (let ((D*  (ast->st-D* 
                                         py_ast_var 
                                         (python-eval "try:\n   d = st_i.next()\nexcept StopIteration:\n   d = 0\n\n") 
                                         '())))
                                (let ((st_i'  (python-eval "try:\n   st_i = st_i_stack.pop()\nexcept IndexError:\n   pass\n\n")))
                                     (cond
                                        ((string=? sym "") (make-st D*))
                                        (else (make-sym-st sym D*))
              ))))))
              ; Else error
              (else (display "Error: AST node type \"")(display node_type)(display "\" is not an Struct node.")(newline))
))))

; Struct[[iter(D)]] = () -> Struct
(define ast->st-D*
   (lambda (py_ast_var e D*)
      (let ((py_D (python-eval "d" #t)))
            (cond
               ; Forthe python iterator, the best way to know if at the end of the list is to catch the except. Once caught, return
               ; a 0, as this is easier to deal with
               ((eqv? py_D 0) D*)
               (else 
                  (let ((D (ast->D "d[1]")))
                       (append (list D) (ast->st-D* py_ast_var (python-eval "try:\n   d = st_i.next()\nexcept StopIteration:\n   d = 0\n\n") D*))
))))))

