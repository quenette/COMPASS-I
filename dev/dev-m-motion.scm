(load "../c-execution.scm")
(load "../c-execution-store.scm")
(load "../a-pcd.scm")
(load "../m-motion.scm")

(load "dev-m-tearup.scm")


(display "m01: ") (display m01) (newline)
(display "m02: ") (display m02) (newline)
(display "m03: ") (display m03) (newline)
(display "m04: ") (display m04) (newline)
(display "m05: ") (display m05) (newline)
(display "m06: ") (display m06) (newline)
(display "m07: ") (display m07) (newline)
(display "m08: ") (display m08) (newline)
(display "m09: ") (display m09) (newline)

; test the predicates ...
(newline)
(define k        (m->k      m02)) ; motion
(display "k: ") (display k) (newline)
(define o        (m->o      m02)) ; '()
(display "o: ") (display o) (newline)
(define alpha    (m->alpha  m02)) ; "alpha02"
(display "alpha: ") (display alpha) (newline)
(define pcd      (m->pcd    m02)) ; (and (pcall func-a) (args ()))
(display "pcd: ") (display pcd) (newline)
(define pname    (m->pname  m02)) ; "ab02"
(display "pname: ") (display pname) (newline)
(define pname_|m       (m->pname_|m     m02)) ; "ab01"
(display "pname_|m: ") (display pname_|m) (newline)
(define |p       (m->|p     m02)) ; 'first
(display "|p: ") (display |p) (newline)
(define |pc      (m->|pc    m02)) ; 'always
(display "|pc: ") (display |pc) (newline)


; matchm ... asks the question - given a motion does it satisfy the PCD and abstract body name?
(newline)
(define matchm01 (matchm   pcd02 abname02   m01))   ; _b
(display "matchm01: ")(display matchm01)(newline)
(define matchm02 (matchm   pcd03 abname03   m01))   ; _b  (because abname not the same) 
(display "matchm02: ")(display matchm02)(newline)
(define matchm03 (matchm   pcd01 abname01   m01))   ; m01 (proc match works)
(display "matchm03: ")(display matchm03)(newline)
(define matchm05 (matchm   pcd04 abname01   m01))   ; _b   (means overloading on func args is supported)
(display "matchm05: ")(display matchm05)(newline)
(define matchm06 (matchm   pcd05 abname04   m04))   ; _b   (means method vs none method works with same name works)
(display "matchm06: ")(display matchm06)(newline)
(define matchm07 (matchm   pcd06 abname05   m05))   ; m05
(display "matchm07: ")(display matchm07)(newline)

(define matchm08 (matchm   pcd08 abname07   m07))   ; m07
(display "matchm08: ")(display matchm08)(newline)
(define matchm09 (matchm   pcd09 abname07   m07))   ; _b
(display "matchm09: ")(display matchm09)(newline)


;uniquem?... asks the question - given an m is it unique compared to another m? (different question to does an m match a pcd/abname)
(newline)
(define uniquem?01 (uniquem? m01 m02))
(display "uniquem?01: ")(display uniquem?01)(newline) ; m01
(define uniquem?03 (uniquem? m01 m03))
(display "uniquem?03: ")(display uniquem?03)(newline) ; _b
(define uniquem?04 (uniquem? m01 m04))
(display "uniquem?04: ")(display uniquem?04)(newline) ; m01  (means overloading on func args is supported)
(define uniquem?05 (uniquem? m01 m05))
(display "uniquem?05: ")(display uniquem?05)(newline) ; m01  (means method vs non-method w same name works)
(define uniquem?06 (uniquem? m10 m05))
(display "uniquem?06: ")(display uniquem?06)(newline) ; m10
(define uniquem?07 (uniquem? m10 m13))
(display "uniquem?07: ")(display uniquem?07)(newline) ; _b


