; Advice - an instruction on a joinpoint.
;
; Given you know where you are (JP in the monad) and given a computation (T(Val)) and given an advice on that computation, produces a
;  new computation (T(Val)').  The computations will be procedures, functions, etc.
;
; Unlike Wand04, the Proc domain is implied in the T(Val), because the procedure/function argument variables are on the store and the
;  environment, both of which are part of the monadic store. Wand04 has to create/pass a Val* on procedures because the model hasn't
;  a mechanism for stacks (or whatever mechanisms to have variables per procedure).
;
; The advice counter - Is modelled here to be an environment variable that is exposed during the advice body as the local stored
;  variable "ai", on the assumption, that when not read by the advice body(s) it can be optimised out. The envionment identifer for
;  it is the JP itself (meaning that Sym += JP), ensuring that the counter is unique per joinpoint.
;
; Semantic algebras...
;   Domain aplha in Adv in T(Val)
;     (Domain jp in JP)
;     (Domain chi in T(Val))
;
;   Adv = T(Val) -> T(Val)c'
;
; Valuation functions...
;
;  Adv[[after  pcd pbody]]    = T(Val) -> T(Val)'
;  Adv[[before pcd pbody]]    = T(Val) -> T(Val)'
;  Adv[[around pcd pbody]]    = T(Val) -> T(Val)'
;
;
; TODO: ... actually not sure how this will change (if at all) given that in my model the alphas need to be ordered and hence the
;   "advice" keyword is needed to create the ordered list!!!   [Definition of 'Program' becomes important because it will state
;    when/where "advices" are read.
;
;
; Developed for guile scheme v 1.8.7


; Adv[[after  pcd (pname) chi_abody]]    = T(Val) -> T(Val)'
; pname is not part of the model - its there for more info
(define e-adv-after
   (lambda (pcd pname chi_abody)
      (lambda (chi)
         (lambda (jp zeta rho s)
            ((e-pcd 
               pcd 
               (lambda (delta-rho^al)
                  (seq-e
                     ; first - execute the original computation
                     chi
                     (lambda (r1) (seq-e
                        ; Create the stack-frame for the advice body. Populate the advice body arguments with the copy of the
                        ; original / intended values. Also expose the name of the procedure/function (original computation) through
                        ; the localvariable "within" and expose the advice counter through the local variable "counter".
                        (e-cpenv '()) 
                        (lambda (rho') (seq-e 
                           delta-rho^al 
                           (lambda (_) (seq-e
                              (e-alpha->rho,s (jp->pname jp))
                              (lambda (ai) (display "Calling advice body: \"")(display pname)(display "\"...\n") (seq-e
                                 ; apply the advice body
                                 chi_abody
                                 (lambda (r2) (seq-e
                                    ; revert to the previous environment
                                    (e-setenv rho')
                                    ; return the value
                                    (lambda (_) (seq-e
                                       ; increment the advice index
                                       (e-extend-env jp (+ ai 1) (display ""))
                                       (lambda (_) (e-ac r1 r1 r2))  ;r1
               ))))))))))))))
               chi
            ) jp zeta rho s)
))))


; Adv[[before pcd (pname) chi_abody]]    = T(Val) -> T(Val)'
; pname is not part of the model - its there for more info
(define e-adv-before
   (lambda (pcd pname chi_abody)
      (lambda (chi)
         (lambda (jp zeta rho s)
            ((e-pcd 
               pcd 
               (lambda (delta-rho^al)
                  (seq-e
                     ; Create the stack-frame for the advice body. Populate the advice body arguments with the copy of the
                     ; original / intended values. Also expose the name of the procedure/function (original computation) through
                     ; the localvariable "within" and expose the advice counter through the local variable "counter".
                     (e-cpenv '()) 
                     (lambda (rho') (seq-e 
                        delta-rho^al 
                        (lambda (_) (seq-e
                           (e-alpha->rho,s (jp->pname jp))
                           (lambda (ai) (display "Calling advice body: \"")(display pname)(display "\"...\n") (seq-e
                              ; apply the advice body
                              chi_abody
                              (lambda (r1) (seq-e
                                 ; revert to the previous environment
                                 (e-setenv rho')
                                 ; return the value
                                 (lambda (_) (seq-e
                                    ; second - execute the original computation
                                    chi
                                    (lambda (r2) (seq-e
                                       ; increment the advice index
                                       (e-extend-env jp (+ ai 1) (display ""))
                                       (lambda (_) (e-ac r2 r1 r2))   ;r2
               )))))))))))))) 
               chi
            ) jp zeta rho s)
))))


; Adv[[around pcd (pname) chi_abody]]    = T(Val) -> T(Val)'
; pname is not part of the model - its there for more info
(define e-adv-around
   (lambda (pcd pname chi_abody)
      (lambda (chi)
         (lambda (jp zeta rho s)
            ((e-pcd 
               pcd 
               (lambda (delta-rho^al)
                  (seq-e
                     ; Create the stack-frame for the advice body. Populate the advice body arguments with the copy of the
                     ; original / intended values. Also expose the name of the procedure/function (original computation) through
                     ; the localvariable "within" and expose the advice counter through the local variable "counter".
                     (e-cpenv '()) 
                     (lambda (rho') (seq-e 
                        delta-rho^al 
                        (lambda (_) (seq-e
                           (e-alpha->rho,s (jp->pname jp))
                           (lambda (ai) (display "Calling advice body: \"")(display pname)(display "\"...\n") (seq-e
                              ; apply the advice body
                              chi_abody
                              (lambda (r1) (seq-e
                                 ; revert to the previous environment
                                 (e-setenv rho')
                                 ; return the value
                                 (lambda (_) (seq-e
                                    ; increment the advice index
                                    (e-extend-env jp (+ ai 1) (display ""))
                                    (lambda (_) (e-ac r1 r1 r1))  ;r1
               ))))))))))))
               chi
            ) jp zeta rho s)
))))


; e-alpha->rho,s :  PName -> ( JP -> Env -> Sto ) -> ( Val x Env' x Sto' )                        i.e. PName -> T(Val)
;  Add the advice body variables to the environment and store.
;  Env' is a new resultant environment. Env is the initial environment of which the argument list is added to. The result is the
;  advice count.
(define e-alpha->rho,s
   (lambda (name)
      (lambda (jp zeta rho s) 
         ((seq-e
            (e-apply-env jp)
            (lambda (ai) (seq-e
               (e-decl "ai" 1 (display "")) ; TODO: impose a type on it as const unsigned int?
               (lambda (_)  (seq-e
                  (e-setref "ai" ai)
                  (lambda (ai) (seq-e
                     (e-decl "within" 1 (display "")) ; TODO: impose a type on it as const char*?
                     (lambda (_) (seq-e
                        (e-setref "within" name)
                         (lambda (_) (return-e ai))
         ))))))))) jp zeta rho s)
)))


