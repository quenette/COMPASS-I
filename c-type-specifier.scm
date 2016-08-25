; This datatype/domain is motivted by the C99 standard as distinct from Papasprou01 and pycparser's AST. We are ideally wanting to
;  create Papasprou's Type_dat but the pycparser's AST doesn't include pointers in this domain. Hence this is a bridge between the
;  the two.
;
; Semantic algebras...
;   Domain ts in TS = type-specifier
;
;   type-specifier ::= 'void | 'char | 'short | 'int | 'long | 'float | 'double | 'signed | 'unsigned
;     [others in C99 not implemented: _Bool _Complex struct-or-union-specifier enum-specifier typedef-name
;
; Abstract syntax...
;  None
;
; Valuation functions...
;  None
;
; Developed for guile scheme v 1.8.7

(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")

; Construction operations...

; make-ts : type-specifier -> TS_b
(define make-ts
   (lambda (kind) 
      (let ( (newTs (list kind) )) 
         (cond ((ts? newTs) newTs))
)))


; Predicate operations...

; ts? : Any -> Bool
(define ts?
   (lambda (ts)
       (cond 
          ((has-kind? ts)
             (cond
                ((eqv? (ts->kind ts) 'void) #t)
                ((eqv? (ts->kind ts) 'char) #t)
                ((eqv? (ts->kind ts) 'short) #t)
                ((eqv? (ts->kind ts) 'int) #t)
                ((eqv? (ts->kind ts) 'long) #t)
                ((eqv? (ts->kind ts) 'float) #t)
                ((eqv? (ts->kind ts) 'double) #t)
                ((eqv? (ts->kind ts) 'signed) #t)
                ((eqv? (ts->kind ts) 'unsigned) #t)
                (else #f)
          ))
          (else #f)
)))

; void-ts? : Any -> Bool
(define void-ts?
   (lambda (ts)
      (cond
         ((and (ts? ts) (eqv? (ts->kind ts) 'void) #t))
         (else #f)
)))

; char-ts? : Any -> Bool
(define char-ts?
   (lambda (ts)
      (cond
         ((and (ts? ts) (eqv? (ts->kind ts) 'char) #t))
         (else #f)
)))

; short-ts? : Any -> Bool
(define short-ts?
   (lambda (ts)
      (cond
         ((and (ts? ts) (eqv? (ts->kind ts) 'short) #t))
         (else #f)
)))

; int-ts? : Any -> Bool
(define int-ts?
   (lambda (ts)
      (cond
         ((and (ts? ts) (eqv? (ts->kind ts) 'int) #t))
         (else #f)
)))

; long-ts? : Any -> Bool
(define long-ts?
   (lambda (ts)
      (cond
         ((and (ts? ts) (eqv? (ts->kind ts) 'long) #t))
         (else #f)
)))

; float-ts? : Any -> Bool
(define float-ts?
   (lambda (ts)
      (cond
         ((and (ts? ts) (eqv? (ts->kind ts) 'float) #t))
         (else #f)
)))

; double-ts? : Any -> Bool
(define double-ts?
   (lambda (ts)
      (cond
         ((and (ts? ts) (eqv? (ts->kind ts) 'double) #t))
         (else #f)
)))

; signed-ts? : Any -> Bool
(define signed-ts?
   (lambda (ts)
      (cond
         ((and (ts? ts) (eqv? (ts->kind ts) 'signed) #t))
         (else #f)
)))

; unsigned-ts? : Any -> Bool
(define unsigned-ts?
   (lambda (ts)
      (cond
         ((and (ts? ts) (eqv? (ts->kind ts) 'unsigned) #t))
         (else #f)
)))


; Extraction operations...

; ts->kind : TS -> type-specifier
(define ts->kind
   (lambda (ts)
      (car ts)
))


