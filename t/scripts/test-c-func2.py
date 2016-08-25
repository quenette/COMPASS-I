import pycparser

def main_eg():
   parser = pycparser.CParser()
   buf = open( 't/scripts/test-c-func2.c', 'rU').read()
   t = parser.parse( buf, 'x.c' )
   return t

if __name__ == "__main__":
    t = main_eg()
    t.show()

