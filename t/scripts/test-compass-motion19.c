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

void e( int u ) {
   int z = u;
}

void f( int t ) {
   int z = t;
}

int main( int argc, char** argv ) {
   motion_append_after_call( c, a );
   motion_append_after_call( d, a );
   a( 3 );
   b( 5 );
   return 0;
}

