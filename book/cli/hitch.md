Hitch
=====

Hitch &mdash; [github.com/polydawn/hitch](https://github.com/polydawn/hitch) &mdash;
manages a filesystem database of [Releases](../design/releasing).

Hitch is used by [Layer 3 Planners](../design/API#layer-3) (like [Heft](./heft),
for example) as a source of information for which [Wares](../glossary#Ware)
might be used.  WareIDs discovered by [scanning](./rio#scan) or produced as
results of executing a [Formula](../glossary#Formula) can be added to new
releases... as can entire sets of multi-step build instructions in
[Layer 2](../design/API#layer-2) format.
