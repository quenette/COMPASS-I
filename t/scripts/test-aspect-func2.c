void a() {
}

void b() {
}

void c() {
}

void d() {
}

advice_after_call( d, a );

int main( int argc, char** argv ) {
   a();
   b();
   return 0;
}

