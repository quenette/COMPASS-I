import pycparser

def main_eg():
   parser = pycparser.CParser()
   buf = '''
      unsigned int i = 1;
      float j = i + 2.0;
      static const int k = ( j == 3.0 );
      char s[] = "Hello world!";
   '''
   
   t = parser.parse( buf, 'x.c' )
   return t

if __name__ == "__main__":
    t = main_eg()
    t.show()
