#!/bin/bash

## Hello!
## This is a reppl script which builds reppl, repeatr, and the other components of the Timeless Stack,
## and assembles an omnibus tarball containing all those lovely things.
##
## It's both how we release, and a pretty good demo of using reppl :)
##
## You need repeatr and reppl on your $PATH in order to run this script.
## Download one of the omnibus tarballs to bootstrap.
## (You can also build them from source individually if you like;
## their individual build instructions are in their respective git repos.)
##
## Note: we're currently only building for linux-amd64, sorry :( PRs welcome!!
## Todo: also bundle r2k8s... etc...
##

set -euo pipefail ## standard bash "strict mode"
cd "$(cd -P -- "$(dirname -- "$BASH_SOURCE[0]")" && pwd -P)" ## normalize cwd to "here"

reppl init ## make a project
mkdir -p wares ## make a dir to store intermediates in
## pin some upstream things and assign them names.
reppl put hash base-img           aLMH4qK1EdlPDavdhErOs0BPxqO0i6lUaeRE4DuUmnNMxhHtF56gkoeSulvwWNqT  --warehouse="http+ca://repeatr.s3.amazonaws.com/assets/"
reppl put hash go-compiler-bin    jZ8NkMmCPUb5rTHtjBLZEe0usTSDjgGfD71hN07wuuPfkoqG6pLB0FR4GKmQRAva  --warehouse="https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz"
## pin the source hashes of the tools we're building
reppl put hash repeatr-src        da3a8d252a4215d46d0ddb321de3f2353aa4c480      --kind=git          --warehouse="https://github.com/polydawn/repeatr"
reppl put hash reppl-src          7566e337bc90d1863d823e2baeb80f4e547e85f3      --kind=git          --warehouse="https://github.com/polydawn/reppl"
## do some builds!  each of these is pretty much independent.
reppl eval build-reppl.reppltmpl
reppl eval build-repeatr.reppltmpl
## assemble the omnibus tar!
reppl eval assemble-omnibus.reppltmpl

## done :)
reppl unpack timeless-pkg /opt/timeless
