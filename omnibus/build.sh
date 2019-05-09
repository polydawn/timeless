#!/bin/bash

## Hello!
## This is a bash script which builds rio, repeatr, and the other components of the Timeless Stack,
## and assembles an omnibus tarball containing all those lovely things.
##
## It's both how we release, and a pretty good demo of using repeatr :)
##
## Identical results should be produced by using the 'module.tl' file
## via the `reach emerge` command in this directory.
## We're keeping both build paths around because this one is a neat demo
## of how to use the APIs!
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

GO_COMPILER_HASH="tar:3SbM6Wy1SpEKxAsEGrdTBLx8L3jHWUsLfASWAjHaT1Tc8294ok3fKnobgYKdVaHs6c"
GO_COMPILER_URL="https://storage.googleapis.com/golang/go1.11.linux-amd64.tar.gz"

RIO_SRC_HASH="git:08fb8cc73674ef1f9db75b16e1450f3d27e03ac5"
RIO_SRC_URL="https://github.com/polydawn/rio"

REPEATR_PLUGIN_RUNC_HASH="tar:9ZaF8VyS4kiVThF3gxFGKVpb3df7wE4vqgTdWFXG5KnQJdYScbjtDsCfxNvQbw6JiB"
REPEATR_PLUGIN_RUNC_URL="ca+https://repeatr.s3.amazonaws.com/warehouse/"

REPEATR_SRC_HASH="git:c51c7956672176eb59c1b0a7f992bd74812fa3dd"
REPEATR_SRC_URL="https://github.com/polydawn/repeatr"

REACH_SRC_HASH="git:6547ee45e14c65b57d07b519da4cbea4236324ea"
REACH_SRC_URL="https://github.com/polydawn/reach"

REFMT_SRC_HASH="git:01bf1e26dd14f9b71f26b7005a2b1ef514d5f9a4"
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


### Build Reach
rr="$(repeatr run <(refmt yaml=json << EOF
  formula:
    inputs:
      "/":         "$BASE_IMG_HASH"
      "/app/go":   "$GO_COMPILER_HASH"
      "/task":     "$REACH_SRC_HASH"
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
      "/task":     ["$REACH_SRC_URL"]
    saveUrls:
      "/task/bin": "ca+file://./warehouse/"
EOF
))"
echo "$rr"
REACH_LINUXAMD64_HASH="$(echo "$rr" | jq -r '.results["/task/bin"]')"


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
      "/task/parts/reach":    "$REACH_LINUXAMD64_HASH"
      "/task/parts/refmt":    "$REFMT_LINUXAMD64_HASH"
    action:
      exec:
        - "/bin/bash"
        - "-c"
        - |
          mkdir out
          mkdir out/bin
          mv parts/{rio,repeatr,reach,refmt}/* out/bin
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
      "/task/parts/reach":    ["ca+file://./warehouse/"]
      "/task/parts/refmt":    ["ca+file://./warehouse/"]
    saveUrls:
      "/task/out": "ca+file://./warehouse/"
EOF
))"
echo "$rr"
OMNIBUS_LINUXAMD64_HASH="$(echo "$rr" | jq -r '.results["/task/bin"]')"
