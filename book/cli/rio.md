The `rio` Tool
==============

`rio` -- an abbreviation for **R**epeatable **I**nput/**O**utput -- is the
tool in the Timeless Stack which handles all packing, identification, unpacking, transport, and mirroring of filesystems and data.

`rio` is (sort of) comparable to the role of the venerable and ancient `tar`
command: it specifies a way to pack and transport data.  `rio` is also much
more than `tar`, because `rio` also handles identifying data by hash -- we call
this a WareID -- which lets us be clear about handling immutable snapshots of
filesystems.

CLI synopsis
------------

```
rio pack <packType> <srcPath>
rio unpack <packType:wareID> <dstPath>
rio scan <packType> --source=<url>
rio mirror <packType:wareID> --target=<url...>

```

- `rio pack` takes files on your filesystem and packs them into a Ware (also
  uploading it to a warehouse, if one is specified).
- `rio unpack` fetches a Ware by WareID, and unpack it into a Fileset on your
  local filesystem.
- `rio scan` examines some existing data stream see if it's matches a pack
  format we recognize, and computes its WareID.  This is useful for importing
  data made somewhere outside the Timeless Stack.
- `rio mirror` replicates data to more storage warehouses.

The `rio pack` and `rio unpack` commands contain many flags for how to handle
POSIX permission and ownership bits, as well as timestamps (which are discarded
by default in pack operations, for
[reproducibility](https://reproducible-builds.org/docs/timestamps/) reasons).
Check `rio pack -h` and `rio unpack -h` for more information on those options.
