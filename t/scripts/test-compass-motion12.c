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
   motion_prepend_after_call( c, a );
   motion_alwaysfirst_around_call( d, a );
   motion_prepend_after_call( e, a );
   a();
   b();
   return 0;
}

