Formulas
========

Formulas are one of the core API objects in the Timeless Stack.
They're a [Layer 1](../design/API#layer-1) object in the big picture.

Formulas are a description of a container, as a pure function:
we list inputs (by hash, thus immutably), then describe a process,
and list what paths in the filesystem we want to save as outputs.

Formula **inputs** and **outputs** are fairly straightforward; you can quickly get
a grasp of what they're representing if you've already understood the
[rio](../cli/rio) command and the [Layer 0](../design/API#layer-0) model
of [Wares](../glossary#Ware).

Formula **actions** can include many details, covered in further sections:

- [Default Values](./defaults)
- [Execution Policy](./policy)
