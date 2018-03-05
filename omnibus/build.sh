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

RIO_SRC_HASH="git:21e49c26cb6fbfd5838bc3d9b2da802fc37bcc97"
RIO_SRC_URL="https://github.com/polydawn/rio"

REPEATR_PLUGIN_RUNC_HASH="tar:9ZaF8VyS4kiVThF3gxFGKVpb3df7wE4vqgTdWFXG5KnQJdYScbjtDsCfxNvQbw6JiB"
REPEATR_PLUGIN_RUNC_URL="ca+https://repeatr.s3.amazonaws.com/warehouse/"

REPEATR_SRC_HASH="git:99addc1f0ee65fdc6e8dd03c6e0d13ed2ea212ea"
REPEATR_SRC_URL="https://github.com/polydawn/repeatr"

HITCH_SRC_HASH="git:30fa18f5ee71bde8b07edbab150a83073487e6ad"
HITCH_SRC_URL="https://github.com/polydawn/hitch"

HEFT_SRC_HASH="git:a4857a9e3dbf7a232f3df6d27f4b3e00327110b8"
HEFT_SRC_URL="https://github.com/polydawn/heft"

REFMT_SRC_HASH="git:e8b5eff0fd0354ff81d16c4b28f9dd916fc6aca9"
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
          ./goad install
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
echo $rr
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
          ./fling install
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
echo $rr
REPEATR_LINUXAMD64_HASH="$(echo "$rr" | jq -r '.results["/task/bin"]')"


### Build Hitch.
rr="$(repeatr run <(refmt yaml=json << EOF
  formula:
    inputs:
      "/":         "$BASE_IMG_HASH"
      "/app/go":   "$GO_COMPILER_HASH"
      "/task":     "$HITCH_SRC_HASH"
    action:
      exec:
        - "/bin/bash"
        - "-c"
        - |
          export PATH=\$PATH:/app/go/go/bin
          ./goad
    outputs:
      "/task/bin": {packtype: "tar"}
  context:
    fetchUrls:
      "/":         ["$BASE_IMG_URL"]
      "/app/go":   ["$GO_COMPILER_URL"]
      "/task":     ["$HITCH_SRC_URL"]
    saveUrls:
      "/task/bin": "ca+file://./warehouse/"
EOF
))"
echo $rr
HITCH_LINUXAMD64_HASH="$(echo "$rr" | jq -r '.results["/task/bin"]')"


### Build Heft
rr="$(repeatr run <(refmt yaml=json << EOF
  formula:
    inputs:
      "/":         "$BASE_IMG_HASH"
      "/app/go":   "$GO_COMPILER_HASH"
      "/task":     "$HEFT_SRC_HASH"
    action:
      exec:
        - "/bin/bash"
        - "-c"
        - |
          export PATH=\$PATH:/app/go/go/bin
          export GOPATH=\$PWD/.gopath
          export GOBIN=\$PWD/bin
          go test ./...
          go install ./cmd/...
    outputs:
      "/task/bin": {packtype: "tar"}
  context:
    fetchUrls:
      "/":         ["$BASE_IMG_URL"]
      "/app/go":   ["$GO_COMPILER_URL"]
      "/task":     ["$HEFT_SRC_URL"]
    saveUrls:
      "/task/bin": "ca+file://./warehouse/"
EOF
))"
echo $rr
HEFT_LINUXAMD64_HASH="$(echo "$rr" | jq -r '.results["/task/bin"]')"


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
          ./goad
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
echo $rr
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
      "/task/parts/hitch":    "$HITCH_LINUXAMD64_HASH"
      "/task/parts/heft":     "$HEFT_LINUXAMD64_HASH"
      "/task/parts/refmt":    "$REFMT_LINUXAMD64_HASH"
    action:
      exec:
        - "/bin/bash"
        - "-c"
        - |
          mkdir out
          mkdir out/bin
          mv parts/{rio,repeatr,hitch,heft,refmt}/* out/bin
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
      "/task/parts/heft":     ["ca+file://./warehouse/"]
      "/task/parts/refmt":    ["ca+file://./warehouse/"]
    saveUrls:
      "/task/out": "ca+file://./warehouse/"
EOF
))"
echo $rr
OMNIBUS_LINUXAMD64_HASH="$(echo "$rr" | jq -r '.results["/task/bin"]')"
