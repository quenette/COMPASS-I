; The implementation of an 'Argument List' using the model of an environment (motivated by Schmidt88). The environment model/code
;  itself is largely motivated from EOPLv3, code in 2.2.3.  Argument-lists are essentially a map from symbols to values with their
;  typeinfo. 
;
;
; Semantic algebras ...
;   Domain al in ArgList
;   (Domain sym in Sym)
;   (Domain v in Val)
;
; ArgList ::= < 'empty-al >
;         ::= < 'extend-al sym v al >
; 
; Abstract syntax...
;  None
;
; Valuation functions...
;  None
;
; Developed for guile scheme v 1.8.7

(load "error.scm")


; Constructors for this data type...

; empty-al : () -> ArgList
(define empty-al
   (lambda () 
      (list 'empty-al)
))

; extend-al : Sym -> Val -> ArgList -> TypeInfo -> ArgList
(define extend-al
   (lambda (sym v al ti)
      (list 'extend-al sym v al ti)
))

; merge-al : ArgList x ArgList -> ArgList
; The second argument-list is added to the first, one entry at a time, starting with the last (i.e. the second al takes precedence)
(define merge-al
   (lambda (al1 al2)
      (cond
         ((eqv? (al->kind al2) 'extend-al) (extend-al (al->sym al2) (al->v al2) (merge-al al1 (al->al al2)) (al->ti al2)))
         (else al1)
)))


; Other members for this data type...

; apply-al : ArgList x Sym -> Val
(define apply-al
   (lambda (al search-sym)
      (cond
         ((eqv? (al->kind al) 'empty-al)
            (report-no-binding-found search-sym))
         ((eqv? (al->kind al) 'extend-al)
            (let ((saved-sym (al->sym al))
                  (saved-v (al->v al))
                  (saved-al (al->al al)))
               (if (equal? search-sym saved-sym)
                  saved-v
                  (apply-al saved-al search-sym))))
         (else (report-invalid-al al))
)))


; lookup-al : ArgList x Sym -> ArgList
(define lookup-al
   (lambda (al search-sym)
      (cond
         ((eqv? (al->kind al) 'empty-al)
            (report-no-binding-found search-sym))
         ((eqv? (al->kind al) 'extend-al)
            (let ((saved-sym (al->sym al))
                  (saved-al (al->al al)))
               (if (equal? search-sym saved-sym)
                  al
                  (lookup-al saved-al search-sym))))
         (else (report-invalid-al al))
)))

; al-length : ArgList -> Val
(define al-length
   (lambda (al)
      (cond
         ((eqv? (al->kind al) 'empty-al) 0)
         ((eqv? (al->kind al) 'extend-al) (+ 1 (al-length (al->al al))))
)))

(define report-no-binding-found
   (lambda (search-sym)
      (error 'apply-al "No binding for ~s" search-sym)))

(define report-invalid-al
   (lambda (al)
      (error 'apply-al "Bad argument-list: ~s" al)))


; e-al->rho : ArgList -> ( JP -> Mot* -> Env -> Sto ) -> ( Val x Mot* x Env' x Sto' )         ; i.e. Env' -> ArgList -> T(Val)
;  Add the argument list to "an" environment.
;  Env' is a new resultant environment. Env is the initial environment of which the argument list is added to. The result is always
;  1.
(define e-al->rho
   (lambda (al)
      (lambda (jp zeta rho s)
         (cond
            ((empty-al? al) ((return-e 1) jp zeta rho s))
            (else ((seq-e 
               ; create a new location for the argument symbol
               ; TODO: replace "1" with size, which should come from the typeinfo (but in the ArgList case is undefined because JP
               ;  doesn't have it
               (e-decl (al->sym al) 1 (al->ti al)) 
               (lambda (_) (seq-e
                  ; Store the argument value bound to the symbol
                  (e-setref (al->sym al) (al->v al))
                  ;(display ":::: ")(display (al->sym al))(display " ----> ")(display (al->v al))(newline)
                  (lambda (_) (e-al->rho (al->al al)))
            ))) jp zeta rho s))
))))



; Predicates for the data type...

; al? : SchemeVal -> Bool
(define al?
   (lambda (al)
      (cond
         ((eqv? (al->kind al) 'empty-al)
            #t)
         ((eqv? (al->kind al) 'extend-al)
            #t)
         (else 
            #f)
)))

; empty-al? : ArgList -> Bool
(define empty-al?
   (lambda (al)
      (cond
         ((eqv? (al->kind al) 'empty-al)
            #t)
         (else 
            #f)
)))

; non-empty-al? : ArgList -> Bool
(define non-empty-al?
   (lambda (al)
      (cond
         ((eqv? (al->kind al) 'extend-al)
            #t)
         (else 
            #f)
)))


; Extractors for the data type...

; al->kind : ArgList -> ArgListKind
(define al->kind
   (lambda (al)
      (car al)
))

; al->sym : ArgList -> Sym
(define al->sym
   (lambda (al)
      (cadr al)
))

; al->v : ArgList -> Val
(define al->v
   (lambda (al)
      (caddr al)
))

; al->al : ArgList -> ArgList
(define al->al
   (lambda (al)
      (cadddr al)
))

; al->ti: ArgList -> TypeInfo
(define al->ti
   (lambda (al)
      (car (cdr (cdr (cdr (cdr al)))))
))

