#!/bin/bash
set -euo pipefail

BASE_IMG_HASH="tar:6q7G4hWr283FpTa5Lf8heVqw9t97b5VoMU6AGszuBYAz9EzQdeHVFAou7c4W9vFcQ6"
BASE_IMG_URL="ca+https://repeatr.s3.amazonaws.com/warehouse/"

GO_COMPILER_HASH="tar:8ZaAmtWZbjtNfJWD8nmGRLDn2Ec745wKWoee4Tu1ZcxacdmMWMv1ssjbGrg8kmwn1e"
GO_COMPILER_URL="https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz"

RIO_SRC_HASH="git:825d8382ac3d46deb89104460bbfb5fbc779dab5"
RIO_SRC_URL="https://github.com/polydawn/rio"

REPEATR_PLUGIN_RUNC_HASH="tar:9ZaF8VyS4kiVThF3gxFGKVpb3df7wE4vqgTdWFXG5KnQJdYScbjtDsCfxNvQbw6JiB"
REPEATR_PLUGIN_RUNC_URL="ca+https://repeatr.s3.amazonaws.com/warehouse/"

REPEATR_SRC_HASH="git:892c1eee2641ea49c4d1d3e606630a76c8157f99"
REPEATR_SRC_URL="https://github.com/polydawn/repeatr"

HITCH_SRC_HASH="git:412cd1d14836502b86fb4d66059890d4ed48ec97"
HITCH_SRC_URL="https://github.com/polydawn/hitch"

REFMT_SRC_HASH="git:4a659d150bf4e66fe6f74ab510ffc059db6936fe"
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
      "/task/parts/refmt":    "$REFMT_LINUXAMD64_HASH"
    action:
      exec:
        - "/bin/bash"
        - "-c"
        - |
          mkdir out
          mkdir out/bin
          mv parts/{rio,repeatr,hitch,refmt}/* out/bin
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
      "/task/parts/refmt":    ["ca+file://./warehouse/"]
    saveUrls:
      "/task/out": "ca+file://./warehouse/"
EOF
))"
echo $rr
OMNIBUS_LINUXAMD64_HASH="$(echo "$rr" | jq -r '.results["/task/bin"]')"
