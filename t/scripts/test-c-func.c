
int a( int x ) {
   return 1;
}

int* b( int i, int* j ) {
   int* k = 2;
   int l;
   return k;
}

void c() {
}

void d();

int e( int x, int y ) {
   printnum( x );
   return x;
}

int main( int argc, char** argv ) {
   c();
   return e( 5, 7 );
}

void f() {
   printnum( 9 );
}

int g( int a, int b ) {
   printnum( b );
   return b;
}


