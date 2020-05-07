package com.ia;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;

public class Main {

    public static void main(String[] args) {

        GrilleQuantik grille = new GrilleQuantik();
        DataInputStream in;
        DataOutputStream out;
        int nbPartie = 0;
        int l = 0, c = 0;
        int prop = 0;
        int typePion = 1;
        int numPartie = 0;
        int stop;
        boolean finPartie;
        boolean premierJoueur;
        //ajoute la grille en mem avec une classe
        //socket client + connect serv 8888
        if(args.length != 1){
          System.out.println("(IA) Usage : ./java -cp compiled/:compiled/IA/jpl-7.0.1.jar com/ia/Main numPort");
          return;
        }
        int portServ = Integer.parseInt(args[0]);
        try {
            Socket sockClient = new Socket("127.0.0.1", portServ);
            in = new DataInputStream(sockClient.getInputStream());
            out = new DataOutputStream(sockClient.getOutputStream());
            int premier = in.readInt();
            if(premier == 1){
                System.out.println("premier joueur\n");
                premierJoueur = true;
            }else {
                System.out.println("deuxieme joueur\n");
                premierJoueur = false;
            }
            TCoul couleur = TCoul.BLANC;
            if(!premierJoueur){
                couleur = TCoul.NOIR;
            }
            while(nbPartie < 2) {
                finPartie = false;
                if (premierJoueur) {
                    //demander à l'ia + modif variable
                    out.writeInt(typePion);
                    out.writeInt(l);
                    out.writeInt(c);
                    out.writeInt(prop);
                    grille.plateau[l][c] = typePion;
                }
                while (!finPartie) {
                  finPartie = true;
                  nbPartie++;
                  stop = in.readInt();
                  if(stop == 1){
                    break;
                  }
                  typePion = in.readInt();
                  System.out.println(typePion);
                  l = in.readInt();//peut etre -1 vu que c'est un tab
                  System.out.println(l);
                  c = in.readInt();
                  System.out.println(c);
                  prop = in.readInt();
                  System.out.println(prop);
                  if (prop != 0) {
                      finPartie = true;
                  } else {
                    grille.plateau[l][c] = -typePion;
                    //ia + modif + send4

                    /*out.writeInt(typePion);
                    out.writeInt(l);
                    out.writeInt(c);
                    out.writeInt(prop);
                    grille.plateau[l][c] = typePion;*/
                    stop = in.readInt();
                    if(stop == 1){
                      break;
                    }
                    for (int i = 0; i < 4; i++) {
                        for (int j = 0; j < 4; j++) {
                            System.out.print(" | " + grille.plateau[i][j] + " | ");
                        }
                        System.out.println("");
                    }

                      System.out.println("envoie de données");
                  }

                }
                nbPartie++;
                premierJoueur = !premierJoueur;
                grille = new GrilleQuantik();
            }
            in.close();
            out.close();
            sockClient.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        //att partie
        //att si premier joueur

    }


}
