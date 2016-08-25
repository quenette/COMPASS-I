#!/usr/bin/guile -s
!#

(use-modules (guiletap))
(use-modules (pyguile))

(plan 1)
(python-eval "import imp\n")
(python-eval "pyc = imp.load_source( 'test_pycparser', 't/scripts/test_pycparser.py' )\n")
(python-eval "t = pyc.main_eg()\n")

(is-ok 1 "Name" "main" (python-eval "t.ext[0].decl.name" #t))

