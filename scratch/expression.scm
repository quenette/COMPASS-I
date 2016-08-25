;
; Grammars
;
; Domain i  in Id = Identifier
; Domain ts in TS = type-specifier
; Domain it in IT = IdentiferType
;
; type-specifier ::= 'void | 'char | 'short | 'int | 'long | 'float | 'double | 'signed | 'unsigned
;   [others in C99 not implemented: _Bool _Complex struct-or-union-specifier enum-specifier typedef-name
; IT ::= TS | TS TS
;
; 



; primary-expression: Id | constant TS
;   [others in C99 not implemented: string-literal ( expression )]
;
; Developed for guile scheme v 1.8.7

(load "error.scm")


; Constructors for this data type...

; make-single-ts : type-specifier -> TS_b
(define make-single-ts
   (lambda (kind) 
      (let ( (newTs (list kind) )) 
         (cond ((ts? newTs) newTs))
)))

; make-double-ts : type-specifier -> type-specifier -> TS_b
(define make-double-ts
   (lambda (kind1 kind2) 
      (if (eqv? kind2 '())
         (make-single-ts kind1)
         (let ( (newTs (list kind1 kind2) )) 
            (cond ((ts? newTs) newTs))
))))



; Predicates for the data type...

; ts? : SchemeVal -> Bool
(define ts?
   (lambda (ts)
       (cond 
         ((eqv? (ts->count ts) 1)
            (cond
               ((eqv? (ts->kind1 ts) 'void) #t)
               ((eqv? (ts->kind1 ts) 'char) #t)
               ((eqv? (ts->kind1 ts) 'short) #t)
               ((eqv? (ts->kind1 ts) 'int) #t)
               ((eqv? (ts->kind1 ts) 'long) #t)
               ((eqv? (ts->kind1 ts) 'float) #t)
               ((eqv? (ts->kind1 ts) 'double) #t)
               ((eqv? (ts->kind1 ts) 'signed) #t)
               ((eqv? (ts->kind1 ts) 'unsigned) #t)
               (else #f)
         ))
         ((eqv? (ts->count ts) 2)
            (cond
               ((eqv? (ts->kind1 ts) 'short)
                  (cond
                     ((eqv? (ts->kind2 ts) 'int) #t)
                     (else #f)
               ))
               ((eqv? (ts->kind1 ts) 'double)
                  (cond
                     ((eqv? (ts->kind2 ts) 'double) #t)
                     (else #f)
               ))
               ((eqv? (ts->kind1 ts) 'signed)
                  (cond
                     ((eqv? (ts->kind2 ts) 'int) #t)
                     ((eqv? (ts->kind2 ts) 'long) #t)
                     (else #f)
               ))
               ((eqv? (ts->kind1 ts) 'unsigned)
                  (cond
                     ((eqv? (ts->kind2 ts) 'int) #t)
                     ((eqv? (ts->kind2 ts) 'long) #t)
                     (else #f)
               ))
               (else #f)
         ))
         (else #f)
)))

; void-ts? : SchemeVal -> Bool
(define void-ts?
   (lambda (ts)
      (cond
         ((eqv? (ts->count ts) 1)
            (cond
               ((eqv? (ts->kind1 ts) 'void) #t)
               (else #f)
         ))
         (else #f)
)))

; char-ts? : SchemeVal -> Bool
(define char-ts?
   (lambda (ts)
      (cond
         ((eqv? (ts->count ts) 1)
            (cond
               ((eqv? (ts->kind1 ts) 'char) #t)
               (else #f)
         ))
         (else #f)
)))

; short-ts? : SchemeVal -> Bool
(define short-ts?
   (lambda (ts)
      (cond
         ((eqv? (ts->count ts) 1)
            (cond
               ((eqv? (ts->kind1 ts) 'short) #t)
               (else #f)
         ))
         ((eqv? (ts->count ts) 2)
            (cond
               ((eqv? (ts->kind1 ts) 'short)
                  (cond
                     ((eqv? (ts->kind2 ts) 'int) #t)
                     (else #f)
               ))
               (else #f)
         ))
         (else #f)
)))

; int-ts? : SchemeVal -> Bool
(define int-ts?
   (lambda (ts)
      (cond
         ((eqv? (ts->count ts) 1)
            (cond
               ((eqv? (ts->kind1 ts) 'int) #t)
               (else #f)
         ))
         ((eqv? (ts->count ts) 2)
            (cond
               ((eqv? (ts->kind1 ts) 'signed)
                  (cond
                     ((eqv? (ts->kind2 ts) 'int) #t)
                     (else #f)
               ))
               (else #f)
         ))
         (else #f)
)))

; long-ts? : SchemeVal -> Bool
(define long-ts?
   (lambda (ts)
      (cond
         ((eqv? (ts->count ts) 1)
            (cond
               ((eqv? (ts->kind1 ts) 'long) #t)
               (else #f)
         ))
         ((eqv? (ts->count ts) 2)
            (cond
               ((eqv? (ts->kind1 ts) 'signed)
                  (cond
                     ((eqv? (ts->kind2 ts) 'long) #t)
                     (else #f)
               ))
               (else #f)
         ))
         (else #f)
)))

; float-ts? : SchemeVal -> Bool
(define float-ts?
   (lambda (ts)
      (cond
         ((eqv? (ts->count ts) 1)
            (cond
               ((eqv? (ts->kind1 ts) 'float) #t)
               (else #f)
         ))
         (else #f)
)))

; double-ts? : SchemeVal -> Bool
(define double-ts?
   (lambda (ts)
      (cond
         ((eqv? (ts->count ts) 1)
            (cond
               ((eqv? (ts->kind1 ts) 'double) #t)
               (else #f)
         ))
         (else #f)
)))

; double-double-ts? : SchemeVal -> Bool
(define double-double-ts?
   (lambda (ts)
      (cond
         ((eqv? (ts->count ts) 2)
            (cond
               ((eqv? (ts->kind1 ts) 'double)
                  (cond
                     ((eqv? (ts->kind2 ts) 'double) #t)
                     (else #f)
               ))
               (else #f)
         ))
         (else #f)
)))

; signed-ts? : SchemeVal -> Bool
(define signed-ts?
   (lambda (ts)
      (cond
         ((eqv? (ts->count ts) 1)
            (cond
               ((eqv? (ts->kind1 ts) 'signed) #t)
               (else #f)
         ))
         ((eqv? (ts->count ts) 2)
            (cond
               ((eqv? (ts->kind1 ts) 'signed)
                  (cond
                     ((eqv? (ts->kind2 ts) 'int) #t)
                     (else #f)
               ))
               (else #f)
         ))
         (else #f)
)))

; signed-long-ts? : SchemeVal -> Bool
(define signed-long-ts?
   (lambda (ts)
      (cond
         ((eqv? (ts->count ts) 2)
            (cond
               ((eqv? (ts->kind1 ts) 'signed)
                  (cond
                     ((eqv? (ts->kind2 ts) 'long) #t)
                     (else #f)
               ))
               (else #f)
         ))
         (else #f)
)))

; unsigned-ts? : SchemeVal -> Bool
(define unsigned-ts?
   (lambda (ts)
      (cond
         ((eqv? (ts->count ts) 1)
            (cond
               ((eqv? (ts->kind1 ts) 'unsigned) #t)
               (else #f)
         ))
         ((eqv? (ts->count ts) 2)
            (cond
               ((eqv? (ts->kind1 ts) 'unsigned)
                  (cond
                     ((eqv? (ts->kind2 ts) 'int) #t)
                     (else #f)
               ))
               (else #f)
         ))
         (else #f)
)))

; unsigned-long-ts? : SchemeVal -> Bool
(define unsigned-long-ts?
   (lambda (ts)
      (cond
         ((eqv? (ts->count ts) 2)
            (cond
               ((eqv? (ts->kind1 ts) 'unsigned)
                  (cond
                     ((eqv? (ts->kind2 ts) 'long) #t)
                     (else #f)
               ))
               (else #f)
         ))
         (else #f)
)))


; Extractors for the data type...

; ts->kinds : TS -> TS_Kind*
(define ts->kinds
   (lambda (ts)
      ts
))

; ts->count : TS -> Size
(define ts->count
   (lambda (ts)
      (length ts)
))

; ts->kind1 : TS -> TS_Kind
(define ts->kind1
   (lambda (ts)
      (car ts)
))

; ts->kind2 : TS -> TS_Kind
(define ts->kind2
   (lambda (ts)
      (cadr ts)
))


; Valuation function
; [[TS TS]] = () -> TS
(define ts-vf
   (lambda (ast)
      

; tests ...
(display "(make-single-ts 'void): ") (display (make-single-ts 'void)) (display"\n")
(display "(make-single-ts 'BAD): ") (display (make-single-ts 'BAD)) (display"\n")
(display "(make-double-ts 'unsigned 'int): ") (display (make-double-ts 'unsigned 'int)) (display"\n")
(display "(make-double-ts 'unsigned '()): ") (display (make-double-ts 'unsigned '())) (display"\n")

(display "(ts? (make-single-ts 'void)): ") (display (ts? (make-single-ts 'void))) (display"\n")
(display "(void-ts? (make-single-ts 'void)): ") (display (void-ts? (make-single-ts 'void))) (display"\n")

(display "(ts? (make-single-ts 'char)): ") (display (ts? (make-single-ts 'char))) (display"\n")
(display "(char-ts? (make-single-ts 'char)): ") (display (char-ts? (make-single-ts 'char))) (display"\n")

(display "(ts? (make-single-ts 'short)): ") (display (ts? (make-single-ts 'short))) (display"\n")
(display "(ts? (make-double-ts 'short 'int)): ") (display (ts? (make-double-ts 'short 'int))) (display"\n")
(display "(short-ts? (make-single-ts 'short)): ") (display (short-ts? (make-single-ts 'short))) (display"\n")
(display "(short-ts? (make-double-ts 'short 'int)): ") (display (short-ts? (make-double-ts 'short 'int))) (display"\n")

(display "(ts? (make-single-ts 'int)): ") (display (ts? (make-single-ts 'int))) (display"\n")
(display "(ts? (make-double-ts 'signed 'int)): ") (display (ts? (make-double-ts 'signed 'int))) (display"\n")
(display "(int-ts? (make-single-ts 'int)): ") (display (int-ts? (make-single-ts 'int))) (display"\n")
(display "(int-ts? (make-double-ts 'signed 'int)): ") (display (int-ts? (make-double-ts 'signed 'int))) (display"\n")

(display "(ts? (make-single-ts 'long)): ") (display (ts? (make-single-ts 'long))) (display"\n")
(display "(long-ts? (make-single-ts 'long)): ") (display (long-ts? (make-single-ts 'long))) (display"\n")

(display "(ts? (make-single-ts 'float)): ") (display (ts? (make-single-ts 'float))) (display"\n")
(display "(float-ts? (make-single-ts 'float)): ") (display (float-ts? (make-single-ts 'float))) (display"\n")

(display "(ts? (make-single-ts 'double)): ") (display (ts? (make-single-ts 'double))) (display"\n")
(display "(double-ts? (make-single-ts 'double)): ") (display (double-ts? (make-single-ts 'double))) (display"\n")

(display "(ts? (make-double-ts 'double 'double)): ") (display (ts? (make-double-ts 'double 'double))) (display"\n")
(display "(double-double-ts? (make-double-ts 'double 'double)): ") (display (double-double-ts? (make-double-ts 'double 'double))) (display"\n")

(display "(ts? (make-single-ts 'signed)): ") (display (ts? (make-single-ts 'signed))) (display"\n")
(display "(ts? (make-double-ts 'signed 'int)): ") (display (ts? (make-double-ts 'signed 'int))) (display"\n")
(display "(signed-ts? (make-single-ts 'signed)): ") (display (signed-ts? (make-single-ts 'signed))) (display"\n")
(display "(signed-ts? (make-double-ts 'signed 'int)): ") (display (signed-ts? (make-double-ts 'signed 'int))) (display"\n")

(display "(ts? (make-double-ts 'signed 'long)): ") (display (ts? (make-double-ts 'signed 'long))) (display"\n")
(display "(signed-long-ts? (make-double-ts 'signed 'long)): ") (display (signed-long-ts? (make-double-ts 'signed 'long))) (display"\n")

(display "(ts? (make-single-ts 'unsigned)): ") (display (ts? (make-single-ts 'unsigned))) (display"\n")
(display "(ts? (make-double-ts 'unsigned 'int)): ") (display (ts? (make-double-ts 'unsigned 'int))) (display"\n")
(display "(unsigned-ts? (make-single-ts 'unsigned)): ") (display (unsigned-ts? (make-single-ts 'unsigned))) (display"\n")
(display "(unsigned-ts? (make-double-ts 'unsigned 'int)): ") (display (unsigned-ts? (make-double-ts 'unsigned 'int))) (display"\n")

(display "(ts? (make-double-ts 'unsigned 'long)): ") (display (ts? (make-double-ts 'unsigned 'long))) (display"\n")
(display "(unsigned-long-ts? (make-double-ts 'unsigned 'long)): ") (display (unsigned-long-ts? (make-double-ts 'unsigned 'long))) (display"\n")

