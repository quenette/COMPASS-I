; This datatype/domain is motivated by the C99 standard but using the Papasprou01 model (as opposed to pycparser's AST). It
; represents all c-primitives (including pointers) denotations (in code) that yields a value, but without c-qualifications.
;
; Semantic algebras...
;   Domain tyda in Type_Dat
;
;   Type_Dat ::= IT | 'ptr Type_Den
;
; Abstract syntax...
;  None
;
; Valuation functions...
;  None
;
; Developed for guile scheme v 1.8.7

(load "error.scm")
(load "kind.scm")

; Construction operations...

; make-it-tyda : IT -> Type_Dat
(define make-it-tyda
   (lambda (it) 
      it
))

; make-ptr-tyda : Type_Den -> Type_Dat
(define make-ptr-tyda
   (lambda (tyde) 
      (list 'ptr tyde) 
))


; Predicate operations...

; tyda? : Any -> Bool
(define tyda?
   (lambda (tyda)
       (cond 
          ((and (has-kind? tyda) (it? tyda)) #t)
          ((and (has-kind? tyda) (eqv? (tyda->kind tyda) 'ptr)) #t)
          (else #f)
)))

; ptr-tyda? : Any -> Bool
(define ptr-tyda?
   (lambda (tyda)
      (cond
         ((and (tyda? tyda) (eqv? (tyda->kind tyda) 'ptr) #t))
         (else #f)
)))


; void-tyda? : Any -> Bool
(define void-tyda?
   (lambda (tyda)
      (cond
         ((void-it? tyda) #t)
         (else #f)
)))

; char-tyda? : Any -> Bool
(define char-tyda?
   (lambda (tyda)
      (cond
         ((char-it? tyda) #t)
         (else #f)
)))

; short-tyda? : Any -> Bool
(define short-tyda?
   (lambda (tyda)
      (cond
         ((short-it? tyda) #t)
         (else #f)
)))

; int-tyda? : Any -> Bool
(define int-tyda?
   (lambda (tyda)
      (cond
         ((int-it? tyda) #t)
         (else #f)
)))

; long-tyda? : Any -> Bool
(define long-tyda?
   (lambda (tyda)
      (cond
         ((long-it? tyda) #t)
         (else #f)
)))

; float-tyda? : Any -> Bool
(define float-tyda?
   (lambda (tyda)
      (cond
         ((float-it? tyda) #t)
         (else #f)
)))

; double-tyda? : Any -> Bool
(define double-tyda?
   (lambda (tyda)
      (cond
         ((double-it? tyda) #t)
         (else #f)
)))

; long-double-tyda? : Any -> Bool
(define long-double-tyda?
   (lambda (tyda)
      (cond
         ((long-double-it? tyda) #t)
         (else #f)
)))

; signed-tyda? : Any -> Bool
(define signed-tyda?
   (lambda (tyda)
      (cond
         ((signed-it? tyda) #t)
         (else #f)
)))

; signed-char-tyda? : Any -> Bool
(define signed-char-tyda?
   (lambda (tyda)
      (cond
         ((signed-char-it? tyda) #t)
         (else #f)
)))

; unsigned-tyda? : Any -> Bool
(define unsigned-tyda?
   (lambda (tyda)
      (cond
         ((unsigned-it? tyda) #t)
         (else #f)
)))

; unsigned-char-tyda? : Any -> Bool
(define unsigned-char-tyda?
   (lambda (tyda)
      (cond
         ((unsigned-char-it? tyda) #t)
         (else #f)
)))

; unsigned-short-tyda? : Any -> Bool
(define unsigned-short-tyda?
   (lambda (tyda)
      (cond
         ((unsigned-short-it? tyda) #t)
         (else #f)
)))

; unsigned-int-tyda? : Any -> Bool
(define unsigned-int-tyda?
   (lambda (tyda)
      (cond
         ((unsigned-int-it? tyda) #t)
         (else #f)
)))

; unsigned-long-tyda? : Any -> Bool
(define unsigned-long-tyda?
   (lambda (tyda)
      (cond
         ((unsigned-long-it? tyda) #t)
         (else #f)
)))


; Extraction operations...

; tyda->kind : Type_Dat -> type-specifier
(define tyda->kind
   (lambda (tyda)
      (car tyda)
))

; tyda->ptr-type : Type_Dat -> Type_Den
(define tyda->ptr-type
   (lambda (tyda)
      (cadr tyda)
))


;(load "c-IdentifierType.scm")
;(display (make-it-tyda (make-single-it 'void)))(newline)
;(display (it? (make-it-tyda (make-single-it 'void))))(newline)
;(display (tyda? (make-it-tyda (make-single-it 'void))))(newline)
;(display (make-ptr-tyda (make-single-it 'void)))(newline)

