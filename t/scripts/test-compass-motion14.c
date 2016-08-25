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
   motion_append_before_call( c, a );
   motion_append_before_call( d, a );
   motion_append_advice_before_call( e, a, c );
   a();
   b();
   return 0;
}

