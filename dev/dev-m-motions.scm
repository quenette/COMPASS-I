(load "../c-execution.scm")
(load "../c-execution-store.scm")
(load "../a-pcd.scm")
(load "../m-motion.scm")
(load "../m-advices.scm")
(load "../m-motions.scm")

(load "dev-m-tearup.scm")


(newline)
(define zeta01   (list m01 m02 m05 m07 m09))
(display "zeta01: ") (display zeta01) (newline)


; getm' ... (non-monadic version)
(newline)
(define getm'01  (getm' pcd01 abname01 zeta01))
(display "getm'01: ") (display getm'01) (newline)   ; m01
(define getm'02  (getm' pcd02 abname02 zeta01))
(display "getm'02: ") (display getm'02) (newline)   ; m02
(define getm'03  (getm' pcd05 abname05 zeta01))
(display "getm'03: ") (display getm'03) (newline)   ; m05
(define getm'04  (getm' pcd07 abname07 zeta01))
(display "getm'04: ") (display getm'04) (newline)   ; m07
(define getm'05  (getm' pcd09 abname09 zeta01))
(display "getm'05: ") (display getm'05) (newline)   ; m09

(define getm'06  (getm' pcd01 abname02 zeta01))
(display "getm'06: ") (display getm'06) (newline)   ; _b


(newline)
(define jp       (display ""))
(define zeta02   '())
(define rho     (make-env 0 100000))
(define s        (empty-s))
(define tval00   ((return-e '()) jp zeta02 rho s))
(display "tval00: ")(display tval00)(newline)

; monad appendm and getm...
(newline)
(define tval01    ((appendm m01) jp (tval->zeta tval00) (tval->rho tval00) (tval->s tval00))) ; len = 1
(display "len(zeta): ")(display (length (tval->zeta tval01)))(newline)
(define tval02    ((appendm m02) jp (tval->zeta tval01) (tval->rho tval01) (tval->s tval01))) ; len = 2
(display "len(zeta): ")(display (length (tval->zeta tval02)))(newline)
(define tval03    ((appendm m05) jp (tval->zeta tval02) (tval->rho tval02) (tval->s tval02))) ; len = 3
(display "len(zeta): ")(display (length (tval->zeta tval03)))(newline)
(define tval04    ((appendm m07) jp (tval->zeta tval03) (tval->rho tval03) (tval->s tval03))) ; len = 4
(display "len(zeta): ")(display (length (tval->zeta tval04)))(newline)
(define tval05    ((appendm m09) jp (tval->zeta tval04) (tval->rho tval04) (tval->s tval04))) ; len = 5
(display "len(zeta): ")(display (length (tval->zeta tval05)))(newline)

(define tval06    ((getm pcd01 abname01) jp (tval->zeta tval05) (tval->rho tval05) (tval->s tval05))) ; m01
(display "tval06: ")(display (tval->val tval06))(newline)
(define tval07    ((getm pcd02 abname02) jp (tval->zeta tval06) (tval->rho tval06) (tval->s tval06))) ; m02
(display "tval07: ")(display (tval->val tval07))(newline)
(define tval08    ((getm pcd05 abname05) jp (tval->zeta tval07) (tval->rho tval07) (tval->s tval07))) ; m05
(display "tval08: ")(display (tval->val tval08))(newline)
(define tval09    ((getm pcd07 abname07) jp (tval->zeta tval08) (tval->rho tval08) (tval->s tval08))) ; m07
(display "tval09: ")(display (tval->val tval09))(newline)
(define tval10    ((getm pcd09 abname09) jp (tval->zeta tval09) (tval->rho tval09) (tval->s tval09))) ; m09
(display "tval10: ")(display (tval->val tval10))(newline)

(define tval11    ((getm pcd01 abname02) jp (tval->zeta tval10) (tval->rho tval10) (tval->s tval10))) ; _b
(display "tval11: ")(display (tval->val tval11))(newline)


; Test the basic relative motion operations (they require a list of motions)
(newline)

(define zeta_all   (list m01 m02 m03 m04 m05 m06 m07 m08 m09 m10 m11 m12 m13 m14 m15 m16 m17 m18 m19 m20 m21 m22 m23 m24))
(display "zeta_all: ") (display zeta_all) (newline)
(define matchm04 (matchm   
   (m->pcd (pname->zeta->m (m->pname_|m m02) zeta_all)) 
   (m->pname (pname->zeta->m (m->pname_|m m02) zeta_all))   
   m01)
)   ; m01   (means relative motion match works!)
(display "matchm04: ")(display matchm04)(newline)

(define uniquem?02 (uniquem? m01 (pname->zeta->m (m->pname_|m m02) (tval->zeta tval05))))
(display "uniquem?02: ")(display uniquem?02)(newline) ; _b



(newline)
(define zeta03   (list m05 m10 m11 m12))
(display "zeta03: ") (display zeta03) (newline)

(newline)
(define gamma01  (zeta->gamma|pc zeta03 zeta03 '())) ; alpha12 alpha10 alpha05 alpha11
(display "gamma01: ") (display gamma01) (newline)
(define zeta03'  (uniquezeta? zeta03))            ; '()
(display "zeta03': ") (display zeta03') (newline)


(newline)
(define zeta04   (list m05 m10 m11 m12 m13))
(display "zeta04: ") (display zeta04) (newline)

(newline)
(define zeta04'  (uniquezeta? zeta04))            ; _b
(display "zeta04': ") (display zeta04') (newline)


(newline)
(define gamma,zeta_c01  (zeta->gamma|m zeta03 zeta03 '() '())) ; (), m05 m10 m11 m12
(display "gamma,zeta_c01 (gamma): ") (display (car gamma,zeta_c01)) (newline)
(display "gamma,zeta_c01 (zeta_c): ") (display (cadr gamma,zeta_c01)) (newline)


(newline)
(define zeta05   (list m16 m17 m18 m19 m20 m21 m22 m23))
(define zeta06   (list m16 m17 m18 m19 m20 m21 m22 m23 m24))
(define zeta07   (list m16 m17 m18 m19 m10 m11 m12 m20 m21 m22 m23))
;(display "zeta05: ") (display zeta05) (newline)
(define gamma02  (list (m->alpha m06) (m->alpha m14) (m->alpha m15)))
;(display "gamma02: ") (display gamma02) (newline)


(newline)
(define gamma,zeta_c02  (zeta->gamma|m zeta_all zeta05 gamma02 '())) ; a20 a06 a21 a18 a23 a14 a22 a19 a16 15 a17 , ()
(display "gamma,zeta_c02 (gamma): ") (display (car gamma,zeta_c02)) (newline)
(display "gamma,zeta_c02 (zeta_c): ") (display (cadr gamma,zeta_c02)) (newline)
(define gamma,zeta_c03  (zeta->gamma|m zeta_all zeta06 gamma02 '())) ; _b, () ... 01 not motioned yet. works.
(display "gamma,zeta_c03 (gamma): ") (display (car gamma,zeta_c03)) (newline)
(display "gamma,zeta_c03 (zeta_c): ") (display (cadr gamma,zeta_c03)) (newline)
(define gamma,zeta_c04  (zeta->gamma|m zeta_all zeta07 gamma02 '())) ; a20 a06 a21 a18 a23 a14 a22 a19 a16 15 a17, m10 m11 m12
(display "gamma,zeta_c04 (gamma): ") (display (car gamma,zeta_c04)) (newline)
(display "gamma,zeta_c04 (zeta_c): ") (display (cadr gamma,zeta_c04)) (newline)


(newline)
(define zeta08   (list m06 m14 m15))
(define zeta09   (list m06 m14 m15 m16 m17 m18 m19 m05 m10 m11 m12 m20 m21 m22 m23 ))
(define zeta10   (list m23 m06 m14 m15 m16 m17 m18 m19 m05 m10 m11 m12 m20 m21 m22))
(define zeta11   (list m06 m14 m15 m16 m17 m18 m19 m05 m10 m11 m12 m20 m21 m22 m23 m13))
(define zeta12   (list m06 m14 m15 m16 m17 m18 m19 m05 m10 m11 m12 m20 m21 m22 m23 m24))

(newline)
(define gamma,zeta_|01  (zeta->gamma|<> zeta_all zeta08 '() '())) ;  a06 a14 a15,   ()
(display "gamma,zeta_|01 (gamma): ") (display (car gamma,zeta_|01)) (newline)
(display "gamma,zeta_|01 (zeta_|): ") (display (cadr gamma,zeta_|01)) (newline)
(define gamma,zeta_|02  (zeta->gamma|<> zeta_all zeta09 '() '())) ;  a06 a14 a15,   m16 m17 m18 m19 m05 m10 m11 m12 m20 m21 m22 m23
(display "gamma,zeta_|02 (gamma): ") (display (car gamma,zeta_|01)) (newline)
(display "gamma,zeta_|02 (zeta_|): ") (display (cadr gamma,zeta_|01)) (newline)

; TODO:
;  * gamma03 and gamma04 gives the wrong answer - should be a12 a10 a20 a06 a21 a23 a18 a14 a19 a22 15 a16 a17 a05 a11
;      thinking that insert-after/before-gamma always 'append' and fail to acknowledge when 'first' and is supposed to prepend
;  * Update the test pycompasscparser to have the attributes in root-pycompasscparser

(newline)
(define gamma03   (zeta->gamma  zeta09))
(display "gamma03: ") (display gamma03) (newline) ; a12 a10 a20 a06 a21 a18 a23 a14 a22 a19 a16 15 a17 a05 a11
(define gamma04   (zeta->gamma  zeta10))
(display "gamma04: ") (display gamma04) (newline) ; a12 a10 a20 a06 a21 a18 a23 a14 a22 a19 a16 15 a17 a05 a11 ... motion order doesn't matter ... good.
(define gamma05   (zeta->gamma  zeta11))
(display "gamma05: ") (display gamma05) (newline) ; _b (non unique constraints)
(define gamma06   (zeta->gamma  zeta12))
(display "gamma06: ") (display gamma06) (newline) ; _b (a relative that's not yet defined)





