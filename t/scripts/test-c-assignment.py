import pycparser

def main_eg():
   parser = pycparser.CParser()
   buf = '''
      int a;
      int b;
      int* c;
      int* d;
      int* e;
      int main( int argc, char** argv ) {
         a = 5;
         b = a;
         c = a = 3;
         d = &a;
         *d = 7;
         e[0] = 9;
      }
   '''


   t = parser.parse( buf, 'x.c' )
   return t

if __name__ == "__main__":
    t = main_eg()
    t.show()
