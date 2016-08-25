import pycparser

def main_eg():
   parser = pycparser.CParser()
   buf = '''
      int a( int x ) {
         return 1;
      }
      int* b( int i, int* j ) {
         int* k = 2;
         int l;
         return k;
      }
      void c() {
         return q;
      }
      void d() {
      }
      int e() {
         int k = 3;
         {
            int k = 4;
            return k;
         }
         return 5;
      }
      int f() {
         int k = 3;
         int i = 0;
         {
            int k = 4;
            int j = 1;
         }
         return k;
      }
   '''
   
   t = parser.parse( buf, 'x.c' )
   return t

if __name__ == "__main__":
    t = main_eg()
    t.show()
