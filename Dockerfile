FROM golang:1.7.4-alpine

ENV ELASTICSEARCH_URL= \
  LOGSTASH_URL=http://logstash:5044

# TODO: We should consider building the binary in a separate container
#     and copying it over here. We dont need these packages at runtime.
RUN apk update && \
  apk add git make bash ca-certificates wget && \
  update-ca-certificates

RUN wget https://s3.amazonaws.com/dispatchbot-devops/ca-chain.cert.pem && \
  mv ca-chain.cert.pem /usr/local/share/ca-certificates/dispatchbot-ca-chain.cert.crt && \
  update-ca-certificates

RUN go get github.com/radoondas/elasticbeat && \
  cd $GOPATH/src/github.com/radoondas/elasticbeat && \
  make && \
  rm elasticbeat.yml

RUN mkdir /etc/elasticbeat
COPY elasticbeat.yml /etc/elasticbeat/elasticbeat.yml

WORKDIR $GOPATH/src/github.com/radoondas/elasticbeat
CMD ["./elasticbeat", "-e", "-v", "-d", "elasticbeat", "-c", "/etc/elasticbeat/elasticbeat.yml"]
