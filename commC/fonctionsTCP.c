	#include "fonctionsTCP.h"

	int socketServeur(ushort nPort){
		struct sockaddr_in addServ;	/* adresse socket connex serveur */

		int sockConx = socket(AF_INET, SOCK_STREAM, 0); /* resulat */

		if (sockConx < 0) {
		    return -1;
		}
		/*
		* initialisation de l'adresse de la socket
		*/
		int iOption = 1;
  	setsockopt(sockConx, SOL_SOCKET, SO_REUSEADDR, (char*)&iOption, sizeof(iOption));
		addServ.sin_family = AF_INET;
		addServ.sin_port = htons(nPort); // conversion en format réseau (big endian)
		addServ.sin_addr.s_addr = INADDR_ANY;
		// INADDR_ANY : 0.0.0.0 (IPv4) donc htonl inutile ici, car pas d'effet
		bzero(addServ.sin_zero, 8);

		int sizeAddr = sizeof(struct sockaddr_in);

		/*
		* attribution de l'adresse a la socket
		*/
		int err = bind(sockConx, (struct sockaddr *)&addServ, sizeAddr);
		if (err < 0) {
			close(sockConx);
			return -2;
		}

		/*
		* utilisation en socket de controle, puis attente de demandes de
		* connexion.
		*/
		err = listen(sockConx, 1);
		if (err < 0) {
			close(sockConx);
			return -3;
		}

		return sockConx;
	}

	int socketClient(char * nomMachine, ushort nPort){
  		struct sockaddr_in addSockServ;
		int sock = socket(AF_INET, SOCK_STREAM, 0);
		if (sock < 0) {
			return -1;
		}

		/*
		* initialisation de l'adresse de la socket - version inet_aton
		*/

		addSockServ.sin_family = AF_INET;
		int err = inet_aton(nomMachine, &addSockServ.sin_addr);
		if (err == 0) {
			close(sock);
			return -2;
		}

		addSockServ.sin_port = htons(nPort);
		bzero(addSockServ.sin_zero, 8);

		int sizeAdd = sizeof(struct sockaddr_in);

		/*
		*  initialisation de l'adresse de la socket - version getaddrinfo
		*/
		/*
		memset(&hints, 0, sizeof(struct addrinfo));
		hints.ai_family = AF_INET; // AF_INET / AF_INET6
		hints.ai_socktype = SOCK_STREAM;
		hints.ai_flags = 0;
		hints.ai_protocol = 0;


		// récupération de la liste des adresses corespondante au serveur

		err = getaddrinfo(nomMachServ, argv[2], &hints, &result);
		if (err != 0) {
		perror("(client) erreur sur getaddrinfo");
		close(sock);
		return -3;
		}

		addSockServ = *(struct sockaddr_in*) result->ai_addr;
		sizeAdd = result->ai_addrlen;
		*/

		/*
		* connexion au serveur
		*/
		err = connect(sock, (struct sockaddr *)&addSockServ, sizeAdd);

		if (err < 0) {
			close(sock);
			return -3;
		}
		return sock;
	}

int commJava(int port) {
  struct sockaddr_in addClient;
  int sizeAddr = sizeof(struct sockaddr_in);
  int sockCon = socketServeur(port);
  if (sockCon < 0){
  	perror("(Serveur Java) erreur création de la socket\n");
    return -1;
  }

	int sockTrans = accept(sockCon, (struct sockaddr *)&addClient, (socklen_t *)&sizeAddr);
		if (sockTrans < 0) {
    	perror("(Serveur Java) erreur sur accept\n");
			return -2;
    }

  return sockTrans;
}

int sendJava(int sock, int val){
	int currVal = htonl(val);
	int err = send(sock, &currVal, sizeof(int), 0);
	if(err <= 0){
		perror("(Client java) error sur send\n");
		shutdown(sock, SHUT_RDWR);
		close(sock);
		return -1;
	}
	return 0;
}

int recvJava(int sock){
	int currVal;
	int err = 0;
	while(err < 4){
		err = recv(sock, &currVal, sizeof(int), MSG_PEEK);
	}
	//Fin du send depuis java
	err = recv(sock, &currVal, sizeof(int), 0);
	if(err <= 0){
		perror("(Client java) erreur sur recv\n");
		shutdown(sock, SHUT_RDWR);
		close(sock);
		return -1;
	}
	return ntohl(currVal);
}
