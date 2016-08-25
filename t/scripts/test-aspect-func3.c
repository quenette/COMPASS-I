void a( int y ) {
   int z = y;
}

void b( int x ) {
   int z = x;
}

void c( int w ) {
   int z = w;
}

void d( int v ) {
   int z = v;
}

advice_after_call( d, a );

int main( int argc, char** argv ) {
   a( 3 );
   b( 5 );
   return 0;
}

