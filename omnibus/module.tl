{
	"imports": {
		"base": "catalog:early.polydawn.io/monolith/busybash:v1:linux-amd64",
		"go": "catalog:early.hyphae.polydawn.io/go:v1.11:linux-amd64",
		"src_rio": "catalog:timeless.polydawn.io/rio:v0.310:src",
		"src_repeatr": "catalog:timeless.polydawn.io/repeatr:v0.310:src",
		"src_reach": "catalog:timeless.polydawn.io/reach:v0.310:src",
		"src_refmt": "catalog:timeless.polydawn.io/refmt:v0.300:src",
		"runc-bin-linux-amd64": "catalog:timeless.polydawn.io/runc:v0.200.4:bin-linux-amd64"
	},
	"steps": {
		"rio_build": {
			"operation": {
				"inputs": {
					"/":       "base",
					"/app/go": "go",
					"/task":   "src_rio"
				},
				"action": {
					"exec": [
						"/bin/bash", "-c",
						"export PATH=$PATH:/app/go/go/bin && export GOPATH=$PWD/.gopath && export GOBIN=$PWD/bin && CGO_ENABLED=0 go install --ldflags '-extldflags \"-static\"' ./cmd/*"
					]
				},
				"outputs": {
					"bin-linux-amd64": "/task/bin"
				}
			}
		},
		"repeatr_build": {
			"operation": {
				"inputs": {
					"/":       "base",
					"/app/go": "go",
					"/task":   "src_repeatr"
				},
				"action": {
					"exec": [
						"/bin/bash", "-c",
						"export PATH=$PATH:/app/go/go/bin && export GOPATH=$PWD/.gopath && export GOBIN=$PWD/bin && CGO_ENABLED=0 go install --ldflags '-extldflags \"-static\"' ./cmd/*"
					]
				},
				"outputs": {
					"bin-linux-amd64": "/task/bin"
				}
			}
		},
		"reach_build": {
			"operation": {
				"inputs": {
					"/":       "base",
					"/app/go": "go",
					"/task":   "src_reach"
				},
				"action": {
					"exec": [
						"/bin/bash", "-c",
						"export PATH=$PATH:/app/go/go/bin && export GOPATH=$PWD/.gopath && export GOBIN=$PWD/bin && CGO_ENABLED=0 go install --ldflags '-extldflags \"-static\"' ./cmd/*"
					]
				},
				"outputs": {
					"bin-linux-amd64": "/task/bin"
				}
			}
		},
		"refmt_build": {
			"operation": {
				"inputs": {
					"/":       "base",
					"/app/go": "go",
					"/task":   "src_refmt"
				},
				"action": {
					"exec": [
						"/bin/bash", "-c",
						"export PATH=$PATH:/app/go/go/bin && export GOPATH=$PWD/.gopath && export GOBIN=$PWD/bin && CGO_ENABLED=0 go install --ldflags '-extldflags \"-static\"' ./cmd/*"
					]
				},
				"outputs": {
					"bin-linux-amd64": "/task/bin"
				}
			}
		},
		"assemble": {
			"operation": {
				"inputs": {
					"/":                                 "base",
					"/task/parts/rio":         "rio_build.bin-linux-amd64",
					"/task/parts/repeatr": "repeatr_build.bin-linux-amd64",
					"/task/parts/runc":                  "runc-bin-linux-amd64",
					"/task/parts/reach":     "reach_build.bin-linux-amd64",
					"/task/parts/refmt":     "refmt_build.bin-linux-amd64"
				},
				"action": {
					"exec": [
						"/bin/bash", "-c",
						"mkdir out && mkdir out/bin && mv parts/{rio,repeatr,reach,refmt}/* out/bin && mkdir out/bin/plugins && mv parts/runc/runc out/bin/plugins/repeatr-plugin-runc"
					]
				},
				"outputs": {
					"bin-linux-amd64": "/task/out"
				}
			}
		}
	},
	"exports": {
		"bin-linux-amd64": "assemble.bin-linux-amd64"
	}
}
