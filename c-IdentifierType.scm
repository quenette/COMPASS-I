;
; Semantic algebras...
;   Domain it in IT = TS
;    Domain tname in TName in Sym
;
; Abstract syntax...
;  IT in IdentiferType
;
;  IT ::= TS | TS TS | < 'it tname ti >
;
; Valuation functions...
;  IT[[TS1]] = ...
;  IT[[TS1 TS2]] = ...
;  IT[[TNAME]] = ...
;
; Developed for guile scheme v 1.8.7


(load "error.scm")
(load "kind.scm")
(load "c-type-specifier.scm")


; Construction operations ...

; make-single-it : type-specifier -> IT_b
(define make-single-it
   (lambda (kind)
      (make-ts kind) 
))

; make-double-it : type-specifier -> type-specifier -> IT_b
(define make-double-it
   (lambda (kind1 kind2) 
      (if (eqv? kind2 '())
         (make-single-it kind1)
         (let ( (newIt (append (make-ts kind1) (make-ts kind2)) )) 
            (cond ((it? newIt) newIt))
))))


; make-user-it : TName -> IT_b
(define make-user-it
   (lambda (tname)
      (list 'it tname)
))


; Predicate operations...

; it? : Any -> Bool
(define it?
   (lambda (it)
      (cond
         ((inbuilt-it? it)   #t)
         ((user-it? it)      #t)
         (else               #f)
)))

; user-it? : Any -> Bool
(define user-it?
   (lambda (it)
      (cond
         ((and (has-kind? it) (eqv? (car it) 'it)) #t)
         (else #f)
)))
      
; inbuilt-it? : Any -> Bool
(define inbuilt-it?
   (lambda (it)
       (cond 
         ((and (has-kind? it) (eqv? (it->count it) 1))
            (ts? it)
         )
         ((and (has-kind? it) (eqv? (it->count it) 2))
            (cond
               ((long-ts? it)
                  (cond
                     ((eqv? (it->kind2 it) 'double) #t)
                     (else #f)
               ))
               ((signed-ts? it)
                  (cond
                     ((eqv? (it->kind2 it) 'char) #t)
                     ((eqv? (it->kind2 it) 'int) #t)
                     (else #f)
               ))
               ((unsigned-ts? it)
                  (cond
                     ((eqv? (it->kind2 it) 'char) #t)
                     ((eqv? (it->kind2 it) 'short) #t)
                     ((eqv? (it->kind2 it) 'int) #t)
                     ((eqv? (it->kind2 it) 'long) #t)
                     (else #f)
               ))
               (else #f)
         ))
         (else #f)
)))

; void-it? : Any -> Bool
(define void-it?
   (lambda (it)
      (cond
         ((and (inbuilt-it? it) (eqv? (it->count it) 1))
            (void-ts? it)
         )
         (else #f)
)))

; char-it? : Any -> Bool
(define char-it?
   (lambda (it)
      (cond
         ((and (inbuilt-it? it) (eqv? (it->count it) 1))
            (char-ts? it)
         )
         ; According to Papa... signed-char is distinct from char.  So here I'm interpreting signed-/unsigned-char as ints not chars
         ;((eqv? (it->count it) 2)
         ;   (cond
         ;      ((signed-ts? it)
         ;         (cond
         ;            ((eqv? (it->kind2 it) 'char) #t)
         ;            (else #f)
         ;      ))
         ;      (else #f)
         ;))
         (else #f)
)))

; short-it? : Any -> Bool
(define short-it?
   (lambda (it)
      (cond
         ((and (inbuilt-it? it) (eqv? (it->count it) 1))
            (short-ts? it)
         )
         ((and (inbuilt-it? it) (eqv? (it->count it) 2))
            (cond
               ((signed-ts? it)
                  (cond
                     ((eqv? (it->kind2 it) 'short) #t)
                     (else #f)
               ))
               (else #f)
         ))
         (else #f)
)))

; int-it? : Any -> Bool
(define int-it?
   (lambda (it)
      (cond
         ((and (inbuilt-it? it) (eqv? (it->count it) 1))
            (or (int-ts? it) (signed-ts? it))
         )
         ((and (inbuilt-it? it) (eqv? (it->count it) 2))
            (cond
               ((signed-ts? it)
                  (cond
                     ((eqv? (it->kind2 it) 'int) #t)
                     (else #f)
               ))
               (else #f)
         ))
         (else #f)
)))

; long-it? : Any -> Bool
(define long-it?
   (lambda (it)
      (cond
         ((and (inbuilt-it? it) (eqv? (it->count it) 1))
            (long-ts? it)
         )
         ((and (inbuilt-it? it) (eqv? (it->count it) 2))
            (cond
               ((signed-ts? it)
                  (cond
                     ((eqv? (it->kind2 it) 'long) #t)
                     (else #f)
               ))
               (else #f)
         ))
         (else #f)
)))

; float-it? : Any -> Bool
(define float-it?
   (lambda (it)
      (cond
         ((and (inbuilt-it? it) (eqv? (it->count it) 1))
            (float-ts? it)
         )
         (else #f)
)))

; double-it? : Any -> Bool
(define double-it?
   (lambda (it)
      (cond
         ((and (inbuilt-it? it) (eqv? (it->count it) 1))
            (double-ts? it)
         )
         (else #f)
)))

; long-double-it? : Any -> Bool
(define long-double-it?
   (lambda (it)
      (cond
         ((and (inbuilt-it? it) (eqv? (it->count it) 2))
            (cond
               ((long-ts? it)
                  (cond
                     ((eqv? (it->kind2 it) 'double) #t)
                     (else #f)
               ))
               (else #f)
         ))
         (else #f)
)))

; signed-it? : Any -> Bool
(define signed-it?
   (lambda (it)
      (cond
         ((and (inbuilt-it? it) (eqv? (it->count it) 1))
            (or (int-ts? it) (signed-ts? it))
         )
         ((and (inbuilt-it? it) (eqv? (it->count it) 2))
            (cond
               ((signed-ts? it)
                  (cond
                     ((eqv? (it->kind2 it) 'int) #t)
                     (else #f)
               ))
               (else #f)
         ))
         (else #f)
)))

; signed-char-it? : Any -> Bool
(define signed-char-it?
   (lambda (it)
      (cond
         ((and (inbuilt-it? it) (eqv? (it->count it) 2))
            (cond
               ((signed-ts? it)
                  (cond
                     ((eqv? (it->kind2 it) 'char) #t)
                     (else #f)
               ))
               (else #f)
         ))
         (else #f)
)))

; unsigned-it? : Any -> Bool
(define unsigned-it?
   (lambda (it)
      (cond
         ((and (inbuilt-it? it) (eqv? (it->count it) 1))
            (unsigned-ts? it)
         )
         ((and (inbuilt-it? it) (eqv? (it->count it) 2))
            (cond
               ((unsigned-ts? it)
                  (cond
                     ((eqv? (it->kind2 it) 'int) #t)
                     (else #f)
               ))
               (else #f)
         ))
         (else #f)
)))

; unsigned-char-it? : Any -> Bool
(define unsigned-char-it?
   (lambda (it)
      (cond
         ((and (inbuilt-it? it) (eqv? (it->count it) 2))
            (cond
               ((unsigned-ts? it)
                  (cond
                     ((eqv? (it->kind2 it) 'char) #t)
                     (else #f)
               ))
               (else #f)
         ))
         (else #f)
)))

; unsigned-short-it? : Any -> Bool
(define unsigned-short-it?
   (lambda (it)
      (cond
         ((and (inbuilt-it? it) (eqv? (it->count it) 2))
            (cond
               ((unsigned-ts? it)
                  (cond
                     ((eqv? (it->kind2 it) 'short) #t)
                     (else #f)
               ))
               (else #f)
         ))
         (else #f)
)))

; unsigned-int-it? : Any -> Bool
(define unsigned-int-it?
   (lambda (it)
      (unsigned-it? it)
))

; unsigned-long-it? : Any -> Bool
(define unsigned-long-it?
   (lambda (it)
      (cond
         ((and (inbuilt-it? it) (eqv? (it->count it) 2))
            (cond
               ((unsigned-ts? it)
                  (cond
                     ((eqv? (it->kind2 it) 'long) #t)
                     (else #f)
               ))
               (else #f)
         ))
         (else #f)
)))


; Extractors for the data type...

; it->kinds : IT -> type-specifier*
(define it->kinds
   (lambda (it)
      ts
))

; it->count : IT -> Size
(define it->count
   (lambda (it)
      (cond
         ((user-it? it)  1)
         (else   (length it))
)))

; it->kind1 : IT -> type-specifier | Kind
(define it->kind1
   (lambda (it)
      (cond
         ((user-it? it)  (car it))
         (else   (car it))
)))

; it->kind2 : IT -> type-specifier_b
(define it->kind2
   (lambda (it)
      (cond
         ((user-it? it)  (display "")) ; i.e. fail (a convenience to pose this way because using inbuilt-it? recurses indefinatly
         (else  (cadr it))
         ; else fail
)))

; it->tname : IT -> TName_b
(define it->tname
   (lambda (it)
      (cond
         ((user-it? it)  (cadr it))
         ((and (inbuilt-it? it) (eq? (it->count it) 1)) (qts2sts (it->kind1 it)))
         ((and (inbuilt-it? it) (eq? (it->count it) 2)) (string-append (qts2sts (it->kind1 it)) " " (qts2sts (it->kind2 it))))
         (else (display "In it->name, dont know how to convert ")(display it)(display " to a tname!\n"))
)))




; Valuation functions ...

; sts2qts = Str -> type-specifer
(define sts2qts
   (lambda (ts1)
     (cond 
        ((string=? ts1 "void")     'void)
        ((string=? ts1 "char")     'char)
        ((string=? ts1 "short")    'short)
        ((string=? ts1 "int")      'int)
        ((string=? ts1 "long")     'long)
        ((string=? ts1 "float")    'float)
        ((string=? ts1 "double")   'double)
        ((string=? ts1 "signed")   'signed)
        ((string=? ts1 "unsigned") 'unsigned)
        ; else fail
    )
))


; qts2sts = type-specifer -> Str
(define qts2sts
   (lambda (ts)
     (cond 
        ((eq? ts 'void)     "void")
        ((eq? ts 'char)     "char")
        ((eq? ts 'short)    "short")
        ((eq? ts 'int)      "int")
        ((eq? ts 'long)     "long")
        ((eq? ts 'float)    "float")
        ((eq? ts 'double)   "double")
        ((eq? ts 'signed)   "signed")
        ((eq? ts 'unsigned) "unsigned")
        ; else fail
    )
))



; IT[[TName]] = () -> IT_b
; IT[[TS1 TS2]] = () -> IT_b
(define ast->it
   (lambda (py_ast_var)
      (let ((count   (python-eval (string-append "len(" py_ast_var ".names)") #t))
            (ts1_str (python-eval (string-append py_ast_var ".names[0].encode('ascii')") #t))
           )
           (let ((ts1 (sts2qts ts1_str)))
              (cond
                 ((unspecified? ts1)  (make-user-it ts1_str))
                 (else
                    (cond
                       ((= count 1) (make-single-it ts1))
                       ((> count 1) 
                          (let ((ts2 (sts2qts (python-eval (string-append py_ast_var ".names[1].encode('ascii')") #t)))
                               )
                                  (make-double-it ts1 ts2)
                 ))))
)))))

; The following is for testing/developing the valuation function...
;
;(python-eval "import imp")
;(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-type-specifier.py' )")
;(python-eval "t = pyc.main_eg()")
;
;(display "\"")(display (ast->it "t.ext[0].children()[0][1].type"))(display "\"")(newline)
;(display "\"")(display (ast->it "t.ext[1].children()[0][1].type"))(display "\"")(newline)
;(display "\"")(display (ast->it "t.ext[2].children()[0][1].type"))(display "\"")(newline)
;(display "\"")(display (ast->it "t.ext[3].children()[0][1].type"))(display "\"")(newline)
;(display "\"")(display (ast->it "t.ext[4].children()[0][1].type"))(display "\"")(newline)
;(display "\"")(display (ast->it "t.ext[5].children()[0][1].type"))(display "\"")(newline)
;(display "\"")(display (ast->it "t.ext[6].children()[0][1].type"))(display "\"")(newline)
;(display "\"")(display (ast->it "t.ext[7].children()[0][1].type"))(display "\"")(newline)
;(display "\"")(display (ast->it "t.ext[8].children()[0][1].type"))(display "\"")(newline)
;(display "\"")(display (ast->it "t.ext[9].children()[0][1].type"))(display "\"")(newline)
;(display "\"")(display (ast->it "t.ext[10].children()[0][1].type"))(display "\"")(newline)
;(display "\"")(display (ast->it "t.ext[11].children()[0][1].type"))(display "\"")(newline)
;(display "\"")(display (ast->it "t.ext[12].children()[0][1].type"))(display "\"")(newline)
;(display "\"")(display (ast->it "t.ext[13].children()[0][1].type"))(display "\"")(newline)


