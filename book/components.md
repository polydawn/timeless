Components
==========

The Timeless Stack is broken up into a series of "Do One Job and Do It Well" components.
Each of these is built into a separate executable and runs as a separate process.
In addition to this manual, each project also has detailed documentation in its own repo.

These are all the individual source repositories for Timeless Stack component processes:


| Repo                                                             |  Role     |
|:----------------------------------------------------------------:|:----------|
| [timeless](https://github.com/polydawn/timeless)               |  docs -- this book's source is here!
| [repeatr](https://github.com/polydawn/repeatr)                 |  repeatr evaluates formulas.  `formula` ---`repeatr run`---> `runrecord`.  Most of the other major docs are here.
| [rio](https://github.com/polydawn/rio)                         |  rio, our Repeatable Input/Output component: tooling for packing Filesets into Wares, mirroring Wares between storage systems, and unpacking Filesets fetched by WareID.  Glue for getting files to and from other systems, in other words.
| [hitch](https://github.com/polydawn/hitch)                     |  hitch associates human-readable names and metadata to WareIDs.  It's a release tracking system.
| [heft](https://github.com/polydawn/heft)                       |  heft (experimental) is a Skylark-based "language" for composing formulas programatically
| [go-timeless-api](https://github.com/polydawn/go-timeless-api) |  developers: here's the common API library
