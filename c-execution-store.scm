; 
; Developed for guile scheme v 1.8.7

(load "a-jp.scm")
(load "c-execution.scm")
(load "c-env.scm")
(load "c-store.scm")


; Construction operations ...


; Other operations...

; e-apply-env : Sym -> ( JP -> Mot -> Env -> Sto ) -> ( Loc x Mot x Env x Sto )_b                 i.e: Sym -> T(Val)
(define e-apply-env
   (lambda (sym)
      (lambda (jp zeta rho s)
         ((return-e (apply-env sym rho)) jp zeta rho s)
)))

; e-extend-env : Sym -> Loc -> TypeInfo ->( JP -> Mot -> Env -> Sto ) -> ( Loc x Mot x Env' x Sto )     i.e: Sym -> Val -> T(Val)
(define e-extend-env
   (lambda (sym l ti)
      (lambda (jp zeta rho s)
         ((return-e l) jp zeta (extend-env sym l rho ti) s)
)))

; e-apply-s : Loc -> ( JP -> Mot -> Env -> Sto ) -> ( Val x Mot x Env x Sto )_b                 i.e: Loc -> T(Val)
(define e-apply-s
   (lambda (l)
      (lambda (jp zeta rho s)
         ((return-e (apply-s l s)) jp zeta rho s)
)))

; e-extend-s : Loc -> Val -> ( JP -> Mot -> Env -> Sto ) -> ( Val x Mot x Env' x Sto )          i.e: Sym -> Val -> T(Val)
(define e-extend-s
   (lambda (l v)
      (lambda (jp zeta rho s)
         ((return-e v) jp zeta rho (extend-s l v s))
)))


; e-alloc : Size -> ( JP -> Mot -> Env -> Sto ) -> ( Loc x Mot x Env' x Sto )                     i.e: Size -> T(Val)
(define e-alloc
   (lambda (sz)
      (lambda (jp zeta rho s)
         (let ((l-rho (alloc sz rho)))
              ((return-e (car l-rho)) jp zeta (cdr l-rho) s)
))))

; e-allocn : Size -> Count -> ( JP -> Mot -> Env -> Sto ) -> ( Loc x Mot x Env' x Sto )           i.e: Size -> Count -> T(Val)
(define e-allocn
   (lambda (sz c)
      (lambda (jp zeta rho s)
         (let ((l-rho (alloc (* sz c) rho)))
              ((return-e (car l-rho)) jp zeta (cdr l-rho) s)
))))

; e-falloc : Size -> ( JP -> Mot -> Env -> Sto ) -> ( Loc x Mot x Env' x Sto )                    i.e: Size -> T(Val)
(define e-falloc
   (lambda (sz)
      (lambda (jp zeta rho s)
         (let ((l-rho (falloc sz rho)))
              ((return-e (car l-rho)) jp zeta (cdr l-rho) s)
))))

; e-newref : Sym x Loc x TypeInfo -> ( JP -> Mot -> Env -> Sto ) -> ( Loc x Mot x Env' x Sto )    i.e: Sym x Loc x TypeInfo -> T(Val)
;   Note: TypeInfo is not part of the theoretical model at this point, but is very useful for the implementation at this point.
(define e-newref
   (lambda (sym l ti)
      (lambda (jp zeta rho s)
         ((return-e l) jp zeta (extend-env sym l rho ti) s)
)))

; e-decl : Sym -> Size -> ( JP -> Mot -> Env -> Sto ) -> ( Loc x Mot x Env' x Sto )               i.e: Sym -> Size -> T(Val)
(define e-decl
   (lambda (sym sz ti)
      (lambda (jp zeta rho s)
         ((seq-e (e-alloc sz) (lambda (x) (e-newref sym x ti))) jp zeta rho s)
)))

; e-decln : Sym -> Size -> Count -> ( JP -> Mot -> Env -> Sto ) -> ( Loc x Mot x Env' x Sto )   i.e: Sym -> Size -> Count -> T(Val)
(define e-decln
   (lambda (sym sz c ti)
      (lambda (jp zeta rho s)
         ((seq-e (e-allocn sz c) (lambda (x) (e-newref sym x ti))) jp zeta rho s)
)))

; e-fdecl : Sym -> Size -> ( JP -> Mot -> Env -> Sto ) -> ( Loc x Mot x Env' x Sto )              i.e: Sym -> Size -> T(Val)
(define e-fdecl
   (lambda (sym sz ti)
      (lambda (jp zeta rho s)
         ((seq-e (e-falloc sz) (lambda (x) (e-newref sym x ti))) jp zeta rho s)
)))


; e-deref : Sym -> ( JP -> Mot -> Env -> Sto ) -> ( Val x Mot x Env' x Sto )_b                    i.e: Sym -> T(Val)
(define e-deref
   (lambda (sym)
      (lambda (jp zeta rho s)
         ((return-e (deref sym rho s)) jp zeta rho s)
)))

; e-setref : Sym x Val -> ( JP -> Mot -> Env -> Sto ) -> ( Val x Mot x Env x Sto' )              i.e: Sym x Val -> T(Val)
;  returns v, and hence setref in the monadic context is also an expression
(define e-setref
   (lambda (id v)
      (lambda (jp zeta rho s)
         ((return-e v) jp zeta rho (extend-s (apply-env id rho) v s))
)))

; e-extend-sn : Loc x Val -> Count -> (JP->Mot->Env->Sto) -> ( Count x Mot x Env x Sto' )    i.e: Loc -> Val -> Count -> T(Val)
; return number set operations performed (given by offset and should be same as count)
(define e-extend-sn
   (lambda (l v c)
      (lambda (jp zeta rho s)
         ((e-extend-sn' l v c 0) jp zeta rho s)
)))

(define e-extend-sn'
   (lambda (l v c offset)
      (lambda (jp zeta rho s)
         (cond
            ((eq? c offset)   ((return-e offset) jp zeta rho s))
            (else             ((e-extend-sn' l v c (+ offset 1)) jp zeta rho (extend-s (+ l offset) v s)))
))))

; e-extend-s* : Loc x Val* -> Count -> (JP->Mot->Env->Sto) -> ( Val x Mot x Env x Sto' )  i.e: Loc -> Val* -> Count -> T(Val)
; return number set operations performed (given by offset and should be same as count)
(define e-extend-s*
   (lambda (l v* c)
      (lambda (jp zeta rho s)
         ((e-extend-s*' l v* c 0) jp zeta rho s)
)))

(define e-extend-s*'
   (lambda (l v* c offset)
      (lambda (jp zeta rho s)
         (cond
            ((eq? c offset) ((return-e offset) jp zeta rho s))
            (else           ((e-extend-s*' l (cdr v*) c (+ offset 1)) jp zeta rho (extend-s (+ l offset) (car v*) s)))
))))

; e-getenv : () -> ( JP -> Mot -> Env -> Sto ) -> ( Env x Mot x Env x Sto )                       i.e. () -> T(Val)
;  Return the current (monadic) environment
(define e-getenv
   (lambda (x)
      (lambda (jp zeta rho s)
         ((return-e rho) jp zeta rho s)
)))


; e-cpenv : () -> ( JP -> Mot -> Env -> Sto ) -> ( Env x Mot x Env x Sto )                        i.e. () -> T(Val)
;  Create a copy of the current (monadic) environment and return that copy
(define e-cpenv
   (lambda (x)
      (lambda (jp zeta rho s)
         (let ((rho'   (cp-env rho)))
              ((return-e rho') jp zeta rho' s)
))))


; e-setenv : Env' -> ( JP -> Mot -> Env -> Sto ) -> ( Env' x Mot x Env' x Sto )                   i.e. () -> T(Val)
(define e-setenv
   (lambda (rho')
      (lambda (jp zeta rho s)
         ((return-e rho') jp zeta rho' s)
)))

