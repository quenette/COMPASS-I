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

void g( int v, int u ) {
   int z = v;
   int arg = u;
}

void h( int t, int s ) {
   int z = t;
   int arg = s; 
}

int main( int argc, char** argv ) {
   int _zObj;
   int _iObj;
   int _jObj;

   void* zObj = &_zObj;
   void* iObj = &_iObj;
   void* jObj = &_jObj;

   motion_append_after_call( iObj, g, zObj, z );
   motion_append_after_call( jObj, h, zObj, z );
   
   pointcut( z, zObj; 9 );
   return 0;
}


