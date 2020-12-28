FROM scratch
COPY batcher /
ENTRYPOINT ["/batcher"]
