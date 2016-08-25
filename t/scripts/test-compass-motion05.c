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
   motion_prepend_before_call( c, a );
   motion_prepend_before_call( d, a );
   a();
   b();
   return 0;
}

