      int main( int argc, char** argv ) {
         int i;
         int j = 0;

         for( i = 0; i <= 10; i++ ) {
            j += i;
         }

         for( ; i <= 20; i++ ) {
            j += i;
         }

         for( i = 0; ; i++ ) {
            j += i;
            if( i > 10 ) {
               break;
            }
         }

         for( i = 0; i <= 10; ) {
            j += i;
            i += 1;
         }

         for( int k = 0, i = 0; i <= 10; i++ ) {
            j += i;
            k = j * j;
         }

         for( k = 0, i = 0; i <= 10; i++ ) {
            j += i;
            k = j * j;
         }

         for( k = 11, i = 0; i <= 10; i++, k-- ) {
            j += i;
         }

         return k;
      }

