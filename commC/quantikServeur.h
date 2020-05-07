#ifndef QUANTIK_JOUEUR_H
#define QUANTIK_JOUEUR_H

#include "fonctionsTCP.h"
#include "protocolQuantik.h"
#include "validation.h"

typedef struct {
    int sockClient;
    struct sockaddr_in addrClient;
    char nom[T_NOM];
    TCoul couleur;
} Joueur;

void error(int sock);
int sendCoupRep(Joueur tabJoueur[2], TCodeRep code, TValCoup val,TPropCoup prop, int joueurJoue);
int sendPartieRep(Joueur tabJoueur[2], TCodeRep code, char nomAdvers[T_NOM], TValidCoul validCoul, int joueur);
int jouerUnCoup(int joueurJoue, int joueurAtt, Joueur tabJoueur[2], int nbJoueurs, int numJoueur);
#endif
