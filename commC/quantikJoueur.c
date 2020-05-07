#include "quantikJoueur.h"

void recupInfoJava(TCoupReq *coupJoue, int sockTrans){
  int res;
  res=recvJava(sockTrans);
  switch(res){
   case 1 : coupJoue->pion.typePion = CYLINDRE;
     printf("type : CYLINDRE\n");
     break;
   case 2 : coupJoue->pion.typePion = PAVE;
     printf("type : PAVE\n");
     break;
   case 3 : coupJoue->pion.typePion = SPHERE;
     printf("type : SPHERE\n");
     break;
   case 4 : coupJoue->pion.typePion = TETRAEDRE;
     printf("type : TETRAEDRE\n");
     break;
  }

  res = recvJava(sockTrans);
  switch(res){
    case 0 : coupJoue->posPion.l = UN;
      printf("ligne : un\n");
      break;
    case 1 : coupJoue->posPion.l = DEUX;
      printf("ligne : deux\n");
      break;
    case 2 : coupJoue->posPion.l = TROIS;
      printf("ligne : TROIS\n");
      break;
    case 3 : coupJoue->posPion.l = QUATRE;
      printf("ligne : QUATRE\n");
      break;
  }


  res = recvJava(sockTrans);
  switch(res){
    case 0 : coupJoue->posPion.c = A;
      printf("Colonne : a\n");
      break;
    case 1 : coupJoue->posPion.c = B;
      printf("Colonne : b\n");
      break;
    case 2 : coupJoue->posPion.c = C;
      printf("Colonne : c\n");
      break;
    case 3 : coupJoue->posPion.c = D;
      printf("Colonne : d\n");
      break;
  }

  res = recvJava(sockTrans);
  switch(res){
    case 0 : coupJoue->propCoup = CONT;
     printf("type : CONT\n");
     break;
     case 1 : coupJoue->propCoup = GAGNE;
     printf("type : GAGNE\n");
     break;
     case 2 : coupJoue->propCoup = NUL;
     printf("type : NUL\n");
     break;
     case 3 : coupJoue->propCoup = PERDU;
     printf("type : PERDU\n");
     break;
  }
}

int main (int argc, char** argv) {
   if(argc != 5){
     printf("Usage : %s ipServ portServ nomJoueur portServJava\n", argv[0]);
     return -1;
   }

   char* ipServ = argv[1];
   int portServ = atoi(argv[2]);
   int portServJava = atoi(argv[4]);

   if(portServ == portServJava){
     printf("Votre port du serv c doit être différent de celui de java \n");
     return -1;
   }
   int sock = socketClient(ipServ, portServ);
   int nbPartie = 0;
   int premierJoueur;
   TCoul couleur;
   char nomAdvers[T_NOM];
   if(sock < 0){
     perror("(client) Erreur creation de la socket");
     shutdown(sock, SHUT_RDWR);
     close(sock);
     return -2;
   }

   int sockTrans = commJava(portServJava);
   if(sockTrans < 0){
     shutdown(sock, SHUT_RDWR);
     close(sock);
     return -1;
   }

   TPartieReq reqPartie;
   TPartieRep repPartie;

   int choixCoul;
   printf("Selectionner la couleur voulue (0 : Noir, 1 : Blanc) :\n");
   scanf("%d", &choixCoul);
   if(choixCoul == 0){
     reqPartie.coulPion = NOIR;
   }else{
     reqPartie.coulPion = BLANC;
   }
   strcpy(reqPartie.nomJoueur, argv[3]);
   reqPartie.idReq = PARTIE;
   int err = send(sock, &reqPartie, sizeof(TPartieReq), 0);
   if(err <= 0){
     perror("(Client) erreur sur le send");
     shutdown(sock, SHUT_RDWR);
     close(sock);
     return -3;
   }

   err = recv(sock, &repPartie, sizeof(TPartieRep), 0);
   if(err <= 0){
     perror("(Client) erreur sur le recv");
     shutdown(sock, SHUT_RDWR);
     close(sock);
     return -4;
   }
   if(repPartie.validCoulPion == OK){
     if(choixCoul == 0){
       printf("Couleur : Noir\n");
       premierJoueur = 0;
       couleur = NOIR;
     }else{
       printf("Couleur : Blanc\n");
       premierJoueur = 1;
       couleur = BLANC;
     }
   }else{
     if(choixCoul == 0){
       printf("Couleur : Blanc\n");
       premierJoueur = 1;
       couleur = BLANC;
     }else{
       printf("Couleur : Noir\n");
       premierJoueur = 0;
       couleur = NOIR;
     }
   }
   strcpy(nomAdvers, repPartie.nomAdvers);
   printf("Adversaire : %s\n", repPartie.nomAdvers);
   TCoupReq coupJoue;
   TCoupReq coupRecu;
   TCoupRep coupValid;
   int finPartie = 0;
   coupJoue.idRequest = COUP;
   coupJoue.estBloque = false;
   coupJoue.pion.coulPion = couleur;
   while(nbPartie < 2){
     coupJoue.numPartie = nbPartie + 1;
     if(premierJoueur == 1){
       err = sendJava(sockTrans, 1);
       if(err < 0){
         shutdown(sock, SHUT_RDWR);
         close(sock);
         return -1;
       }

       recupInfoJava(&coupJoue, sockTrans);

       err = send(sock, &coupJoue, sizeof(TCoupReq), 0);
       if(err <= 0){
         perror("(Client) erreur sur le send");
         shutdown(sock, SHUT_RDWR);
         close(sock);
         return -6;
       }

     }else{
       err = sendJava(sockTrans, 0);
       if(err < 0){
         shutdown(sock, SHUT_RDWR);
         close(sock);
         return -1;
       }
     }
     while(finPartie == 0){
       //Coup adverse
      err = recv(sock, &coupValid, sizeof(TCoupRep), 0);
      if(err <= 0){
        perror("(Client) erreur sur le recv valid");
        fprintf(stderr, "recv: %s (%d)\n", strerror(errno), errno);
        shutdown(sock, SHUT_RDWR);
        close(sock);
        return -7;
      }
      if(coupValid.propCoup != CONT || coupValid.err == ERR_COUP){
        //evoie fin de cette partie au moteur ia
        err = sendJava(sockTrans, 1);
        if(err < 0){
          shutdown(sock, SHUT_RDWR);
          close(sock);
          return -1;
        }
        nbPartie++;
        finPartie = 1;
        if(premierJoueur == 0){
          premierJoueur = 1;
        }else{
          premierJoueur = 0;
        }
      }
      switch(coupValid.propCoup){
        case GAGNE : printf("%s a gagne contre %s\n", argv[3], nomAdvers);
          break;
        case PERDU : printf("%s a perdu contre %s\n", argv[3], nomAdvers);
          break;
        case NUL : printf("Il y a eu un nul entre %s et %s\n", argv[3], nomAdvers);
            break;
        case CONT :
          err = sendJava(sockTrans, 0);
          if(err < 0){
            shutdown(sock, SHUT_RDWR);
            close(sock);
            return -1;
          }
          err = recv(sock, &coupRecu, sizeof(TCoupReq), 0);
          if(err <= 0){
            perror("(Client) erreur sur le recv coup recu");
            shutdown(sock, SHUT_RDWR);
            close(sock);
            return -8;
          }

          switch(coupRecu.pion.typePion){
           case CYLINDRE :
            printf("Envoie de Cylindre\n");
            err = sendJava(sockTrans, 1);
            break;
           case PAVE :
            printf("Envoie de Pave\n");
            err = sendJava(sockTrans, 2);
            break;
           case SPHERE :
            printf("Envoie de Sphere\n");
            err = sendJava(sockTrans, 3);
            break;
           case TETRAEDRE :
            printf("Envoie de Tetraedre\n");
            err = sendJava(sockTrans, 4);
            break;
          }
          if(err < 0){
            shutdown(sock, SHUT_RDWR);
            close(sock);
            return -1;
          }

          switch(coupRecu.posPion.l){
            case UN : err = sendJava(sockTrans, 0);
              break;
            case DEUX : err = sendJava(sockTrans, 1);
              break;
            case TROIS : err = sendJava(sockTrans, 2);
              break;
            case QUATRE : err = sendJava(sockTrans, 3);
              break;
          }
          if(err < 0){
            shutdown(sock, SHUT_RDWR);
            close(sock);
            return -1;
          }

          switch(coupRecu.posPion.c){
            case A : err = sendJava(sockTrans, 0);
              break;
            case B : err = sendJava(sockTrans, 1);
              break;
            case C : err = sendJava(sockTrans, 2);
              break;
            case D : err = sendJava(sockTrans, 3);
              break;
          }
          if(err < 0){
            shutdown(sock, SHUT_RDWR);
            close(sock);
            return -1;
          }

          switch(coupRecu.propCoup){
            case CONT : err = sendJava(sockTrans, 0);
              break;
            case GAGNE : err = sendJava(sockTrans, 1);
              break;
            case NUL : err = sendJava(sockTrans, 2);
              break;
            case PERDU : err = sendJava(sockTrans, 3);
              break;
          }

          if(err < 0){
            shutdown(sock, SHUT_RDWR);
            close(sock);
            return -1;
          }

          recupInfoJava(&coupJoue, sockTrans);

          int err = send(sock, &coupJoue, sizeof(TCoupReq), 0);
          if(err <= 0){
            perror("(Client) erreur sur le send coup joue");
            shutdown(sock, SHUT_RDWR);
            close(sock);
            return -9;
          }

          err = recv(sock, &coupValid, sizeof(TCoupRep), 0);
          if(err <= 0){
            perror("(Client) erreur sur le recv valid");
            shutdown(sock, SHUT_RDWR);
            close(sock);
            return -10;
          }
          if(coupValid.propCoup != CONT || coupValid.err == ERR_COUP){
            //evoie fin de cette partie au moteur ia
            err = sendJava(sockTrans, 1);
            if(err < 0){
              shutdown(sock, SHUT_RDWR);
              close(sock);
              return -1;
            }
            nbPartie++;
            finPartie = 1;
            if(premierJoueur == 0){
              premierJoueur = 1;
            }else{
              premierJoueur = 0;
            }
          }

          switch(coupValid.propCoup){
            case GAGNE : printf("%s a perdu contre %s\n", argv[3], nomAdvers);
              break;
            case PERDU : printf("%s a gagne contre %s\n", argv[3], nomAdvers);
              break;
            case NUL : printf("Il y a eu un nul entre %s et %s\n", argv[3], nomAdvers);
                break;
            case CONT :
              err = sendJava(sockTrans, 0);
              if(err < 0){
                shutdown(sock, SHUT_RDWR);
                close(sock);
                return -1;
              }
              break;
          }
          break;
      }
    }
  }
return 0;
}
