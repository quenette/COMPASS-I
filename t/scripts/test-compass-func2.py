# This file is my first go at 'extending' pycparser to include a new keyword. It finally works (a bit finicky)
# The new keyword is "motion_append_after( adviceBody, Id )"

import pycparser

from pycparser.c_lexer import CLexer as CLexerBase
import pycparser.c_ast as c_ast
import pycparser.c_parser
import ply.yacc

import sys
#import pdb

# Lexer extensions ---------

# This function is derived from pycparserext
def add_lexer_keywords(cls, keywords):
    cls.keywords = cls.keywords + tuple(
            kw.upper() for kw in keywords)

    cls.keyword_map = cls.keyword_map.copy()
    cls.keyword_map.update(dict(
        (kw, kw.upper()) for kw in keywords))

    cls.tokens = cls.tokens + tuple(
            kw.upper() for kw in keywords)


class CompassCLexer( CLexerBase ):
   def __init__( self, *args, **kwargs ):
      CLexerBase.__init__( self, *args, **kwargs )

add_lexer_keywords( CompassCLexer, ['motion_append_after_call'] )


# Parser extensions -----------

class CompassCParser( pycparser.c_parser.CParser ):
   def __init__( self, yacc_debug = True ):
      print 'CompassCParser starting'

      #import CompassCLexer as lexer_class
      self.lexer_class = CompassCLexer

      #self.clex = self.lexer_class(
      #   error_func = self._lex_error_func,
      #   on_lbrace_func = self._lex_on_lbrace_func,
      #   on_rbrace_func = self._lex_on_rbrace_func,
      #   type_lookup_func = self._lex_type_lookup_func )
      self.clex = self.lexer_class(
         error_func = self._lex_error_func,
         type_lookup_func = self._lex_type_lookup_func )

      self.clex.build()
      self.tokens = self.clex.tokens
        
      rules_with_opt = [
           'abstract_declarator',
           'assignment_expression',
           'declaration_list',
           'declaration_specifiers',
           'designation',
           'expression',
           'identifier_list',
           'init_declarator_list',
           'parameter_type_list',
           'specifier_qualifier_list',
           'block_item_list',
           'type_qualifier_list',
           'struct_declarator_list'
      ]
        
      for rule in rules_with_opt:
            self._create_opt_rule(rule)

      if hasattr(self, "p_translation_unit_or_empty"):
         # v2.08 and later
         self.ext_start_symbol = "translation_unit_or_empty"
      else:
         # v2.07 and earlier
         self.ext_start_symbol = "translation_unit"

      self.cparser = ply.yacc.yacc(
         module = self,
         start = self.ext_start_symbol,
         debug = yacc_debug, write_tables = False )

      # Stack of scopes for keeping track of typedefs. _scope_stack[-1] is
      # the current (topmost) scope.
      #
      self._scope_stack = [set()]


   def parse(self, text, filename='', debuglevel=0):
        """ Parses C code and returns an AST.
        
            text:
                A string containing the C source code
            
            filename:
                Name of the file being parsed (for meaningful
                error messages)
            
            debuglevel:
                Debug level to yacc
        """
        self.clex.filename = filename
        self.clex.reset_lineno()
        self._scope_stack = [set()]
        return self.cparser.parse(text, lexer=self.clex, debug=debuglevel)



   def p_motion_append_after_call_keyword( self, p ):
      """ motion_append_after_call_keyword    : MOTION_APPEND_AFTER_CALL LPAREN ID COMMA ID RPAREN SEMI
      """
      p[0] = c_ast.MotionCall( p[3], p[5], None, "last", None, "after" )
      #pdb.set_trace()
      #p[0].show()
   
   def p_statement_compass( self, p ):
      """ statement : motion_append_after_call_keyword 
      """
      p[0] = p[1]

class MotionCall( c_ast.Node ):
    def __init__( self, adviceBody, identifier, rel_motion, rel_pos, pos_constraint, advice, coord = None ):
        self.adviceBody = adviceBody
        self.identifier = identifier
        self.rel_motion = rel_motion
        if( rel_motion == None ):
           self.has_rel_motion = False
        else:
           self.has_rel_motion = True
        if( rel_pos in [ "first", "last" ] ):
           self.rel_pos = rel_pos
        elif( rel_pos in [ "", None ] ):  # this makes the guile code easier
           self.rel_pos = "last"
        else:
           raise ValueError
        if( pos_constraint in [ "always" ] ):
           self.pos_constraint = pos_constraint
        elif( pos_constraint in [ "", None ] ):
           self.pos_constraint = "none"  # this makes the guile code easier
        else:
           raise ValueError
        if( advice in [ "after", "before", "around" ] ):
           self.advice = advice
        else:
           raise ValueError

    def children( self ):
        nodelist = []
        if self.adviceBody is not None:
            nodelist.append( ("adviceBody", c_ast.ID( self.adviceBody ) ) )
        if self.identifier is not None:
            nodelist.append( ("identifier", c_ast.ID( self.identifier ) ) )
        if self.rel_motion is not None:
            nodelist.append( ("rel_motion", c_ast.ID( self.rel_motion ) ) )
        return tuple( nodelist )

    def show(self, buf=sys.stdout, offset=0, attrnames=False, nodenames=False, showcoord=False, _my_node_name=None):
       #pdb.set_trace()
       c_ast.Node.show( self, buf, offset, attrnames, nodenames, showcoord, _my_node_name )

    attr_names = ( "has_rel_motion", "rel_pos", "pos_constraint", "advice" )

c_ast.MotionCall = MotionCall


# Main ------------

def main_eg():
   parser = CompassCParser()
   buf = open( 't/scripts/test-compass-func2.c', 'rU').read()
   t = parser.parse( buf, 'x.c' )
   return t

if __name__ == "__main__":
    t = main_eg()
    #print t.children()[4][1].children()[1][1].children()
    t.show()

