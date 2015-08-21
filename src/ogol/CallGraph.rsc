module ogol::CallGraph

import ogol::Syntax;
import ogol::NameAnalysis;
import ParseTree;
import IO;

alias FunEnv = map[FunId id, FunDef def];
alias CallHistory = lrel[str callName, str scopeName, int cmdPos];
alias Calls = rel[str callerCmdName, str calleeCmdName, loc src, str scopeName, int varPos, int cmdPos];
alias FunCommands = rel[str callerFunc, list[Calls] calls];


FunEnv collectFunDefs(Program p)
 = (f.id : f | /FunDef f := p);
 
FunCommands collectFuncCmds(Program p) {
 	FunEnv funcs = (f.id : f | /FunDef f := p);
 	FunCommands fcmds;
 	for (f <- funcs){
 		for (/Command* c := f){
 		fmcds += cmdsCalledInCommands("", 
 	}
 	
 	return rel[
}

Calls main(list[value] args){
	 Program p = parse(#start[Program], |project://Ogol/input/dashed_nested.ogol|).top;
	 println(p);
	
	FunCommands fenv = collectFuncCmds(p);
	 
	 return cmdsCalledInCommands("global", p.commands, []);
}

Calls cmdsCalledInCommands(str scopeName, Command* commands, CallHistory ch) =
 { *cmdsCalledInCommandType(scopeName, cmd, ch) | cmd <- commands };



Calls cmdsCalledInCommandType(str scopeName,
(Command) `<Command cmd>`,
CallHistory defs)
{
 println("Checking command type!" + cmd);

 if (/FunCall f := cmd) {
 	// if function
 	println("Its A function call!");
 	return cmdsCalledInFunctionCall(scopeName, f, defs);
 } else if (/FunDef f := cmd) {
 	// function definition
 	 	println("Its A function definition!");
	return cmdsCalledInFunctionDef(scopeName, cmd, defs);
 } else {
 	// command
 	 	println("Its A Command!");
 	return cmdsCalledInCommand(scopeName, cmd, defs);
 }
}

Calls cmdsCalledInCommand(str scopeName,
(Command) `<Command* commands>`,
CallHistory defs)
{
 innerScope = "<scopeName>/<fid>";
 int i = 0;
 for(arg <- args){
	 defs = <"<arg>", innerScope, i> + defs;
	 i += 1;
 }
 return cmdsCalledInCommands(innerScope, commands, defs);
}


Calls cmdsCalledInFunctionDef(str scopeName, (FunDef) `to" <FunId id> <VarId* vars> <Command* commands> end`, CallHistory ch){

	
	if (size(commands) > 0) {
		calls = cmdsCalledInCommands(scopeName, commands, ch);
		println(calls);
	}



	return cmdsCalledInCommands(scopeName, commands, ch);
}

Calls cmdsCalledInFunctionCall(str scopeName, (FunCall) `<FunId fid> <Expr* e>;`, CallHistory ch){



	return cmdsCalledInCommands(scopeName, cmd, ch);
}

/*
rel[str, list[Calls]] cmdsInFunctionDef(str name, (FunDef) `to" <FunId id> <VarId* vars> <Command* commands> end`){

	// list[Calls] = cmdsCalledInCommands("",commands, "");


	return rel[id, calls];
}

*/