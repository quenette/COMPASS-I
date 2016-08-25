; This datatype/domain is motivated by the C99 standard but using the Papasprou01 model (as opposed to pycparser's AST). It
; represents all data-type (including functional) denotations (in code) that yields a value.
;
; Semantic algebras...
;   Domain tyde in Type_Den
;
;   Type_Den ::= Type_Obj | Type_Fun
;     ... but because these dont exist yet, its just ::= Type_Dat
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
(load "c-Type_Data.scm")

; Construction operations...

; make-tyob-tyde : Type_Obj -> Type_Den
(define make-tyob-tyde
   (lambda (tyob) 
      tyob
))


; Predicate operations...

; tyde? : Any -> Bool
(define tyde?
   (lambda (tyde)
       (cond 
          ((and (has-kind? tyde) (tyda? tyde)) #t)
          (else #f)
)))


; ptr-tyde? : Any -> Bool
(define ptr-tyde?
   (lambda (tyde)
      (cond
         ((ptr-tyda? tyde) #t)
         (else #f)
)))

; void-tyde? : Any -> Bool
(define void-tyde?
   (lambda (tyde)
      (cond
         ((void-tyda? tyde) #t)
         (else #f)
)))

; char-tyde? : Any -> Bool
(define char-tyde?
   (lambda (tyde)
      (cond
         ((char-tyda? tyde) #t)
         (else #f)
)))

; short-tyde? : Any -> Bool
(define short-tyde?
   (lambda (tyde)
      (cond
         ((short-tyda? tyde) #t)
         (else #f)
)))

; int-tyde? : Any -> Bool
(define int-tyde?
   (lambda (tyde)
      (cond
         ((int-tyda? tyde) #t)
         (else #f)
)))

; long-tyde? : Any -> Bool
(define long-tyde?
   (lambda (tyde)
      (cond
         ((long-tyda? tyde) #t)
         (else #f)
)))

; float-tyde? : Any -> Bool
(define float-tyde?
   (lambda (tyde)
      (cond
         ((float-tyda? tyde) #t)
         (else #f)
)))

; double-tyde? : Any -> Bool
(define double-tyde?
   (lambda (tyde)
      (cond
         ((double-tyda? tyde) #t)
         (else #f)
)))

; long-double-tyde? : Any -> Bool
(define long-double-tyde?
   (lambda (tyde)
      (cond
         ((long-double-tyda? tyde) #t)
         (else #f)
)))

; signed-tyde? : Any -> Bool
(define signed-tyde?
   (lambda (tyde)
      (cond
         ((signed-tyda? tyde) #t)
         (else #f)
)))

; signed-char-tyde? : Any -> Bool
(define signed-char-tyde?
   (lambda (tyde)
      (cond
         ((signed-char-tyda? tyde) #t)
         (else #f)
)))

; unsigned-tyde? : Any -> Bool
(define unsigned-tyde?
   (lambda (tyde)
      (cond
         ((unsigned-tyda? tyde) #t)
         (else #f)
)))

; unsigned-char-tyde? : Any -> Bool
(define unsigned-char-tyde?
   (lambda (tyde)
      (cond
         ((unsigned-char-tyda? tyde) #t)
         (else #f)
)))

; unsigned-short-tyde? : Any -> Bool
(define unsigned-short-tyde?
   (lambda (tyde)
      (cond
         ((unsigned-short-tyda? tyde) #t)
         (else #f)
)))

; unsigned-int-tyde? : Any -> Bool
(define unsigned-int-tyde?
   (lambda (tyde)
      (cond
         ((unsigned-int-tyda? tyde) #t)
         (else #f)
)))

; unsigned-long-tyde? : Any -> Bool
(define unsigned-long-tyde?
   (lambda (tyde)
      (cond
         ((unsigned-long-tyda? tyde) #t)
         (else #f)
)))


; Extraction operations...

; tyde->kind : tyde -> type-specifier
(define tyde->kind
   (lambda (tyde)
      (car tyde)
))

; tyde->tyob : Type_Den -> Type_Obj
(define tyde->tyob
   (lambda (tyde)
      tyde
))


;(load "c-IdentifierType.scm")
;(load "c-Type_Data.scm")
;(display (make-tyob-tyde (make-it-tyda (make-single-it 'void))))(newline)
;(display (it? (make-tyob-tyde (make-it-tyda (make-single-it 'void)))))(newline)
;(display (tyda? (make-tyob-tyde (make-it-tyda (make-single-it 'void)))))(newline)
;(display (tyde? (make-tyob-tyde (make-it-tyda (make-single-it 'void)))))(newline)

