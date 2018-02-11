Heft
====

Heft &mdash; [github.com/polydawn/heft](https://github.com/polydawn/heft) &mdash;
is a [Layer 3](../design/API#layer-3) "planning" tool, which generates
[Layer 2](../design/API#layer-2) computation graphs for execution.

Heft uses info from [release](../design/releasing) databases managed by
[Hitch](./hitch) to select which versions of [Wares](../glossary#Ware) to use.
The computation graphs Heft produces can be evaluated by [Repeatr](./repeatr),
and the results of this evaluation are more Wares (which can be put into a new
release!).
