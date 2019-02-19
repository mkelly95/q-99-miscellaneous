\d .kt
system"S ",string `long$.z.p mod `long$.z.d; 

/ Init[8 8;0 0;1b]
Init:{[size;start;heuristic]
  if[any start>size-1;1"Start must be in range (0,0) -> ","(",("," sv string size-1),")"];
  board:(cross) . til each size;
  .kt.Moves:board!{m where (m:y +/: raze (-1 1;-2 2) cross' (-2 2;-1 1)) in x}[board] each board; / Map possible moves for each square
  .kt.Warnsdorf:count each Moves;                     
  solution:Trial[size;Moves start;enlist start;heuristic];
  $[()~solution;1"No solution possible";solution]
  };

Trial:{[s;x;y;z]
  if[prd[s]=count y;:y];                                                                          / If knight visited every square then return
  if[0=count x;:()];                                                                              / Error if tour unfinished but no available moves
  nextMove:1?$[1b~z;{where poss=min poss:x#Warnsdorf};::] x;                                      / Pick next move using Warnsdorf's Heuristic or randomly
  u:.z.s[s;first[Moves nextMove] except y;y,nextMove;z];
  
  $[not u~();
    u;                                                                                            / Return if successful
    .z.s[s;;y;z] x except nextMove                                                                / Else remove tried move from potential moves and try again
   ]
 };