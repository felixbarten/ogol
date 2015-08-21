module ogol::CallGraph4

import analysis::graphs::Graph;
import ogol::Syntax;
import ParseTree;
import IO;

alias Definitions = lrel[str varName, str scopeName, int varPos];
alias Uses = rel[str funcA, str funcB, loc src, str scopeName, int varPos];
alias CallGraph = rel[str funcA, str funcB, loc src, str Scope];
alias Call = lrel[str from, str to];
//alias graph[str] = rel[str from, str to];

CallGraph main(list[value] args){
 Program p = parse(#start[Program], |project://Ogol/input/dashed.ogol|).top;
 //println(p);
 return varsUsedInCommands("global", p.commands, [], []);
}


CallGraph varsUsedInCommands(str scopeName, Command* commands, Definitions defs, Call calls) =
 { *varsUsedInCommand(scopeName, cmd, defs, calls) | cmd <- commands };
 
 
 /* gathers commands from functions */
 CallGraph varsUsedInCommand(
str scopeName,
(Command) `to <FunId fid> <VarId* args> <Command* commands> end`,
Definitions defs, Call calls)
{
callgraph = {};
println(calls);
 funccalls = calls;

 innerScope = "<scopeName>/<fid>";
 int i = 0;

 for(c <-commands){ 	 
 		funccalls = funccalls + <"<fid>", "<c>">;
	 	callgraph = <"<fid>", "<c>",c@\loc, "<innerScope>"> + callgraph;
 }
 
 println("Calls in FunDef: <funccalls>");

 println("Callgraph: <callgraph>");
 
 //Graph(callgraph);
//render(calls);
 return varsUsedInCommands(innerScope, commands, defs, funccalls);
}

// catch blocks
CallGraph varsUsedInCommand(str scopeName,
(Block) `[<Command* commands>]`,
Definitions defs, Call calls)
= varsUsedInCommands(scopeName, commands, defs, calls);


// catch funcalls
CallGraph varsUsedInCommand(str scopeName,
(Command) `<FunCall c>`,
Definitions defs, Call calls) {

println();

callgraph = {};
funccalls = calls;
println("Before selection: <funccalls>");
// calls is empty after a set is returned in the default method.
//calls = calls["<c.id>"];

for( <from, to> <- funccalls){
	println("from: <from>");
}

callgraph += funccalls;
println("In FunCall: <c.id>");
println(funccalls);
println(callgraph);

return {};
//= varsUsedInCommands(scopeName, commands, defs, calls);

}
 
 
 // default function
default CallGraph varsUsedInCommand(
str scopeName,
Command command,
Definitions defs, Call calls)
{
 /*
 println("in default command");
 println(command);
 println(calls);
 */
 uses = {};
 callgraph = {};
 calls = calls;
 
 
 for(/FunDef varid := command){
	 lrel[str scopeName, int varPos] vardefs = defs["<varid>"];
	 lrel[str from, str to] funcdefs = calls["<varid.id>"];
	 
	// lrel[str from, str to] funcdefs = defs["<varid.id>"];
	 for (/Command c := varid){
	 	////////////
	 	callgraph += <"<varid.id>", "<c>", c@\loc, scopeName>;
	 }
	 println("CALLGRAPH: <callgraph>");
	 	 
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
	 	callgraph = <"<varid.id>", "<c>",c@\loc, scopeName, calls> + callgraph;
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
 return callgraph;
}
 