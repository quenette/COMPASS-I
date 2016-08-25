void a() {
   return 1;
}

void b() {
   return 2;
}

void c() {
   return 3;
}

void d() {
   return 4;
}

void e() {
   return 5;
}

void f() {
   return 6;
}

int main( int argc, char** argv ) {
   int i;

   motion_append_after_call( c, z );
   motion_append_after_call( d, z );
   motion_append_after_call( e, z );
   
   i = pointcut_first( z );
   return i;
}

