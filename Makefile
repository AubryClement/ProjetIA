LD_FLAGS =

all: 
	make -C commC
	javac -cp IA/jpl-7.0.1.jar IA/src/com/ia/*.java -d compiled/
	cp commC/quantikServeur compiled/
	cp commC/quantikJoueur compiled/

