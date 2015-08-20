module ogol::Eval

// imports
import ogol::Syntax;
import ogol::Canvas;
import ParseTree;
import String;
import IO;

alias FunEnv = map[FunId id, FunDef def];

alias VarEnv = map[VarId id, Value val];

data Value
  = boolean(bool b)
  | number(real r)
  ;

/*
         +y
         |
         |
         |
-x ------+------- +x
         |
         |
         |
        -y

NB: home = (0, 0)
*/

// alias Result = tuple(Env env, State state);

alias Turtle = tuple[int dir, bool pendown, Point position];


// incorporate environments in state?
alias State = tuple[Turtle turtle, Canvas canvas];

// Top-level eval function
Canvas eval((Program)`<Command* cmds>`) {

	funenv = collectFunDefs(p);
	varEnv = ();
	state = <<0, false, <0,0>>, []>;
	
	for (c <- cmds) {
		state = evalCommand(c, funenv, varEnv, state);
	}
	return state.Canvas;
}


FunEnv collectFunDefs(Program p)
 = (f.id : f | /FunDef f := p);
// =  ( f: d | /d:(Command)`to <FunId f> <VarId* _> <Command _> end` := p);

FunEnv fenf = ();
	VarEnv varEnv = ();
	State state = <<0, false, <0,0>>, []>;

State eval(Command cmd, FunEnv fenv, VarEnv venv, State state) {
	
	switch(cmd){
		case forward(Expr e): {
			println(e);
			
			eval(e);
			println(eval(e));
			;
		}
	
}

}
// if 
State evalCommand((Command)`if <Expr* e><Block b>;`, FunEnv fenv, VarEnv venv, State state) {

	return state;
}
//ifelse
State evalCommand((Command)`ifelse <Expr* e><Block b><Block c>;`, FunEnv fenv, VarEnv venv, State state) {

	return state;
}
// repeat
State evalCommand((Command)`repeat <Expr* e><Block b>;`, FunEnv fenv, VarEnv venv, State state) {

	return state;
}

// forward, fd
State evalCommand((Command)`forward <Expr* e>;`, FunEnv fenv, VarEnv venv, State state) {

	return state;
}
// back, bvk
State evalCommand((Command)`back <Expr* e>;`, FunEnv fenv, VarEnv venv, State state) {

	return state;
}
// left, lt
State evalCommand((Command)`left <Expr* e>;`, FunEnv fenv, VarEnv venv, State state) {

	return state;
}
// right, rt
State evalCommand((Command)`right <Expr* e>;`, FunEnv fenv, VarEnv venv, State state) {

	return state;
}				
// home;
State evalCommand((Command)`home;`, FunEnv fenv, VarEnv venv, State state) {
	state.turtle.position.x = 0;
	state.turtle.position.y = 0;
	return state;
}

test bool testHomeCmd() = evalCommand((Command)`home;`, (), (), <<0, false, <4,5>>, []>) == <<0, false, <0,0>>, []>;
test bool testHomeCmd() = evalCommand((Command)`home;`, (), (), <<0, false, <7,2>>, []>) == <<0, false, <0,0>>, []>;
// penup, pu;
State evalCommand((Command)`penup;`, FunEnv fenv, VarEnv venv, State state) {
	state.turtle.pendown = false;
	return state;		
}
test bool testPenUp() = evalCommand((Command)`penup;`, (), (), <<0, true, <0,0>>, []>) == <<0, false, <0,0>>, []>;
test bool testPenUp() = evalCommand((Command)`penup;`, (), (), <<0, false, <0,0>>, []>) != <<0, true, <0,0>>, []>;

// pendown, pd; 
State evalCommand((Command)`pendown;`, FunEnv fenv, VarEnv venv, State state) {
		state.turtle.pendown = true;
		return state;
}

test bool testPenDown() = evalCommand((Command)`pendown;`, (), (), <<0, true, <0,0>>, []>) == <<0, true, <0,0>>, []>;
test bool testPenDown() = evalCommand((Command)`pendown;`, (), (), <<0, false, <0,0>>, []>) == <<0, true, <0,0>>, []>;
// 


//test bool testHomeCmd() = evalCommand((Command)`forward 50;`, (),(), <<0, false, <0,0>>, []>);
//test bool testHomeCmd() = evalCommand((Command)`forward :n;`, map[FunId id, FunDef def],((Expr)`:n`: number(50.0)), <<0, false, <0,0>>, []>);


default Value eval(Expr e, FunEnv _, VarEnv _) {
  throw "Cannot eval: <e>";
}

/*
Value eval(Expr e, FunEnv fenv, VarEnv venv) {
	switch(e) {
		case variable(str name):{
			return venv[name];
		}
		case boolean(bool b): {
			return b;
		
		}
		case number(number n): { 
			return number(n);
		
		}
		case mul(Exp lhs, Expr rhz): 
			return eval(lhs, fenv, venv) * eval(rhs, fenv, venv);
		
	}
}
*/

FunEnv fenv = ();
VarEnv venv = ();

Value eval((Expr)`true`, FunEnv fenv, VarEnv env) 
  = boolean(true);

Value eval((Expr)`false`, FunEnv fenv, VarEnv env) 
  = boolean(false);
  
Value eval((Expr)`<Number n>`, FunEnv fenv, VarEnv env)  = number(toReal(unparse(n)));
  
Value eval((Expr)`<VarId x>`, FunEnv fenv, VarEnv env)
  = env[x];
 

test bool testTrue() 
 = eval((Expr)`true`, (), ()) == boolean(true);
  
  
test bool testBool() = eval((Expr)`true`, (),()) == boolean(true);

test bool testNum() = eval((Expr)`2.0`, (),()) == number(2.0);


test bool testVar() = eval((Expr)`:x`, (), ((VarId)`:x`: boolean(true))) == boolean(true);


Value eval((Expr)`<Expr lhs> + <Expr rhs>`, FunEnv fenv, VarEnv venv)
  = number(x + y)
  when
    number(x) := eval(lhs, fenv, venv),
    number(y) := eval(rhs, fenv, venv);
    
Value eval((Expr)`<Expr lhs> - <Expr rhs>`, FunEnv fenv, VarEnv venv)
  = number(x - y)
  when
    number(x) := eval(lhs, fenv, venv),
    number(y) := eval(rhs, fenv, venv);
    
Value eval((Expr)`<Expr lhs> * <Expr rhs>`, FunEnv fenv, VarEnv venv)
  = number(x * y)
  when
    number(x) := eval(lhs, fenv, venv),
    number(y) := eval(rhs, fenv, venv);
    
Value eval((Expr)`<Expr lhs> / <Expr rhs>`, FunEnv fenv, VarEnv venv)
  = number(x / y)
  when
    number(x) := eval(lhs, fenv, venv),
    number(y) := eval(rhs, fenv, venv);

Value eval((Expr)`<Expr lhs> \> <Expr rhs>`, FunEnv fenv, VarEnv venv)
  = boolean(x > y)
  when
    number(x) := eval(lhs, fenv, venv),
    number(y) := eval(rhs, fenv, venv);

Value eval((Expr)`<Expr lhs> \>= <Expr rhs>`, FunEnv fenv, VarEnv venv)
  = boolean(x >= y)
  when
    number(x) := eval(lhs, fenv, venv),
    number(y) := eval(rhs, fenv, venv);
    
Value eval((Expr)`<Expr lhs> \< <Expr rhs>`, FunEnv fenv, VarEnv venv)
  = boolean(x < y)
  when
    number(x) := eval(lhs, fenv, venv),
    number(y) := eval(rhs, fenv, venv);
    
Value eval((Expr)`<Expr lhs> \<= <Expr rhs>`, FunEnv fenv, VarEnv venv)
  = boolean(x <= y)
  when
    number(x) := eval(lhs, fenv, venv),
    number(y) := eval(rhs, fenv, venv);
    
Value eval((Expr)`<Expr lhs> = <Expr rhs>`, FunEnv fenv, VarEnv venv)
  = boolean(x == y)
  when
    number(x) := eval(lhs, fenv, venv),
    number(y) := eval(rhs, fenv, venv);

Value eval((Expr)`<Expr lhs> != <Expr rhs>`, FunEnv fenv, VarEnv venv)
  = boolean(x != y)
  when
    number(x) := eval(lhs, fenv, venv),
    number(y) := eval(rhs, fenv, venv);
    
    
Value eval((Expr)`<Expr lhs> && <Expr rhs>`, FunEnv fenv, VarEnv venv)
  = boolean(x && y)
  when
    boolean(x) := eval(lhs, fenv, venv),
    boolean(y) := eval(rhs, fenv, venv);

Value eval((Expr)`<Expr lhs> || <Expr rhs>`, FunEnv fenv, VarEnv venv)
  = boolean(x || y)
  when
    boolean(x) := eval(lhs, fenv, venv),
    boolean(y) := eval(rhs, fenv, venv);

/* test arithmatic */

test bool testAdd() = number(6.0) := eval((Expr)`1 + 5`, (),());
test bool testAdd1() = number(230.0) := eval((Expr)`142 + 88`, (),());
test bool testMinus() = number(69.0) := eval((Expr)`72 - 3`, (),());
test bool testMinus1() = number(1.0) := eval((Expr)`6 - 5`, (),());
test bool testMul() = number(25.0) := eval((Expr)`5 * 5`, (),());
test bool testMul1() = number(40.0) := eval((Expr)`2 *20`, (),());
test bool testDiv() = number(10.0) := eval((Expr)`100 / 10`, (),());
test bool testDiv1() = number(10.0) := eval((Expr)`30/3`, (),());

/* test comparison */

test bool testEq() = boolean(true) := eval((Expr)`10 = 10`, (),());
test bool testEq1() = boolean(true) := eval((Expr)`4*4 = 16`, (),());
test bool testNotEq() = boolean(true) := eval((Expr)`100 != 10`, (),());
test bool testNotEq1() = boolean(false) := eval((Expr)`10 != 10`, (),());

test bool testGt() = boolean(false) := eval((Expr)`10 \> 10`, (),());
test bool testGt1() = boolean(true) := eval((Expr)`4*5 \> 16`, (),());
test bool testGte() = boolean(true) := eval((Expr)`100 \>= 100`, (),());
test bool testGte1() = boolean(false) := eval((Expr)`10000 \>= 100000`, (),());

test bool testLt() = boolean(false) := eval((Expr)`10 \< 10`, (),());
test bool testLt1() = boolean(false) := eval((Expr)`5*4 \< 16`, (),());
test bool testLte() = boolean(true) := eval((Expr)`10 \<= 10`, (),());
test bool testLte1() = boolean(false) := eval((Expr)`17 \<= 10`, (),());

test bool testOr() = boolean(true) := eval((Expr)`true || false`, (),());
test bool testOr() = boolean(true) := eval((Expr)`false || true`, (),());
test bool testOr() = boolean(false) := eval((Expr)`false || false || false`, (),());
test bool testOr() = boolean(true) := eval((Expr)`true || true|| false`, (),());
test bool testAnd() = boolean(false) := eval((Expr)`true && false`, (),());
test bool testAnd() = boolean(true) := eval((Expr)`true && true`, (),());
test bool testAnd() = boolean(false) := eval((Expr)`true && false && true`, (),());
test bool testAnd() = boolean(false) := eval((Expr)`false&& false && false`, (),());


/** functions **/

// match function calls with 0 ore more expressions
Value eval((FunCall)`<FunId id><Expr* expr>`, FunEnv fenv, VarEnv venv) {
	
	return eval();

}

