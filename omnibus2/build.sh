#!/bin/bash
set -euo pipefail

BASE_IMG_HASH="tar:6q7G4hWr283FpTa5Lf8heVqw9t97b5VoMU6AGszuBYAz9EzQdeHVFAou7c4W9vFcQ6"
BASE_IMG_URL="ca+https://repeatr.s3.amazonaws.com/warehouse/"

GO_COMPILER_HASH="tar:8ZaAmtWZbjtNfJWD8nmGRLDn2Ec745wKWoee4Tu1ZcxacdmMWMv1ssjbGrg8kmwn1e"
GO_COMPILER_URL="https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz"

RIO_SRC_HASH="git:1bf0880eff3d9772d610c182e78b3bc7b772eb90"
RIO_SRC_URL="https://github.com/polydawn/rio"

REPEATR_PLUGIN_RUNC_HASH="tar:todo"
REPEATR_PLUGIN_RUNC_URL="ca+https://repeatr.s3.amazonaws.com/warehouse/"

REPEATR_SRC_HASH="git:892c1eee2641ea49c4d1d3e606630a76c8157f99"
REPEATR_SRC_URL="https://github.com/polydawn/repeatr"

HITCH_SRC_HASH="git:todo"
HITCH_SRC_URL="https://github.com/polydawn/hitch"

REFMT_SRC_HASH="git:todo"
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
RIO_LINUXAMD64_HASH="$(jq -r '.results["/task/bin"]')"


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
REPEATR_LINUXAMD64_HASH="$(jq -r '.results["/task/bin"]')"


### TODO build formulas for the rest

### TODO an assembly formula at the end that takes all the intermediate wares
###  and stitches them together into one easy-to-download omnibus tar!
