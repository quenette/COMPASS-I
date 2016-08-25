;
; Note - if the constant is a string, the actual result is not a Constant but an ExprList of Constants!  Don't blame me just
;  mapping pycparsers AST to here.
;
; Semantic algebras...
;   Domain co in Constant = IT x Val
;    (Domain it in IT)
;    (Domain v in Val)
;
; Abstract syntax...
;  co in Constant
;
;  Val      ::= all possible int, float, ...
;  Kind     ::= 'constant
;  Constant ::= < 'constant it v >
;
; Valuation functions...
;  Constant[[it v]]      = () -> IT
;
; Developed for guile scheme v 1.8.7

(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-execution-store.scm")
(load "c-IdentifierType.scm")
(load "c-ExprList.scm")


; Construction operations ...

; make-co : IT x Val -> Constant
(define make-co
   (lambda (it v)
      (list 'constant it (co-cast it v)) 
))


; Other operations ...

; "Apply"
; e-co : Constant -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )             ; i.e. Constant -> T(Val)
(define e-co
   (lambda (co)
      (lambda (jp zeta rho s)
         (cond
            ((co? co) ((return-e (co->val co)) jp zeta rho s))
            ((el? co) ((e-el co) jp zeta rho s))
            (else (display "Error: in e-co expected a Constant or ExprList!\n"))
))))

; co-cast : IT x Val -> Val_b
(define co-cast
   (lambda (it v)
      (cond
         ((char-it? it) (co-cast2char v))
         ((short-it? it) (co-cast2int v))
         ((int-it? it) (co-cast2int v))
         ((long-it? it) (co-cast2int v))
         ((float-it? it) (co-cast2real v))
         ((double-it? it) (co-cast2real v))
         ((long-double-it? it) (co-cast2real v))
         ((signed-it? it) (co-cast2int v))
         ((signed-char-it? it) (co-cast2int v))
         ((unsigned-char-it? it) (co-cast2int v))
         ((unsigned-short-it? it) (co-cast2int v))
         ((unsigned-it? it) (co-cast2int v))
         ((unsigned-long-it? it) (co-cast2int v))
         ((void-it? it) v)
         ; else fail ... dont know type
)))


; co-cast2int : Val -> Val_b
(define co-cast2int
   (lambda (val)
      (cond
         ((integer? val) val)
         ((char? val) (char->integer val))
         ((string? val)
            ; Could just return the conversion, but we want it to fail if the conversion fails (rather than #f as per 
            ; guile/scheme)
            (let ((num (string->number val)))
               (cond ((integer? num) num))
)))))


; co-cast2real : Val -> Val_b
(define co-cast2real
   (lambda (val)
      (cond
         ((integer? val) val)
         ((real? val) val)
         ((char? val) (char->integer val))
         ((string? val)
            ; Could just return the conversion, but we want it to fail if the conversion fails (rather than #f as per 
            ; guile/scheme)
            (let ((num (string->number val)))
               (cond 
                  ((integer? num) num)
                  ((real? num) num)
               )
)))))


; co-cast2char : Val -> Val_b
(define co-cast2char
   (lambda (val)
      (cond
         ((integer? val) (integer->char val))
         ((char? val) val)
         ((string? val)
            (cond
               ; Handle pycparser which provides characters as strings in the form "'<val>'"
               ((and (eq? (string-length val) 3) (string-every #\' val 0 1) (string-every #\' val 2 3))
                  (car (string->list val 1 2))
               )
        ; else fail (eg. for reals)
)))))


(define pyc_string->E*
   (lambda (str)
      ; Convert the pyc string to a list. Strip away the leading and tailing \".
      (v*->co-char* (string->list str 1 (- (string-length str) 1)))
))

; note this WILL add the tailing constant char with the value of 0 to the list of constant chars
(define v*->co-char*
   (lambda (v*)
      (cond
         ((eq? v* '())    (list (make-co (make-single-it 'char) #\nul)))
         (else (append  (list (make-co (make-single-it 'char) (car v*)))  (v*->co-char* (cdr v*))))
)))


; Predicate operations...

; co? : Any -> Bool
(define co?
   (lambda (co)
      (cond 
         ((and (has-kind? co) (eqv? (co->kind co) 'constant) (it? (co->it co))) #t)
         (else #f)
)))


; Extraction operations...

; co->kind : Constant -> Kind
(define co->kind
   (lambda (co)
      (car co)
))

; co->it : Constant -> IT
(define co->it
   (lambda (co)
      (cadr co)
))

; co->val : Constant -> Val
(define co->val
   (lambda (co)
      (caddr co)
))


; Valuation functions ...

; Constant[[it v]] = () -> Constant
(define ast->co
   (lambda (py_ast_var)
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "Constant" node_type)
                 ; Second - valuate the code
                 (let ((v    (python-eval (string-append py_ast_var ".value.encode('ascii')") #t))
                       ; TODO: The following a hack until typedefs are implemented and i know exactly how I'm going to deal with
                       ; non-C99 types, such as the result of typedefs and pycparser's string
                       (type (python-eval (string-append py_ast_var ".type.encode('ascii')") #t))
                      )
                      (cond
                         ((string=? type "string")
                            ;(display "ast->co, v: ")(display v)(newline)
                            ;(display "ast->co, E*: ")(display (pyc_string->E* (substring v 1 (- (string-length v) 1))))(newline)
                            (make-str-el (pyc_string->E* v) (substring v 1 (- (string-length v) 1)))
                         )
                         (else
                            (make-co (make-single-it (sts2qts type)) v)
                         )
              )))
              (else 
                 (display "Error: \"")(display node_type)(display "\" wrong for ast->co, was expecting \"Constant\"")(newline)
                 (exit)
              )
))))

; ConstantApply[[co]] = () -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )    ; i.e () -> T(Val)
(define ast->e-co
   (lambda (py_ast_var)
      (lambda (jp zeta rho s)
         ((e-co (ast->co py_ast_var)) jp zeta rho s)
)))


