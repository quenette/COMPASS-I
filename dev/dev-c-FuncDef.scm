(load "../c-FuncDef.scm")
(load "../c-DenDecl.scm")
(load "../c-Declaration.scm")
(load "../c-Statement.scm")

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())

(define td1 (make-it-td (make-id "argc") (make-single-it 'int)))
(define od1 (make-td-od td1 (display "")))
(define dd1a (make-od-dd od1))
(define  D1 (make-od-D dd1a))
(define pl1 (make-pl (list D1)))
(define td2 (make-it-td (make-id "main") (make-single-it 'int)))
(define od4 (make-td-od td2 (display "")))
(define fd1 (make-fd pl1 od4))
(define  D2 (make-fd-D fd1))

(define td3 (make-it-td (make-id "test") (make-single-it 'int)))
(define co1 (make-co (make-single-it 'int) 1))
(define  D3 (make-od-Eel-D td3 co1))
(define co2 (make-co (make-single-it 'float) "1.5"))
(define re1 (make-re co2))
(define  C1 (make-C (list D3) (list re1)))

(define  F1 (make-F D2 C1))
(display F1) (newline)
(display (F? F1))(newline) ;#t
(display (F->sym F1))(newline) ;main

;(func-def 
;   (func-decl 
;     (paramlist 
;       ( (decl (type-decl (identifier argc) (int) #<unspecified>)) ) 
;     ) 
;     (type-decl (identifier main) (int) #<unspecified>) 
;   ) 
;   (compound 
;      ( (decl (type-decl (identifier test) (int)) (constant (int) 1)) ) 
;      ( (return (constant (float) 1.5)) ) 
;   )
;)

(define tval1_0 ((e-F F1) jp1 zeta1 (car rho,s) (cadr rho,s)))
(display tval1_0)(newline)
(display (apply-env 'fnext-l (tval->rho tval1_0))) (newline) ;1
(display (apply-env "main" (tval->rho tval1_0))) (newline) ;1


(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-c-func.py' )")
(python-eval "t = pyc.main_eg()")

(define F2 (ast->F "t.ext[1]"))
(display F2) (newline)
(display (F? F2))(newline) ;#t
(display (F->sym F2))(newline) ;b

;(func-def 
;   (decl 
;      (func-decl 
;         (paramlist 
;            ( 
;               (decl (type-decl (identifier i) (int) #<unspecified>)) 
;               (decl (ptr-decl (type-decl (identifier j) (int) #<unspecified>) #<unspecified>))
;            )
;         ) 
;         (ptr-decl 
;            (type-decl 
;               (identifier b) 
;               (int) 
;               #<unspecified>
;            ) 
;            #<unspecified>
;         )
;      )
;   ) 
;   (compound 
;      ( 
;         (decl (ptr-decl (type-decl (identifier k) (int) #<unspecified>) #<unspecified>) (constant (int) 2)) 
;         (decl (type-decl (identifier l) (int) #<unspecified>))
;      ) 
;      (
;         (return (identifier k)) 
;      )
;   )
;)

(define tval2_0 ((e-F F2) jp1 zeta1 (car rho,s) (cadr rho,s)))
(display tval2_0)(newline)
(display (apply-env 'fnext-l (tval->rho tval2_0))) (newline) ;1
(display (apply-env "b" (tval->rho tval2_0))) (newline) ;0

