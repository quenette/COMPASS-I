import pycparser

def main_eg():
   parser = pycparser.CParser()
   buf = '''
      struct _A {
         int i;
         int j;
      };
      typedef struct {
         int k;
         int l;
         int m;
      } B;
      
      int a = sizeof(int);
      int b = sizeof(unsigned long);
      int c = sizeof(struct _A);
      int d = sizeof(B);
   '''
   
   t = parser.parse( buf, 'x.c' )
   return t

if __name__ == "__main__":
    t = main_eg()
    t.show()
