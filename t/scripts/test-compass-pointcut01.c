void a() {
}

void b() {
}

void c() {
}

void d() {
}

void e() {
}

void f() {
}

int main( int argc, char** argv ) {
   motion_append_after_call( c, z );
   motion_append_after_call( d, z );
   motion_append_after_call( e, z );
   
   pointcut( z );
   return 0;
}

