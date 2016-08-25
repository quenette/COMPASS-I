(use-modules (pyguile))

(python-eval "import imp\n")
(python-eval "pyc = imp.load_source( 'test_pycparser', 'test_pycparser.py' )\n")
(python-eval "t = pyc.main_eg()\n")
;(python-eval "t.show()")
;(if (eqv? (python-eval "len( t.ext[0].decl.name)\n" #t) 4) (display "yes") (display "no"))
(display (python-eval "t.ext[0].decl.name\n" #t)) 

;t.ext[0].children()[0][1].type.names
;t.ext[0].children()[0][1]   - ast node
;t.ext[0].children()[0][0]   - ensure == 'type'
;type.names  - list of TS names
