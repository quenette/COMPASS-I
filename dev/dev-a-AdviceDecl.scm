(load "../a-AdviceDecl.scm")
(load "../c-FuncDef.scm")
 (load "../c-Statement.scm")
 (load "../c-FuncCall.scm")
  (load "../a-pcd.scm")
  (load "../a-advice.scm")
  (load "../a-weave.scm")
  (load "../a-advcomb.scm")
  (load "../m-motion.scm")
;(load "../c-DenDecl.scm")
;(load "../c-Declaration.scm")

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())

; Test very basic A
(define  A1 (make-A-after (make-id "c") (make-id "b")))
(display A1) (newline)
(display (A? A1))(newline) ;#t
(display (A->kind A1))(newline) ;advice-after
(display (A->sym_pcall A1))(newline) ;b
(display (A->sym_body A1))(newline) ;c
(newline)


; Load the functions (so they exist are known)...
(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test-aspect-func2.py' )")
(python-eval "t = pyc.main_eg()")
(define tval_F1 ((ast->e-F "t.ext[0]") jp1 zeta1 (car rho,s) (cadr rho,s)))
(define tval_F2 ((ast->e-F "t.ext[1]") jp1 zeta1 (tval->rho tval_F1) (tval->s tval_F1)))
(define tval_F3 ((ast->e-F "t.ext[2]") jp1 zeta1 (tval->rho tval_F2) (tval->s tval_F2)))
(define tval_F4 ((ast->e-F "t.ext[3]") jp1 zeta1 (tval->rho tval_F3) (tval->s tval_F3)))
(define tval_F5 ((ast->e-F "t.ext[5]") jp1 zeta1 (tval->rho tval_F4) (tval->s tval_F4)))

; Test that A can interact with the environment to extract the motion it must create
(define tval_1_1 ((A->e-pcd A1) jp1 zeta1 (tval->rho tval_F5) (tval->s tval_F5))) 
(display (tval->val tval_1_1))(newline) ;(and (pcall b) (args ()))
(define tval_1_2 ((A->e-alpha A1 (tval->val tval_1_1)) jp1 (tval->zeta tval_1_1) (tval->rho tval_1_1) (tval->s tval_1_1))) 
(display (tval->val tval_1_2))(newline) ;#<procedure #f (chi)>
(define tval_1_3 ((A->e-m A1) jp1 (tval->zeta tval_1_2) (tval->rho tval_1_2) (tval->s tval_1_2))) 
(display (tval->val tval_1_3))(newline) ;(motion () #<procedure #f (chi)> (and (pcall b) (args ())) c () () ())
(define tval_1_4 ((e-A A1) jp1 (tval->zeta tval_1_3) (tval->rho tval_1_3) (tval->s tval_1_3))) 
(display (tval->zeta tval_1_4))(newline) ;((motion () #<procedure #f (chi)> (and (pcall b) (args ())) c () () ()))
(newline)

; Test that an A can be created and applied from the AST
(define tval_A2 ((ast->e-A "t.ext[4]") jp1 (tval->zeta tval_F5) (tval->rho tval_F5) (tval->s tval_F5)))
(display (tval->zeta tval_A2))(newline) ;((motion () #<procedure #f (chi)> (and (pcall a) (args ())) d () () ()))
(newline)

; Test that the function call to the pcalls result in expected weaves
(define  el1 (make-el '()))
(define  id1 (make-id "b"))
(define  fc1 (make-fc id1 el1))
(display fc1) (newline)
(define  el2 (make-el '()))
(define  id2 (make-id "a"))
(define  fc2 (make-fc id2 el2))
(display fc2) (newline)
(newline)

; Test that a real function call to "b" triggers the weave to include "c"...
(define tval_2 ((e-fc fc1) jp1 (tval->zeta tval_1_4) (tval->rho tval_1_4) (tval->s tval_1_4)))
(newline)

; Test that a real function call to "a" triggers the weave to include "d"...
(define tval_3 ((e-fc fc2) jp1 (tval->zeta tval_A2) (tval->rho tval_A2) (tval->s tval_A2)))
(newline)

