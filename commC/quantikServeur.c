#include "quantikServeur.h"

void error(int sock){
  shutdown(sock, SHUT_RDWR);
  close(sock);
}

int sendCoupRep(Joueur tabJoueur[2], TCodeRep code, TValCoup val,TPropCoup prop, int joueur){
  TCoupRep coupValid;
  coupValid.err = code;
  coupValid.validCoup = val;
  coupValid.propCoup = prop;
  int err = send(tabJoueur[joueur].sockClient, &coupValid, sizeof(TCoupRep), 0);
  if(err <= 0){
    perror("(Serveur) erreur sur le send");
    for(int i = 0 ; i < 2 ; ++i){
      error(tabJoueur[i].sockClient);
    }
    return -1;
  }
  return 0;
}

int sendPartieRep(Joueur tabJoueur[2], TCodeRep code, char nomAdvers[T_NOM], TValidCoul validCoul, int joueur){
  TPartieRep repPartie;
  repPartie.err = code;
  strcpy(repPartie.nomAdvers, nomAdvers);
  repPartie.validCoulPion = validCoul;
  int err = send(tabJoueur[joueur].sockClient, &repPartie, sizeof(TPartieRep), 0);
  if(err <= 0){
    perror("(Serveur) erreur sur le send");
    for(int i = 0 ; i < 2 ; ++i){
      error(tabJoueur[i].sockClient);
    }
    return -1;
  }
  return 0;
}

int jouerUnCoup(int joueurJoue, int joueurAtt, Joueur tabJoueur[2], int nbJoueurs, int numJoueur){
  TCoupReq coupJoue;
  TPropCoup propCoup;
  fd_set readSet;
  struct timeval time;

  FD_ZERO(&readSet);
  FD_SET(tabJoueur[joueurJoue].sockClient, &readSet);

  time.tv_sec = 15;
  time.tv_usec = 0;

  //int err = setsockopt(tabJoueur[joueurJoue].sockClient, SOL_SOCKET, SO_RCVTIMEO, (const char*)&time, sizeof(struct timeval));

  /*int err = select(tabJoueur[joueurJoue].sockClient, &readSet, NULL, NULL, &time);
  if(err < 0){
    for(int i = 0 ; i < nbJoueurs ; ++i){
      perror("(Serveur) erreur dans le select");
      error(tabJoueur[i].sockClient);
    }
    return -1;
  }*/
  int err = 1;

  //if(FD_ISSET(tabJoueur[joueurJoue].sockClient, &readSet) > 0){
  if(err != 0){
    err = recv(tabJoueur[joueurJoue].sockClient, &coupJoue, sizeof(TCoupReq), 0);
    if(err <= 0){
      perror("(Serveur) erreur sur le recv");
      for(int i = 0 ; i < nbJoueurs ; ++i){
        error(tabJoueur[i].sockClient);
      }
      return -2;
    }
    bool valid = validationCoup(numJoueur, coupJoue, &propCoup);
    if(valid == false){
      if(coupJoue.propCoup != propCoup){
        err = sendCoupRep(tabJoueur, ERR_OK, TRICHE, GAGNE, joueurAtt);
        if(err < 0){
          return -3;
        }
        err = sendCoupRep(tabJoueur, ERR_OK, TRICHE, PERDU, joueurJoue);
        if(err < 0){
          return -4;
        }
      }else{
        err = sendCoupRep(tabJoueur, ERR_COUP, VALID, GAGNE, joueurAtt);
        if(err < 0){
          return -3;
        }
        err = sendCoupRep(tabJoueur, ERR_COUP, VALID, PERDU, joueurJoue);
        if(err < 0){
          return -4;
        }
      }
      return 1;
    }else{
      switch(propCoup){
        case GAGNE :
          err = sendCoupRep(tabJoueur, ERR_OK, VALID, GAGNE, joueurJoue);
          if(err < 0){
            return -5;
          }
          err = sendCoupRep(tabJoueur, ERR_OK, VALID, PERDU, joueurAtt);
          if(err < 0){
            return -6;
          }
          return 2;
          break;
        case PERDU :
          err = sendCoupRep(tabJoueur, ERR_OK, VALID, PERDU, joueurJoue);
          if(err < 0){
            return -7;
          }
          err = sendCoupRep(tabJoueur, ERR_OK, VALID, GAGNE, joueurAtt);
          if(err < 0){
            return -8;
          }
          return 3;
          break;
        case NUL :
          err = sendCoupRep(tabJoueur, ERR_OK, VALID, NUL, joueurJoue);
          if(err < 0){
            return -9;
          }
          err = sendCoupRep(tabJoueur, ERR_OK, VALID, NUL, joueurAtt);
          if(err < 0){
            return -10;
          }
          return 4;
          break;
        case CONT :
          err = sendCoupRep(tabJoueur, ERR_OK, VALID, CONT, joueurJoue);
          if(err < 0){
            return -11;
          }
          err = sendCoupRep(tabJoueur, ERR_OK, VALID, CONT, joueurAtt);
          if(err < 0){
            return -12;
          }
          err = send(tabJoueur[joueurAtt].sockClient, &coupJoue,sizeof(TCoupReq), 0);
          if(err <= 0){
            perror("(Serveur) erreur sur le send");
            for(int i = 0 ; i < nbJoueurs ; ++i){
              error(tabJoueur[i].sockClient);
            }
            return -13;
          }
          return 0;
          break;
        }
      }
  }else{
    err = sendCoupRep(tabJoueur, ERR_OK, TIMEOUT, PERDU, joueurJoue);
    if(err < 0){
      return -14;
    }
    err = sendCoupRep(tabJoueur, ERR_OK, TIMEOUT, GAGNE, joueurAtt);
    if(err < 0){
      return -15;
    }
    return 5;
  }
  return 0;
}

int main (int argc, char** argv) {
  if(argc != 2){
    printf("Usage : %s port\n", argv[0]);
    return -1;
  }
  int nbJoueurs = 0;
  int nbChoixCoul = 0;
  int port = atoi(argv[1]);
  int sizeAddr = sizeof(struct sockaddr_in);
	struct sockaddr_in addClient;
  TPartieReq reqPartie;
  int sockCon = socketServeur(port);
  int sockTrans;
  int err;
  int noir = 0;
  int blanc = 0;
  Joueur tabJoueur[2];
  fd_set readSet;
  TCoul couleurVoulue;
  int nbPartie = 0;

  if(sockCon < 0){
    perror("(Serveur) erreur creation de la socket");
    error(sockCon);
    return -2;
  }
  /*while(nbJoueurs < 2){
    sockTrans = accept(sockCon, (struct sockaddr * )&addClient, (socklen_t *)&sizeAddr);
    if(sockTrans < 0){
      perror("(Serveur) erreur sur accept");
      error(sockTrans);
      error(sockCon);
      return -3;
    }
    tabJoueur[nbJoueurs].sockClient = sockTrans;
    tabJoueur[nbJoueurs].addrClient = addClient;
    nbJoueurs++;
  }*/
  while(noir == 0 || blanc == 0 || nbJoueurs < 2){
    FD_ZERO(&readSet);
    FD_SET(sockCon, &readSet);
    for(int i = 0 ; i < nbJoueurs ; ++i){
      FD_SET(tabJoueur[i].sockClient, &readSet);
    }
    err = select(FD_SETSIZE, &readSet, NULL, NULL, NULL);
    if(err < 0){
      perror("(Serveur) erreur dans le select");
      close(sockCon);
      close(sockTrans);
      for(int i = 0 ; i < nbJoueurs ; ++i){
        error(tabJoueur[i].sockClient);
      }
      return -4;
    }
    if(FD_ISSET(sockCon, &readSet) > 0){
      sockTrans = accept(sockCon, (struct sockaddr * )&addClient, (socklen_t *)&sizeAddr);
      if(sockTrans < 0){
        perror("(Serveur) erreur sur accept");
        error(sockTrans);
        error(sockCon);
        return -3;
      }
      tabJoueur[nbJoueurs].sockClient = sockTrans;
      tabJoueur[nbJoueurs].addrClient = addClient;
      nbJoueurs++;
    }else{
      for(int i = 0 ; i < nbJoueurs ; ++i){
        if(FD_ISSET(tabJoueur[i].sockClient, &readSet) > 0){
          err = recv(tabJoueur[i].sockClient, &reqPartie, sizeof(TPartieReq), 0);
          if(err <= 0){
            perror("(Client) erreur sur le recv");
            for(int j = 0 ; j < nbJoueurs ; ++j){
              error(tabJoueur[j].sockClient);
            }
            close(sockTrans);
            error(sockCon);
            return -5;
          }
          strcpy(tabJoueur[nbChoixCoul].nom, reqPartie.nomJoueur);
          if(i == 1){
            couleurVoulue = reqPartie.coulPion;
          }
          if(reqPartie.coulPion == BLANC){
            if(blanc == 0){
              tabJoueur[nbChoixCoul].couleur = BLANC;
              blanc = 1;
            }else{
              tabJoueur[nbChoixCoul].couleur = NOIR;
              noir = 1;
            }
          }else{
            if(noir == 0){
              tabJoueur[nbChoixCoul].couleur = NOIR;
              noir = 1;
            }else{
              tabJoueur[nbChoixCoul].couleur = BLANC;
              blanc = 1;
            }
          }
          nbChoixCoul++;
        }
      }
    }
  }
  
  err = sendPartieRep(tabJoueur, ERR_OK, tabJoueur[1].nom, OK, 0);
  if(err < 0){
    shutdown(sockTrans, SHUT_RDWR);
    error(sockCon);
    return -6;
  }
  if(couleurVoulue != tabJoueur[1].couleur){
    err = sendPartieRep(tabJoueur, ERR_OK, tabJoueur[0].nom, KO, 1);
  }else{
    err = sendPartieRep(tabJoueur, ERR_OK, tabJoueur[0].nom, OK, 1);
  }
  if(err < 0){
    for(int i = 0 ; i < nbJoueurs ; ++i){
      error(tabJoueur[i].sockClient);
    }
    shutdown(sockTrans, SHUT_RDWR);
    error(sockCon);
    return -7;
  }

  initialiserPartie();
  int res;

  while(nbPartie < 2){
    if(nbPartie == 0){
      if(tabJoueur[0].couleur == NOIR){
        res = jouerUnCoup(1, 0, tabJoueur, nbJoueurs, 1);
      }else{
        res = jouerUnCoup(0, 1, tabJoueur, nbJoueurs, 1);
      }
    }else{
      if(tabJoueur[0].couleur == NOIR){
        res = jouerUnCoup(0, 1, tabJoueur, nbJoueurs, 1);
      }else{
        res = jouerUnCoup(1, 0, tabJoueur, nbJoueurs, 1);
      }
    }
    printf("%d\n", res);
    if(res < 0){
      shutdown(sockTrans, SHUT_RDWR);
      error(sockCon);
      return -8;
    }else if(res > 0){
      if(nbPartie == 0){
        initialiserPartie();
        printf("Deuxieme partie \n");
      }
      nbPartie++;
    }else{
      if(nbPartie == 0){
        if(tabJoueur[0].couleur == NOIR){
          res = jouerUnCoup(0, 1, tabJoueur, nbJoueurs, 2);
        }else{
          res = jouerUnCoup(1, 0, tabJoueur, nbJoueurs, 2);
        }
      }else{
        if(tabJoueur[0].couleur == NOIR){
          res = jouerUnCoup(1, 0, tabJoueur, nbJoueurs, 2);
        }else{
          res = jouerUnCoup(0, 1, tabJoueur, nbJoueurs, 2);
        }
      }
      if(res < 0){
        shutdown(sockTrans, SHUT_RDWR);
        error(sockCon);
        return -9;
      }else if(res > 0){
        if(nbPartie == 0){
          printf("Deuxieme partie\n");
          initialiserPartie();
        }
        nbPartie++;
      }
    }
  }
  for(int i = 0 ; i < nbJoueurs ; ++i){
    error(tabJoueur[i].sockClient);
  }
  shutdown(sockTrans, SHUT_RDWR);
  error(sockCon);
  printf("Fin de la partie \n");
}
