FROM golang:1.25-trixie@sha256:59c4b53dd554f422eadd0aef5239125e8b47b0cb4d1125c9e86a8e3dd0bab18d AS build

ARG VERSION=0.4.6

RUN apt-get update && apt-get install -y git

ENV CGO_ENABLED=0

RUN git clone https://github.com/letsencrypt/unbound_exporter.git && \
    cd unbound_exporter && \
    git checkout tags/v${VERSION} && \
    go build -o /go/bin/unbound_exporter -trimpath -ldflags="-s -w  -extldflags=-static" .

FROM busybox:1.37@sha256:2f590fc602ce325cbff2ccfc39499014d039546dc400ef8bbf5c6ffb860632e7

COPY --from=build /go/bin/unbound_exporter /

ENTRYPOINT ["/unbound_exporter"]
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD wget http://localhost:9167/metrics -q -O - > /dev/null 2>&1