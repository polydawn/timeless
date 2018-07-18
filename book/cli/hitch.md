Hitch
=====

Hitch &mdash; [github.com/polydawn/hitch](https://github.com/polydawn/hitch) &mdash;
manages a filesystem database of [Releases](../design/releasing.md).

Hitch is used by [Layer 3 Planners](../design/API.md#layer-3) (like [Heft](./heft.md),
for example) as a source of information for which [Wares](../glossary.md#Ware)
might be used.  WareIDs discovered by [scanning](./rio.md#scan) or produced as
results of executing a [Formula](../glossary.md#Formula) can be added to new
releases... as can entire sets of multi-step build instructions in
[Layer 2](../design/API.md#layer-2) format.
