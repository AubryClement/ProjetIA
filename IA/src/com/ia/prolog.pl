:-use_module(library(plunit)).
:-use_module(library(clpfd)).

% Note: Nos coups sont positifs allant de 1 à 4 selon le type de piece. Ceux de l'ennemi sont négatifs.

% Calculs utilisés ultérieurement afin de trouver les coordonées de notre piece en position X

findLettre(X, Res):-
	X1 is X mod 4,
	X1 == 0 -> Res = 4
	; X2 is X mod 4,
	Res = X2.

isMultiple4(X1):-
	X1 == 4 ;X1 == 8 ;X1 == 12 ;X1 == 16.	
findChiffre(X, Res):-
	X1 is X / 4,
	isMultiple4(X) -> Res = X1
	; X2 is X // 4 + 1,
	Res = X2.


isCarre1(X):-
    X == 1 ;X == 2 ;X == 5 ;X == 6.
isCarre2(X):-
    X == 3 ;X == 4 ;X == 7 ;X == 8.
isCarre3(X):-
    X == 9 ;X == 10 ;X == 13 ;X == 14.
isCarre4(X):-
    X == 11 ;X == 12 ;X == 15 ;X == 16.
findCarre(X, Res):-
    isCarre1(X)-> Res = 1; isCarre2(X) -> Res = 3 ; isCarre3(X) -> Res = 9 ; isCarre4(X) -> Res = 11.

:- begin_tests(test_findCarre).
	test("test_findCarre_true", [set(Res == [1])]):-findCarre(5, Res).
	test("test_findCarre_true2", [set(Res == [9])]):-findCarre(10, Res).
	test("test_findCarre_true3", [set(Res == [11])]):-findCarre(15, Res).
	test("test_findCarre_true4", [set(Res == [3])]):-findCarre(3, Res).
	test("test_findCarre_fail", [set(Res == [])]):-findCarre(17, Res).
	test("test_findCarre_zero", [set(Res == [])]):-findCarre(0, Res).
	test("test_findCarre_negative", [set(Res == [])]):-findCarre(-1, Res).
:- end_tests(test_findCarre).

% Verification de la piece et de sa position

verifPiece(Piece):-
	Piece #\= 0,
	Piece >= -4,
	Piece =< 4.

verifPos(Position):-
	Position >= 1,
	Position =< 4.

:- begin_tests(test_verif_piece_et_position).
	test("test_piece_true", true):-verifPiece(-4).
	test("test_piece_true2", true):-verifPiece(4).
	test("test_piece_fail", fail):-verifPiece(5).
	test("test_piece_zero", fail):-verifPiece(0).
	test("test_position_true", true):-verifPos(1).
	test("test_position_true2", true):-verifPos(4).
	test("test_position_fail", fail):-verifPos(0).
	test("test_position_fail2", fail):-verifPos(5).
:- end_tests(test_verif_piece_et_position).

% Dans le quaduplet on ne doit pas avoir un pion ennemi du meme type

interdiction(_, []):-!.
interdiction(A, [0|C]):-
	interdiction(A, C).
interdiction(A, [B|C]):-
	A #\= -B,
	interdiction(A, C).

:- begin_tests(test_interdiction).
	test("test_interdiction_true", true):-interdiction(1, [16, 26, 18, 421, 2, 1]).
	test("test_interdiction_true2", true):-interdiction(42, [42]).
	test("test_interdiction_fail", fail):-interdiction(1, [0, 0, -1]).
	test("test_interdiction_vide", true):-interdiction(1, []).
:- end_tests(test_interdiction).


% On vérifie que toutes les pieces sont de types différents et sont bien compris dans les choix possibles
% Coup interdit : si l'adversaire a posé sa piece sur une case, impossible de remettre une piece de ce type sur ligne, colonne ou carré

diffType([]):-!.
diffType([0|L]):-
	diffType(L).
diffType([X|L]):-
	verifPiece(X),
	interdiction(X, L),
	diffType(L).

:- begin_tests(test_diffType).
	test("test_diffType_true", true):-diffType([1, -2, 3, 4]).
	test("test_diffType_true2", true):-diffType([1, 1, 2]).
	test("test_diffType_fail", fail):-diffType([0, 1, -1]).
	test("test_diffType_outOfBounds", fail):-diffType([-5, 0, 2, 1]).
	test("test_diffType_vide", true):-diffType([]).
:- end_tests(test_diffType).	


% Idem mais ce coup si on verifie que chaque case est bien différentes l'un de l'autre, pour les cas gagnants notamment 

interdictionAll(_, []):-!.
interdictionAll(A, [B|C]):-
	A #\= 0,
	A #\= abs(B),
	interdictionAll(A, C).

:- begin_tests(test_interdictionAll).
	test("test_interdictionAll_true2", true):-interdictionAll(42, [34]).
	test("test_interdictionAll_fail", fail):-interdictionAll(1, [0, 0, -1]).
	test("test_interdictionAll_fail2", fail):-interdictionAll(1, [16, 26, 18, 421, 2, 1]).
	test("test_interdictionAll_vide", true):-interdictionAll(1, []).
:- end_tests(test_interdictionAll).


% On vérifie que toutes les pieces sont de types différents et sont bien compris dans les choix possibles
% Coup interdit : si l'adversaire a posé sa piece sur une case, impossible de remettre une piece de ce type sur ligne, colonne ou carré

diffTypeAll([]):-!.
diffTypeAll([0|L]):-
	diffTypeAll(L).
diffTypeAll([X|L]):-
	verifPiece(X),
	interdictionAll(X, L),
	diffTypeAll(L).

:- begin_tests(test_diffTypeAll).
	test("test_diffTypeAll_true", true):-diffTypeAll([1, -2, 3, 4]).
	test("test_diffTypeAll_fail", fail):-diffTypeAll([0, 1, -1]).
	test("test_diffTypeAll_fail2", fail):-diffTypeAll([1, 1, 2]).
	test("test_diffTypeAll_outOfBounds", fail):-diffTypeAll([-5, 0, 2, 1]).
	test("test_diffTypeAll_vide", true):-diffTypeAll([]).
:- end_tests(test_diffTypeAll).	

% On vérifie maintenant chaque cas où l'on peut gagner, quand toutes les pieces sont placées et de types différents

isPos(Pos, Case, VarPos, Var, Res):-
	Case == Pos -> Res = VarPos; Res = Var.

recupLigne(X, Pos, Grille, Res):-
	findChiffre(Pos, PosChiffre),
	
	Case is (PosChiffre-1)*4 + 1,
	nth1(Case, Grille, A),
	Case1 is Case+1,
	nth1(Case1, Grille, B),
	Case2 is Case1+1,
	nth1(Case2, Grille, C),
	Case3 is Case2+1,
	nth1(Case3, Grille, D),
	
	isPos(Pos, Case, X, A, A1),
	isPos(Pos, Case1, X, B, B1),
	isPos(Pos, Case2, X, C, C1),
	isPos(Pos, Case3, X, D, D1),
	Res = [A1, B1, C1, D1].

recupColonne(X, Pos, Grille, Res):-
	findLettre(Pos, Case),
	
	nth1(Case, Grille, A),
	Case1 is Case+4,
	nth1(Case1, Grille, B),
	Case2 is Case1+4,
	nth1(Case2, Grille, C),
	Case3 is Case2+4,
	nth1(Case3, Grille, D),
	
	isPos(Pos, Case, X, A, A1),
	isPos(Pos, Case1, X, B, B1),
	isPos(Pos, Case2, X, C, C1),
	isPos(Pos, Case3, X, D, D1),
	Res = [A1, B1, C1, D1].

recupCarre(X, Pos, Grille, Res):-
	findCarre(Pos, Case),
	
	nth1(Case, Grille, A),
	Case1 is Case+1,
	nth1(Case1, Grille, B),
	Case2 is Case+4,
	nth1(Case2, Grille, C),
	Case3 is Case+5,
	nth1(Case3, Grille, D),
	
	isPos(Pos, Case, X, A, A1),
	isPos(Pos, Case1, X, B, B1),
	isPos(Pos, Case2, X, C, C1),
	isPos(Pos, Case3, X, D, D1),
	Res = [A1, B1, C1, D1].

coupGagnant([A, B, C, D]):-
	writeln([A, B, C, D]),
	A #\= 0,
	B #\= 0,
	C #\= 0,
	D #\= 0,
	diffTypeAll([A, B, C, D]).

verifGagneLigne(X, Pos, Grille):-
	recupLigne(X, Pos, Grille, Ligne),
	coupGagnant(Ligne).

verifGagneColonne(X, Pos, Grille):-
	recupColonne(X, Pos, Grille, Colonne),
	coupGagnant(Colonne).

verifGagneCarre(X, Pos, Grille):-
	recupCarre(X, Pos, Grille, Carre),
	coupGagnant(Carre).

coupGagnant(X, Pos, Grille):-
	verifGagneLigne(X, Pos, Grille)
	;verifGagneColonne(X, Pos, Grille)
	;verifGagneCarre(X, Pos, Grille).


:- begin_tests(test_coupGagnant).
	test("test_coupGagnant_true", [nondet,true]):-coupGagnant([1, -2, 3, -4]).
	test("test_coupGagnant_true2", [nondet,true]):-coupGagnant([1, 2, 3, 4]).
	test("test_coupGagnant_true3", [nondet,true]):-coupGagnant([-4, -2, -1, -3]).
	test("test_coupGagnant_fail", fail):-coupGagnant([0, -1, 2, -3]).
	test("test_coupGagnant_fail2", fail):-coupGagnant([1, 1, 2, -4]).
	test("test_coupGagnant_ouOfBounds", fail):-coupGagnant([-6, 2, 1, 5]).
:- end_tests(test_coupGagnant).	

:- begin_tests(test_coupGagnantGrille).
	test("test_coupGagnant_true", [nondet, true]):-coupGagnant(1, 7, [0, 0, 0, 0, 3, 4, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0]).	
	test("test_coupGagnant_fail", fail):-coupGagnant(1, 7, [0, 0, 0, 0, 0, 4, 0, 2, 3, 0, 0, 0, 0, 0, 0, 0]).	
:- end_tests(test_coupGagnantGrille).	


% Dans le cas où l'on pose une pièce offrant la victoire à l'adversaire
% On va considérer ça comme un coup mauvais
% Dans le cas où notre pion serait posé

coupMauvais([0, B, C, D]):-
	B #\= 0,
	C #\= 0,
	D #\= 0,
	diffType([B, C, D]).
coupMauvais([A, 0, C, D]):-
	A #\= 0,
	C #\= 0,
	D #\= 0,
	diffType([A, C, D]).
coupMauvais([A, B, 0, D]):-
	diffType([A, B, D]),
	A #\= 0,
	B #\= 0,
	D #\= 0.
coupMauvais([A, B, C, 0]):-
	A #\= 0,
	B #\= 0,
	C #\= 0,
	diffType([A, B, C]).

verifMauvaisLigne(X, Pos, Grille):-
	recupLigne(X, Pos, Grille, Ligne),
	coupMauvais(Ligne).

verifMauvaisColonne(X, Pos, Grille):-
	recupColonne(X, Pos, Grille, Colonne),
	coupMauvais(Colonne).

verifMauvaisCarre(X, Pos, Grille):-
	recupCarre(X, Pos,Grille, Carre),
	coupMauvais(Carre).

coupMauvais(X, Pos, Grille):-
	verifMauvaisLigne(X, Pos, Grille)
	;verifMauvaisColonne(X, Pos, Grille)
	;verifMauvaisCarre(X, Pos, Grille).

:- begin_tests(test_coupMauvais).
	test("test_coupMauvais_true", [nondet,true]):-coupMauvais([0, -2, 3, -4]).
	test("test_coupMauvais_true2", [nondet,true]):-coupMauvais([1, 2, 0, 4]).
	test("test_coupMauvais_true3", [nondet,true]):-coupMauvais([-4, 0, -1, -3]).
	test("test_coupMauvais_fail", fail):-coupMauvais([0, 0, 0, 0]).
	test("test_coupMauvais_ouOfBounds", fail):-coupMauvais([-5, 2, 1, 5]).
:- end_tests(test_coupMauvais).	

:- begin_tests(test_coupMauvaisGrille).
	test("test_coupMauvais_true_grille",[nondet,true]):-coupMauvais(2, 2, [0, 0, 3, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]).
	test("test_coupMauvais_false_grille", fail):-coupMauvais(1, 1, [0, 1, 3, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]).
:- end_tests(test_coupMauvaisGrille).	

% Verification des coups impossible à partir des pièces deja presentes sur la grille, en fonction des lignes, des colonnes, et des carrés

verifPosInterditeLigne(X, NewPos, Grille):-
	recupLigne(X, NewPos, Grille, Ligne),
	diffType(Ligne).

verifPosInterditeColonne(X, NewPos, Grille):-
	recupColonne(X, NewPos, Grille, Colonne),
	diffType(Colonne).

verifPosInterditeCarre(X, NewPos, Grille):-
	recupCarre(X, NewPos, Grille, Carre),
	diffType(Carre).


:- begin_tests(test_posLigne).
	test("test_posLigne_true", true):-
		verifPosInterditeLigne(3, 10, [0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 2, 1, 0, 0, 0, 0]).
	test("test_posLigne_true2", true):-
		verifPosInterditeLigne(3, 7, [0, 0, 0, 0, 1, -2, 0, -4, 0, 0, 0, 0, 0, 0, 0, 0]).
	test("test_posLigne_fail", fail):-verifPosInterditeLigne(1, 7, [0, 0, 0, 0, -1, 2, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0]).
:- end_tests(test_posLigne).

:- begin_tests(test_posColonne).
	test("test_posColonne_true", true):-
		verifPosInterditeColonne(2, 10, [0, 4, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0]).
	test("test_posColonne_true2", true):-
		verifPosInterditeColonne(-2, 7, [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, -4, 0]).
	test("test_posColonne_fail", fail):-verifPosInterditeColonne(-1, 3, [0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 3, 0]).
:- end_tests(test_posColonne).

:- begin_tests(test_posCarre).
	test("test_posCarre_zero", [nondet,true]):-
		verifPosInterditeCarre(1, 7, [ 0, 0, 0, 0,
									0, 0, 0, 0, 
									0, 0, 0, 0,
									0, 0, 0, 0]).
	test("test_posCarre_true", [nondet,true]):-
		verifPosInterditeCarre(2, 10, [0, 0, 0, 0,
									 0, 0, 0, 0, 
									 1, 0, 0, 0,
									 4, 3, 0, 0]).
	test("test_posCarre_true2", [nondet, true]):-verifPosInterditeCarre(-4, 7, [0, 0, -2, -1, 0, 0, 0, -3, 0, 0, 0, 0, 0, 0, 0, 0]).
	test("test_posCarre_fail", fail):-verifPosInterditeCarre(-3, 7, [0, 0, -1, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0]).
:- end_tests(test_posCarre).	

verifPosInterdite(X, Pos, Grille):-
	verifPosInterditeLigne(X, Pos, Grille),
	verifPosInterditeColonne(X, Pos, Grille),
	verifPosInterditeCarre(X, Pos, Grille).

:- begin_tests(test_posInterdite).
	test("test_posInterdite_true", [nondet,true]):-
		verifPosInterdite(-4, 2, [3, 0, 0, 0,
							  2, 1, 0, 0,
							  0, 0, 0, 4, 
							  0, 3, 0, 0]).
	test("test_posInterdite_true2", [nondet,true]):-verifPosInterdite(1, 1, [0, 0, 1, 4,
																		  0, 0, 3, -3, 
																		  0, 0, 0, 0,	
																		  0, 0, 4, 0]).
	test("test_posInterdite_outOfBounds", fail):-verifPosInterdite(4, 17, [0, 0, 1, 2, 0, 0, -3, 1, 0, 0, 2, 3, 4, 0, 0, 0]).
:- end_tests(test_posInterdite).

% On place maintenant les pièces sur la grille de jeu

placerPiece(X, Pos, Grille):-
	verifPiece(X),
	findLettre(Pos, PosLettre),
	findChiffre(Pos, PosChiffre),
	verifPos(PosLettre),
	verifPos(PosChiffre),
	verifPosInterdite(X, Pos, Grille),
	nth1(Pos, Grille, 0).

:- begin_tests(test_placerPiece).
	test("test_placerPiece_true", [nondet,true]):-
		placerPiece(3, 1, [ 0, 0, 1, 0,
							0, 0, 0, 2,
							0, 0, 0, 0,
							0, 0, 4, 4]).
	test("test_placerPiece_failPiece", fail):-placerPiece(0, 7, [0, 0, 1, 1, 0, 0, 2, 2, 0, 0, 3, 3, 0, 0, 4, 4]).
	test("test_placerPiece_failPos", fail):-placerPiece(1, 1, [2, 0, 1, 1, 0, 0, 2, 2, 0, 0, 3, 3, 0, 0, 4, 4]).
:- end_tests(test_placerPiece).	




% Main

quantik(PiecesDispo, Case, Grille, NewPiece, NewLettre, NewChiffre, TypeCoup):-
	quantik(PiecesDispo, Case, Grille, PiecesDispo,  NewPiece, NewLettre, NewChiffre, TypeCoup).

quantik(_Pieces, 17, _Grille, _PiecesDispo, _NewPiece, _NewLettre, _NewChiffre, _TypeCoup):-!.
quantik([], Case, Grille, PiecesDispo, NewPiece, NewLettre, NewChiffre, TypeCoup):-
	NewCase is Case+1,
	quantik(PiecesDispo, NewCase, Grille, PiecesDispo, NewPiece, NewLettre, NewChiffre, TypeCoup).
quantik([Piece|Pieces], Case, Grille, PiecesDispo, NewPiece, NewLettre, NewChiffre, TypeCoup):- 
	placerPiece(Piece, Case, Grille) 
		-> quantikVerifCoupGagnant([Piece|Pieces], Case, Grille, PiecesDispo, NewPiece, NewLettre, NewChiffre, TypeCoup) 
		;quantik(Pieces, Case, Grille, PiecesDispo, NewPiece, NewLettre, NewChiffre, TypeCoup) .

% Si la piece correspond à un coup gagnant on envoie la reponse

quantikVerifCoupGagnant([Piece|Pieces], Case, Grille, PiecesDispo, NewPiece, NewLettre, NewChiffre, TypeCoup):-
	coupGagnant(Piece, Case, Grille)
		-> sendReponse(Piece, Case, 2)
		; quantikVerifCoupMauvais([Piece|Pieces], Case, Grille, PiecesDispo, NewPiece, NewLettre, NewChiffre, TypeCoup).

%On retire tous les coups qui sont mauvais

quantikVerifCoupMauvais([Piece|Pieces], Case, Grille, PiecesDispo, NewPiece, NewLettre, NewChiffre, TypeCoup):-
	\+ coupMauvais(Piece, Case, Grille)
	-> addTableauPoids([Piece|Pieces], Case, Grille, PiecesDispo, NewPiece, NewLettre, NewChiffre, TypeCoup)
	 	;print("Coup mauvais sur la case "), 
		print(Case),
		print(" avec la piece "),
		writeln(Piece),
		quantik(Pieces, Case, Grille, PiecesDispo, NewPiece, NewLettre, NewChiffre, TypeCoup).

% On envoie la réponse avec le type de coup, avec comme référence le barème ci dessous
% Continuer 1, Gagner 2, Perdu 4

sendReponse(Piece, Case, _TypeCoup):-
	print("Send Reponse sur la case "), 
	print(Case),
	writeln(" avec la piece "),
	print(Piece),
	findLettre(Case, _Lettre),
	findChiffre(Case, _Chiffre).
	%appeler quantik avec les param Lettre et Chiffre.

% Tableau dans lequel tous les coups qui ne sont ni gagnants ni mauvais sont stockés 

addTableauPoids([Piece|Pieces], Case, Grille, PiecesDispo, NewPiece, NewLettre, NewChiffre, TypeCoup):-
	print("Ajout Poids sur la case "), 
	print(Case),
	print(" avec la piece "),
	writeln(Piece),
	quantik(Pieces, Case, Grille, PiecesDispo, NewPiece, NewLettre, NewChiffre, TypeCoup).
		

maxList([],0):-!.
maxList([X|L], Res):-
	maxList(L, Var),
	Res is max(Var, X).


% Description algo (si fatigue)
%
%Si coupGagnant -> on envoie la réponse
%   Sinon
%       Si coupMauvais -> on passe à la piece suivante
%          Sinon
%              Calcul des poids (à voir...) -> affecter un poids à une position X piece et placer ca dans un tableau
%    
% Une fois toutes les pieces effectuées sur toutes les cases, si pas de coupGagnant -> prendre Max du tableau des poids -> Si tableau poids vide prendre un coupMauvais (on s'en fou duquel)

% (1,[4, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 4], [1,2,3])
%
% 	[4, 0, 1, 0, 
%	 0, 0, 0, 2,
%	 0, 0, 0, 3,
%	 0, 0, 0, 4]