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
   struct _A a;
   B b;
   E e;
   int q;

   a.i = 2;
   a.j = 3;
   b.z[0] = 'a';
   b.z[4] = 0;
   e.x[1] = 'b';
   e.x[4] = 0;
   e.c.k = 5;
   e.c.l = 7;
   e.m = 11;
   e.d.n = 13;
   e.d.o = 17;
   e.p = 19;
   q = 23;

   return 0;
}
