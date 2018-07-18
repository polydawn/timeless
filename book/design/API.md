Timeless Stack API Layers
=========================

The Timeless Stack APIs are split into several distinct levels, based on their expressiveness.
The lower level layers are extremely concrete references, and focus heavily on
immutability and use of hashes as identifiers; these layers are the "timeless"
parts of the stack, because they leave no ambiguity and are simple serializable
formats.
The higher level layers are increasingly expressive, but also require increasing
amount of interpretation.

- [**Layer 0: Identifying Content**](#layer-0) &mdash;
    simple, static identifiers for snapshots of filesystems.
- [**Layer 1: Identifying Computation**](#layer-1) &mdash;
    scripts, plus explicit declarations of needed input filesystem snapshots,
    and selected paths which should be snapshotted and kept as outputs.
- [**Layer 2: Computation Graphs**](#layer-2) &mdash;
    statically represented pipelines, using multiple isolated computations (each
    with independent, declarative environments) to build complex outputs.
- [**Layer 3+: Planners**](#layer-3) &mdash;
    use any tools you want to generate Layer 2 pipelines!  The Timeless Stack has
    standard bring import and export APIs, and you can compute Layer 2 however you like!

The Timeless Stack focuses ensuring the lower level layers are appropriate
to track in [version control](https://en.wikipedia.org/wiki/Version_control).
There's a strong separation between Layer 3 and everything below: since Layer 3
may require *computation* itself to generate the Layer 2 specifications, we
require all of the lower layers to make sense and be manipulable *without* any
relationship or dependency on Layer 3 semantics.

As with the layers of a pyramid: the lower layers are absolutely essential
foundation for everything that comes on top of them; and also, relatively small
amounts of code at the highest levels can direct massive amounts of work in
the lower layers.


The Layers, in detail
---------------------


<a id=layer-0></a>
### Layer 0: Identifying Content

The most basic part of the Timeless Stack APIs are WareIDs -- hashes, which
identify content, fully immutably.

The main tool at this level is [Rio](../cli/rio.md).
Operations like `rio pack` and `rio unpack` convert filesystems into packed
Wares (which are easy to replicate to other computers) and WareIDs (so we can
easily refer to the Wares even before copying them)... and back again to filesystems.

<a id=layer-0-examples></a>
#### Data Examples

Data at Layer 0 is very terse: it's all WareIDs, which are a simple string identifier
composed of a "packtype" (e.g. `tar`, `git`, `zip`, etc) and a hash.

These are all examples of WareIDs:

- `tar:6q7G4hWr283FpTa5Lf8heVqw9t97b5VoMU6AGszuBYAz9EzQdeHVFAou7c4W9vFcQ6`
- `tar:8ZaAmtWZbjtNfJWD8nmGRLDn2Ec745wKWoee4Tu1ZcxacdmMWMv1ssjbGrg8kmwn1e`
- `git:825d8382ac3d46deb89104460bbfb5fbc779dab5`
- `git:3cf6a45846f1b33e6459adee244f1ac18ae0d511`

As you can see, these aren't very human-readable.  We'll address this in the
higher protocol layers -- around Layer 2 we'll begin to construct mappings
that associate human-readable names to these opaque and immutable references.


<a id=layer-1></a>
### Layer 1: Identifying Computation

Formulas and RunRecords -- hashable, contain no human naming, identifying computations, fully static.

The main tool at this level is [Repeatr](../cli/repeatr.md).  The most common
command is `repeatr run`, which takes a `Formula`, evaluates it, and returns
a `RunRecord` (see the example data structures, below).

<a id=layer-1-examples></a>
#### Data Examples

A formula looks something like this (in YAML format), though they may have
*many* inputs, and also multiple outputs:

```
# This is a Formula.
inputs:
  "/":       "tar:6q7G4hWr283FpTa5Lf8heVqw9t97b5VoMU6AGszuBYAz9EzQdeHVFAou7c4W9vFcQ6"
  "/app/go": "tar:8ZaAmtWZbjtNfJWD8nmGRLDn2Ec745wKWoee4Tu1ZcxacdmMWMv1ssjbGrg8kmwn1e"
  "/task":   "git:825d8382ac3d46deb89104460bbfb5fbc779dab5"
action:
  exec:
    - "/bin/bash"
    - "-c"
    - |
      export PATH=\$PATH:/app/go/go/bin
      ./goad install
outputs:
  "/task/bin": {packtype: "tar"}
```

As you can see, a Formula composes many of the Layer 0 components.
It also *generates* more Layer 0 WareIDs.
When you feed the above formula to `repeatr run`, you'll get a JSON
object on stdout called a RunRecord, which resembles this one:

```
# This is a RunRecord.
{
	"guid": "c3rms673-o2k84p3y-4ztef48q",
	"time": 1515875768,
	"formulaID": "3vFsH3UbWJZHPrhgckpf5DJrq5DisykE3ND6Z14ineQJxdvZb9iapiKKGtE8ZHEDzM",
	"exitCode": 0,
	"results": {
		"/task/bin": "tar:6XKnQ4Kcf6zmf16VNUAyBHirTEKV8WfB3JunSx3Szenc7keiotuEDCNZjCXcxod7mH"
	}
}
```

RunRecords contain several items which are essentially random -- namely, the
`time` and `guid` fields.  They also contain many fields which should be
deterministic given the same Formula -- specifically, `formulaID` is actually
a **hash** of the Formula that was evaluated; it's an immutable, unforgeable
reference back to the Formula.  Most importantly, though, the RunRecord
contains the `results` map.  This contains a key-value pair of path to WareID --
one pair for each output path specified in the Formula.  The `results` section
depends on what your formula *does*, of course.

Like Formulas, RunRecords can also be hashed to produce unique identifiers.
These hashes cover the unreproducible fields like `time` and `guid`, so they
tend not to collide, and thus are useful as primary key for storing RunRecords.
The collision resistance makes it easy to gather RunRecords from many different
authors -- useful if we want to compare their `results` fields later!

(`repeatr run` will also emit the stdout and stderr printed by your contained
process on its own stderr channel, plus some decoration.  This is configurable,
but the important note here is that we consider those streams to be debug info,
and we don't keep them.  Use `tee` or route them to a file if they're needed
as outputs that can be referenced by other formulas later.)


<a id=layer-2></a>
### Layer 2: Computation Graphs

The Timeless Stack represents multi-stage computations by generating a series of
formulas from a document which has psuedo-formulas, which rather than having all
hashed wareIDs as inputs already pinned, instead uses human-readable names
and references.
These human-readable references can connect the outputs of one formula to be
the inputs of another; or reference external data (e.g. previous releases of
system which have publicly tracked names).

These multi-stage computations are called "modules", and each psuedo-formula is a "step".
The module-local named references which connect Steps are called "slot refs".
Slot Refs can be initialized either by the outputs of a Step, or by external data using a "import".
Imports come in several forms, but the main one is "catalog imports", which refer to snapshots of previously produced data.

At Layer 2 we also begin to have multiple documents of different types which
will all be referenced at the same time.
We have not just the Module which you will author; but will need to import data
from Catalogs, and export releases to put more info into Catalogs for future use.
We're starting move towards updatability rather than repeatability here;
it will be up to the user to make sure all these documents are versioned in
a coherent snapshot for deep-time repeatability.

As a result of the use of human-meaningful names rather than hashes, documents
at Layer 2 are *not* trivially globally content-addressable.
In other words, two different people can write semantically identical
Layer 2 modules, which generate totally identical Layer 1 formulas...
and while the Layer 1 formulas *will* converge to the exact same identity
hashes, the Layer 2 modules may not, if different locally-scoped names were used.
Examples of differences that may result in identical Layer 1 content but
distinct Layer 2 modules include step names (one author may have called a step
`"stepFoo"` while the other titled it `"stepBaz"`) or imports which resolve to
the same Wares but got there via different references (one module might import
a WareID released as `"foo:v1.0:linux"` while another references it as
`"foo:v1.0rc2:linux"`, regardless of whether both names resolve to the same WareID).

<a id=layer-2-examples></a>
#### Data Examples

A module is composed of several steps (mostly "operations", which are the precursor
to a formula, and will generate a formula when all inputs are resolved to hashes),
plus some information to wire intermediate steps together ("imports") and information
to name the final interesting results ("exports"):

```
{
	"imports": {
		"base": "catalog:example.timeless.io/base:201801:linux-amd64"
	},
	"steps": {
		"stepBar": {
			"operation": {
				"inputs": {
					"base": "/",
					"stepFoo.out": "/woof",
				},
				"action": {
					"exec": [
						"cat",
						"/woof/records"
					]
				},
				"outputs": {}
			}
		},
		"stepFoo": {
			"operation": {
				"imports": {
					"base": "/",
				},
				"action": {
					"exec": [
						"bash",
						"-c",
						"mkdir out\nls -la /usr/bin | tee > out/records"
					]
				},
				"outputs": {
					"out": "/task/out"
				}
			}
		}
	},
	"exports": {
		"a-final-product": "stepFoo.out"
	}
}
```

Evaluating a modules simply evaluates each step in order, plugs together any
intermediates, templates this info into a formula, evaluates it, and then turns
the crank for the next step.  (Modules can be automatically topo-sorted based
on dependencies, and Timeless Stack tools will evaluate things in that order.)

The final result of evaluating a Layer 2 Module is very similar to the results
of Layer 1 evaluation: each formula will yield a RunRecord, so we get a whole
series of those which we can retain (mostly for audit purposes)... plus,
we get a map of all the WareIDs produced that were marked for export.

The final map of exports is isomorphic to a catalog release items map.
You can pipe the exports map right into a making a new release!

:warning: Layer 2's `Module` format is recently developed (mid 2018).  It is subject to change.

Modules have several other interesting features, such as "submodules" and
"ingest references" -- docs for these are TODO :)


<a id=layer-3></a>
### Layer 3: Planners

Planners at large -- this layer is open to substantial interpretation and not actually standardized;
the only constraint for integrating it into the Timeless ecosystem is that
whatever is going on at this layer, it has to produce the "basting" format;
from there, other tools can interoperate.


Which layer should I interact with?
-----------------------------------

Which layer you should interact with depends on what kind of work you're doing.

In short, most people will author stuff up at Layer 3.  It's where the most
expressive forms of authorship are at.  But most **tools** will operate on the
lower layers, and integrations with other ecosystems (you want to track releases
on the blockchain?  Hello, welcome!) will similarly want to interface with
these lower layers.


### What can we do *without* Layer 3?

We can do a great deal of work with Layer 0/1/2 alone!

- We can transport snapshots of data, source code, and program binaries;
- We can run programs and compilers (exact versions of them, on exact versions
  of source code and input data);
- and we can run whole pipelines of various programs and compilers, each with
  their own complete environments.

And since all of these pieces of data are serializable, we can commit
entire snapshots of these pipelines to version control.

This means someone else, given this snapshot (and the Timeless Stack tools),
can *reproduce our entire environments, with all dependencies, and repeat our
entire pipeline of data processing*.


### What do we need Layer 3 semantics for, then?

In short, moving forward.

When handling data at Layer 0, it's all immutable.

When handling computations at Layer 1, they're still all immutable.  The only
way that using the same Layer 1 instructions will generate different data is
if they generate *random* data (which is probably a Problem rather than anything
you'd want).

When handling sets of computations at Layer 2, they're *still*, yes still, all
immutable.  Even though some steps refer to other steps for their inputs, the
typical expectation is that each step should reliably produce the same data,
so the overall semantics of re-executing a whole Layer 2 module should be the
same as an individual Layer 1 step.

Layer 3 is where we finally relax on immutability, and thus it's where we begin
to do the interesting work of generating *new* modules and *updating* inputs.
Layer 3 can look up release information from other projects, for
example, and bring that in as an input to the Layer 2 data.
Being precise in this information in Layer 2 is critical for later auditability
and reproducibility; but in Layer 3, we're free to compute new plans using
whatever latest freshest data we want.

Thus, most human authorship happens using Layer 3 tools and languages,
because it provides the most flexibility and leverage -- then,
we bake those plans into Layer 2 immutable data ASAP, in order to get
the best benefits of both worlds (expressive *and* immutable).


### Integration Examples

Layer 0 WareIDs are short and easy to copy-paste to share in emails, slacks,
tweets, or good ol' IRC.  Other people can download data produced by Timeless
Stack pipelines without a fuss.

Layer 1 Formulas can be put on something as simple as *pastebin* in order to
share with other people.
It can be useful for self-contained bug reports, for example.

Layer 2 Modules are suitable to feed to tools which can traverse graphs and e.g.
draw nice renderings of build dependencies.
Such tools could also ask and quickly answer questions like "Find all
dependencies ever used, recursively, to build $tool-foobar; now, tell me if they
currently have any security vulnerabilities".

Layer 2 Modules is suitable for publication in a distributed ledger.
This can be used as part of a system to make read-only public audit and
accountability possible.

Layer 2 Modules, like Layer 1 Formulas, can be easily re-evaluated -- even by
other people, other machines, and even months or years later -- so it can be
used to distribute small and reproducible instructions rather than large
binary blobs that take lots of network and disk space.  This makes it excellent
for Continuous Integration / Continuous Deployment systems, which can use it to
track and report the health as well as historical states of large systems.

The possibilities are pretty much endless.  If you can parse a JSON API, you can
build integrations with the Timeless Stack at whatever layer seems the most
useful to *you*.
