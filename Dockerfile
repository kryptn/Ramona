FROM nimlang/nim:alpine as build

RUN apk -U add openssl

RUN mkdir -p /opt/ramona
WORKDIR /opt/ramona

COPY . .

RUN nimble build -d:ssl -d:release -y

FROM alpine:3.11.3
RUN apk -U add openssl

COPY --from=build /opt/ramona/bin/ramona /ramona
CMD ["/ramona"]
