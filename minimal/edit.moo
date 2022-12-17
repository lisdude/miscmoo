;add_verb(#2, {#2, "rd", "@edit"}, {"any", "any", "any"});
.program #2:@edit
"Usage: @edit <object>:<verb>";
"";
"A Minimal.db code editor. Has the following exciting features:";
" - Edit code with a local editor. Note: This uses the LambdaMOO protocol, not MCP.";
" - Prompt to create a verb if it doesn't exist.";
" - Chock full of crazy to avoid dependencies!";
if (player != this)
return E_PERM;
endif
usage_string = "Usage: @edit <object>:<verb>";
if (!args)
return notify(player, usage_string);
endif
ind = index(argstr, ":");
if (!ind)
return notify(player, usage_string);
endif
{object, vrb} = {argstr[1..ind - 1], argstr[ind + 1..$]};
"Very basic object matching:";
if (object[1] == "#")
object = toobj(object);
elseif (object[1] == "$")
object = `#0.(object[2..$]) ! ANY';
if (typeof(object) == ERR)
return notify(player, tostr("#0 doesn't define that property."));
endif
elseif (object == "me")
object = player;
elseif (object == "here")
object = player.location;
else
exact = partial = {};
for x in ({@player.contents, @`player.location.contents ! E_INVIND => {}'})
if (!valid(x))
continue;
elseif (x.name == object)
exact = {@exact, x};
elseif (index(x.name, object))
partial = {@partial, x};
endif
endfor
if ((!exact) && (!partial))
return notify(player, ("No objects matched " + object) + ".");
elseif (length(exact) == 1)
object = exact[1];
elseif ((!exact) && (length(partial) == 1))
object = partial[1];
else
notify(player, "Multiple matches were found. Which object do you want?");
count = 0;
if (exact != {})
notify(player, "-- Exact Matches --");
for x in (exact)
count = count + 1;
notify(player, tostr("[", count, "] ", x.name, " (", x, ")"));
endfor
endif
if (partial != {})
notify(player, "-- Partial Matches --");
for x in (partial)
count = count + 1;
notify(player, tostr("[", count, "] ", x.name, " (", x, ")"));
endfor
endif
choices = {@exact, @partial};
notify(player, "[Type a line of input or `@abort' to abort the command.]");
choice = read(player);
if (choice == "@abort")
return notify(player, ">> Command Aborted <<");
else
choice = toint(choice);
if ((choice <= 0) || (choice > length(choices)))
return notify(player, "Invalid selection.");
else
object = choices[choice];
endif
endif
endif
endif
vc = `verb_code(object, vrb) ! ANY';
if (typeof(vc) == ERR)
notify(player, tostr(object.name, " (", object, ") does not define that verb. Would you like to create it?"));
yn = read(player);
if (yn in {"yes", "ye", "y"})
vc = {};
perms = "rd";
notify(player, "How exciting! Arguments?");
arguments = read(player);
if (arguments == "")
arguments = {"none", "none", "none"};
elseif (arguments == "tnt")
arguments = {"this", "none", "this"};
else
arguments = explode(arguments);
endif
while (length(arguments) < 3)
arguments = {@arguments, "none"};
endwhile
if (length(arguments) != 3)
return notify(player, "Incorrect number of arguments.");
endif
if (arguments == {"this", "none", "this"})
perms = perms + "x";
endif
vi = {player, perms, vrb};
if (typeof(`add_verb(object, vi, arguments) ! ANY') == ERR)
return notify(player, "Failed to add verb.");
endif
else
return notify(player, "Not adding verb.");
endif
endif
notify(player, tostr("Editing ", object, ":", vrb, "..."));
notify(player, tostr("#$# edit name: ", object, ":", vrb, " upload: .program ", object, ":", vrb));
for x in (vc)
yin();
notify(player, x);
endfor
notify(player, ".");
.
