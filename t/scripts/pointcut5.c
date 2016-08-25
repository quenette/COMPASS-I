typedef struct {
   int x[30];
} TestClass;

void body1( TestClass* self );

void* malloc( int sz );
void memset( void* ptr, int val, int sz );

void __co_display( int val );
void __co_newline();
void __co_display_nextl();
void __co_display_rho();
void __co_display_s();
void __co_display_jp();
void __co_display_zeta();
void __co_display_loc( int loc );
int NULL = 0;

void test1( TestClass* self )
{
   int *x = self->x;
   int i;

   for (i = 1; i <= 10; i += 1) {
      x[2 * i] = x[2 * i + 1] + 2;
   }
}

void test2( TestClass* self )
{
   int *x = self->x;
   int i;

   for (i = 1; i <= 10; i += 1) {
      x[2 * i + 3] = x[2 * i] + i;
   }
}

int main( int argc, char** argv )
{
   TestClass *obj = malloc( sizeof( TestClass ) );

   __co_display( obj ); __co_newline();
   __co_display_nextl(); __co_newline();

   motion_append_after_call( test1, body1 );
   motion_append_after_call( test2, body1 );

   memset( obj->x, 0, sizeof(int) * 30 );

   obj->x[2] = 3;

   __co_display( "100004 = " ); __co_display_loc( 100004 ); __co_newline();
   __co_display( "100005 = " ); __co_display_loc( 100005 ); __co_newline();
   __co_display( "100006 = " ); __co_display_loc( 100006 ); __co_newline();
   __co_display( "100007 = " ); __co_display_loc( 100007 ); __co_newline();
   __co_display( "100008 = " ); __co_display_loc( 100008 ); __co_newline();
   __co_display( "100033 = " ); __co_display_loc( 100033 ); __co_newline();

   body1( obj );

   __co_display( "x[21] = " ); __co_display( obj->x[21] ); __co_newline();

   return 0;
}

void body1( TestClass * obj ) 
{
}

