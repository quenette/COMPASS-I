int a( int y ) {
   int z = y;
   return z;
}

int b( int x ) {
   int z = x;
   return z;
}

int c( int w ) {
   int z = w;
   return z;
}

int d( int v ) {
   int z = v;
   return z;
}

int e( int u ) {
   int z = u;
   return z;
}

int f( int t ) {
   int z = t;
   return z;
}

int main( int argc, char** argv ) {
   int i;

   motion_append_after_call( c, z );
   motion_append_after_call( d, z );
   motion_append_after_call( e, z );
   
   i = pointcut_add( z; 10 );
   return i;
}

