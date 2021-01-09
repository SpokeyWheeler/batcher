FROM spokey/batcher

FROM ibmcom/informix-innovator-c:latest

WORKDIR /opt/ibm/scripts

COPY informix* /opt/ibm/scripts/
COPY --from=0 /batcher /opt/ibm/scripts/
