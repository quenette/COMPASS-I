export GUILE_WARN_DEPRECATED=no


# Simple C (calls "a" and then "b", both do nothing)  ...

guile compass-c.scm -C -s t/scripts/test-c-func2.c
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -s t/scripts/test-c-func2.c

# With extensions (i.e. check extensions loads ok but still only a C program) ...

PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -a -s t/scripts/test-c-func2.c
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -s t/scripts/test-c-func2.c


#------------------------------------------------------------------------------

# Simple Aspect/C (calls "a" which has "d" call advice after it, and then "b", all three do nothing) ...

PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -a -s t/scripts/test-aspect-func2.c


#------------------------------------------------------------------------------

# Simple Compass/C motion (calls "a" which has "c" and "d" call advice after it, and then "b", all three do nothing) ...

PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -s t/scripts/test-compass-motion01.c

# More...
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -s t/scripts/test-compass-motion02.c
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -s t/scripts/test-compass-motion03.c
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -s t/scripts/test-compass-motion04.c
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -s t/scripts/test-compass-motion05.c
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -s t/scripts/test-compass-motion06.c
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -s t/scripts/test-compass-motion07.c
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -s t/scripts/test-compass-motion08.c
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -s t/scripts/test-compass-motion09.c
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -s t/scripts/test-compass-motion10.c
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -s t/scripts/test-compass-motion11.c
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -s t/scripts/test-compass-motion12.c
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -s t/scripts/test-compass-motion13.c
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -s t/scripts/test-compass-motion14.c
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -s t/scripts/test-compass-motion15.c
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -s t/scripts/test-compass-motion16.c
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -s t/scripts/test-compass-motion17.c
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -s t/scripts/test-compass-motion18.c
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -s t/scripts/test-compass-motion19.c

# Simple Compass/C pointcut (calls "c" and "d" call advice at pointcut z, all two do nothing) ...

PYTHONPATH=`pwd`:$PYTHONPATH guile --debug compass-c.scm -m -s t/scripts/test-compass-pointcut01.c 

# More...
PYTHONPATH=`pwd`:$PYTHONPATH guile --debug compass-c.scm -m -s t/scripts/test-compass-pointcut02.c 
PYTHONPATH=`pwd`:$PYTHONPATH guile --debug compass-c.scm -m -s t/scripts/test-compass-pointcut03.c 
PYTHONPATH=`pwd`:$PYTHONPATH guile --debug compass-c.scm -m -s t/scripts/test-compass-pointcut04.c 
PYTHONPATH=`pwd`:$PYTHONPATH guile --debug compass-c.scm -m -s t/scripts/test-compass-pointcut05.c 
PYTHONPATH=`pwd`:$PYTHONPATH guile --debug compass-c.scm -m -s t/scripts/test-compass-pointcut06.c 
PYTHONPATH=`pwd`:$PYTHONPATH guile --debug compass-c.scm -m -s t/scripts/test-compass-pointcut07.c 
PYTHONPATH=`pwd`:$PYTHONPATH guile --debug compass-c.scm -m -s t/scripts/test-compass-pointcut08.c 
PYTHONPATH=`pwd`:$PYTHONPATH guile --debug compass-c.scm -m -s t/scripts/test-compass-pointcut09.c 
PYTHONPATH=`pwd`:$PYTHONPATH guile --debug compass-c.scm -m -s t/scripts/test-compass-pointcut10.c 


#------------------------------------------------------------------------------

# These should fail...

# Should fail because extension python modules fail to load (needs python path)
guile compass-c.scm -s t/scripts/test-c-func2.c

# Can't use AOP and C at the same time
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -a -C -s t/scripts/test-c-func2.c

# Can't use Compass/C and C at the same time
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -C -s t/scripts/test-c-func2.c

# With C only, dont know Aspect/C extensions
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -C -s t/scripts/test-aspect-func2.c

# With C only, dont know Compass/C extensions
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -C -s t/scripts/test-compass-func2.c

# With Aspect/C only, dont know Compass/C extensions
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -C -s t/scripts/test-compass-func2.c

# With Compass/C only, dont know Apect/C extensions
PYTHONPATH=`pwd`:$PYTHONPATH guile compass-c.scm -m -s t/scripts/test-aspect-func2.c

