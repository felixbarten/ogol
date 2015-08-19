module ogol::Syntax

import ParseTree;
import vis::ParseTree;
import vis::Render;
import vis::Figure;
/*

Ogol syntax summary

Program: Command...

Command:
 * Control flow: 
  if Expr Block;
  ifelse Expr Block Block
  while Expr Block
  repeat Expr Block
 * Drawing (mind the closing semicolons)
  forward Expr; fd Expr; back Expr; bk Expr; home;
  right Expr; rt Expr; left Expr; lt Expr; 
  pendown; pd; penup; pu;
 * Procedures
  definition: to Name [Var...] Command... end
  call: Name Expr... ;
 
Block: [Command...]
 
Expressions
 * Variables :x, :y, :angle, etc.
 * Number: 1, 2, -3, 0.7, -.1, etc.
 * Boolean: true, false
 * Arithmetic: +, *, /, -
 * Comparison: >, <, >=, <=, =, !=
 * Logical: &&, ||

Reserved keywords
 if, ifelse, while, repeat, forward, back, right, left, pendown, 
 penup, to, true, false, end

Bonus:
 - add literal for colors
 - support setpencolor

*/

start syntax Program = Command*; 

keyword Reserved =  "if"
	| "ifelse"
	| "while"
	| "repeat"
	| "forward"
	| "fd"
	| "back"
	| "bk"
	| "right"
	| "rt"
	| "left"
	| "lt"
	| "pendown"
	| "pd"
	| "penup"
	| "pu"
	| "to"
	| "true"
	| "false"
	| "end";

syntax FunDef = "to" FunId id Variable+ Command* "end";

syntax Expr 
   = Boolean
   | Number
   | VarId
   > left   div: Expr "/" Expr 
   > left   mul: Expr "*" Expr
   > left ( add: Expr "+" Expr 
   		  | sub: Expr "-" Expr
   		  )
   > left ( gt:  Expr "\>"  Expr
          | st:  Expr "\<"  Expr
          | gte: Expr "\>=" Expr
          | ste: Expr "\<=" Expr
          | eq:  Expr "="  Expr
          | neq: Expr "!=" Expr
          )    
   | left ( and: Expr "&&" Expr
          | or:  Expr "||" Expr
          )
   ;

syntax Command = "if" Expr Block
	| "ifelse" Expr Block Block
	| "while" Expr Block
	| "repeat" Expr Block
	| DrawingCommand
	| FunDef
	| FunId Expr+";" 
	;
	
syntax DrawingCommand = "forward" Expr";" 
	|"fd" Expr ";" 
	|"back" Expr ";" 
	|"bk" Expr ";" 
	|"home;"
	|"right" Expr ";" 
	|"rt" Expr ";" 
	|"left" Expr ";" 
	|"lt" Expr ";" 
	|"pendown;" 
	|"pd;"
	|"penup;"
	|"pu;" 	
	;
	
syntax Block = "["  Command*  "]";

lexical Number = "-"? ([0-9]* ".")? [0-9]+ !>> [0-9];
lexical Boolean = "true" | "false";

lexical VarId
  = ":" [a-zA-Z][a-zA-Z0-9]* \ Reserved !>> [a-zA-Z0-9]; // added difference reserved
  
lexical FunId
  = [a-zA-Z][a-zA-Z0-9]* \ Reserved !>> [a-zA-Z0-9]; // added difference reserved


layout Standard 
  = WhitespaceOrComment* !>> [\ \t\n\r] !>> "--";
  
lexical WhitespaceOrComment 
  = whitespace: Whitespace
  | comment: Comment
  ; 

lexical Whitespace
  = [\ \t\n\r]
  ;

lexical Comment
  = @category="Comment" "--" ![\n\r]* [\r][\n]
  ;
  
/* Tests  */
  
bool canparse(cls, str s){
	try {
		parse(cls, s);
		return true;
	}
  	catch:
  		return false;
}
	
bool canparsetree(cls, str s){
	try {
		vis::ParseTree::renderParsetree(parse(cls, s));
		return true;
	} catch:
		return false;
}


  /* num test*/
  test bool n0() = false := canparse(#Number, ""); 
  test bool n1() = true := canparse(#Number, ".7"); 
  test bool n2() = true := canparse(#Number, "-1.0"); 
  
  
  /* Variable test */
  test bool t0() = false := canparse(#VarId,""); 
  test bool t1() = true := canparse(#VarId,":v"); 
  test bool t2() = true := canparse(#VarId,":variable"); 
  test bool t3() = true := canparse(#Number,"-0"); 
  test bool t8() = true := canparse(#Number,"199"); 
  test bool t9() = true := canparse(#Number,"-0.2"); 
  test bool t10() = true := canparse(#Number,"2000000"); 
  test bool t11() = true := canparse(#Boolean,"false"); 
  test bool t12() = true := canparse(#Number,"0.8");  
  test bool t13() = true := canparse(#Number,"-1");  
  
  /* expression test */
  test bool expr() = true := canparse(#Expr,"true + false");
  test bool expr0() = true := canparse(#Expr,"true");
  test bool expr1() = true := canparse(#Expr,"4");  
  test bool expr2() = true := canparse(#Expr,"1.0 + false");
  test bool expr3() = true := canparse(#Expr,"true && :bool");
  test bool expr4() = true := canparse(#Expr,":bool || :falsebool");
  test bool expr5() = true := canparse(#Expr,":bool && true");
  test bool expr6() = true := canparse(#Expr,":var");
  
  // assert false
  test bool cmd() = true := canparse(#Command,"if true + false []");
  test bool cmd0() = false := canparse(#Command,"repeat 36");
  test bool cmd4() = false := canparse(#Command,"if -1 + 1");
  test bool cmd7() = false := canparse(#Command,"");
  
  test bool cmd1() = true := canparse(#Command,"repeat 36 [fd 36;]");  
  test bool cmd2() = true := canparse(#Command,"fd 50;");
  test bool cmd3() = true := canparse(#Command,"if true + false [fd 20; rt 200;]");
  test bool cmd5() = true := canparse(#Command,"home;");
  test bool cmd5() = false := canparse(#Command,"home");
  test bool cmd7() = true := canparse(#Command,"if 1 + 1 [fd 40;]");
  test bool cmd8() = true := canparse(#Command,"if 1 + 1 [fd 40; fd 50;]");
  
  test bool cmd10() = true := canparse(#Command,"if 1 + 1 [squareDash :n :n; rt 10;]");
  test bool cmd11() = true := canparse(#Command,"if 1 + 1 [squareDash :n;]");
  test bool cmd13() = true := canparse(#Command,"if 1 + 1 [squareDash :n;]");
  test bool cmd12() = true := canparse(#Command,"squareDash :n;");


  /* test block */
  test bool block() = true := canparse(#Block, "[squareDash :n :n; rt 10;]");
  test bool block01() = true := canparse(#Block,"[squareDash :n;]");  
  
              
 
 /* draw trees */
 // test bool draw() = true := canparsetree(#Command,"if 1 + 1 [fd 40; fd 50;]");
 // test bool func10() = true := canparsetree(#Expr,"true + false"); 
 
  
  
  