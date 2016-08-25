import pycparser

def main_eg():
   parser = pycparser.CParser()
   buf = '''
      int a[5];
      int b[] = { 1, 2 };
      char c[] = "abcdef";
      int main( int argc, char** argv ) {
         char z = c[5];
         *b = 7;
         b[1] = 9;
      }
   '''
   
   t = parser.parse( buf, 'x.c' )
   return t

if __name__ == "__main__":
    t = main_eg()
    t.show()
