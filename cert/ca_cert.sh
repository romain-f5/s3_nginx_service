#!/bin/bash
# this script generates a ca, server and client certifitates for testing purposes only.
# do not use the generated certificates or certificate authority in prod.
# enter "clean" as argument to delete previously created certs and exit.
# for testing purposes only - no password/phrase
# used in this example - THIS IS BAD
# a little clean up
rm -f *.crt
rm -f *.key
rm -f *.csr
rm -f *.srl

if [ "$1" == clean ]; then 
  echo "cleaning and exiting"
  exit 1
else
  echo "done cleaning, generating new certs "
fi

# (( $1 eq "clean" )) || { echo >&2 "you asked to clean - not continuing."; exit 1; }

# start by creating the CA
echo "creating the CA (ca.key, ca.crt)"
openssl genrsa -out ca.key 4096 
openssl req -new -x509 -days 365 -key ca.key -out ca.crt -config ca.cnf

# then create a server cert - note that this requires a couple of cnf files (probaly only one but
# got it to work only w/ both... server_cert_ext.cnf and server.cnf... )
echo "creating a server certificate and key"
echo "create a key (server.key), then a csr (server.csr), then sign the csr (server.crt)"
openssl genrsa -out server.key 4096
openssl req -new -key server.key -out server.csr -config server.cnf
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -out server.crt -CAcreateserial -days 365 -sha256 -extfile server_cert_ext.cnf

# create a client certificate - requires another cnf file 
echo "creating a client certificate and key"
openssl genrsa -out client.key 4096
echo "generating the client certificate csr"
openssl req -new -key client.key -out client.csr -config client.cnf
echo "generating the client certificate"
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -out client.crt -CAcreateserial -days 365 -sha256 -extfile client_cert_ext.cnf

