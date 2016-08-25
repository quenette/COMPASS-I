void a() {
}

void b( int y ) {
   int z = y;
}

void c() {
}

void d() {
}

void e( int x ) {
   int z = x;
}

void f( int w ) {
   int z = w;
}

int main( int argc, char** argv ) {
   void* aObj;
   void* bObj;

   void* iObj;
   void* jObj;
   void* kObj;

   motion_append_after_call( iObj, c, aObj, a );
   motion_append_after_call( iObj, d, aObj, a );
   motion_append_after_call( jObj, e, bObj, b );
   motion_append_after_call( kObj, f, bObj, b );
   motion_append_after_call( iObj, c, bObj, a );

   a();
   b( 3 );
   return 0;
}

