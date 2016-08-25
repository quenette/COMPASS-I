(load "c-Module.scm")
(load "c-DenDecl.scm")
(load "c-all-expressions.scm")
(load "c-Declaration.scm")
(load "c-Statement.scm")
(load "c-FuncCall.scm")

(use-modules (ice-9 getopt-long))

(define rho  (make-env 0 100000))

(define s  (empty-s))
(define rho,s (list rho s))
(define jp1 (display ""))
(define zeta1 '())

; TODO: Improvements...
;  * When python extensions fail to load, should error gracefully (right now it just continues on until it subsequently fails!!!)
;  * When compass/aspect keywords are not known (e.g. when using C-only), have more obvious erroring


(define load-file
   (lambda (fn compass-only aop-only c-only)
      (begin
         (begin
            (display "Parsing file: \"")(display fn)(display "\"\n")
            (python-eval "import imp")
         )
         (cond
            ((eq? compass-only #t)
               (python-eval "import pycompasscparser")
               (python-eval "parser = pycompasscparser.CompassCParser()")
               (display "Using Compass language extensions")(newline)
               (load "m-MotionStmt.scm")
               (load "m-PointcutCall.scm")
               (load "m-Statement.scm")
               (load "m-Expression.scm")
               (load "a-pcd.scm")
               (load "a-advcomb.scm")
            ) 
            ((eq? aop-only #t)
               (python-eval "import pyaspectcparser")
               (python-eval "parser = pyaspectcparser.AspectCParser()")
               (display "Using AOP language extensions")(newline)
               (load "a-ModDeclDef.scm")
               (load "a-pcd.scm")
               (load "a-advice.scm")
               (load "a-weave.scm")
               (load "a-advcomb.scm")
               (load "m-motion.scm")
            ) 
            ((eq? c-only #t)
               (python-eval "import pycparser")
               (python-eval "parser = pycparser.CParser()")
            )
            (else
               ; Should be same as for "(eq? compass-only #t)"...
               (python-eval "import pycompasscparser")
               (python-eval "parser = pycompasscparser.CompassCParser()")
               (display "Using Compass language extensions")(newline)
               (load "m-MotionStmt.scm")
               (load "m-PointcutCall.scm")
               (load "m-Statement.scm")
               (load "m-Expression.scm")
               (load "a-pcd.scm")
               (load "a-advcomb.scm")
            )
         )
         (begin
            (python-eval (string-append "buf = open( '" fn "', 'rU').read()"))
            (python-eval (string-append "t1 = parser.parse( buf, '" fn "' )"))
         )
      )
))

(define load-module
   (lambda _
      (begin
         (display "Creating module...\n")
         (let ((M1 (ast->M "t1")))
              (let ((tval ((e-M M1) jp1 zeta1 (car rho,s) (cadr rho,s))))
                   tval
)))))

(define call-main
   (lambda _
      ; Load the module
      (let ((tval    (load-module)))
         (begin
            (display "Run...\n")
            ; Create the call to main
            (let ((argc    (make-co (make-single-it 'signed) 0))
                  (argv    (make-co (make-single-it 'signed) 0))
                 )
                 (let ((el1   (make-el (list argc argv)))
                       (id1   (make-id "main"))
                      )
                      (let ((fc1 (make-fc id1 el1)))
                           ; Call main
                           ((e-fc fc1) jp1 (tval->zeta tval) (tval->rho tval) (tval->s tval))
)))))))


(define helpMsg "\
Compass C [options]

Options:
       -v, --version        Display version
       -h, --help           Display this help
       -c, --compile        Compile only (don't call main)
       -t, --ast            Show AST
       -a, --aop            Aspect-Oriented-Programming language extensions only
       -m, --compass        Compass language extensions only
       -C, --C              C language only
       -s FN, --source=FN   C source file name
")

(define (main args)
   (let* ((option-spec '((version (single-char #\v) (value #f))
                         (help    (single-char #\h) (value #f))
                         (source  (single-char #\s) (value #t))
                         (compile (single-char #\c) (value #f))
                         (ast     (single-char #\t) (value #f))
                         (aop     (single-char #\a) (value #f))
                         (C       (single-char #\C) (value #f))
                         (compass (single-char #\m) (value #f))
          ))
          (options        (getopt-long args option-spec))
          (help-wanted    (option-ref options 'help #f))
          (version-wanted (option-ref options 'version #f))
          (source-fn      (option-ref options 'source ""))
          (compile-only   (option-ref options 'compile #f))
          (show-ast       (option-ref options 'ast #f))
          (aop-only       (option-ref options 'aop #f))
          (C-only         (option-ref options 'C #f))
          (compass-only   (option-ref options 'compass #f))
         )
         (cond
            ((eq? help-wanted #t)
               (display helpMsg)
            )
            ((eq? version-wanted #t)
               (display "Compass C interpreter 0.1\n")
            )
            ((eq? source-fn "")
               (display "Error: A source file must be given!\n")
            )
            ((and (eq? aop-only #t) (eq? C-only #t))
               (display "Error: Cannot use --aop and --C at the same time!\n")
            )
            ((and (eq? compass-only #t) (eq? C-only #t))
               (display "Error: Cannot use --compass and --C at the same time!\n")
            )
            ((eq? compile-only #t)
               (begin
                  (load-file source-fn compass-only aop-only c-only)
                  (cond
                     ((eq? show-ast #t)
                        (python-eval "t1.show()" #t)
                     )
                     (load-module)
                  )
               )
            )
            ((eq? compile-only #f)
               (begin
                  (load-file source-fn compass-only aop-only C-only)
                  (cond
                     ((eq? show-ast #t)
                        (python-eval "t1.show()" #t)
                     )
                  )
                  ;(load-module)
                  (let ((tval  (call-main)))
                       (cond
                          ((unspecified? tval)
                             (begin
                                (display "Program failed and was aborted!\n")
                          ))
                          ((and (tval? tval) (unspecified? (tval->val tval)))
                             (begin
                                (display "The last computation of the program yielded an unspecified result!\n")
                          ))
                          (else
                             (begin
                                (display "Program returned: ")(display (tval->val tval))(newline)
                          ))
                  ))
               )
            )
)))

(main (command-line))

