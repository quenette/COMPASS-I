(load "../m-MotionStmt.scm")
(load "../m-PointcutCall.scm")
(load "../c-FuncDef.scm")
 (load "../c-Statement.scm")
 (load "../c-FuncCall.scm")
  (load "../a-pcd.scm")
  (load "../a-advice.scm")
  (load "../a-weave.scm")
  (load "../a-advcomb.scm")
  (load "../m-motion.scm")

(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())


; Test very basic ms

(define  co1 (make-co (make-single-it 'signed) 1))
(define  co2 (make-co (make-single-it 'long) 2))
(define  el1 (make-el (list co1 co2)))
(define  id1 (make-id "test"))
(define  pc1 (make-pc id1 el1))
(display pc1) (newline)
(display (pc? pc1)) (newline) ; #t
(display (pc->sym pc1)) (newline) ; "test"
(newline)


; Load the functions (so they exist are known)...
(python-eval "import imp")
(python-eval "pyc = imp.load_source( 'test_pycparser', 'pycompasscparser.py' )")
(python-eval "import pycompasscparser")
(python-eval "parser = pycompasscparser.CompassCParser()")
(python-eval "fn = 't/scripts/test-compass-pointcut01.c'")
(python-eval "buf = open( fn, 'rU').read()")
(python-eval "t = parser.parse( buf, fn )")
(define tval_F1 ((ast->e-F "t.ext[0]") jp1 zeta1 (car rho,s) (cadr rho,s)))
(define tval_F2 ((ast->e-F "t.ext[1]") jp1 zeta1 (tval->rho tval_F1) (tval->s tval_F1)))
(define tval_F3 ((ast->e-F "t.ext[2]") jp1 zeta1 (tval->rho tval_F2) (tval->s tval_F2)))
(define tval_F4 ((ast->e-F "t.ext[3]") jp1 zeta1 (tval->rho tval_F3) (tval->s tval_F3)))
(define tval_F5 ((ast->e-F "t.ext[4]") jp1 zeta1 (tval->rho tval_F4) (tval->s tval_F4)))

(define tval_ms1 ((ast->e-ms "t.ext[6].children()[1][1].children()[0][1]") jp1 (tval->zeta tval_F5) (tval->rho tval_F5) (tval->s tval_F5)))
(define tval_ms2 ((ast->e-ms "t.ext[6].children()[1][1].children()[1][1]") jp1 (tval->zeta tval_ms1) (tval->rho tval_ms1) (tval->s tval_ms1)))
(display (tval->zeta tval_ms2))(newline) ;((motion #<unspecified> #<procedure #f (chi)> (and (pcall a) (args ())) d () () ()))
(newline)



; Call c then d
(define tval_pc1 ((ast->e-pc "t.ext[6].children()[1][1].children()[2][1]") jp1 (tval->zeta tval_ms2) (tval->rho tval_ms2) (tval->s tval_ms2)))


;; Test that the function call to the pcalls result in expected weaves
;(define  el1 (make-el '()))
;(define  id1 (make-id "b"))
;(define  fc1 (make-fc id1 el1))
;(display fc1) (newline)
;(define  el2 (make-el '()))
;(define  id2 (make-id "a"))
;(define  fc2 (make-fc id2 el2))
;(display fc2) (newline)
;(newline)
;
;; Test that a real function call to "b" triggers the weave to include "c"...
;(define tval_2 ((e-fc fc1) jp1 (tval->zeta tval_1_4) (tval->rho tval_1_4) (tval->s tval_1_4)))
;(newline)
;
;; Test that a real function call to "a" triggers the weave to include "d"...
;(define tval_3 ((e-fc fc2) jp1 (tval->zeta tval_ms2) (tval->rho tval_ms2) (tval->s tval_ms2)))
;(newline)

