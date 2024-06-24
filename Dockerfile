FROM golang:1.21-bookworm@sha256:992f091ae49a48dcf4857c0879116cc9c0794d5f4dc7f7989399c43b7f71631e AS build

# renovate: datasource=github-releases depName=letsencrypt/unbound_exporter
ARG VERSION=0.4.6

RUN apt-get update && apt-get install -y git

ENV CGO_ENABLED=0

RUN git clone https://github.com/letsencrypt/unbound_exporter.git && \
    cd unbound_exporter && \
    git checkout tags/v${VERSION} && \
    go build -o /go/bin/unbound_exporter -trimpath -ldflags="-s -w  -extldflags=-static" .

FROM busybox:1.36

COPY --from=build /go/bin/unbound_exporter /

ENTRYPOINT ["/unbound_exporter"]
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD wget http://localhost:9167/metrics -q -O - > /dev/null 2>&1