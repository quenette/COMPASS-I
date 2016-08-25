# Given these have "-" in the filename (sorry), the equivalent to "import * from test-c-struct" in the python interpreter is ...
#  tmp = __import__('test-c-for')
#  globals().update(vars(tmp))

import pycparser

def main_eg():
   parser = pycparser.CParser()
   buf = '''
      int main( int argc, char** argv ) {
         int i;
         int j = 0;
         int k;

         for( i = 0; i < 10; i = i + 1 ) {
            j = j + i;
         }

         for( ; i < 20; i++ ) {
            j += i;
         }

         for( i = 0; ; i++ ) {
            j += i;
            if( i > 10 ) {
               break;
            }
         }

         for( i = 0; i < 10; ) {
            j += i;
            i += 1;
         }

         for( int l = 0, i = 0; i < 10; i++ ) {
            j += i;
            l = j * j;
         }

         for( k = 0, i = 0; i < 10; i++ ) {
            j += i;
            k = j * j;
         }

         for( k = 11, i = 0; i < 10; i++, k-- ) {
            j += i;
         }

         for( i = 0; i < 10; i++ ) j += i;

         return j;
      }
   '''
   
   t = parser.parse( buf, 'x.c' )
   return t

if __name__ == "__main__":
    t = main_eg()
    t.show()
