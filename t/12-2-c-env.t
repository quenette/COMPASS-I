#!/usr/bin/guile -env
!#

(use-modules (guiletap))
(load "../c-env.scm")
(load "../c-TypeDecl.scm")
(load "../c-DenDecl.scm")


(plan 18)


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

(define rho1
   (extend-env "d" 6
      (extend-env "y" 8
         (extend-env "x" 7
            (extend-env "y" 14
               (empty-env) typeinfo-y ) typeinfo-x ) typeinfo-y ) typeinfo-d ))

(is-ok  1 "(env? rho1)"                                 #t             (env? rho1))
(is-ok  2 "(env? (list 1 2))"                           #f             (env? (list 1 2)))

(is-ok  3 "(equal? (apply-env \"d\" rho1) 6)"           #t             (equal? (apply-env "d" rho1) 6))
(is-ok  4 "(equal? (apply-env \"y\" rho1) 8)"           #t             (equal? (apply-env "y" rho1) 8))
(is-ok  5 "(equal? (apply-env \"x\" rho1) 7)"           #t             (equal? (apply-env "x" rho1) 7))
(is-ok  6 "(equal? (apply-env \"y\" rho1) 14)"          #f             (equal? (apply-env "y" rho1) 14)) 

(is-ok  7 "(equal? (type-info \"d\" rho1) typeinfo-d)"  #t             (equal? (type-info "d" rho1) typeinfo-d))
(is-ok  8 "(equal? (type-info \"y\" rho1) typeinfo-y)"  #t             (equal? (type-info "y" rho1) typeinfo-y))
(is-ok  9 "(equal? (type-info \"x\" rho1) typeinfo-x)"  #t             (equal? (type-info "x" rho1) typeinfo-x))

(define rho2
   (extend-env "d" 6
      (extend-env "y" 8
         (extend-env "x" 7
            (extend-env "y" 14
               (make-env 0 23) typeinfo-y ) typeinfo-x ) typeinfo-y ) typeinfo-d ))
(is-ok 10 "env? rho2"                                   #t             (env? rho2))
(is-ok 11 "'next-l = 23?"                               #t             (equal? (apply-env 'next-l rho2) 23))

(define l,rho3 (alloc 1 rho2))
(is-ok 12 "car alloc = 23?"                             #t             (equal? (car l,rho3) 23))
(is-ok 13 "'next-l = 24?"                               #t             (equal? (apply-env 'next-l (cdr l,rho3)) 24))

(define rho4 (cp-env (cdr l,rho3)))
(is-ok 14 "(equal? (apply-env \"d\" rho4) 6)"           #t             (equal? (apply-env "d" rho4) 6))
(is-ok 15 "(equal? (apply-env \"y\" rho4) 8)"           #t             (equal? (apply-env "y" rho4) 8))
(is-ok 16 "(equal? (apply-env \"x\" rho4) 7)"           #t             (equal? (apply-env "x" rho4) 7))
(is-ok 17 "(equal? (apply-env \"y\" rho4) 14)"          #f             (equal? (apply-env "y" rho4) 14)) 
(is-ok 18 "'next-l = 24?"                               #t             (equal? (apply-env 'next-l (cdr l,rho3)) 24))

