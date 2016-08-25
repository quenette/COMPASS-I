import pycparser

def main_eg():
   parser = pycparser.CParser()
   buf = '''
      int main( int argc, char** argv ) {
         j = p && r || q;
         return j;
      }
   '''
   
   t = parser.parse( buf, 'x.c' )
   return t

if __name__ == "__main__":
    t = main_eg()
    t.show()
