import pycparser

def main_eg():
   parser = pycparser.CParser()
#   buf = '''
#      int a( int x ) {
#         return 1;
#      }
#      int* b( int i, int* j ) {
#         int* k = 2;
#         int l;
#         return k;
#      }
#      void c() {
#      }
#      void d();
#      int e( int x, int y ) {
#         return x;
#      }
#      int main( int argc, char** argv ) {
#         c();
#         return e( 5, 7 );
#      }
#   '''
   buf = open( 't/scripts/test-c-func.c', 'rU').read()
  
   t = parser.parse( buf, 'x.c' )
   return t

if __name__ == "__main__":
    t = main_eg()
    t.show()
