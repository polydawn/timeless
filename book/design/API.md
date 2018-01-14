Timeless Stack API Layers
=========================

The Timeless Stack APIs are split into several distinct levels, based on their expressiveness versus their staticness.

0. WareIDs -- hashes, identifying content, fully static.
1. Formulas and RunRecords -- hashable, contain no human naming, identifying computations, fully static.
2. Basting -- statically represented pipelines consisting of multiple formulas, but some of which do *not* have all inputs pinned, and instead rely on other formulas in the group.
  While this layer is still standardized and used by multiple core tools in the timeless stack, it is much more relaxed that the prior two layers: human-selected names are present here to identify the individual step formulas and their relationships (and as a result, these documents are *not* trivially globally content-addressable).
3. Planners at large -- this layer is open to substantial interpretation and not actually standardized; the only constraint for integrating it into the Timeless ecosystem is that whatever is going on at this layer, it has to produce the "basting" format; from there, other tools can interoperate.
