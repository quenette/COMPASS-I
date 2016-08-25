(load "../error.scm")
(load "../kind.scm")
(load "../c-env.scm")
(load "../c-TypeDecl.scm")
(load "../c-DenjDecl.scm")

(define td1 (make-it-td (make-id "d") (make-single-it 'int)))
(define od1 (make-td-od td1 (display "")))
(define dd1 (make-od-dd od1))
(define typeinfo-d dd1)

(define td2 (make-it-td (make-id "x") (make-double-it 'unsigned 'int)))
(define od2 (make-td-od td2 (display "")))
(define dd2 (make-od-dd od2))
(define typeinfo-x dd2)

(define td3 (make-it-td (make-id "x") (make-single-it 'short)))
(define od3 (make-td-od td3 (display "")))
(define dd3 (make-od-dd od3))
(define typeinfo-y dd3)

(define rho
   (extend-env "d" 6
      (extend-env "y" 8
         (extend-env "x" 7
            (extend-env "y" 14
               (empty-env) typeinfo-y ) typeinfo-x ) typeinfo-y ) typeinfo-d ))
(display rho)(newline)
(display (env? rho))(newline)
(display (apply-env "d" rho))(newline)
(display (apply-env "x" rho))(newline)
(display (apply-env "y" rho))(newline)
(display (type-info "d" rho))(newline)
(display (type-info "y" rho))(newline)
(display (type-info "x" rho))(newline)

(define rho2
   (extend-env "d" 6
      (extend-env "y" 8
         (extend-env "x" 7
            (extend-env "y" 14
               (make-env 0 23) typeinfo-y ) typeinfo-x ) typeinfo-y ) typeinfo-d ))
(display rho2)(newline)
(display (apply-env 'next-l rho2))(newline)
(display (equal? (apply-env 'next-l rho2) 23))(newline)
(display (alloc 1 rho2))(newline)
(display (car (alloc 1 rho2)))(newline)
(display (cdr (alloc 1 rho2)))(newline)

(display (cp-env (cdr (alloc 1 rho2))))(newline)

