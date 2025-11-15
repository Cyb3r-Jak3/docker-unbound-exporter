// Special target: https://github.com/docker/metadata-action#bake-definition
target "docker-metadata-action" {
    platforms = [
        "linux/amd64",
        "linux/arm64",
        "linux/386",
        "linux/arm/v7",
        "linux/ppc64le",
        "linux/s390x",
    ]
}

variable "EXPORTER_VERSION" {
    # renovate: datasource=github-releases depName=letsencrypt/unbound_exporter
    default = "0.5.0"
}

target "default" {
    tags = [
        "cyb3rjak3/unbound-exporter:latest",
        "cyb3rjak3/unbound-exporter:${EXPORTER_VERSION}",
        "ghcr.io/cyb3r-jak3/unbound-exporter:latest",
        "ghcr.io/cyb3r-jak3/unbound-exporter:${EXPORTER_VERSION}",
    ]
    args = {
        VERSION = EXPORTER_VERSION
    }
}

target "release" {
    inherits = ["docker-metadata-action", "default"]
}