
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

add_lexer_keywords( CompassCLexer, [
   'motion_append_after_call',
   'motion_append_before_call',
   'motion_append_around_call',
   'motion_prepend_after_call',
   'motion_prepend_before_call',
   'motion_prepend_around_call',
   'motion_alwaysfirst_after_call',
   'motion_alwaysfirst_before_call',
   'motion_alwaysfirst_around_call',
   'motion_alwayslast_after_call',
   'motion_alwayslast_before_call',
   'motion_alwayslast_around_call',
   'motion_append_advice_after_call',
   'motion_append_advice_before_call',
   'motion_append_advice_around_call',
   'motion_prepend_advice_after_call',
   'motion_prepend_advice_before_call',
   'motion_prepend_advice_around_call',
   'pointcut',
   'pointcut_add',
   'pointcut_sub',
   'pointcut_first',
   'pointcut_last',
   'pointcut_min',
   'pointcut_max',
] )


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
                                              | MOTION_APPEND_AFTER_CALL LPAREN ID COMMA ID COMMA ID COMMA ID RPAREN SEMI
      """
      p[0] = c_ast.MotionCall( 
         p[3] if len( p ) == 12 else None, 
         p[5] if len( p ) == 12 else p[3], 
         p[7] if len( p ) == 12 else None, 
         p[9] if len( p ) == 12 else p[5], 
         None, "last", None, "after" )
   
   def p_motion_append_before_call_keyword( self, p ):
      """ motion_append_before_call_keyword   : MOTION_APPEND_BEFORE_CALL LPAREN ID COMMA ID RPAREN SEMI
                                              | MOTION_APPEND_BEFORE_CALL LPAREN ID COMMA ID COMMA ID COMMA ID RPAREN SEMI
      """
      p[0] = c_ast.MotionCall( 
         p[3] if len( p ) == 12 else None, 
         p[5] if len( p ) == 12 else p[3], 
         p[7] if len( p ) == 12 else None, 
         p[9] if len( p ) == 12 else p[5], 
         None, "last", None, "before" )
   
   def p_motion_append_around_call_keyword( self, p ):
      """ motion_append_around_call_keyword   : MOTION_APPEND_AROUND_CALL LPAREN ID COMMA ID RPAREN SEMI
                                              | MOTION_APPEND_AROUND_CALL LPAREN ID COMMA ID COMMA ID COMMA ID RPAREN SEMI
      """
      p[0] = c_ast.MotionCall( 
         p[3] if len( p ) == 12 else None, 
         p[5] if len( p ) == 12 else p[3], 
         p[7] if len( p ) == 12 else None, 
         p[9] if len( p ) == 12 else p[5], 
         None, "last", None, "around" )
   
   def p_motion_prepend_after_call_keyword( self, p ):
      """ motion_prepend_after_call_keyword   : MOTION_PREPEND_AFTER_CALL LPAREN ID COMMA ID RPAREN SEMI
                                              | MOTION_PREPEND_AFTER_CALL LPAREN ID COMMA ID COMMA ID COMMA ID RPAREN SEMI
      """
      p[0] = c_ast.MotionCall( 
         p[3] if len( p ) == 12 else None, 
         p[5] if len( p ) == 12 else p[3], 
         p[7] if len( p ) == 12 else None, 
         p[9] if len( p ) == 12 else p[5], 
         None, "first", None, "after" )
   
   def p_motion_prepend_before_call_keyword( self, p ):
      """ motion_prepend_before_call_keyword  : MOTION_PREPEND_BEFORE_CALL LPAREN ID COMMA ID RPAREN SEMI
                                              | MOTION_PREPEND_BEFORE_CALL LPAREN ID COMMA ID COMMA ID COMMA ID RPAREN SEMI
      """
      p[0] = c_ast.MotionCall( 
         p[3] if len( p ) == 12 else None, 
         p[5] if len( p ) == 12 else p[3], 
         p[7] if len( p ) == 12 else None, 
         p[9] if len( p ) == 12 else p[5], 
         None, "first", None, "before" )
   
   def p_motion_prepend_around_call_keyword( self, p ):
      """ motion_prepend_around_call_keyword  : MOTION_PREPEND_AROUND_CALL LPAREN ID COMMA ID RPAREN SEMI
                                              | MOTION_PREPEND_AROUND_CALL LPAREN ID COMMA ID COMMA ID COMMA ID RPAREN SEMI
      """
      p[0] = c_ast.MotionCall( 
         p[3] if len( p ) == 12 else None, 
         p[5] if len( p ) == 12 else p[3], 
         p[7] if len( p ) == 12 else None, 
         p[9] if len( p ) == 12 else p[5], 
         None, "first", None, "around" )
   
   def p_motion_alwaysfirst_after_call_keyword( self, p ):
      """ motion_alwaysfirst_after_call_keyword  : MOTION_ALWAYSFIRST_AFTER_CALL LPAREN ID COMMA ID RPAREN SEMI
                                                 | MOTION_ALWAYSFIRST_AFTER_CALL LPAREN ID COMMA ID COMMA ID COMMA ID RPAREN SEMI
      """
      p[0] = c_ast.MotionCall( 
         p[3] if len( p ) == 12 else None, 
         p[5] if len( p ) == 12 else p[3], 
         p[7] if len( p ) == 12 else None, 
         p[9] if len( p ) == 12 else p[5], 
         None, "first", "always", "after" )
   
   def p_motion_alwaysfirst_before_call_keyword( self, p ):
      """ motion_alwaysfirst_before_call_keyword : MOTION_ALWAYSFIRST_BEFORE_CALL LPAREN ID COMMA ID RPAREN SEMI
                                                 | MOTION_ALWAYSFIRST_BEFORE_CALL LPAREN ID COMMA ID COMMA ID COMMA ID RPAREN SEMI
      """
      p[0] = c_ast.MotionCall( 
         p[3] if len( p ) == 12 else None, 
         p[5] if len( p ) == 12 else p[3], 
         p[7] if len( p ) == 12 else None, 
         p[9] if len( p ) == 12 else p[5], 
         None, "first", "always", "before" )
   
   def p_motion_alwaysfirst_around_call_keyword( self, p ):
      """ motion_alwaysfirst_around_call_keyword : MOTION_ALWAYSFIRST_AROUND_CALL LPAREN ID COMMA ID RPAREN SEMI
                                                 | MOTION_ALWAYSFIRST_AROUND_CALL LPAREN ID COMMA ID COMMA ID COMMA ID RPAREN SEMI
      """
      p[0] = c_ast.MotionCall( 
         p[3] if len( p ) == 12 else None, 
         p[5] if len( p ) == 12 else p[3], 
         p[7] if len( p ) == 12 else None, 
         p[9] if len( p ) == 12 else p[5], 
         None, "first", "always", "around" )
   
   def p_motion_alwayslast_after_call_keyword( self, p ):
      """ motion_alwayslast_after_call_keyword   : MOTION_ALWAYSLAST_AFTER_CALL LPAREN ID COMMA ID RPAREN SEMI
                                                 | MOTION_ALWAYSLAST_AFTER_CALL LPAREN ID COMMA ID COMMA ID COMMA ID RPAREN SEMI
      """
      p[0] = c_ast.MotionCall( 
         p[3] if len( p ) == 12 else None, 
         p[5] if len( p ) == 12 else p[3], 
         p[7] if len( p ) == 12 else None, 
         p[9] if len( p ) == 12 else p[5], 
         None, "last", "always", "after" )
   
   def p_motion_alwayslast_before_call_keyword( self, p ):
      """ motion_alwayslast_before_call_keyword  : MOTION_ALWAYSLAST_BEFORE_CALL LPAREN ID COMMA ID RPAREN SEMI
                                                 | MOTION_ALWAYSLAST_BEFORE_CALL LPAREN ID COMMA ID COMMA ID COMMA ID RPAREN SEMI
      """
      p[0] = c_ast.MotionCall( 
         p[3] if len( p ) == 12 else None, 
         p[5] if len( p ) == 12 else p[3], 
         p[7] if len( p ) == 12 else None, 
         p[9] if len( p ) == 12 else p[5], 
         None, "last", "always", "before" )
   
   def p_motion_alwayslast_around_call_keyword( self, p ):
      """ motion_alwayslast_around_call_keyword  : MOTION_ALWAYSLAST_AROUND_CALL LPAREN ID COMMA ID RPAREN SEMI
                                                 | MOTION_ALWAYSLAST_AROUND_CALL LPAREN ID COMMA ID COMMA ID COMMA ID RPAREN SEMI
      """
      p[0] = c_ast.MotionCall( 
         p[3] if len( p ) == 12 else None, 
         p[5] if len( p ) == 12 else p[3], 
         p[7] if len( p ) == 12 else None, 
         p[9] if len( p ) == 12 else p[5], 
         None, "last", "always", "around" )
   
   def p_motion_append_advice_after_call_keyword( self, p ):
      """ motion_append_advice_after_call_keyword  : MOTION_APPEND_ADVICE_AFTER_CALL LPAREN ID COMMA ID COMMA ID RPAREN SEMI
                                                   | MOTION_APPEND_ADVICE_AFTER_CALL LPAREN ID COMMA ID COMMA ID COMMA ID COMMA ID RPAREN SEMI
      """
      p[0] = c_ast.MotionCall( 
         p[3] if len( p ) == 12 else None, 
         p[5] if len( p ) == 12 else p[3], 
         p[7] if len( p ) == 12 else None, 
         p[9] if len( p ) == 12 else p[5], 
         p[11] if len( p ) == 12 else p[7], "last", None, "after" )
   
   def p_motion_append_advice_before_call_keyword( self, p ):
      """ motion_append_advice_before_call_keyword : MOTION_APPEND_ADVICE_BEFORE_CALL LPAREN ID COMMA ID COMMA ID RPAREN SEMI
                                                   | MOTION_APPEND_ADVICE_BEFORE_CALL LPAREN ID COMMA ID COMMA ID COMMA ID COMMA ID RPAREN SEMI
      """
      p[0] = c_ast.MotionCall( 
         p[3] if len( p ) == 12 else None, 
         p[5] if len( p ) == 12 else p[3], 
         p[7] if len( p ) == 12 else None, 
         p[9] if len( p ) == 12 else p[5], 
         p[11] if len( p ) == 12 else p[7], "last", None, "before" )
   
   def p_motion_append_advice_around_call_keyword( self, p ):
      """ motion_append_advice_around_call_keyword : MOTION_APPEND_ADVICE_AROUND_CALL LPAREN ID COMMA ID COMMA ID RPAREN SEMI
                                                   | MOTION_APPEND_ADVICE_AROUND_CALL LPAREN ID COMMA ID COMMA ID COMMA ID COMMA ID RPAREN SEMI
      """
      p[0] = c_ast.MotionCall( 
         p[3] if len( p ) == 12 else None, 
         p[5] if len( p ) == 12 else p[3], 
         p[7] if len( p ) == 12 else None, 
         p[9] if len( p ) == 12 else p[5], 
         p[11] if len( p ) == 12 else p[7], "last", None, "around" )
   
   def p_motion_prepend_advice_after_call_keyword( self, p ):
      """ motion_prepend_advice_after_call_keyword : MOTION_PREPEND_ADVICE_AFTER_CALL LPAREN ID COMMA ID COMMA ID RPAREN SEMI
                                                   | MOTION_PREPEND_ADVICE_AFTER_CALL LPAREN ID COMMA ID COMMA ID COMMA ID COMMA ID RPAREN SEMI
      """
      p[0] = c_ast.MotionCall( 
         p[3] if len( p ) == 12 else None, 
         p[5] if len( p ) == 12 else p[3], 
         p[7] if len( p ) == 12 else None, 
         p[9] if len( p ) == 12 else p[5], 
         p[11] if len( p ) == 12 else p[7], "first", None, "after" )
   
   def p_motion_prepend_advice_before_call_keyword( self, p ):
      """ motion_prepend_advice_before_call_keyword  : MOTION_PREPEND_ADVICE_BEFORE_CALL LPAREN ID COMMA ID COMMA ID RPAREN SEMI
                                                     | MOTION_PREPEND_ADVICE_BEFORE_CALL LPAREN ID COMMA ID COMMA ID COMMA ID COMMA ID RPAREN SEMI
      """
      p[0] = c_ast.MotionCall( 
         p[3] if len( p ) == 12 else None, 
         p[5] if len( p ) == 12 else p[3], 
         p[7] if len( p ) == 12 else None, 
         p[9] if len( p ) == 12 else p[5], 
         p[11] if len( p ) == 12 else p[7], "first", None, "before" )
   
   def p_motion_prepend_advice_around_call_keyword( self, p ):
      """ motion_prepend_advice_around_call_keyword  : MOTION_PREPEND_ADVICE_AROUND_CALL LPAREN ID COMMA ID COMMA ID RPAREN SEMI
                                                     | MOTION_PREPEND_ADVICE_AROUND_CALL LPAREN ID COMMA ID COMMA ID COMMA ID COMMA ID RPAREN SEMI
      """
      p[0] = c_ast.MotionCall( 
         p[3] if len( p ) == 12 else None, 
         p[5] if len( p ) == 12 else p[3], 
         p[7] if len( p ) == 12 else None, 
         p[9] if len( p ) == 12 else p[5], 
         p[11] if len( p ) == 12 else p[7], "first", None, "around" )
   

   # pointcut( pname )        - pointcut described by a function call name and no arguments.
   # pointcut( pname, o )     - pointcut described by a method call name and no arguments.
   # pointcut( pname; el )    - pointcut described by a function call name and arguments.
   # pointcut( pname, o; el ) - pointcut described by a method call name and arguments.
   def p_pointcut_keyword( self, p ):
      """ pointcut_keyword    : POINTCUT LPAREN ID SEMI argument_expression_list RPAREN
                              | POINTCUT LPAREN ID COMMA ID SEMI argument_expression_list RPAREN
                              | POINTCUT LPAREN ID COMMA ID RPAREN
                              | POINTCUT LPAREN ID RPAREN
      """
      if( len( p ) == 9 ):
         p[0] = c_ast.PointcutCall( p[5], p[3], p[7], "imperative" )
      elif( len( p ) == 7 ):
         if( type(p[5]).__name__ == 'ExprList' ):
            p[0] = c_ast.PointcutCall( None, p[3], p[5], "imperative" )
         else:
            p[0] = c_ast.PointcutCall( p[5], p[3], None, "imperative" )
      else:
         p[0] = c_ast.PointcutCall( None, p[3], None, "imperative" )

   def p_pointcut_add_keyword( self, p ):
      """ pointcut_add_keyword    : POINTCUT_ADD LPAREN ID SEMI argument_expression_list RPAREN
                                  | POINTCUT_ADD LPAREN ID COMMA ID SEMI argument_expression_list RPAREN
                                  | POINTCUT_ADD LPAREN ID COMMA ID RPAREN
                                  | POINTCUT_ADD LPAREN ID RPAREN
      """
      if( len( p ) == 9 ):
         p[0] = c_ast.PointcutCall( p[5], p[3], p[7], "add" )
      elif( len( p ) == 7 ):
         if( type(p[5]).__name__ == 'ExprList' ):
            p[0] = c_ast.PointcutCall( None, p[3], p[5], "add" )
         else:
            p[0] = c_ast.PointcutCall( p[5], p[3], None, "add" )
      else:
         p[0] = c_ast.PointcutCall( None, p[3], None, "add" )
   
   def p_pointcut_sub_keyword( self, p ):
      """ pointcut_sub_keyword    : POINTCUT_SUB LPAREN ID SEMI argument_expression_list RPAREN
                                  | POINTCUT_SUB LPAREN ID COMMA ID SEMI argument_expression_list RPAREN
                                  | POINTCUT_SUB LPAREN ID COMMA ID RPAREN
                                  | POINTCUT_SUB LPAREN ID RPAREN
      """
      if( len( p ) == 9 ):
         p[0] = c_ast.PointcutCall( p[5], p[3], p[7], "sub" )
      elif( len( p ) == 7 ):
         if( type(p[5]).__name__ == 'ExprList' ):
            p[0] = c_ast.PointcutCall( None, p[3], p[5], "sub" )
         else:
            p[0] = c_ast.PointcutCall( p[5], p[3], None, "sub" )
      else:
         p[0] = c_ast.PointcutCall( None, p[3], None, "sub" )
   
   def p_pointcut_first_keyword( self, p ):
      """ pointcut_first_keyword    : POINTCUT_FIRST LPAREN ID SEMI argument_expression_list RPAREN
                                    | POINTCUT_FIRST LPAREN ID COMMA ID SEMI argument_expression_list RPAREN
                                    | POINTCUT_FIRST LPAREN ID COMMA ID RPAREN
                                    | POINTCUT_FIRST LPAREN ID RPAREN
      """
      if( len( p ) == 9 ):
         p[0] = c_ast.PointcutCall( p[5], p[3], p[7], "first" )
      elif( len( p ) == 7 ):
         if( type(p[5]).__name__ == 'ExprList' ):
            p[0] = c_ast.PointcutCall( None, p[3], p[5], "first" )
         else:
            p[0] = c_ast.PointcutCall( p[5], p[3], None, "first" )
      else:
         p[0] = c_ast.PointcutCall( None, p[3], None, "first" )

   def p_pointcut_last_keyword( self, p ):
      """ pointcut_last_keyword    : POINTCUT_LAST LPAREN ID SEMI argument_expression_list RPAREN
                                   | POINTCUT_LAST LPAREN ID COMMA ID SEMI argument_expression_list RPAREN
                                   | POINTCUT_LAST LPAREN ID COMMA ID RPAREN
                                   | POINTCUT_LAST LPAREN ID RPAREN
      """
      if( len( p ) == 9 ):
         p[0] = c_ast.PointcutCall( p[5], p[3], p[7], "last" )
      elif( len( p ) == 7 ):
         if( type(p[5]).__name__ == 'ExprList' ):
            p[0] = c_ast.PointcutCall( None, p[3], p[5], "last" )
         else:
            p[0] = c_ast.PointcutCall( p[5], p[3], None, "last" )
      else:
         p[0] = c_ast.PointcutCall( None, p[3], None, "last" )


   def p_pointcut_min_keyword( self, p ):
      """ pointcut_min_keyword    : POINTCUT_MIN LPAREN ID SEMI argument_expression_list RPAREN
                                  | POINTCUT_MIN LPAREN ID COMMA ID SEMI argument_expression_list RPAREN
                                  | POINTCUT_MIN LPAREN ID COMMA ID RPAREN
                                  | POINTCUT_MIN LPAREN ID RPAREN
      """
      if( len( p ) == 9 ):
         p[0] = c_ast.PointcutCall( p[5], p[3], p[7], "min" )
      elif( len( p ) == 7 ):
         if( type(p[5]).__name__ == 'ExprList' ):
            p[0] = c_ast.PointcutCall( None, p[3], p[5], "min" )
         else:
            p[0] = c_ast.PointcutCall( p[5], p[3], None, "min" )
      else:
         p[0] = c_ast.PointcutCall( None, p[3], None, "min" )

   def p_pointcut_max_keyword( self, p ):
      """ pointcut_max_keyword    : POINTCUT_MAX LPAREN ID SEMI argument_expression_list RPAREN
                                  | POINTCUT_MAX LPAREN ID COMMA ID SEMI argument_expression_list RPAREN
                                  | POINTCUT_MAX LPAREN ID COMMA ID RPAREN
                                  | POINTCUT_MAX LPAREN ID RPAREN
      """
      if( len( p ) == 9 ):
         p[0] = c_ast.PointcutCall( p[5], p[3], p[7], "max" )
      elif( len( p ) == 7 ):
         if( type(p[5]).__name__ == 'ExprList' ):
            p[0] = c_ast.PointcutCall( None, p[3], p[5], "max" )
         else:
            p[0] = c_ast.PointcutCall( p[5], p[3], None, "max" )
      else:
         p[0] = c_ast.PointcutCall( None, p[3], None, "max" )


   def p_statement_compass( self, p ):
      """ statement : motion_append_after_call_keyword 
                    | motion_append_before_call_keyword
                    | motion_append_around_call_keyword
                    | motion_prepend_after_call_keyword
                    | motion_prepend_before_call_keyword
                    | motion_prepend_around_call_keyword
                    | motion_alwaysfirst_after_call_keyword
                    | motion_alwaysfirst_before_call_keyword
                    | motion_alwaysfirst_around_call_keyword
                    | motion_alwayslast_after_call_keyword
                    | motion_alwayslast_before_call_keyword
                    | motion_alwayslast_around_call_keyword
                    | motion_append_advice_after_call_keyword
                    | motion_append_advice_before_call_keyword
                    | motion_append_advice_around_call_keyword
                    | motion_prepend_advice_after_call_keyword
                    | motion_prepend_advice_before_call_keyword
                    | motion_prepend_advice_around_call_keyword
      """
      p[0] = p[1]

   def p_unary_expression_compass( self, p ):
        """ unary_expression    : pointcut_keyword 
                                | pointcut_add_keyword
                                | pointcut_sub_keyword
                                | pointcut_first_keyword
                                | pointcut_last_keyword
                                | pointcut_min_keyword
                                | pointcut_max_keyword
        """
        p[0] = p[1]


# rel_pos = "first" ...              prepend
# rel_pos = "last" or "" or None ... append
# pos_constraint = "always" ...      constrain to "always" (first, last)
# pos_constraint = "" or None ...    no constraint
# advice = "after" ...               after
# advice = "before" ...              before
# advice = "around" ...              around
class MotionCall( c_ast.Node ):
    def __init__( self, adviceObj, adviceBody, obj, identifier, rel_motion, rel_pos, pos_constraint, advice, coord = None ):
        self.adviceObj = adviceObj
        self.adviceBody = adviceBody
        self.obj = obj
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
        if self.adviceObj is not None:
            nodelist.append( ("adviceObj", c_ast.ID( self.adviceObj ) ) )
        if self.adviceBody is not None:
            nodelist.append( ("adviceBody", c_ast.ID( self.adviceBody ) ) )
        if self.obj is not None:
            nodelist.append( ("obj", c_ast.ID( self.obj ) ) )
        if self.identifier is not None:
            nodelist.append( ("identifier", c_ast.ID( self.identifier ) ) )
        if self.rel_motion is not None:
            nodelist.append( ("rel_motion", c_ast.ID( self.rel_motion ) ) )
        return tuple( nodelist )

    def show( self, buf = sys.stdout, offset = 0, attrnames = False, nodenames = False, showcoord = False, _my_node_name = None ):
       #pdb.set_trace()
       c_ast.Node.show( self, buf, offset, attrnames, nodenames, showcoord, _my_node_name )

    attr_names = ( "has_rel_motion", "rel_pos", "pos_constraint", "advice" )

class PointcutCall( c_ast.Node ):
    def __init__( self, o, pname, args, advice_comb, coord = None ):
        self.o = o
        self.pname = pname
        self.args = args
        self.advice_comb = advice_comb

    def children( self ):
        nodelist = []
        if self.pname is not None:
            nodelist.append( ("pname", c_ast.ID( self.pname ) ) )
        if self.args is not None:
            nodelist.append( ("args", self.args ) )
        if self.o is not None:
            nodelist.append( ("o", c_ast.ID( self.o ) ) )
        return tuple( nodelist )

    def show( self, buf = sys.stdout, offset = 0, attrnames = False, nodenames = False, showcoord = False, _my_node_name = None ):
       #pdb.set_trace()
       c_ast.Node.show( self, buf, offset, attrnames, nodenames, showcoord, _my_node_name )

    attr_names = ( "advice_comb", )


c_ast.MotionCall = MotionCall
c_ast.PointcutCall = PointcutCall

