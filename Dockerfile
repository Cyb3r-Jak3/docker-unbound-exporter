FROM golang:1.26-trixie@sha256:98988b42f3293b627bf07c884ff17181a59501769cd8c06c7ba901e0ce2c9853 AS build

ARG VERSION

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y git

ENV CGO_ENABLED=0

RUN git clone https://github.com/letsencrypt/unbound_exporter.git && \
    cd unbound_exporter && \
    git checkout tags/v${VERSION} && \
    go build -o /go/bin/unbound_exporter -trimpath -ldflags="-s -w -extldflags=-static" .

FROM busybox:1.38@sha256:dc2d74b28e4cf8984fa52af1f39bc7c3d9c73760b41a74d629f5d11b1ab28616

COPY --from=build /go/bin/unbound_exporter /

ENTRYPOINT ["/unbound_exporter"]
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD wget http://localhost:9167/_healthz -q -O - > /dev/null 2>&1