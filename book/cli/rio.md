The `rio` Tool
==============

`rio` -- an abbreviation for **R**epeatable **I**nput/**O**utput -- is the
tool in the Timeless Stack which handles all packing, identification, unpacking, transport, and mirroring of filesystems and data.

`rio` is (sort of) comparable to the role of the venerable and ancient `tar`
command: it specifies a way to pack and transport data.  `rio` is also much
more than `tar`, because `rio` also handles identifying data by hash -- we call
this a WareID -- which lets us be clear about handling immutable snapshots of
filesystems.

`rio` has a ton of different capabilities -- it can handle many different pack
formats; as long as a consistent hash can be defined, `rio` can probably handle
it.  Most typically, we use `rio` with the `"tar"` packType, but there's also
support for `"git"` (yes! git support is built in!), and support for more
formats is welcome in the future.

`rio` abstracts the actual storage location from the identity of the data.
The most obvious expression of this is that most of the `rio` commands can
take the `--source=<url>` and `--target=<url>` arguments *multiple times*.
`rio` also has native support for a wide variety of cloud storage systems in
addition to using your local filesystem: AWS S3, GCP Cloud Storage, and local
filesystems can all be used pretty much interchangeably, as well as HTTPS URLs
for read-only modes.


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
