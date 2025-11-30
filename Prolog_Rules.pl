% ==============================================================================
%  PROLOG FAMILY KNOWLEDGE BASE
% ==============================================================================
%
%  INSTRUCTIONS:
%  1. Add your specific facts in the "FACTS" section below.
%  2. Run the queries using the "is_..." predicates (e.g., ?- is_grandson(X, Y).)
%
%  NOTE: We use "is_father", "is_sister" etc. for the rules to avoid 
%  name conflicts with the raw facts "father", "sister" etc.
% ==============================================================================

% ==============================
% SECTION 1: USER FACTS
% ==============================
% Add your data here using ANY of the 14 predicate forms.
% Examples are provided below.

mother(helena, victor).
father(dummy1, dummy2).
daughter(dummy1, dummy2).
son(dummy1, dummy2).
grandmother(dummy1, dummy2).
grandfather(dummy1, dummy2).
granddaughter(dummy1, dummy2).
grandson(dummy1, dummy2).
brother(dummy1, dummy2).
sister(dummy1, dummy2).
husband(dummy1, dummy2).
wife(chloe, victor).
aunt(dummy1, dummy2).
uncle(dummy1, dummy2).



% ==============================
% SECTION 2: CORE INFERENCE LOGIC
% ==============================
% These rules extract "Basic Truths" (Gender, Parenthood, Marriage) 
% from the mixed bag of facts above.

% --- Gender Inference ---
% Determine if someone is Male based on provided facts
gender(X, male) :- father(X, _).
gender(X, male) :- brother(X, _).
gender(X, male) :- grandson(X, _).
gender(X, male) :- uncle(X, _).
gender(X, male) :- husband(X, _).
gender(X, male) :- wife(_,X).
gender(X, male) :- son(X, _).
gender(X, male) :- grandfather(X, _).

% Determine if someone is Female based on provided facts
gender(X, female) :- mother(X, _).
gender(X, female) :- sister(X, _).
gender(X, female) :- granddaughter(X, _).
gender(X, female) :- aunt(X, _).
gender(X, female) :- wife(X, _).
gender(X, female) :- husband(_,X).
gender(X, female) :- daughter(X, _).
gender(X, female) :- grandmother(X, _).

% --- Parent Inference ---
% Determine Parent(P, C) relationship from various facts
parent(P, C) :- father(P, C).
parent(P, C) :- mother(P, C).
parent(P, C) :- son(C, P).
parent(P, C) :- daughter(C, P).
parent(A,B) :- father(A,C),brother(B,C).
parent(A,B) :- father(A,C),sister(B,C).
parent(A,B) :- mother(A,C),brother(B,C).
parent(A,B) :- mother(A,C),sister(B,C).


% Special Case: If grandfather(GP, GC), we know GP is parent of SOMEONE who is parent of GC.
% (This is a 'blind' inference, useful for checking, but can't name the middle parent)
ancestor(A, D) :- parent(A, D).
ancestor(A, D) :- parent(A, X), ancestor(X, D).

% --- Marriage Inference ---
married(X, Y) :- husband(X, Y).
married(X, Y) :- wife(Y, X).
married(X,Y) :- father(X,Z),mother(Y,Z).
% Bi-directional marriage check
spouses(X, Y) :- married(X, Y).
spouses(X, Y) :- married(Y, X).


% ==============================
%QUERY RULES
% ==============================
% These rules allow you to query relationships dynamically.
% They use the inferred primitives above to ensure consistency.

% 1. FATHER: A male parent
is_father(X, Y) :- 
    gender(X, male), 
    parent(X, Y).

% 2. MOTHER: A female parent
is_mother(X, Y) :- 
    gender(X, female), 
    parent(X, Y).

% 3. SON: A male child
is_son(X, Y) :- 
    gender(X, male), 
    parent(Y, X).

% 4. DAUGHTER: A female child
is_daughter(X, Y) :- 
    gender(X, female), 
    parent(Y, X).

% 5. HUSBAND: Male spouse
is_husband(X, Y) :- 
    gender(X, male), 
    spouses(X, Y).

% 6. WIFE: Female spouse
is_wife(X, Y) :- 
    gender(X, female), 
    spouses(X, Y).

% 7. BROTHER: Male sibling (shares at least one parent)
is_brother(X, Y) :- 
    gender(X, male), 
    parent(Z, X), 
    parent(Z, Y), 
    X \= Y.

% 8. SISTER: Female sibling (shares at least one parent)
is_sister(X, Y) :- 
    gender(X, female), 
    parent(Z, X), 
    parent(Z, Y), 
    X \= Y.

% 9. GRANDFATHER: Male parent of a parent
is_grandfather(X, Y) :- 
    gender(X, male), 
    parent(X, Z), 
    parent(Z, Y).

is_grandfather(X, Z) :- 
    gender(X, male), 
    grandfather(X, Y), 
    brother(Y, Z).

is_grandfather(X, Z) :- 
    gender(X, male), 
    grandfather(X, Y), 
    sister(Y, Z).

% 10. GRANDMOTHER: Female parent of a parent
is_grandmother(X, Y) :- 
    gender(X, female), 
    parent(X, Z), 
    parent(Z, Y).

is_grandmother(X, Z) :- 
    gender(X, female), 
    grandmother(X, Y), 
    brother(Y, Z).

is_grandmother(X, Z) :- 
    gender(X, female), 
    grandmother(X, Y), 
    sister(Y, Z).

% 11. GRANDSON: Male child of a child
is_grandson(X, Y) :- 
    gender(X, male), 
    parent(Y, Z), 
    parent(Z, X).

is_grandson(X, Z) :- 
    gender(X, male), 
    grandson(Y, Z), 
    brother(Y, X).

is_grandson(X, Z) :- 
    gender(X, male), 
    granddaughter(Y, Z), 
    sister(Y, X).

% 12. GRANDDAUGHTER: Female child of a child
is_granddaughter(X, Y) :- 
    gender(X, female), 
    parent(Y, Z), 
    parent(Z, X).

is_granddaughter(X, Z) :- 
    gender(X, female), 
    granddaughter(Y, Z), 
    sister(Y, X).

is_granddaughter(X, Z) :- 
    gender(X, female), 
    granddaughter(Y, Z), 
    brother(Y, X).

% 13. UNCLE: Brother of parent (Blood Uncle) 
% Note: This excludes 'Uncle by marriage' to keep logic simple, 
% unless we add a rule for spouses of aunts.
is_uncle(X, Y) :- 
    brother(X, Z), 
    parent(Z, Y).

is_uncle(X,Z):-
uncle(X,Y),
is_brother(Y,Z).

is_uncle(X,Z):-
uncle(X,Y),
is_sister(Y,Z).

% 14. AUNT: Sister of parent (Blood Aunt)
is_aunt(X, Y) :- 
    is_sister(X, Z), 
    parent(Z, Y).

% 15. FATHER-IN-LAW: Father of one's spouse
is_father_in_law(X, Y) :- 
    gender(X, male),      % X must be male
    spouses(Y, Z),        % Y is married to Z
    parent(X, Z).         % X is the parent of Z (the spouse)

% 16. MOTHER-IN-LAW: Mother of one's spouse
is_mother_in_law(X, Y) :- 
    gender(X, female),    % X must be female
    spouses(Y, Z),        % Y is married to Z
    parent(X, Z).         % X is the parent of Z (the spouse)