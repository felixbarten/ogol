module ogol::CallGraph

import ogol::Syntax;
import ogol::NameAnalysis;
import ParseTree;
import IO;

alias CallHistory = lrel[str callName, str scopeName, int cmdPos];


alias Calls = rel[str callerCmdName, str calleeCmdName, loc src, str scopeName, int varPos, int cmdPos];


Calls main(list[value] args){
	 Program p = parse(#start[Program], |project://Ogol/input/dashed_nested.ogol|).top;
	 println(p);
	 
	 return cmdsCalledInCommands("global", p.commands, []);
}

Calls cmdsCalledInCommands(str scopeName, Command* commands, CallHistory ch) =
 { *cmdsCalledInCommand(scopeName, cmd, ch) | cmd <- commands };



Calls cmdsCalledInCommandType(str scopeName,
(Command) `<Command* commands>`,
CallHistory defs)
{
 if (/FunCall f := commands) {
 	// if function
 	return cmdsCalledInFunction(scopeName, commands, defs);
 } else if (/FunDef f := commands) {
 	// function definition
	return cmdsCalledInFunction(scopeName, commands, defs);
 } else {
 	// command
 	return cmdsCalledInCommand(scopeName, commands, defs);
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


Calls cmdsCalledInFunction(str scopeName, (FunDef) `<FunId fid> <Expr* e> <Commands* commands>`, CallHistory ch){


	return cmdsCalledInCommands(scopeName, commands, cs);
}