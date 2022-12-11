add_verb(#2, {#2, "rd", "@fulldump"}, {"none", "none", "none"});
.program #2:@fulldump
builtins = {"name", "location", "owner", "r", "w", "f", "programmer", "wizard", "contents", "last_move", "a"};
for x in [#0..max_object()]
  if (!valid(x))
    notify(player, tostr(x, " <<invalid>>"));
    continue;
  endif
  notify(player, tostr(x.name, " (", x, ")"));
  notify(player, tostr(" Bits: ", is_player(x) ? "player " | "", x.programmer ? "programmer " | "", x.wizard ? "wizard " | ""));
  for y in (builtins)
    notify(player, tostr("  .", y, " => ", toliteral(x.(y))));
  endfor
  for y in (verbs(x))
    notify(player, tostr("  :", y, " ", toliteral(verb_info(x, y))));
  endfor
  for y in (properties(x))
    notify(player, tostr("  .", y, " ", toliteral(property_info(x, y))));
  endfor
endfor
.
