; Note: My ObjDecl is synonymous with Papaspyrou01's Type_obj
;
; TODO: Present limitation - assumes all declarations have size 1, rather than the size of the datatype.
; TODO: Qualifiers
;
; Semantic algebras...
;   Domain od in ObjDecl
;     (Domain od_k in ObjDecl_Kind in Kind)
;     (Domain td in TypeDecl)
;     (Domain pd in PtrDecl)
;     (Domain ad in ArrayDecl)
;     (Domain qu in Qual) ; TODO
;     (Domain sz in Size in Loc)
;
; Abstract syntax...
;  Not in pycparser's AS
;
;  ObjDecl_Kind ::= 'type-decl | 'ptr-decl | 'array-decl
;  ObjDecl      ::= td qu | pd qu | ad
;
; Valuation functions...
;  ObjDecl[[od]] = () -> ObjDecl
;
; Developed for guile scheme v 1.8.7

(use-modules (pyguile))
(load "error.scm")
(load "kind.scm")
(load "c-store.scm")
(load "c-env.scm")
(load "c-TypeDecl.scm")
(load "c-PtrDecl.scm")
(load "c-ArrayDecl.scm")


; Construction operations ...

; make-td-od : TypeDecl -> Qual -> ObjDecl
(define make-td-od
   (lambda (td qu)
      (append td (list qu))
))

; make-pd-od : PtrDecl -> Qual -> ObjDecl
(define make-pd-od
   (lambda (pd qu)
      (append pd (list qu))
))

; make-ad-od : ArrayDecl -> Qual -> ObjDecl
(define make-ad-od
   (lambda (ad qu)
      (append ad (list qu))
))


; Other operations ...

; "Apply"
; e-od : ObjDecl -> ExprOrList_b -> (JP->Mot*->Env->Sto) -> ( Val x Mot x Env' x Sto' )    ; i.e. ObjDecl -> ExprOrList_b -> T(Val)
;  Note: ExprOrList_b because an initialiser isn't always given
(define e-od
   (lambda (od Eel is_anon)
      (lambda (jp zeta rho s)
         (cond
            ((td? od) ((e-td od Eel is_anon) jp zeta rho s))
            ((pd? od) ((e-pd od Eel is_anon) jp zeta rho s))
            ((ad? od) ((e-ad od Eel is_anon) jp zeta rho s))
            ; Else error
            (else 
               (display "Error: Unknown object datatype/declaration!!! ")(display od)(newline)(exit)
            )
))))

; e-od->sz : ObjDecl -> (JP->Mot*->Env->Sto) -> ( Val x Mot x Env x Sto )    ; i.e. ObjDecl -> T(Val)
(define e-od->sz
   (lambda (od)
      (lambda (jp zeta rho s)
         ((cond 
            ((td? od) (e-td->sz od))
            ((pd? od) (e-pd->sz od))
            ((ad? od) (e-ad->sz od))
            ; Else error
            (else (return-e (display "Error: \"")(display od)(display "\" is not an ObjDecl.")(newline)))
         ) jp zeta rho s)
)))


; Predicate operations...

; od? : Any -> Bool
(define od?
   (lambda (od)
      (cond 
         ((td? od) #t)
         ((pd? od) #t)
         ((ad? od) #t)
         (else #f)
)))


; Extraction operations...

; od->kind : ObjDecl -> Kind
(define od->kind
   (lambda (od)
      (car od)
))

; od->id : ObjDecl -> Id
(define od->id
   (lambda (od)
      (cond 
         ((td? od) (td->id od))
         ((pd? od) (pd->id od))
         ((ad? od) (td->id (ad->td od)))
         ; Else error
         (else (display "Error: \"")(display od)(display "\" is not an ObjDecl.")(newline))
)))

; od->it : ObjDecl -> IT
;  Get the base type (IT) of this object. If its od is a pointer, the result is the type of the od the pointer ultimately points to.
(define od->it
   (lambda (od)
      (cond 
         ((td? od) (td->it od))
         ((pd? od) (pd->it od))
         ((ad? od) (td->it (ad->td od)))
         ; Else error
         (else (display "Error: \"")(display od)(display "\" is not an ObjDecl.")(newline))
)))

; od->sym : ObjDecl -> Sym
(define od->sym
   (lambda (od)
      (cond 
         ((td? od) (td->sym od))
         ((pd? od) (pd->sym od))
         ((ad? od) (ad->sym od))
         ; Else error
         (else (display "Error: \"")(display od)(display "\" is not an ObjDecl.")(newline))
)))

; od->qu : ObjDecl -> Qual
(define od->qu
   (lambda (od)
      (cond 
         ((td? od) (cadr (cdddr od)))
         ((pd? od) (caddr od))
         ((ad? od) (cadddr od))
         ; Else error
         (else (display "Error: \"")(display od)(display "\" is not an ObjDecl.")(newline))
)))


; Valuation functions ...

; ObjDecl[[od]] = () -> ObjDecl
(define ast->od
   (lambda (py_ast_var)
      ; First - ensure the ast node is a TypeDecl  (this is more of an exception [coding failure] than a bottom [semantic failure])
      (let ((node_type (python-eval (string-append py_ast_var ".__class__.__name__.encode('ascii')") #t)))
           (cond
              ((string=? "TypeDecl" node_type)
                 ; Second - valuate the code
                 (make-td-od (ast->td py_ast_var) (display ""))   ;TODO: impl qu
              )
              ((string=? "PtrDecl" node_type)
                 ; Second - valuate the code
                 (make-pd-od (ast->pd py_ast_var) (display ""))   ;TODO: impl qu
              )
              ((string=? "ArrayDecl" node_type)
                 ; Second - valuate the code
                 (make-ad-od (ast->ad py_ast_var) (display ""))   ;TODO: impl qu
              )
              ; Else error
              (else (display "Error: AST node type \"")(display node_type)(display "\" is not an ObjDecl node.")(newline))
))))

