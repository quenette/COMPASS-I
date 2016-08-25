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
   motion_prepend_after_call( d, a );
   motion_prepend_advice_around_call( e, a, c );
   a();
   b();
   return 0;
}

