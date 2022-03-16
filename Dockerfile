FROM golang:1.18 AS goer
RUN go get github.com/SpokeyWheeler/batcher
WORKDIR /go/src/github.com/SpokeyWheeler/batcher
RUN go get -d -t -v ./...
RUN go build -v ./...
RUN mv batcher /tmp

FROM scratch
COPY --from=goer /tmp/batcher .
ENTRYPOINT ["./batcher"]
