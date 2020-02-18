FROM nimlang/nim:alpine

RUN apk upgrade --update-cache --available && \
    apk add openssl && \
    rm -rf /var/cache/apk/*

RUN mkdir -p /opt/ramona
WORKDIR /opt/ramona

COPY . .

RUN nimble build -d:ssl -y

CMD ["bin/ramona"]


