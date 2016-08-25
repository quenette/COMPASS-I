import pycparser

def main_eg():
   parser = pycparser.CParser()
   buf = '''
      int a = 3;
      int* b = &a;
      int* c;
      int** d = &b;
      int* e[2] = { 0, 1 };
      int* f[2][3];
      int g = a;
      int* h = b;
      int* i = e;
      int j = *b;
      int k = *e;
      int* l = &e;
      int m = *(e+1);
   '''
   
   t = parser.parse( buf, 'x.c' )
   return t

if __name__ == "__main__":
    t = main_eg()
    t.show()
