import pycparser

def main_eg():
   parser = pycparser.CParser()
   buf = '''
      int a = 3;
      int* b = &a;
      int c = a;
      int d = a = 5;
   '''
   
   t = parser.parse( buf, 'x.c' )
   return t

if __name__ == "__main__":
    t = main_eg()
    t.show()
