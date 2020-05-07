#ifndef _FONCTIONSTCP_H_
#define _FONCTIONSTCP_H_

	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <unistd.h>
	#include <sys/types.h>
	#include <sys/socket.h>
	#include <netinet/in.h>
	#include <arpa/inet.h>
	#include <netdb.h>
	#include <errno.h>
	#include <sys/time.h>

	int socketServeur(ushort nPort);
	int socketClient(char * nomMachine, ushort nPort);
	int commJava(int port);
	int sendJava(int sock, int val);
	int recvJava(int sock);

#endif
