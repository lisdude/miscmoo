"Minimal.db Bootstrap Script";
"";
"Establishes a very basic, but mildly comfortable, Minimal.db.";
"(well, at least lisdude's opinionated version of comfortable)";
"";
"- Swap #2 and #3 (making Wizard = #2 and The First Room = #3)";
"- #0:do_start_script: Process command line scripts. (Thanks Todd)";
"- #2:eval: A mostly familiar eval. Has aliases for 'me' and 'here', supports looping properly, and returns object names.";

"provide a stack trace on errors";
set_verb_code(#0, "do_start_script", {
  "callers() && raise(E_PERM);",
  "try",
  "  return eval(@args);",
  "except ex (ANY)",
  "  {line, @lines} = ex[4];",
  "  server_log(tostr(line[4], \":\", line[2], (line[4] != line[1]) ? tostr(\" (this == \", line[1], \")\") | \"\", \", line \", line[6], \":  \", ex[2]));",
  "  for line in (lines)",
  "    server_log(tostr(\"... called from \", line[4], \":\", line[2], (line[4] != line[1]) ? tostr(\" (this == \", line[1], \")\") | \"\", \", line \", line[6]));",
  "  endfor",
  "  server_log(\"(End of traceback)\");",
  "endtry"
});

"eval: Builds upon the basic Minimal.db eval with some quality of life features, such as:";
"      - Eval loops with minimal effort.";
"      - Convenient aliases for 'me' and 'here'.";
"      - Show object names when returning objects.";
set_verb_code(#2, "eval", {
  "set_task_perms(player);",
  "  eval_env = \"me=player; here=player.location;\";",
  "  program = argstr;",
  "  if (!match(program, \"^ *%(;%|%(if%|fork?%|return%|while%|try%)[^a-z0-9A-Z_]%)\"))",
  "    program = \"return \" + program + \";\";",
  "  endif",
  "  program = eval_env + program;",
  "  {code, result} = eval(program);",
  "  if (code)",
  "    if (typeof(result) == OBJ)",
  "      result = tostr(result, \" \", !valid(result) ? \"<invalid>\" | tostr(\"(\", result.name, \")\"));",
  "    else",
  "      result = toliteral(result);",
  "    endif",
  "    notify(player, tostr(\"=> \", result));",
  "  else",
  "    for line in (result)",
  "      notify(player, line);",
  "    endfor",
  "  endif"
});

"Swap Wizard (#3) and The First Room (#2) because it's what I'm used to.";
"Note the order in which this happens is important because it's initially running with #3's permissions.";
#2.name = "Wizard";
set_player_flag(#2, 1);
#2.programmer = 1;
#2.wizard = 1;
set_task_perms(#2);
move(#3, #-1);
move(#2, #3);
for x in [#0..max_object()]
  if (x.owner == #3)
      x.owner = #2;
  endif
  for y in (verbs(x))
      vi = verb_info(x, y);
      if (vi[1] == #3)
          vi[1] = #2;
          set_verb_info(x, y, vi);
      endif
  endfor
  for y in (properties(x))
      pi = property_info(x, y);
      if (pi[1] == #3)
          pi[1] = #2;
          set_property_info(x, y, pi);
      endif
  endfor
endfor
#3.wizard = 0;
#3.programmer = 0;
set_player_flag(#3, 0);
#3.name = "The First Room";
if (verb_code(#0, "do_login_command") == {"return #3;"})
  set_verb_code(#0, "do_login_command", {"return #2;"});
endif
