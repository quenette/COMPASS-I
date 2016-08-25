import pycparser

def load_c( fn ):
   parser = pycparser.CParser()
   buf = open( fn, 'rU').read()
   t = parser.parse( buf, 'x.c' )
   return t

