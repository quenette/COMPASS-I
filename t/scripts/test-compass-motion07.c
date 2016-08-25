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
   motion_append_after_call( c, a );
   motion_alwayslast_after_call( d, a );
   motion_append_after_call( e, a );
   a();
   b();
   return 0;
}

