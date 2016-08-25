import pycparser

def main_eg():
   parser = pycparser.CParser()
   buf = '''
      int main( int argc, char** argv ) {
         if( argc == 0 ) {
            return 0;
         }
         else if( argc == 1 ) {
            return -1;
         }
         else
            return 1;
      }
   '''
   
   t = parser.parse( buf, 'x.c' )
   return t

if __name__ == "__main__":
    t = main_eg()
    t.show()
