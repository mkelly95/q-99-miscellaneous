
\d .sk

Indices:(!) . flip (
  ( `Rows    ; til[9],/:\:til 9                            );
  ( `Columns ; til[9],\:/:til 9                            );
  ( `Grids   ; cross[0 3 6;0 3 6] +/:\: cross[0 1 2;0 1 2] ));

GetRowIdxs:{Indices[`Rows] x 0};
GetColumnIdxs:{Indices[`Columns] x 1};
GetGridIdxs:{Indices[`Grids] sum (2#xbar[3;x]) div 1 3};                                          / Get gird coordinates where grids in top row 0,1,2, second row 3,4,5 etc.
GetNeighbours:{except[;enlist x] raze (GetGridIdxs;GetRowIdxs;GetColumnIdxs)@\:x};                / Neighbours refers to cells on same row, column or in same grid

/ Init[`:./sudoku.csv]
Init:{[f]                                                                                         / Takes file handle to csv as input
  solution:9 9#raze value Solve["J"$"," vs' read0 f];
  1_raze (enlist 15#"-"),/:3 cut " | " sv/: 3 cut/: raze each string solution
 }

Solve:{
  filled:cross[til 9;til 9]!enlist each raze x;                                                   / Initialise unfilled squares with possible values 1-9
  :Trial @[;;:;1+til 9]/[filled;where filled~\:(),0N]
 };

Trial:{
  pen:(Eliminate/) x;                                                                             / Try traditional elimination methods until we can't go any further
  if[not Check pen;:()];                                                                          / If number appears twice in any row or column then error

  if[all 1=count each pen;:pen];                                                                  / If all filled then return completed board

  l:iasc[#[;c] where 1<c:count each pen]#pen;                                                     / Sort by ascending number of possible values

  u:.z.s @[pen;first key l;:;1#first l];                                                          / Pencil in a value for the square with least number of possible values and iterate

  $[not u~();                                                                                     / () indicates penciled value was wrong
    u;
    1=count first l;                                                                              / If no possible values left for that square, a pencilled in value further up must be wrong
    ();
    .z.s @[pen;first key l;:;1_first l]                                                           / Otherwise, discard and try pencilling in another value for that square
   ]
 };

Check:{
  hasDuplicate:{(~) . (distinct;::) @\: raze i where 1=count each i:x y};                         / Check no duplicate filled in squares and that all squares have at least 1 possible value
  :(all 0<count each x) & all hasDuplicate[x] each value Indices
 };

Eliminate:{
  {y x}/[x;(EliminateNeighbours;EliminateSoleAxis;EliminateMatchingSets;EliminateAxis)]           / Apply each elimination method in turn and return reduces dictionary
 };
 
EliminateNeighbours:{
  {@[x;y;{except[z;] distinct raze v where 1=count each v:x GetNeighbours y}[x;y]]}/[x;key x]
 };

EliminateSoleAxis:{
  d:where[1<count each y#x]#x;                                                                    / Get coords of all values that aren't filled in
  d:#[;d] where 1<count each d:group where[count each d]!raze value d;                            / Return dictionary of possible values and squares they appear in
  soleaxis:?[;1b] each {all each 1_/:not differ each flip x} each d;                              / Returns whether values all lie on x/y axis. 0 for x, 1 for y, 2 for none
  d:except[;y] each ((GetRowIdxs;GetColumnIdxs;())soleaxis)@'d[;0];                               / If possible values along same axis in a 3x3 grid, remove from other squares on same x/y axis
  :enlist[()]_@[;;except;]/[x;value d;key d]
 }/[;Indices`Grids]; 

EliminateMatchingSets:{
  sets:except[y] each #[;g] where (count each key g)=count each g:group y#x;                      / Return matching sets and and coordinates of cells not in the set
  sets:where[count each sets]!raze value sets;                                                    / Ungroup to get the values to eliminate from each cell
  :@[;;except;]/[x;value sets;key sets]                                                           / Remove matching set values from other squares
 }/[;raze value Indices];

EliminateAxis:{
  {@[y;;:;(),z] ?[;1b] z in/: x}[s]/[x;] 1+where 1=sum (1+til 9) in/: s:y#x
 }/[;raze value Indices];