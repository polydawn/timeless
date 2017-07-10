
What is the Timeless Stack?
---------------------------

The Timeless Stack is a software ecosystem that's about *making computers reliable*.

### What is "reliable"?

Reliable means the system changes when you want it to, and *stays the same* when not explicitly changed.

Change needs to be easy.  Updates need to be simple.
Simultaneously, control is paramount: *unexpected* change and *unwanted* updates need to be preventable.

Reliability also implies *decentralization*.
Relying on a remote system is not reliable.
Managing change control based on a network service is not reliable.
Change control needs to be something that different systems and different people can own, individually, and needs to operate free-standing.

### What is our edge?

To be reliable, the Timeless Stack builds everything around snapshots, immutable data,
and reproducible transformations.

To do this, the Timeless Stack encompasses...

- **handling snapshots of files**
- **building software** in containers
- **publishing releases** that associate names and metadata to filesets snapshots
- and **distributing packages** of filesets that assemble into useful systems!

It's a lot of responsibilities.  We've broken them up into several tools.  Use the parts you need.  Ditch the ones you don't.  Each tool is API-driven and can be used in isolation, or glues together easily with the others.

At the foundation is Timeless Repeatr: a tool that defines a total sandbox for data processing and running programs, which works together with the concept of a Timeless Fileset in order to be reproducible anywhere, anywhen.
Repeatr consumes a document we call a Formula: in keeping with the theme, it's all timeless.  No dates; just Filesets.

Timeless Hitch records IDs for Timeless Filesets __together with__ the Timeless Repeatr Formulas that produced them.
Timeless Hitch is both a release management system, an update tracking database, and *build instructions* for everything it tracks: with Timeless Hitch, we finally have all the advantages of a source distribution and a binary distribution *in the same system*.

Jump down to the 'Tools' heading for an overview of the other core tools; but we recommend scanning the 'Concepts' heading first, for vocab.


Concepts
--------

|  Subject                           |  Concept          |  Meaning   |
|-----------------------------------:|:-----------------:|:-----------|
| Data/Files                         | Fileset           |  A set of files and directories, including standard posix metadata.  Nothing special :)
| Data/Files                         | Ware              |  The "packed" form of a Fileset.  Tarballs, git commits; many formats are defined.  Wares are immutable and indexed by 'WareID'.
| Data/Files                         | WareID            |  The __hash__ identifying a Ware.  Holding a WareID gives you an immutable reference to a Ware which you can unpack into a Fileset.
| Builds/Compute<br>/Transformation  | Formula           |  A complete definition of a computation.  Pins all input filesystems by WareID.  Runs in a sandbox.  Running produces a 'runrecord'.
| Builds/Compute<br>/Transformation  | Formula.Inputs    |  A group of Filesets and where to mount them in a directory tree when setting up the formula and preparing to exec.
| Builds/Compute<br>/Transformation  | Formula.Action    |  A script to run inside the container when evaluating a formula.
| Builds/Compute<br>/Transformation  | Formula.Output    |  A list of paths to save when the formula's action is complete.  Files under an output path will be exported as a Ware, and when the run is complete, the WareIDs are reported.
| Builds/Compute<br>/Transformation  | SetupHash         |  The hash of a 'formula'.  This is the unique name of a computation!  Use it as a primary key; memoize builds with it!
| Builds/Compute<br>/Transformation  | RunRecord         |  The result of running a 'formula'.  Includes a 'results' map, and also metadata like timestamp and UID (thus, runrecords are always unique).
| Builds/Compute<br>/Transformation  | Results           |  The group of WareIDs produced when a 'formula' is evaluated -- one WareID for every 'output' path!

Tools
-----

|  Tool       |  Repo                                           |  Role      |
|:-----------:|:-----------------------------------------------:|:-----------|
| `repeatr`   | [github](https://github.com/polydawn/repeatr)   |  Repeatr evaluates formulas.  `formula` ---`repeatr run`---> `runrecord`
| `hitch`     | [github](https://github.com/polydawn/hitch)     |  Hitch associates human-readable names and metadata to WareIDs.  It's a release tracking system.
| `rio`       | [github](https://github.com/polydawn/rio)       |  R-I/O stands for Repeatable Input/Output: it's tooling for packing Filesets into Wares, mirroring Wares between storage systems, and unpacking Filesets fetched by WareID.  Glue for getting files to and from other systems, in other words.
| `reppl`     | [github](https://github.com/polydawn/reppl)     |
| `rpkg`      | planned                                         |



Why hashes?  Why can't I just download "somefoo-vbar.baz.tar.gz"?
-----------------------------------------------------------------

Repeatr and the Timeless Stack uses hashes for WareIDs for the same reason stores use SKUs and part numbers: consistency and reliability.

As an individual, you can go to a hardware store and ask for a 5mm screw.  But you haven't really picked yet by saying that: the store staff will show you to an entire rack of screws.

If you're the manager of a factory, you order your screws by their part number, because you don't want to re-order screws halfway through a project and end up with a subtly different threading, or screws that are too *long* in some other dimension, and so forth.
Similarly, as a hardware store manager, your organize your stocks and reorder supplies by their SKUs, because *consistency is important*.

Store bins may have labels of all sorts of descriptions in various precision to help you select which items you need, but the store itself is tracking inventory by SKUs, because a single, precise identifier is vastly simpler to work with.

Repeatr is the same: we use hashes to identify files and data because it's *simple* and it's *consistent* and it's *immune to silent changes* over time.
End-to-end use of hashes is part of what makes the Timeless Stack... *timeless*.
