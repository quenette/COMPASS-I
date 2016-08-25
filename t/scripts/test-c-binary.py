import pycparser

def main_eg():
   parser = pycparser.CParser()
   buf = '''
      int a = 3 * 4;
      int b = 3 / 3;
      int c = 3 + 4;
      int d = 3 - 4;
      int e = 3 < 4;
      int f = 3 > 4;
   '''
   
   t = parser.parse( buf, 'x.c' )
   return t

if __name__ == "__main__":
    t = main_eg()
    t.show()
