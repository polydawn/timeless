#!/bin/bash

## Hello!
## This is a reppl script which builds rio, repeatr, and the other components of the Timeless Stack,
## and assembles an omnibus tarball containing all those lovely things.
##
## It's both how we release, and a pretty good demo of using repeatr :)
##
## You need repeatr and rio on your $PATH in order to run this script.
## Download one of the omnibus tarballs to bootstrap.
## (You can also build them from source individually if you like;
## their individual build instructions are in their respective git repos.)
##
## Note: we're currently only building for linux-amd64, sorry :( PRs welcome!!
## Todo: also bundle r2k8s... etc...
##

set -euo pipefail

mkdir -p .memo
export REPEATR_MEMODIR=".memo"

BASE_IMG_HASH="tar:6q7G4hWr283FpTa5Lf8heVqw9t97b5VoMU6AGszuBYAz9EzQdeHVFAou7c4W9vFcQ6"
BASE_IMG_URL="ca+https://repeatr.s3.amazonaws.com/warehouse/"

GO_COMPILER_HASH="tar:7st3WqLqTZSvYMGL2i68xMr5F5MhjiFqoXAxigxFN7mdW8GdfaXs7CCu61jeycxdJV"
GO_COMPILER_URL="https://storage.googleapis.com/golang/go1.10.linux-amd64.tar.gz"

RIO_SRC_HASH="git:6faca2d4214a32ce47b4ee6736ee8258cc17f6cb"
RIO_SRC_URL="https://github.com/polydawn/rio"

REPEATR_PLUGIN_RUNC_HASH="tar:9ZaF8VyS4kiVThF3gxFGKVpb3df7wE4vqgTdWFXG5KnQJdYScbjtDsCfxNvQbw6JiB"
REPEATR_PLUGIN_RUNC_URL="ca+https://repeatr.s3.amazonaws.com/warehouse/"

REPEATR_SRC_HASH="git:72b79d281720ea29ca77597e3cdba25d1b7145bc"
REPEATR_SRC_URL="https://github.com/polydawn/repeatr"

STELLAR_SRC_HASH="git:db28b64544c38801773bd24922dc55286d73c96b"
STELLAR_SRC_URL="https://github.com/polydawn/stellar"

REFMT_SRC_HASH="git:b1e39ac01e11fdcd9bfa4b80df2e1f7d4fc982b6"
REFMT_SRC_URL="https://github.com/polydawn/refmt"


### Build Rio.
rr="$(repeatr run <(refmt yaml=json << EOF
  formula:
    inputs:
      "/":         "$BASE_IMG_HASH"
      "/app/go":   "$GO_COMPILER_HASH"
      "/task":     "$RIO_SRC_HASH"
    action:
      exec:
        - "/bin/bash"
        - "-c"
        - |
          export PATH=\$PATH:/app/go/go/bin
          export GOPATH=\$PWD/.gopath
          export GOBIN=\$PWD/bin
          CGO_ENABLED=0 go install --ldflags '-extldflags "-static"' ./cmd/*
    outputs:
      "/task/bin": {packtype: "tar"}
  context:
    fetchUrls:
      "/":         ["$BASE_IMG_URL"]
      "/app/go":   ["$GO_COMPILER_URL"]
      "/task":     ["$RIO_SRC_URL"]
    saveUrls:
      "/task/bin": "ca+file://./warehouse/"
EOF
))"
echo "$rr"
RIO_LINUXAMD64_HASH="$(echo "$rr" | jq -r '.results["/task/bin"]')"


### Build Repeatr.
rr="$(repeatr run <(refmt yaml=json << EOF
  formula:
    inputs:
      "/":         "$BASE_IMG_HASH"
      "/app/go":   "$GO_COMPILER_HASH"
      "/task":     "$REPEATR_SRC_HASH"
    action:
      exec:
        - "/bin/bash"
        - "-c"
        - |
          export PATH=\$PATH:/app/go/go/bin
          export GOPATH=\$PWD/.gopath
          export GOBIN=\$PWD/bin
          CGO_ENABLED=0 go install --ldflags '-extldflags "-static"' ./cmd/*
    outputs:
      "/task/bin": {packtype: "tar"}
  context:
    fetchUrls:
      "/":         ["$BASE_IMG_URL"]
      "/app/go":   ["$GO_COMPILER_URL"]
      "/task":     ["$REPEATR_SRC_URL"]
    saveUrls:
      "/task/bin": "ca+file://./warehouse/"
EOF
))"
echo "$rr"
REPEATR_LINUXAMD64_HASH="$(echo "$rr" | jq -r '.results["/task/bin"]')"


### Build Stellar
rr="$(repeatr run <(refmt yaml=json << EOF
  formula:
    inputs:
      "/":         "$BASE_IMG_HASH"
      "/app/go":   "$GO_COMPILER_HASH"
      "/task":     "$STELLAR_SRC_HASH"
    action:
      exec:
        - "/bin/bash"
        - "-c"
        - |
          export PATH=\$PATH:/app/go/go/bin
          export GOPATH=\$PWD/.gopath
          export GOBIN=\$PWD/bin
          CGO_ENABLED=0 go install --ldflags '-extldflags "-static"' ./cmd/*
    outputs:
      "/task/bin": {packtype: "tar"}
  context:
    fetchUrls:
      "/":         ["$BASE_IMG_URL"]
      "/app/go":   ["$GO_COMPILER_URL"]
      "/task":     ["$STELLAR_SRC_URL"]
    saveUrls:
      "/task/bin": "ca+file://./warehouse/"
EOF
))"
echo "$rr"
STELLAR_LINUXAMD64_HASH="$(echo "$rr" | jq -r '.results["/task/bin"]')"


### Build Refmt.
rr="$(repeatr run <(refmt yaml=json << EOF
  formula:
    inputs:
      "/":         "$BASE_IMG_HASH"
      "/app/go":   "$GO_COMPILER_HASH"
      "/task":     "$REFMT_SRC_HASH"
    action:
      exec:
        - "/bin/bash"
        - "-c"
        - |
          export PATH=\$PATH:/app/go/go/bin
          export GOPATH=\$PWD/.gopath
          export GOBIN=\$PWD/bin
          CGO_ENABLED=0 go install --ldflags '-extldflags "-static"' ./cmd/*
    outputs:
      "/task/bin": {packtype: "tar"}
  context:
    fetchUrls:
      "/":         ["$BASE_IMG_URL"]
      "/app/go":   ["$GO_COMPILER_URL"]
      "/task":     ["$REFMT_SRC_URL"]
    saveUrls:
      "/task/bin": "ca+file://./warehouse/"
EOF
))"
echo "$rr"
REFMT_LINUXAMD64_HASH="$(echo "$rr" | jq -r '.results["/task/bin"]')"


### Build final assembly at the end that takes all the intermediate wares
###  and stitches them together into one easy-to-download omnibus tar!
rr="$(repeatr run <(refmt yaml=json << EOF
  formula:
    inputs:
      "/":                    "$BASE_IMG_HASH"
      "/task/parts/rio":      "$RIO_LINUXAMD64_HASH"
      "/task/parts/repeatr":  "$REPEATR_LINUXAMD64_HASH"
      "/task/parts/runc":     "$REPEATR_PLUGIN_RUNC_HASH"
      "/task/parts/stellar":  "$STELLAR_LINUXAMD64_HASH"
      "/task/parts/refmt":    "$REFMT_LINUXAMD64_HASH"
    action:
      exec:
        - "/bin/bash"
        - "-c"
        - |
          mkdir out
          mkdir out/bin
          mv parts/{rio,repeatr,stellar,refmt}/* out/bin
          mkdir out/bin/plugins
          mv parts/runc/runc out/bin/plugins/repeatr-plugin-runc
    outputs:
      "/task/out": {packtype: "tar"}
  context:
    fetchUrls:
      "/":                    ["$BASE_IMG_URL"]
      "/task/parts/rio":      ["ca+file://./warehouse/"]
      "/task/parts/repeatr":  ["ca+file://./warehouse/"]
      "/task/parts/runc":     ["$REPEATR_PLUGIN_RUNC_URL"]
      "/task/parts/hitch":    ["ca+file://./warehouse/"]
      "/task/parts/stellar":  ["ca+file://./warehouse/"]
      "/task/parts/refmt":    ["ca+file://./warehouse/"]
    saveUrls:
      "/task/out": "ca+file://./warehouse/"
EOF
))"
echo "$rr"
OMNIBUS_LINUXAMD64_HASH="$(echo "$rr" | jq -r '.results["/task/bin"]')"
