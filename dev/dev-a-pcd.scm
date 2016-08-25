(load "../a-jp.scm")
(load "../a-pcd.scm")
(load "../c-execution.scm")
(load "../c-execution-store.scm")


; testing ...

; test-advice01: T(Val) -> ( JP -> Env -> Sto ) -> ( Val' x Env x Sto )                      i.e. Val -> T(Val)
; Return t-value is always 1
(define test-advice01
   (lambda (chi_rho)
      (lambda (jp zeta rho s)
         ((seq-e
            ; create a new environment
            (e-cpenv '()) 
            (lambda (rho') (seq-e 
               ; populate the advice arguments with values
               chi_rho 
               (lambda (_) (seq-e 
                  ; apply the advice body...
                  (begin
                     (display "I am a (pretend) advice body.\n")
                     (return-e 1))
                  (lambda (r) (seq-e
                     ; revert to the previous environment
                     (e-setenv rho')
                     ; return the value
                     (lambda (_) (return-e r))
         ))))))) jp zeta rho s)
)))

; test-continuation01: ( JP -> Env -> Sto ) -> ( Val' x Env x Sto )                               i.e. Val -> T(Val)
; Return t-value is always 0
(define test-continuation01
      (lambda (jp zeta rho s)
         (begin
            (display "I am a (pretend) continuation.\n")
            ((return-e 2) jp zeta rho s) 
)))


(define rho  (make-env 0 100000))
(define s  (empty-s))
(define rho,s (list rho s))

(define jp1 ((new-call-jp 'myProc (list 1 2 3)) (display "")))
(define jp2 ((new-mcall-jp 'myObj 'myProc (list 4 5 6)) (display "")))
(display "jp1: ") (display jp1) (newline)
(display "jp2: ") (display jp2) (newline)
(define rho00_1 (extend-env "v1" 100000 rho     'myType1))
(define rho00_2 (extend-env "v2" 100001 rho00_1 'myType2))
(define rho00_3 (extend-env "v3" 100002 rho00_2 'myType3))
(define zeta1 (display ""))


(define pcd01  (list 'pcall 'myProc))
(define al01   (match-pcd pcd01 jp1))
(display "al01: ") (display al01) (newline)                 ; (empty-al)
(define tval01 ((e-pcd pcd01 test-advice01 test-continuation01) jp1 zeta1 rho00_3 s))
(display "val01: ") (display (tval->val tval01)) (newline)  ; 1
(newline)

(define pcd02  (list 'fcall 'myProc))
(define al02   (match-pcd pcd02 jp1))
(display "al02: ") (display al02) (newline)                 ; (empty-al)
(newline)

(define pcd03  (list 'foo 'myProc))
(define al03   (match-pcd pcd03 jp1))
(display "al03: ") (display al03) (newline)                 ; #<unspecified>
(define tval03 ((e-pcd pcd03 test-advice01 test-continuation01) jp1 zeta1 rho00_3 s))
(display "val03: ") (display (tval->val tval03)) (newline)  ; 2
(newline)

(define pcd04  (list 'pcall 'bar))
(define al04   (match-pcd pcd04 jp1))
(display "al04: ") (display al04) (newline)                 ; #<unspecified>
(newline)

(define pcd05  (list 'args (list "v1" "v2" "v3")))
(define al05   (match-pcd pcd05 jp1))
(display "al05: ") (display al05) (newline)
(display (al->sym (lookup-al al05 "v1"))) (newline) ; v1
(display (al->v   (lookup-al al05 "v1"))) (newline) ; 1  (from jp)
(display (al->ti  (lookup-al al05 "v1"))) (newline) ; myType1
(display (al->sym (lookup-al al05 "v2"))) (newline) ; v2
(display (al->v   (lookup-al al05 "v2"))) (newline) ; 2  (from jp)
(display (al->ti  (lookup-al al05 "v2"))) (newline) ; myType2
(display (al->sym (lookup-al al05 "v3"))) (newline) ; v3
(display (al->v   (lookup-al al05 "v3"))) (newline) ; 3  (from jp)
(display (al->ti  (lookup-al al05 "v3"))) (newline) ; myType3
(newline)

(define pcd06  (list 'args (list "v1" "v2")))
(define al06   (match-pcd pcd06 jp1))
(display "al06: ") (display al06) (newline)                 ; #<unspecified>
(newline)

(define pcd07  (list 'args (list "v1" "v2" "v3" "v4")))
(define al07   (match-pcd pcd07 jp1))
(display "al07: ") (display al07) (newline)                 ; #<unspecified>
(newline)

(define pcd08  (list 'and (list 'pcall 'myProc) (list 'args (list "v1" "v2" "v3"))))
(define al08   (match-pcd pcd08 jp1))
(display "al08: ") (display al08)  (newline)                ; (extend-al v1 1 (extend-al v2 2 (extend-al v3 3 (empty-al))))
(display (al->sym (lookup-al al08 "v1"))) (newline) ; v1
(display (al->v   (lookup-al al08 "v1"))) (newline) ; 1  (from jp)
(display (al->ti  (lookup-al al08 "v1"))) (newline) ; myType1
(display (al->sym (lookup-al al08 "v2"))) (newline) ; v2
(display (al->v   (lookup-al al08 "v2"))) (newline) ; 2  (from jp)
(display (al->ti  (lookup-al al08 "v2"))) (newline) ; myType2
(display (al->sym (lookup-al al08 "v3"))) (newline) ; v3
(display (al->v   (lookup-al al08 "v3"))) (newline) ; 3  (from jp)
(display (al->ti  (lookup-al al08 "v3"))) (newline) ; myType3
(newline)

(define pcd09  (list 'and (list 'foo 'myProc) (list 'args (list "v1" "v2" "v3"))))
(define al09   (match-pcd pcd09 jp1))
(display "al09: ") (display al09) (newline)                 ; #<unspecified>
(newline)

(define pcd10  (list 'and (list 'pcall 'myProc) (list 'args (list "v1" "v2"))))
(define al10   (match-pcd pcd10 jp1))
(display "al10: ") (display al10) (newline)                 ; #<unspecified>
(newline)

(define pcd11  (list 'obj 'myObj))
(define al11   (match-pcd pcd11 jp2))
(display "al11: ") (display al11) (newline)                 ; (empty-al)
(newline)

(define pcd12  (list 'and (list 'and (list 'obj 'myObj) (list 'pcall 'myProc)) (list 'args (list "v1" "v2" "v3"))))
(define al12   (match-pcd pcd12 jp2))
(display "al12: ") (display al12) (newline)                 ; (extend-al v1 4 (extend-al v2 5 (extend-al v3 6 (empty-al))))
(display (al->sym (lookup-al al12 "v1"))) (newline) ; v1
(display (al->v   (lookup-al al12 "v1"))) (newline) ; 4  (from jp)
(display (al->ti  (lookup-al al12 "v1"))) (newline) ; myType1
(display (al->sym (lookup-al al12 "v2"))) (newline) ; v2
(display (al->v   (lookup-al al12 "v2"))) (newline) ; 5  (from jp)
(display (al->ti  (lookup-al al12 "v2"))) (newline) ; myType2
(display (al->sym (lookup-al al12 "v3"))) (newline) ; v3
(display (al->v   (lookup-al al12 "v3"))) (newline) ; 6  (from jp)
(display (al->ti  (lookup-al al12 "v3"))) (newline) ; myType3
(newline)

(define pcd13  (list 'and (list 'and (list 'obj 'myObj) (list 'pcall 'myProc)) (list 'args (list "v1" "v2" "v3"))))
(define al13   (match-pcd pcd13 jp1))
(display "al13: ") (display al13) (newline)                 ; #<unspecified>
(newline)

(define pcd14  (list 'and (list 'pcall 'myProc) (list 'args (list "v1" "v2" "v3"))))
(define al14   (match-pcd pcd14 jp2))
(display "al14: ") (display al14) (newline)                 ; (extend-al v1 4 (extend-al v2 5 (extend-al v3 6 (empty-al))))  ;Note - this is not the desired result. To compensate, always set the pcd's obj attribute to '<invalid> when there is no object.
(display (al->sym (lookup-al al14 "v1"))) (newline) ; v1
(display (al->v   (lookup-al al14 "v1"))) (newline) ; 4  (from jp)
(display (al->ti  (lookup-al al14 "v1"))) (newline) ; myType1
(display (al->sym (lookup-al al14 "v2"))) (newline) ; v2
(display (al->v   (lookup-al al14 "v2"))) (newline) ; 5  (from jp)
(display (al->ti  (lookup-al al14 "v2"))) (newline) ; myType2
(display (al->sym (lookup-al al14 "v3"))) (newline) ; v3
(display (al->v   (lookup-al al14 "v3"))) (newline) ; 6  (from jp)
(display (al->ti  (lookup-al al14 "v3"))) (newline) ; myType3
(newline)

(define pcd15  (list 'and (list 'and (list 'obj '<invalid>) (list 'pcall 'myProc)) (list 'args (list "v1" "v2" "v3"))))
(define al15   (match-pcd pcd15 jp1))
(display "al15: ") (display al15) (newline)                 ; (extend-al v1 1 (extend-al v2 2 (extend-al v3 3 (empty-al) #<unspecified>) #<unspecified>) #<unspecified>)  ; Note - see 14. In this case its the correct behaviour - both the pcd and the jp stating no obj but otherwise matching will result in a match.
(display (al->sym (lookup-al al15 "v1"))) (newline) ; v1
(display (al->v   (lookup-al al15 "v1"))) (newline) ; 1  (from jp)
(display (al->ti  (lookup-al al15 "v1"))) (newline) ; myType1
(display (al->sym (lookup-al al15 "v2"))) (newline) ; v2
(display (al->v   (lookup-al al15 "v2"))) (newline) ; 2  (from jp)
(display (al->ti  (lookup-al al15 "v2"))) (newline) ; myType2
(display (al->sym (lookup-al al15 "v3"))) (newline) ; v3
(display (al->v   (lookup-al al15 "v3"))) (newline) ; 3  (from jp)
(display (al->ti  (lookup-al al15 "v3"))) (newline) ; myType3
(newline)

(define pcd16  (list 'and (list 'and (list 'obj '<invalid>) (list 'pcall 'myProc)) (list 'args (list "v1" "v2" "v3"))))
(define al16   (match-pcd pcd16 jp2))
(display "al16: ") (display al16) (newline)                 ; #<unspecified>
(newline)

(define pcd17  (list 'and (list 'and (list 'obj 'someVal) (list 'pcall 'myProc)) (list 'args (list "v1" "v2" "v3"))))
(define al17   (match-pcd pcd17 jp2))
(display "al17: ") (display al17) (newline)                 ; #<unspecified>
(newline)

