import pycparser

def main_eg():
   parser = pycparser.CParser()
   buf = '''
      const int p = 1;

      int main( int argc, char** argv ) {
         int j;
         int k = 3;
         int* l = &k;

         j = p && argc || argv[0];
         return j;
      }
   '''
   
   t = parser.parse( buf, 'x.c' )
   return t

if __name__ == "__main__":
    t = main_eg()
    t.show()
