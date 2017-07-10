Timeless Packages
=================

:warning: this is a Work In Progress :warning:


What are Packages, anyway?
--------------------------

Packages in most linux distros conflate several things:

- packages "depend" on other packages...
- packages include lots of metadata about themselves...
- packages often support "post-install" scripts...
- service restart information...
- user creation...

And thus package mangers end up wearing a lot of hats:

- they manage your $PATH ... ok, fine.
- they select packages ... ok, fine -- but also only meaningful at install time, not run time
- they check for updates ... ok, fine -- but also only meaningful at install time, not run time
- they can be queried for metadata and statuses ... ok, fine -- but also hopefully only meaningful during installs and upgrades, and running services need not query this!
- they manage user IDs and the like ... now we're getting in deep water!  this tends to have *order-dependent* outcomes, which is dangerous to long term maintainence and consistency.
- they run *arbitrary code* by default during installations, since so much glue is required ... and now all control is really lost.

In the Timeless Stack, we want to strip most of that away and return to basics.

In the Timeless Stack, packages are just... Filesets.

In the Timeless Stack, selecting and updating packages can be done in one phase, and
then a formula describing all those packages can be emitted: this is now runnable
*without any additional package management tools* required on the $PATH!

- installation is a no-op: you just... have the fileset.
- metadata is... sparse.
  - the WareID is sufficient to look up *lots* of info, but isn't listed in the fileset itself.  Do this from the outside.
- things following a simple `"$pkgRoot/$appName/bin/*"` path convention can be linked into a reasonable $PATH with one command.
- escape valves are still allowed but discouraged:
  - post-install hooks can be defined, but they're an extension, you shouldn't rely on them unless you absolutely have to, and to be a good citizen a package should behave correctly by emitting warnings if it needed it and it hasn't been run yet.


Lifecycle of Timeless Stack packages
------------------------------------

- Step 1: have all the filesets for all the packages.
- Step 2: run `tlpkg`
- Step 3: done!

What does `tlpkg` *do*?  As little as possible:

- Scan `/app/*` dirs (by default; you can specify other base paths with a flag.)
- For any executable files in paths matching `/app/*/bin/*` or `/app/*/$arch-$os/bin/*`:
  - Symlink to them from `/usr/bin` (by default; you can specify a different bin path with a flag).
- For any files in `/usr/bin` that weren't just created:
  - If the file is a symlink and aims under `/app/*`: remove it.
  - Otherwise, ignore; it was set up by someone else.

The endgame is very simple: everything you installed is now on your $PATH; and it was a one-step process to do this.
