# Given these have "-" in the filename (sorry), the equivalent to "import * from test-c-struct" in the python interpreter is ...
#  tmp = __import__('test-c-struct')
#  globals().update(vars(tmp))

import pycparser

def main_eg():
   parser = pycparser.CParser()
   buf = '''
      struct _A {
         int i;
         int j;
      };

      typedef struct {
         char z[5];
      } B;

      typedef struct _E {
         char x[5];
         struct _C {
            int k;
            int l;
         } c;
         int m;
         struct {
            int n;
            int o;
         } d;
         int p;
      } E;

      void func1( struct _A a ) {
      }

      void func2( struct _A* a ) {
      }

      void func3( struct _A a ) {
         a.i = a.j * 4;
      }

      void func4( struct _A* a ) {
         a->j = a->i * 5;
      }

      void func5( B b ) {
      }

      void func6( B* b ) {
      }

      void func7( B b ) {
         b.z[1] = b.z[4] + 2;
      }

      void func8( B* b ) {
         b->z[2] = b->z[1] + 3;
      }

      int main( int argc, char** argv ) {
         struct { int i; int j[8]; int k; } aa;
         struct _BB { int i; int j[8]; struct _CC { float l; float m; } k; } bb;
         struct _DD { int o; int p[8]; struct { float r; struct _EE { char t; } s; } q; } dd;
         struct _A a;
         B b;
         int g;
         E eTmp;
         E* e = &eTmp;
         int f;

         a.i = 2;
         a.j = a.i * 3;
         b.z[0] = 'a';
         b.z[4] = b.z[0] + 1;
         e->m = 11;
         e->p = e->m * 2;
         e->x[0] = 'b';
         e->x[4] = e->x[0] + 1;
         e->c.k = 5;
         e->c.l = e->c.k * 7;
         e->d.n = 13;
         e->d.o = e->d.n * 17;
         f = 23;

         func1( a );
         func2( &a );
         func3( a );
         func4( &a );

         func5( b );
         func6( &b );
         func7( b );
         func8( &b );

         return 0;
      }
   '''
   
   t = parser.parse( buf, 'x.c' )
   return t

if __name__ == "__main__":
    t = main_eg()
    t.show()
