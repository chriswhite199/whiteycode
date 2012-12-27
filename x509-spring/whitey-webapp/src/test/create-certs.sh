#!/bin/bash
 
# default password for keys
PASSWORD=password
 
OUT_DIR=certs
 
# Subject items
C="US"
ST="My State"
L="My City"
O="My Corp"
 
CN_CA="My CA Root"
CN_SERVER="Test Server"
CN_CLIENT="John Smith jsmith"
 
###############################
 
# Create output directory
mkdir -p ${OUT_DIR}
 
###############################
 
# create CA key
openssl genrsa -des3 -out ${OUT_DIR}/ca.key -passout pass:$PASSWORD 4096
 
# create CA cert
openssl req -new -x509 -days 365 -key ${OUT_DIR}/ca.key -out ${OUT_DIR}/ca.crt \
 -passin pass:$PASSWORD -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/CN=${CN_CA}/"
 
# create truststore
keytool -import -trustcacerts -alias caroot -file ${OUT_DIR}/ca.crt \
 -keystore ${OUT_DIR}/truststore.jks -storepass ${PASSWORD} -noprompt
 
###############################
 
# create server key
openssl genrsa -des3 -out ${OUT_DIR}/server.key -passout pass:$PASSWORD 4096
 
# create server cert request
openssl req -new -key ${OUT_DIR}/server.key -out ${OUT_DIR}/server.csr \
 -passin pass:$PASSWORD -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/CN=${CN_SERVER}/"
 
# create server cert
openssl x509 -req -days 365 -in ${OUT_DIR}/server.csr -CA ${OUT_DIR}/ca.crt \
 -CAkey ${OUT_DIR}/ca.key -set_serial 01 -out ${OUT_DIR}/server.crt \
 -passin pass:${PASSWORD}
 
# convert server cert to PKCS12 format, including key
openssl pkcs12 -export -out ${OUT_DIR}/server.p12 -inkey ${OUT_DIR}/server.key \
 -in ${OUT_DIR}/server.crt -passin pass:${PASSWORD} -passout pass:${PASSWORD}
 
###############################
 
# create client key
openssl genrsa -des3 -out ${OUT_DIR}/client.key -passout pass:${PASSWORD} 4096
 
# create client cert request
openssl req -new -key ${OUT_DIR}/client.key -out ${OUT_DIR}/client.csr \
 -passin pass:$PASSWORD -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/CN=${CN_CLIENT}/"
 
 
# create client cert
openssl x509 -req -days 365 -in ${OUT_DIR}/client.csr -CA ${OUT_DIR}/ca.crt \
 -CAkey ${OUT_DIR}/ca.key -set_serial 02 -out ${OUT_DIR}/client.crt \
 -passin pass:${PASSWORD}
 
# convert client cert to PKCS12, including key
openssl pkcs12 -export -out ${OUT_DIR}/client.p12 -inkey ${OUT_DIR}/client.key \
 -in ${OUT_DIR}/client.crt -passin pass:${PASSWORD} -passout pass:${PASSWORD}
