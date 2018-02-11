"release" schema
================

:warning: draft document; please forgive the roughness

### Catalogs and Release records

Naming a specific artifact is a three-tuple:

- **Catalog name** -- catalogs represent a project, and a single authoring party.
  (In terms of key management, a Catalog is the unit of signing!)
- **Release name** -- a release may contain several wares, but is made as one
  atomic object.  Releases can be tagged with all sorts of metadata.
  (They also share a single "replay" -- jump to the next section for more
  about replays.)
- **Item name** -- releases often contain several "items" -- a typical example
  is a "docs" item, a "linux-amd64" item, a "darwin-amd64" item, etc.

This complete tuple -- `catalog:release:item` -- is enough to identify a specific WareID.

#### Example data

Here is an example of a single release catalog, containing three releases,
each of which has three or four WareIDs itemized in the release:

```
{
  "name": "domain.org/team/project",
  "releases": [
    {
      "name": "v2.0rc1",
      "items": {
        "docs":         "tar:SiUoVi9KiSJoQ0vE29VJDWiEjFlK9s",
        "linux-amd64":  "tar:Ee0usTSDBLZjgjZ8NkMmCPTHtjUb5r",
        "darwin-amd64": "tar:G9ei3jf9weiq00ijvlekK9deJjFjwi",
        "src":          "tar:KE29VJDJKWlSiUoV9siEjF0vi9iSoQ"
      },
      "metadata": {
        "anything": "goes here -- it's a map[string]string",
        "semver":   "2.0rc1",
        "tracks":   "nightly,beta,2.x"
      },
      "hazards": null,
    },{
      "name": "v1.1",
      "items": {
        "docs":         "tar:iSJSiUoVi9KoQ0vE29VJDWlK9siEjF",
        "linux-amd64":  "tar:BLZEe0usTSDjgjZ8NkMmCPUb5rTHtj",
        "darwin-amd64": "tar:weiG9ei3jf9q00ijvlekK9FjwideJj",
        "src":          "tar:KWlKE29VJDJSiUoV9siEjFiSoQ0vi9"
      },
      "metadata": {
        "anything": "goes here -- it's a map[string]string",
        "semver":   "1.1",
        "tracks":   "nightly,beta,stable,1.x"
      },
      "hazards": null,
    },{
      "name": "v1.0",
      "items": {
        "docs":         "tar:iUiSi0vE29VQJSoVK9sjFJDWiEl9Ko",
        "linux-amd64":  "tar:e0BLTjZ8NkMgZEusb5rtjmCPTHUSDj",
        "src":          "tar:E2KWJUoV9siilK9VSoQi9EjF0viDJS"
      },
      "metadata": {
        "anything": "goes here -- it's a map[string]string",
        "semver":   "1.0",
        "tracks":   "nightly,beta,stable,1.x"
      },
      "hazards": {
        "something critical": "CVE-asdf-1234"
      }
    }
  ]
}
```

Notice that each Release name is unique, but also that releases are stored in
an ordered array rather than an unordered map.  This is to remove any potential
ambiguity or complex decision making about the sorting when a user-facing tool
must decide in what order to present choices.
(Automation should refrain from assuming that the top of the list is "latest",
however -- remember, this is the *Timeless* Stack; "latest" is not a concept
we want to give much credence to at any point in time!)

Release names are free-text.  Typically, we recommend they start with a "v"
out of convention.  It is also typical to follow something roughly resembling
SemVer (though there are many, many variations on this, and the Timeless Stack
does not explicitly recommend nor require adherence to any particular variations
of SemVer rules).

Item names are also free-text.  By convention, the most likely names you'll see
are similar to the ones in this example: "docs" and "src" are extremely common;
tuples representing architecture and host OS like "linux-amd64" are also common.
Usually, the same item names should occur in subsequent releases as in earlier
ones -- tooling that generates formulas using WareIDs from release catalogs
expects the *release* name to change for each new version, but the item names
to remain essentially constant.

### Replay records

```
{"replay": {
  "steps": {
	"build-linux": {
	  "imports": {
		"/":            "hub.repeatr.io/base:2017-05-01:linux-amd64",
		"/app/compilr": "hub.repeatr.io/compilr:1.8:linux-amd64",
		"/task/src":    "wire:prepare-step:/task/output/src"
	  },
	  "formula": {
		"inputs": {
		  "/":                "tar:aLMH4qK1EdlPDavdhErOs0BPxqO0i6",
		  "/app/compilr":     "tar:jZ8NkMmCPUb5rTHtjBLZEe0usTSDjg",
		  "/task/output/src": "tar:KWlKE29VJDJSiUoV9siEjFiSoQ0vi9"
		},
		"action": {
		  "exec": [
			"build-cmd",
			"args"
		  ]
		},
		"outputs": {
		  "/task/logs": "tar",
		  "/task/output": "tar"
		}
	  },
	  "runRecords": {
		"krljthklj": {
		  "uID": "23456-2456792",
		  "time": 23456,
		  "formulaID": "h23hsfiuh48svi",
		  "results": {
			"/task/logs":   "tar:UoV9siSoQKWlKE29VJDJSi0vi9EjFi",
			"/task/output": "tar:BLZEe0usTSDjgjZ8NkMmCPUb5rTHtj"
		  },
		  "hostname": "",
		  "metadata": null
		},
		"zjklalkjn": {
		  "UID": "21552-2456792",
		  "time": 23499,
		  "formulaID": "h23hsfiuh48svi",
		  "results": {
			"/task/logs":   "tar:NkMmCPUb5gjZ8rTHtjBLZEe0usTSDj",
			"/task/output": "tar:BLZEe0usTSDjgjZ8NkMmCPUb5rTHtj"
		  },
		  "hostname": "",
		  "metadata": null
		}
	  }
	},
	"prepare-step": {
	  "imports": {
		"/":         "hub.repeatr.io/base:2017-05-01:linux-amd64",
		"/task/src": "team.net/theproj:2.1.1:src"},
	  "formula": {
		"inputs": {
		  "/":         "tar:aLMH4qK1EdlPDavdhErOs0BPxqO0i6",
		  "/task/src": "git:e730adbee91e5584b12dd4cb438673785034ecbe"},
		"action": {
		  "exec": [ "somecommand" ]},
		"outputs": {
		  "/task/output/docs": "tar",
		  "/task/output/src": "tar"}
	  },
	  "runRecords": {
		"349h34tq34r9p8u": {
		  "UID": "234852-23792",
		  "time": 23495,
		  "formulaID": "oeiru43t3ijjrieqo",
		  "results": {
			"/task/output/docs": "tar:iSJSiUoVi9KoQ0vE29VJDWlK9siEjF",
			"/task/output/src":  "tar:KWlKE29VJDJSiUoV9siEjFiSoQ0vi9"
		  },
		  "hostname": "",
		  "metadata": null
		}
	  }
	}
  },
  "products": {
	"src":         "wire:prepare-step:/task/output/src",
	"docs":        "wire:prepare-step:/task/output/docs",
	"linux-amd64": "wire:build-linux:/task/output"
  }
}
```

Features:

- Each step contains the formula -- including pinned input hashes.
- Each step contains the hitch release identifiers, so you can recursively look up those things.
- Each step can refer to other steps with "wire" imports, so you can represent multi-step builds.
- The "products" section describes which steps produced the final outputs -- these names are the same as the items labeled in the main release document.
