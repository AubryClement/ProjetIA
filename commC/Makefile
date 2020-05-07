LD_FLAGS =

all: quantikJoueur quantikServeur

quantikJoueur: quantikJoueur.c quantikJoueur.h fonctionsTCP.a
	gcc -Wall quantikJoueur.c -o quantikJoueur -L. -lfonctionsTCP $(LD_FLAGS)

quantikServeur: quantikServeur.c quantikServeur.h validation.h fonctionsTCP.a quantik.o
	gcc -Wall quantikServeur.c -o quantikServeur -L. -lfonctionsTCP quantik-fPIC.o $(LD_FLAGS)

fonctionsTCP.a: fonctionsTCP.o
	ar rcs libfonctionsTCP.a fonctionsTCP.o

fonctionsTCP.o: fonctionsTCP.c fonctionsTCP.h
	gcc -O -c fonctionsTCP.c

clean:
	rm *~ ; rm -i \#* ;
	rm quantikJoueur ; rm quantikServeur

run:
	./quantikServeur 8080 &
	./quantikJoueur 127.0.0.1 8080
