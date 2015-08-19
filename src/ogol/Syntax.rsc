module ogol::Syntax

import ParseTree;

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

syntax FunDef = FunId Expr+";" 
	| "to" FunId Variable+ Command* "end"
	;

syntax Variables = Variable | 
	| Numbers 
	| Booleans
	;
	
syntax Operation =	Arithmatic
	| Comparison
	| Logical
	;
syntax Expr = Variables Operation Variables
	| Variables
	;

syntax Command = "if" Expr Block
	| "ifelse" Expr Block Block
	| "while" Expr Block
	| "repeat" Expr Block
	| DrawCommand
	| FunDef
	;
	
syntax DrawCommand = "forward" Expr";" 
	|"fd" Expr";" 
	|"back" Expr";" 
	|"bk" Expr";" 
	|"home;"
	|"right" Expr";" 
	|"rt" Expr";" 
	|"left" Expr";" 
	|"lt" Expr";" 
	|"pendown;" 
	|"pd;"
	|"penup;"
	|"pu;" 	
	;
	
syntax Block = "["  Command+  "]";

lexical Variable = VarId;
lexical Numbers = "-"?[0-9]*"."?[0-9]*;
lexical Booleans = "true" | "false";
lexical Arithmatic = "+" | "-" | "*" | "/";
lexical Comparison = "\<" |"\>" |"\<=" |"\>=" | "=" | "!=";
lexical Logical =  "&&" | "||";

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
	



  /* num test*/
  test bool n0() = false := canparse(#Numbers, ""); 
  test bool n1() = true := canparse(#Numbers, ".7"); 
  test bool n2() = true := canparse(#Numbers, "-1.0"); 
  
  
  /* Variable test */
  test bool t0() = true := canparse(#Variables,""); 
  test bool t1() = true := canparse(#Variables,":v"); 
  test bool t2() = true := canparse(#Variables,":variable"); 
  test bool t3() = true := canparse(#Variables,"-0"); 
  test bool t8() = true := canparse(#Variables,"199"); 
  test bool t9() = true := canparse(#Variables,"-0.2"); 
  test bool t10() = true := canparse(#Variables,"2000000"); 
  test bool t11() = true := canparse(#Variables,"false"); 
  test bool t12() = true := canparse(#Variables,"0.8");  
  test bool t13() = true := canparse(#Variables,"-1");  
  
  /* operation test */
  test bool t4() = true := canparse(#Operation,"\<"); 
  test bool t5() = true := canparse(#Operation,"\>"); 
  test bool t6() = true := canparse(#Operation,"\>="); 
  test bool t7() = true := canparse(#Operation,"\<="); 
  test bool t13() = true := canparse(#Operation,"||"); 
  test bool t14() = true := canparse(#Operation,"&&"); 
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
  test bool cmd() = false := canparse(#Command,"if true + false []");
  test bool cmd0() = false := canparse(#Command,"repeat 36");
  test bool cmd4() = false := canparse(#Command,"if -1 + 1");
  test bool cmd7() = false := canparse(#Command,"");
  
  test bool cmd1() = true := canparse(#Command,"repeat 36 [fd 36;]");  
  test bool cmd2() = true := canparse(#Command,"fd 50;");
  test bool cmd3() = true := canparse(#Command,"if true + false [fd 20; rt 200;]");
  test bool cmd5() = true := canparse(#Command,"home;");
  test bool cmd7() = true := canparse(#Command,"if 1 + 1 [fd 40;]");
  test bool cmd8() = true := canparse(#Command,"if 1 + 1 [fd 40; fd 50;]");
  
  test bool cmd10() = true := canparse(#Command,"if 1 + 1 [squareDash :n :n; rt 10;]");
  test bool cmd11() = true := canparse(#Command,"if 1 + 1 [squareDash :n;]");
  test bool cmd13() = true := canparse(#Command,"if 1 + 1 [squareDash :n;]");
  test bool cmd12() = true := canparse(#Command,"squareDash :n;");


  /* test block */
  test bool block() = true := canparse(#Block, "[squareDash :n :n; rt 10;]");
  test bool block01() = true := canparse(#Block,"[squareDash :n;]");  
  
              
   /* test functions*/    
  test bool func1() = true := canparse(#FunDef,"squareDashTwirl 0;");  
  test bool func9() = true := canparse(#FunDef,"squareDash :n :n;");
  
  test bool func7() = true := canparse(#FunDef,"to fillpoly :a :b :c :d fd 50; end");
  test bool func8() = true := canparse(#FunDef,"to dash :n :len repeat :n [ pd; fd :len; pu; fd :len; ] bk :len; pd; end");   
  
  test bool func5() = true := canparse(#FunDef,"home;"); // double V T F

   
   
              
  test bool func5() = true := canparse(#FunDef,"to tree :size  if :size \>= 5 [  	fd :size;  	lt 30; tree :size * 0.7;  	rt 60; tree :size * 0.7;  	lt 30; bk :size; ] end"); 
  test bool cmd_20() = true := canparse(#FunDef," if :size \>= 5 [  	fd :size;  	lt 30; tree :size*0.7;  	rt 60; tree :size*0.7;  	lt 30; bk :size; ]");       // todo     
 test bool func7() = true := canparse(#FunDef,"tree :size * 0.7;");
 
  
  