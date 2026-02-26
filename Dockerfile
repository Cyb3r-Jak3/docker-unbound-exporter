FROM golang:1.26-trixie@sha256:100774df3fd947fbd1f2b674e71215af6bf087b3676d9fcfdf1a9d0ec9e5cb9c AS build

ARG VERSION

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y git

ENV CGO_ENABLED=0

RUN git clone https://github.com/letsencrypt/unbound_exporter.git && \
    cd unbound_exporter && \
    git checkout tags/v${VERSION} && \
    go build -o /go/bin/unbound_exporter -trimpath -ldflags="-s -w  -extldflags=-static" .

FROM busybox:1.37@sha256:b3255e7dfbcd10cb367af0d409747d511aeb66dfac98cf30e97e87e4207dd76f

COPY --from=build /go/bin/unbound_exporter /

ENTRYPOINT ["/unbound_exporter"]
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD wget http://localhost:9167/_healthz -q -O - > /dev/null 2>&1