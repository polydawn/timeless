Timeless Stack API Layers
=========================

The Timeless Stack APIs are split into several distinct levels, based on their expressiveness.
The lower level layers are extremely concrete references, and focus heavily on
immutability and use of hashes as identifiers; these layers are the "timeless"
parts of the stack, because they leave no ambiguity and are simple serializable
formats.
The higher level layers are increasingly expressive, but also require increasing
amount of interpretation.

- Layer 0: Identifying Content --
    simple, static identifiers for data in filesystems.
- Layer 1: Identifying Computation --
    scripts, plus explicit references to outputs and inputs.
- Layer 2: Computation Graphs --
    statically represented pipelines, using multiple isolated computations (with completely independent control over their environments) to build outputs.
- Layer 3: BYOP (Bring Your Own Planner) --
    use any tools you want to generate Layer 2 pipelines; we'll bring import and export APIs!

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


### Layer 0: Identifying Content

WareIDs -- hashes, identifying content, fully static.

The main tool at this level is [`rio`](./cli/rio.md).


### Layer 1: Identifying Computation

Formulas and RunRecords -- hashable, contain no human naming, identifying computations, fully static.

The main tool at this level is [`repeatr`](./cli/repeatr.md).


### Layer 2: Identifying Content

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
"stepFoo" while the other titled it "stepBaz") or using the same Wares but by
different aliases (one pipeline might reference a WareID released as "foo:v1.0:linux" while another references it as "foo:v1.0rc2:linux" when those names actually resolve to the same WareID).

### Layer 3: Planners

Planners at large -- this layer is open to substantial interpretation and not actually standardized; the only constraint for integrating it into the Timeless ecosystem is that whatever is going on at this layer, it has to produce the "basting" format; from there, other tools can interoperate.


What can we do *without* Layer 3?
---------------------------------

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


What do we need Layer 3 semantics for, then?
--------------------------------------------

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

Layer 3 is where we actually do the interesting work of generating *new* pipelines.  Layer 3 can look up release information from other projects, for
example, and bring that in as an input to the Layer 2 data.
Being precise in this information in Layer 2 is critical for later auditability
and reproducibility; but in Layer 3, we're free to compute new plans using
whatever latest freshest data we want.
