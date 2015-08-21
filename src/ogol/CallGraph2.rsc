module ogol::CallGraph2

import ogol::Syntax;
import ParseTree;
import IO;

alias Definitions = lrel[str varName, str scopeName, int varPos];
alias Uses = rel[str cmdA, str cmdB, loc src, str scopeName, int varPos];

Uses main(list[value] args){
 Program p = parse(#start[Program], |project://Ogol/input/dashed.ogol|).top;
 println(p);
 /*
 for (cmd <- p.commands){
 
 
 }
 
 */
 
 return varsUsedInCommands("global", p.commands, []);
}


Uses varsUsedInCommands(str scopeName, Command* commands, Definitions defs) =
 { *varsUsedInCommand(scopeName, cmd, defs) | cmd <- commands };
 
 Uses varsUsedInCommand(
str scopeName,
(Command) `to <FunId fid> <VarId* args> <Command* commands> end`,
Definitions defs)
{
 innerScope = "<scopeName>/<fid>";
 int i = 0;
 for(cmd <- commands){
 
	 defs = <"<cmd>", innerScope, i> + defs;
	 i += 1;
 }
 return varsUsedInCommands(innerScope, commands, defs);
}

Uses varsUsedInCommand(str scopeName,
(Block) `[<Command* commands>]`,
Definitions defs)
= varsUsedInCommands(scopeName, commands, defs);
 
 default Uses varsUsedInCommand(
str scopeName,
Command command,
Definitions defs)
{
 uses = {};
 for(/FunDef funid := command){
	 lrel[str scopeName, int varPos] vardefs = defs["<funid>"];
	 if(size(vardefs) > 0){
		 uses += <"<funid>",
		 funid@\loc,
		 vardefs[0].scopeName,
		 vardefs[0].varPos>;
	 } else
	 uses += <"<funid>", funid@\loc, "***undefined***", -1>;
 };
 return uses;
}
 