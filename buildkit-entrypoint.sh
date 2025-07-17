#!/bin/sh
set -euo pipefail
 
DIR="/certs/buildkit"
CERT_DAYS=7
 
mkdir -p "$DIR" "$DIR/server" "$DIR/client"
 
# Generate CA key
[ -f "$DIR/ca-key.pem" ] || openssl genrsa -out "$DIR/ca-key.pem" 4096
 
# Generate CA certificate
[ -f "$DIR/ca.pem" ] || openssl req -x509 -new -nodes -key "$DIR/ca-key.pem" -sha256 -days 7 -out "$DIR/ca.pem" -subj "/CN=Screwdriver buildkitd CA" -addext keyUsage=critical,digitalSignature,keyCertSign
 
# Generate server key
 [ -f "$DIR/server/key.pem" ] || openssl genrsa -out "$DIR/server/key.pem" 4096
 
# Generate server CSR
[ -f "$DIR/server/server.csr" ] || openssl req -new -key "$DIR/server/key.pem" -out "$DIR/server/server.csr" -subj "/CN=Screwdriver buildkit server"
 
# Server certificate extensions (localhost only)
cat > "$DIR/server/openssl.cnf" <<EOF
[ x509_exts ]
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
 
[ alt_names ]
DNS.1 = localhost
IP.1 = 127.0.0.1
EOF
 
# Generate server certificate with CA
[ -f "$DIR/server/cert.pem" ] || openssl x509 -req -in "$DIR/server/server.csr" -CA "$DIR/ca.pem" -CAkey "$DIR/ca-key.pem" -CAcreateserial -out "$DIR/server/cert.pem" -days "$CERT_DAYS" -extfile "$DIR/server/openssl.cnf" -extensions x509_exts -sha256
 
# Generate client key
[ -f "$DIR/client/key.pem" ] || openssl genrsa -out "$DIR/client/key.pem" 4096
 
# Generate client CSR
[ -f "$DIR/client/client.csr" ] || openssl req -new -key "$DIR/client/key.pem" -out "$DIR/client/client.csr" -subj "/CN=Screwdriver buildkit client"
 
# Client certificate extensions
cat > "$DIR/client/openssl.cnf" <<EOF
[ x509_exts ]
extendedKeyUsage = clientAuth
EOF
 
# Generate certificate with CA
[ -f "$DIR/client/cert.pem" ] || openssl x509 -req -in "$DIR/client/client.csr" -CA "$DIR/ca.pem" -CAkey "$DIR/ca-key.pem" -CAcreateserial -out "$DIR/client/cert.pem" -days "$CERT_DAYS" -extfile "$DIR/client/openssl.cnf" -extensions x509_exts -sha256
 
# Copy CA certificate to server/client folders
cp "$DIR/ca.pem" "$DIR/server/ca.pem"
cp "$DIR/ca.pem" "$DIR/client/ca.pem"
 
# Run buildkitd in rootless mode
# See: https://github.com/moby/buildkit/blob/7841a73c183b0166dcede61eb07ece92e5bc28c8/Dockerfile#L479C1-L479C40
exec rootlesskit buildkitd "$@"
