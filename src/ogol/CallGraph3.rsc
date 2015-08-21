module ogol::CallGraph3

import analysis::graphs::Graph;
import ogol::Syntax;
import ParseTree;
import IO;

alias Definitions = lrel[str varName, str scopeName, int varPos];
alias Uses = rel[str funcA, str funcB, loc src, str scopeName, int varPos];
alias CallGraph = rel[str funcA, str funcB, loc src, str Scope];
alias Call = lrel[str from, str to];
//alias graph[str] = rel[str from, str to];

Uses main(list[value] args){
 Program p = parse(#start[Program], |project://Ogol/input/dashed.ogol|).top;
 //println(p);
 return varsUsedInCommands("global", p.commands, [], []);
}


Uses varsUsedInCommands(str scopeName, Command* commands, Definitions defs, Call calls) =
 { *varsUsedInCommand(scopeName, cmd, defs, calls) | cmd <- commands };
 
 
 /* gathers commands from functions */
 Uses varsUsedInCommand(
str scopeName,
(Command) `to <FunId fid> <VarId* args> <Command* commands> end`,
Definitions defs, Call calls)
{
callgraph = {};
 calls = calls;

 innerScope = "<scopeName>/<fid>";
 int i = 0;

 for(c <-commands){ 	 
 		calls = calls + <"<fid>", "<c>">;
	 	callgraph = <"<fid>", "<c>",c@\loc, "<innerScope>"> + callgraph;
 }
 
 println("calls in fundef");
 println(calls);

 println("Callgraph:");
  println(callgraph);
 //Graph(callgraph);
//render(calls);
 return varsUsedInCommands(innerScope, commands, defs, calls);
}

// catch blocks
Uses varsUsedInCommand(str scopeName,
(Block) `[<Command* commands>]`,
Definitions defs)
= varsUsedInCommands(scopeName, commands, defs);


// catch funcalls
Uses varsUsedInCommand(str scopeName,
(Command) `<FunCall c>`,
Definitions defs, Call calls) {


println("in funcall");
uses = {};
calls = calls["<c.id>"];

uses += calls;

return uses;
//= varsUsedInCommands(scopeName, commands, defs, calls);

}
 
 
 // default function
default Uses varsUsedInCommand(
str scopeName,
Command command,
Definitions defs, Call calls)
{
 uses = {};
 callgraph = {};
 
 println("in default command");
 println(command);
 
 for(/FunDef varid := command){
	 lrel[str scopeName, int varPos] vardefs = defs["<varid>"];
	 lrel[str from, str to] funcdefs = calls["<varid.id>"];
	 
	// lrel[str from, str to] funcdefs = defs["<varid.id>"];
	 for (/Command c := varid){
	 	////////////
	 	callgraph += <"<varid.id>", "<c>", c@\loc, scopeName>;
	 }
	 println("CALLGRAPH:");
	 println(callgraph);
	 
	 /*
	 if(size(funcdefs) > 0){
		 callgraph += <"<varid.id>",
		 varid@\loc,
		 vardefs[0].scopeName,
		 vardefs[0].varPos>;
	 } else {
		 uses += <"<varid>", "", varid@\loc, "***undefined***", -1>;
		 for (/Command c := varid){
		 	println(c);
		 	callgraph = callgraph +  <"<varid.id>", "<c>",c@\loc, scopeName>;
		 	//callgraph += <"<varid.id>", "<c>",c@\loc, scopeName>;
		 }
	 }
	 */
	 
	 if(size(vardefs) > 0){
		 uses += <"<varid>",
		 varid@\loc,
		 vardefs[0].scopeName,
		 vardefs[0].varPos>;
	 } else {
		 uses += <"<varid>", "", varid@\loc, "***undefined***", -1>;
		 for (/Command c := varid){
		 	println(c);
		 	callgraph = callgraph +  <"<varid.id>", "<c>",c@\loc, scopeName>;
		 	//callgraph += <"<varid.id>", "<c>",c@\loc, scopeName>;
		 }
	 	 //println("callgraph");
	 }
	 // println(callgraph);
 }
 
 
 
 callgraph =  {};
 // loop through all function defs
 for(/FunDef varid := command){
	 lrel[str scopeName, int varPos] vardefs = calls;
 		 for (/Command c := varid){
	 	////////////
	 	callgraph = <"<varid.id>", "<c>",c@\loc, scopeName> + callgraph;
	 	vardefs +=<"<varid.id>", "<c>">;
	 	calls = <"<varid.id>", "<c>"> + calls;
	 }
 }
 /*
 println("for2");
 println(callgraph);
 println("calls");
 print(calls);
 */
 ;
 return uses;
}
 