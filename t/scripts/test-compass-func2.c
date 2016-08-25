void a() {
}

void b() {
}

void c() {
}

void d() {
}

int main( int argc, char** argv ) {
   motion_append_after_call( d, a );
   a();
   b();
   return 0;
}

