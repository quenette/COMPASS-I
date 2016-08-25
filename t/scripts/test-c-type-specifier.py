import pycparser

def main_eg():
   parser = pycparser.CParser()
   buf = '''
      char a = 'a';
      short b = 2;
      int c = 3;
      long d = 4;
      float e = 5.0;
      double f = 6.0;
      signed g = 7;
      unsigned h = 8;

      signed char k = 11;
      unsigned char l = 12;
      unsigned short m = 13;
      unsigned int n = 14;
      unsigned long o = 15;
      long double p = 16.0;

      char aa;
      short bb;
      int cc;
      long dd;
      float ee;
      double ff;
      signed gg;
      unsigned hh;

      signed char kk;
      unsigned char ll;
      unsigned short mm;
      unsigned int nn;
      unsigned long oo;
      long double pp;
   '''
   
   t = parser.parse( buf, 'x.c' )
   return t

if __name__ == "__main__":
    t = main_eg()
    t.show()
