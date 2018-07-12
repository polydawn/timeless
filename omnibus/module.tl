{
	"imports": {
		"base": "catalog:images.polydawn.io/busybash:v1:linux-amd64",
		"go": "catalog:entwine.polydawn.io/go:v1.10:linux-amd64",
		"src_rio": "catalog:timeless.polydawn.io/rio:v0.200.4:src",
		"src_repeatr": "catalog:timeless.polydawn.io/repeatr:v0.200.4:src",
		"src_hitch": "catalog:timeless.polydawn.io/hitch:v0.200.4:src",
		"src_heft": "catalog:timeless.polydawn.io/heft:v0.200.4:src",
		"src_refmt": "catalog:timeless.polydawn.io/refmt:v0.200.4:src",
		"runc-bin-linux-amd64": "catalog:timeless.polydawn.io/runc:v0.200.4:bin-linux-amd64"
	},
	"steps": {
		"rio_build": {
			"operation": {
				"inputs": {
					"base": "/",
					"go": "/app/go",
					"src_rio": "/task"
				},
				"action": {
					"exec": [
						"/bin/bash", "-c",
						"export PATH=$PATH:/app/go/go/bin && ./goad install"
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
					"base": "/",
					"go": "/app/go",
					"src_repeatr": "/task"
				},
				"action": {
					"exec": [
						"/bin/bash", "-c",
						"export PATH=$PATH:/app/go/go/bin && ./fling install"
					]
				},
				"outputs": {
					"bin-linux-amd64": "/task/bin"
				}
			}
		},
		"hitch_build": {
			"operation": {
				"inputs": {
					"base": "/",
					"go": "/app/go",
					"src_hitch": "/task"
				},
				"action": {
					"exec": [
						"/bin/bash", "-c",
						"export PATH=$PATH:/app/go/go/bin && ./goad"
					]
				},
				"outputs": {
					"bin-linux-amd64": "/task/bin"
				}
			}
		},
		"heft_build": {
			"operation": {
				"inputs": {
					"base": "/",
					"go": "/app/go",
					"src_heft": "/task"
				},
				"action": {
					"exec": [
						"/bin/bash", "-c",
						"export PATH=$PATH:/app/go/go/bin && export GOPATH=$PWD/.gopath && export GOBIN=$PWD/bin && go test ./... && go install ./cmd/..."
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
					"base": "/",
					"go": "/app/go",
					"src_refmt": "/task"
				},
				"action": {
					"exec": [
						"/bin/bash", "-c",
						"export PATH=$PATH:/app/go/go/bin && ./goad"
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
					"base": "/",
					"rio_build.bin-linux-amd64": "/task/parts/rio",
					"repeatr_build.bin-linux-amd64": "/task/parts/repeatr",
					"runc-bin-linux-amd64": "/task/parts/runc",
					"hitch_build.bin-linux-amd64": "/task/parts/hitch",
					"heft_build.bin-linux-amd64": "/task/parts/heft",
					"refmt_build.bin-linux-amd64": "/task/parts/refmt"
				},
				"action": {
					"exec": [
						"/bin/bash", "-c",
						"mkdir out && mkdir out/bin && mv parts/{rio,repeatr,hitch,heft,refmt}/* out/bin && mkdir out/bin/plugins && mv parts/runc/runc out/bin/plugins/repeatr-plugin-runc"
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
