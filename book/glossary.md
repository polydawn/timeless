Glossary
========

<style>
/* We heavily re-style h5 elements here so that mdbook generates nice links. */
h5 {
	display: inline-block;
}
h5:after {
	font-weight: normal;
	content: " — ";
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

