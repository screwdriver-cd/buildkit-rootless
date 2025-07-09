FROM moby/buildkit:rootless
 
USER root
 
RUN apk add --no-cache openssl
 
COPY buildkit-entrypoint.sh /usr/local/bin/buildkit-entrypoint.sh
RUN chmod +x /usr/local/bin/buildkit-entrypoint.sh
 
COPY buildkitd.toml /etc/buildkit/buildkitd.toml
 
RUN mkdir -p /certs/buildkit/client /certs/buildkit/server && chown -R 1000:1000 /certs
 
USER 1000:1000
 
ENTRYPOINT ["/usr/local/bin/buildkit-entrypoint.sh"]
