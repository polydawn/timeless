Timeless Stack API Layers
=========================

The Timeless Stack APIs are split into several distinct levels, based on their expressiveness.
The lower level layers are extremely concrete references, and focus heavily on
immutability and use of hashes as identifiers; these layers are the "timeless"
parts of the stack, because they leave no ambiguity and are simple serializable
formats.
The higher level layers are increasingly expressive, but also require increasing
amount of interpretation.

- **Layer 0: Identifying Content** &mdash;
    simple, static identifiers for snapshots of filesystems.
- **Layer 1: Identifying Computation** &mdash;
    scripts, plus explicit declarations of needed input filesystem snapshots,
    and selected paths which should be snapshotted and kept as outputs.
- **Layer 2: Computation Graphs** &mdash;
    statically represented pipelines, using multiple isolated computations (each
    with independent, declarative environments) to build complex outputs.
- **Layer 3+: Planners** &mdash;
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


### Layer 0: Identifying Content
<a id=#layer-0>

The most basic part of the Timeless Stack APIs are WareIDs -- hashes, which
identify content, fully immutably.

The main tool at this level is [Rio](./cli/rio).
Operations like `rio pack` and `rio unpack` convert filesystems into packed
Wares (which are easy to replicate to other computers) and WareIDs (so we can
easily refer to the Wares even before copying them)... and back again to filesystems.

#### Data Examples
<a id=#layer-0-examples>

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


### Layer 1: Identifying Computation
<a id=#layer-1>

Formulas and RunRecords -- hashable, contain no human naming, identifying computations, fully static.

The main tool at this level is [Repeatr](./cli/repeatr).  The most common
command is `repeatr run`, which takes a `Formula`, evaluates it, and returns
a `RunRecord` (see the example data structures, below).

#### Data Examples
<a id=#layer-1-examples>

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


### Layer 2: Computation Graphs
<a id=#layer-2>

Basting -- statically represented pipelines consisting of multiple formulas, but some of which do *not* have all inputs pinned, and instead rely on other formulas in the group.

While this layer is still standardized and used by multiple core tools in the timeless stack, it is much more relaxed that the prior two layers: human-selected names are present here to identify the individual step formulas and their relationships.

As a result of the use of human-meaningful names rather than hashes, documents
at Layer 2 are *not* trivially globally content-addressable.
In other words, two different people can write semantically identical
Layer 2 pipelines, which generate totally identically Layer 1 formulas...
and while the Layer 1 formulas *will* converge to the exact same identity
hashes, the Layer pipelines will not.
Examples of differences that may result in identical Layer 1 content but
distinct Layer 2 pipelines include step names (one author may have called a step
`"stepFoo"` while the other titled it `"stepBaz"`) or using the same Wares but
by different aliases (one pipeline might reference a WareID released as
`"foo:v1.0:linux"` while another references it as `"foo:v1.0rc2:linux"` when
those names actually resolve to the same WareID).

#### Data Examples
<a id=#layer-2-examples>

A basting is composed of several formula elements, plus some information to wire
intermediate steps together ("imports") and information to name the final interesting
results ("exports"):

```
{
	"steps": {
		"stepBar": {
			"imports": {
				"/": "example.timeless.io/base:201801:linux-amd64",
				"/woof": "wire:stepFoo:/task/out"
			},
			"formula": {
				"inputs": {
					"/": "tar:6q7G4hWr283FpTa5Lf8heVqw9t97b5VoMU6AGszuBYAz9EzQdeHVFAou7c4W9vFcQ6"
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
			"imports": {
				"/": "example.timeless.io/base:201801:linux-amd64"
			},
			"formula": {
				"inputs": {
					"/": "tar:6q7G4hWr283FpTa5Lf8heVqw9t97b5VoMU6AGszuBYAz9EzQdeHVFAou7c4W9vFcQ6"
				},
				"action": {
					"exec": [
						"bash",
						"-c",
						"mkdir out\nls -la /usr/bin | tee > out/records"
					]
				},
				"outputs": {
					"/task/out": {"packtype": "tar"}
				}
			}
		}
	},
	"exports": {
		"a-final-product": "wire:stepFoo:/task/out"
	},
	"contexts": {
		// ... practical, but non-critical info (e.g. mirror URLs) attaches here
	}
}
```

Evaluating a basting simply evaluates each formula in order, plugs together any
intermediates, and runs the next formula, and so on.  The result is the same as
Layer 1: a series of RunRecords.

Notice how in this example, `"stepBar"`'s Formula has one less `input` than it
does `import`... and that additional `import` is a `"wire"`.  This means it's
dependent on another step in the Basting -- `"stepFoo"`, in this case, and the
output from the `"/task/out"` path when we evaluate that formula.

Exports of final products are the same format as intermediates: a "wire" points
to the outputs from a step.  These "exports" are listed again in a final, additional
`results` map at the end of evaluating a basting.

:warning: Layer 2's `Basting` format is recently developed (early 2018).  It is subject to change.


### Layer 3: Planners
<a id=#layer-3>

Planners at large -- this layer is open to substantial interpretation and not actually standardized; the only constraint for integrating it into the Timeless ecosystem is that whatever is going on at this layer, it has to produce the "basting" format; from there, other tools can interoperate.


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
so the overall semantics of re-executing a whole Layer 2 pipeline should be the
same as an individual Layer 1 step.

Layer 3 is where we finally relax on immutability, and thus it's where we begin
to do the interesting work of generating *new* pipelines and *updating* inputs.
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

Layer 2 Basting is suitable to feed to tools which can traverse graphs and e.g.
draw nice renderings of build dependencies.
Such tools could also ask and quickly answer questions like "Find all
dependencies ever used, recursively, to build $tool-foobar; now, tell me if they
currently have any security vulnerabilities"?

Layer 2 Basting is suitable for publication in a distributed ledger.
This can be used as part of a system to make read-only public audit and
accountability possible.

Layer 2 Basting, like Layer 1 Formulas, can be easily re-evaluated -- even by
other people, other machines, and even months or years later -- so it can be
used to distribute small and reproducible instructions rather than large
binary blobs that take lots of network and disk space.  This makes it excellent
for Continuous Integration / Continuous Deployment systems, which can use it to
track and report the health as well as historical states of large systems.

The possibilities are pretty much endless.  If you can parse a JSON API, you can
build integrations with the Timeless Stack at whatever layer seems the most
useful to *you*.
