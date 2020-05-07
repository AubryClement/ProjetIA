:-use_module(library(plunit)).
:-use_module(library(clpfd)).

% Note: Nos coups sont positifs allant de 1 à 4 selon le type de piece. Ceux de l'ennemi sont négatifs.

verifPiece(Piece):-
	Piece >= -4,
	Piece =< 4.

verifPos(Position):-
	Position >= 1,
	Position =< 4.

:- begin_tests(test_verif_piece_et_position).
	test("test_piece_true", true):-verifPiece(-4), verifPiece(4).
	test("test_piece_fail", fail):-verifPiece(5).
	test("test_position_true", true):-verifPos(1), verifPos(4).
	test("test_position_fail", fail):-verifPos(0).
	test("test_position_fail2", fail):-verifPos(5).
:- end_tests(test_verif_piece_et_position).

% Dans le quaduplet on ne doit pas avoir un pion ennemi du meme type

interdiction(_, []):-!.
interdiction(0, _):-!.
interdiction(A, [B|C]):-
	A #\= -B,
	interdiction(A, C).

:- begin_tests(test_interdiction).
	test("test_interdiction_true", true):-interdiction(1, [16, 26, 18, 421, 2, 1]), interdiction(42, [42]).
	test("test_interdiction_fail", fail):-interdiction(1, [0, 0, -1]).
	test("test_interdiction_vide", true):-interdiction(1, []).
:- end_tests(test_interdiction).

% Coup interdit : si l'adversaire a posé sa piece sur une case, impossible de remettre une piece de ce type sur ligne, colonne ou carré

coupInterdit([]):-!.
coupInterdit([X|L]):-
	verifPiece(X),
	interdiction(X, L),
	coupInterdit(L).

:- begin_tests(test_coupInterdit).
	test("test_coupInterdit_true", true):-coupInterdit([1, -2, 3, 4]).
	test("test_coupInterdit_fail", fail):-coupInterdit([0, 1, -1]).
	test("test_coupInterdit_outOfBounds", fail):-coupInterdit([-5, 0, 0, 2, 1]).
	test("test_coupInterdit_vide", true):-coupInterdit([]).
:- end_tests(test_coupInterdit).	

% On vérifie que la pièce choisie n'a pas déjà été posée par l'adversaire

verifListe(_, []):-!.
verifListe(A, [B|C]):-
	A #\= -B,
	verifListe(A, C).

:- begin_tests(test_interdiction).
	test("test_interdiction_true", true):-interdiction(1, [16, 26, 18, 421, 2, 1]), interdiction(42, [42]).
	test("test_interdiction_fail", fail):-interdiction(1, [0, 0, -1]).
	test("test_interdiction_vide", true):-interdiction(1, []).
:- end_tests(test_interdiction).

% On vérifie que toutes les pieces sont de types différents et sont bien compris dans les choix possibles

diffType([]):-!.
diffType([X|L]):-
	verifPiece(X),
	verifListe(X, L),
	diffType(L).

% Vérification de la grille, par ligne, colonne, et carré

verificationGrille([A1, B1, C1, D1, A2, B2, C2, D2, A3, B3, C3, D3, A4, B4, C4, D4]):-
	
	diffType([A1, B1, C1, D1]),
	diffType([A2, B2, C2, D2]),
	diffType([A3, B3, C3, D3]),
	diffType([A4, B4, C4, D4]),

	diffType([A1, A2, A3, A4]),
	diffType([B1, B2, B3, B4]),
	diffType([C1, C2, C3, C4]),
	diffType([D1, D2, C3, D4]),

	diffType([A1, B1, A2, B2]),
	diffType([A3, B3, A4, B4]),
	diffType([C1, D1, C2, D2]),
	diffType([C3, D3, C4, D4]).

% On vérifie maintenant chaque cas où l'on peut gagner, quand toutes les pieces sont placées et de types différentes

coupGagnant([A, B, C, D]):-
	A #\= 0,
	B #\= 0,
	C #\= 0,
	D #\= 0,
	diffType([A, B, C, D]).
	
	% Ligne
coupGagnant([A1, B1, C1, D1, _, _, _, _, _, _, _, _, _, _, _, _]):- coupGagnant([A1, B1, C1, D1]).
coupGagnant([_, _, _, _, A2, B2, C2, D2, _, _, _, _, _, _, _, _]):- coupGagnant([A2, B2, C2, D2]).
coupGagnant([_, _, _, _, _, _, _, _, A3, B3, C3, D3, _, _, _, _]):- coupGagnant([A3, B3, C3, D3]).
coupGagnant([_, _, _, _, _, _, _, _, _, _, _, _, A4, B4, C4, D4]):- coupGagnant([A4, B4, C4, D4]).

	% Colonne
coupGagnant([A1, _, _, _, A2, _, _, _, A3, _, _, _, A4, _, _, _]):- coupGagnant([A1, A2, A3, A4]).
coupGagnant([_, B1, _, _, _, B2, _, _, _, B3, _, _, _, B4, _, _]):- coupGagnant([B1, B2, B3, B4]).
coupGagnant([_, _, C1, _, _, _, C2, _, _, _, C3, _, _, _, C4, _]):- coupGagnant([C1, C2, C3, C4]).
coupGagnant([_, _, _, D1, _, _, _, D2, _, _, _, D3, _, _, _, D4]):- coupGagnant([D1, D2, D3, D4]).

	% Carré
coupGagnant([A1, B1, _, _, A2, B2, _, _, _, _, _, _, _, _, _, _]):- coupGagnant([A1, B1, A2, B2]).
coupGagnant([_, _, _, _, _, _, _, _, A3, B3, _, _, A4, B4, _, _]):- coupGagnant([A3, B3, A4, B4]).
coupGagnant([_, _, C1, D1, _, _, C2, D2, _, _, _, _, _, _, _, _]):- coupGagnant([C1, D1, C2, D2]).
coupGagnant([_, _, _, _, _, _, _, _, _, _, C3, D3, _, _, C4, D4]):- coupGagnant([C3, D3, C4, D4]).

% Dans le cas où l'on pose une pièce offrant la victoire à l'adversaire
% On va considérer ça comme un coup mauvais
% Dans le cas où notre pion serait posé

coupMauvais([0, B, C, D]):- diffType([0, B, C, D]).
coupMauvais([A, 0, C, D]):- diffType([A, 0, C, D]).
coupMauvais([A, B, 0, D]):- diffType([A, B, 0, D]).
coupMauvais([A, B, C, 0]):- diffType([A, B, C, 0]).

	% Ligne
coupMauvais([A1, B1, C1, D1, _, _, _, _, _, _, _, _, _, _, _, _]):- coupMauvais([A1, B1, C1, D1]).
coupMauvais([_, _, _, _, A2, B2, C2, D2, _, _, _, _, _, _, _, _]):- coupMauvais([A2, B2, C2, D2]).
coupMauvais([_, _, _, _, _, _, _, _, A3, B3, C3, D3, _, _, _, _]):- coupMauvais([A3, B3, C3, D3]).
coupMauvais([_, _, _, _, _, _, _, _, _, _, _, _, A4, B4, C4, D4]):- coupMauvais([A4, B4, C4, D4]).

	% Colonne
coupMauvais([A1, _, _, _, A2, _, _, _, A3, _, _, _, A4, _, _, _]):- coupMauvais([A1, A2, A3, A4]).
coupMauvais([_, B1, _, _, _, B2, _, _, _, B3, _, _, _, B4, _, _]):- coupMauvais([B1, B2, B3, B4]).
coupMauvais([_, _, C1, _, _, _, C2, _, _, _, C3, _, _, _, C4, _]):- coupMauvais([C1, C2, C3, C4]).
coupMauvais([_, _, _, D1, _, _, _, D2, _, _, _, D3, _, _, _, D4]):- coupMauvais([D1, D2, D3, D4]).

	% Carré
coupMauvais([A1, B1, _, _, A2, B2, _, _, _, _, _, _, _, _, _, _]):- coupMauvais([A1, B1, A2, B2]).
coupMauvais([_, _, _, _, _, _, _, _, A3, B3, _, _, A4, B4, _, _]):- coupMauvais([A3, B3, A4, B4]).
coupMauvais([_, _, C1, D1, _, _, C2, D2, _, _, _, _, _, _, _, _]):- coupMauvais([C1, D1, C2, D2]).
coupMauvais([_, _, _, _, _, _, _, _, _, _, C3, D3, _, _, C4, D4]):- coupMauvais([C3, D3, C4, D4]).


% Verification des coups impossible à partir des pièces deja presentes sur la grille

verifPosInterditeLigne(NewPos, PosLettre, Grille):-
	Case is NewPos - (PosLettre-1),
	nth1(Case, Grille, A),
	nth1(Case+1, Grille, B),
	nth1(Case+2, Grille, C),
	nth1(Case+3, Grille, D),
	coupInterdit([A, B, C, D]).

verifPosInterditeColonne(NewPos, PosChiffre, Grille):-
	Case is NewPos - 4*(PosChiffre-1),
	nth1(Case, Grille, A),
	nth1(Case+4, Grille, B),
	nth1(Case+8, Grille, C),
	nth1(Case+12, Grille, D),
	coupInterdit([A, B, C, D]).

isCarre1(X):-
    X == 1 ;X == 2 ;X == 5 ;X == 6.
isCarre2(X):-
    X == 3 ;X == 4 ;X == 7 ;X == 8.
isCarre3(X):-
    X == 9 ;X == 10 ;X == 13 ;X == 14.
isCarre4(X):-
    X == 11 ;X == 12 ;X == 15 ;X == 16.
findCarre(X,Res):-
    isCarre1(X)-> Res = 1; isCarre2(X) -> Res = 3 ; isCarre3(X) -> Res = 9 ; isCarre4(X) -> Res = 11.

verifPosInterditeCarre(NewPos, Grille):-
	findCarre(NewPos, Case),
	nth1(Case, Grille, A),
	nth1(Case+1, Grille, B),
	nth1(Case+4, Grille, C),
	nth1(Case+5, Grille, D),
	coupInterdit([A, B, C, D]).

verifPosInterdite(PosLettre, PosChiffre, Grille):-
	NewPos is PosLettre + (PosChiffre-1)*4,
	verifPosInterditeLigne(NewPos, PosLettre, Grille),
	verifPosInterditeColonne(NewPos, PosChiffre, Grille),
	verifPosInterditeCarre(NewPos, Grille).


% On place maintenant les pièces sur la grille de jeu

placerPiece(X, PosLettre, PosChiffre, Grille, NewGrille):-
	X #\= 0,
	verifPiece(X),
	verifPos(PosLettre),
	verifPos(PosChiffre),
	NewPos is PosLettre + (PosChiffre-1)*4,
	verifPosInterdite(PosLettre, PosChiffre, Grille),
	nth1(NewPos, Grille, 0),
	nth1(NewPos, NewGrille, X, Grille).

% Continuer 1, Gagner 2, Nul 3, Perdu 4

