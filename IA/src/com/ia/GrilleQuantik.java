package com.ia;

public class GrilleQuantik {
    int plateau[][];
    TPion piecesBlanc[];
    TPion piecesNoir[];

    public GrilleQuantik(){
      this.plateau = new int[4][4];
      this.piecesBlanc = new TPion[8];
      this.piecesNoir = new TPion[8];
      for(int i = 0 ; i < 4 ; ++i){
          for(int j = 0 ; j < 4 ; ++j){
              plateau[i][j] = 0;
          }
      }

      TTypePion tabType[] = {TTypePion.CYLINDRE, TTypePion.PAVE, TTypePion.SPHERE, TTypePion.TETRAEDRE};
      for(int i = 0 ; i < 4 ; ++i){
          for (int j = 0; j < 2; ++j) {
              piecesBlanc[j] = new TPion(TCoul.BLANC, tabType[i]);
              piecesNoir[j] = new TPion(TCoul.NOIR, tabType[i]);
          }
      }
    }
}
