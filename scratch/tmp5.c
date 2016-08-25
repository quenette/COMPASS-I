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

         return 0;
      }

