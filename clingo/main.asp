% input parameters:
% - n: number of rings
% - m: The max number of time steps.

tower(a;b;c).
ring(1..n).
entity(X) :- tower(X).
entity(X) :- ring(X).

above(X,Y,T) :- on(X,Y,T).
above(X,Z,T) :- on(X,Y,T), above(Y,Z,T).

occupied(X,T) :- on(R,X,T), ring(R).
top(R,T) :- ring(R), not occupied(R,T), T=0..m.
clear(X,T) :- entity(X), not occupied(X,T), T=0..m.

% initial state
on(R,R+1,0) :- ring(R), R < n.
on(n,a,0).

% goal state
:- ring(R), R < n, not on(R,R+1,m).
:- not on(n,c,m).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pre-conditions and effects of actions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ring can only be moved if nothing is on top of it
:- move(R,E,T), not top(R,T).

%% destination must be clear
:- move(R,E,T), not clear(E,T).

%% ring can be moved to empty tower
on(R,P,T+1) :- ring(R), tower(P), move(R,P,T), T=0..m-1.

%% a ring cannot be placed onto a smaller ring
:- move(R1,R2,T), ring(R1), ring(R2), R1 > R2.

%% a ring cannot be moved to be on top of itself
:- move(R,R,T), T=0..m-1.

%% no two rings can be on top of the same ring
:- on(R1,R,T), on(R2,R,T), R1 != R2, T=0..m.

%% only one ring may move at a time
:- 2 { move(R,E,T) : ring(R), entity(E) }, T=0..m-1.

%% a ring is on top of another if a move is made to be on top of one
on(R,R2,T+1) :- ring(R), ring(R2), move(R,R2,T), R < R2, T=0..m-1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% uniqueness constraints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% a ring may only be in one place at a time
:- on(R,X,T), on(R,Y,T), X != Y, T=0..m.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% law of commonsense inertia
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

on(R,P,T+1) :- on(R,P,T), not moved(R,T), T=0..m-1.
moved(R,T) :- move(R,_,T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fluents
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% actions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% move action
{ move(R,E,T) } :- ring(R), entity(E), T=0..m-1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% find the solution with the least number of moves
#minimize { 1,R,E,T : move(R,E,T) }.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% display data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#show on/3.
