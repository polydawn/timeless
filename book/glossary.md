Glossary
========

<style>
/* We heavily re-style h5 elements here so that mdbook generates nice links. */
h5 {
	display: inline-block;
	margin: 1em 0 0 0;
}
h5:after {
	font-weight: normal;
	content: " — ";
	margin: 0 0.5em;
}
p {
	display: inline;
}
/* We use HR to force breaks back in between defn's.  This is just bending */
/* over backwards to try to keep <angles> out of our markdown. */
/* The important bangs are mostly to communicate to atom's markdown preview. */
hr {
	visibility: hidden;
	margin: 0 !important;
	padding: 0 !important;
	height: 0 !important;
}
</style>


##### Fileset

A Fileset is a term referring to set of files and directories, including some
standard posix metadata.  Roughly, you can consider it interchangeable with
simply saying "directory".  We give it a name in the Timeless Stack glossary
just to speak about it unambiguously.
A Fileset can be "packed" into a '[Ware](#Ware)'.

---

##### Ware

The "packed" form of a [Fileset](#Fileset).
Tarballs, git commits; many formats are defined.
Wares are immutable and identified a by '[WareID](#WareID)'.
We say that we "pack" a Fileset into a Ware, which results in a WareID;
and we an "unpack" a Ware to produce a Fileset after fetching it by WareID.

---

##### WareID

The __hash__ identifying a Ware.
Holding a WareID gives you an immutable reference to a [Ware](#Ware)
(which you can unpack into a [Fileset](#Fileset)).

---

##### content-addressable

Describes the practice of identifying data based on its own content
(rather than identifying it based on a name which conveys other meanings).
Typically implemented by using a cryptographic hash over the content.
Content-addressable systems are immutable.

----

##### Formula

An API structure describing a series of [Ware](#Ware)s,
how to arrange them in a filesystem, some action to perform on them,
and what parts of the filesystem to save as resultant Wares.
Since Wares in a Formula are referred to by their content-addressable
[WareID](#WareID), Formulas in turn are an immutable description of how to set
up and run something.
[Repeatr](./cli/repeatr.md) evaluates a Formula to produce a [RunRecord](#RunRecord).

---


<!--
**catalog**: A named record pointing to one or more `ware`s.  Catalogs associate the name to the `ware`'s hash, and are usually cryptographically signed.  Catalogs are a mutable structure, but also  continue to carry references to previously-referenced `ware`s even when updated.
-->

<!-- it's funny because this much older concept was still pretty close to the mark:

**commission**: A document naming a series of `catalog`s, how to arrange their referenced `ware`s in a filesystem, some action to perform on them, and which `catalog`s should be updated to refer to new `ware`s saved from parts of the resultant filesystem.  In other words -- like formulas, but connected to catalogs instead of directly to wares.
-->
