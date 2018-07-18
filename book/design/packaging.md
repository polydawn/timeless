Responsible Packaging
=====================

This section is TODO :)

Cliff notes:

- "Package Management" is really a bunch of things and we need to acknowledge that and split these roles out:
	- *Authoring* packages;
	- Syncing package metadata, and making it possible to compute *selections* of packages;
	- *Distributing* the bulk data of packages;
	- and finally *Installing* packages (and note well, if you weren't able to separate this from *selection*, you dun goofed megabad).
	- Yes, there are some more peripheral bonus features we can define...
		- for example, keeping enumerations of what's been installed on a host
		- but let's not get distracted: these are *bonuses*.  Even that example is stretching it: "has been installed" on a "host" doesn't even *make sense* in all situations, such as containers.
- Okay!  Now that we've got that split defined, we can identify sensible requirements for each role.
	- Authoring is a human story; we'll leave that aside for this discussion.
	- Publishing metadata is the job of catalogs.  This is already well-spec'd in the Timeless Stack.
	- Performing selections is a somewhat freetext area in the Timeless Stack (though if your result is a Module, we certainly do ensure the selection-vs-usage separation).
	- Distributing the bulk data is explicitly out of band for the Timeless Stack -- and because we have the WareID hash contract, that's okay and easy to punt on without compromising other system design details.
	- *Installing* packages is what we want to talk more about.
- Installing should be easy.
	- *This requires rational design up-front*.
	- Easy means stateless.
	- Easy means drag-n-drop.
	- **Easy means no post-install hooks.**

The rest of this document should discuss how we *quantitatively* measure "easy",
then discuss how we make things that qualify.

Spoilers:

- relocatable binaries
- static linking is an acceptable relocatability
- ELF header relative links are too
- the XORIGIN hack
- PATH is still the monster in the shadows
- sharing shared libraries with CA install paths
- or not (and making as that transparent as possible)
