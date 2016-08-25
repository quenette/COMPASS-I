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
   a();
   b();
   return 0;
}

