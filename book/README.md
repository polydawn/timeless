Welcome
=======

Welcome to the Timeless Stack documentation.

The Timeless Stack is a suite of tools for running processes repeatedly.
All of the tools and APIs in the stack are tailored to make
task definition precise, environment setup portable, and results reproducible.

The Timeless Stack is the logical next step for Linux Containers:
isolation and sandboxing processes is a critical start: the Timeless Stack tools
now let you take total control of your container image builds with a purely
functional and, well, *timeless* approach to composition and dependency management.


Philosophy and Goals
--------------------

The Timeless Stack is about reliable computing.
Reliable software builds; reliable data processing: and enabling them
through reliable data storage, and making the processing itself just another
piece of data we can easily reason about.

Container technology is a key part of our approach to reliability:
containers makes it *possible* to have a *zero-ambiguity environment*,
where all the inputs necessary to make a process run are absolutely clear.

More important than the technology though is the principles of how we use it:

- *Zero-ambiguity environment*: the Timeless Stack is developed on the principle of "precise-by-default".

- *Deep-time reproducibility*: the Timeless Stack represents a commitment to reproducible results today,
  tomorrow, next week, next year, and... you get the picture.

- *Communicable results*: the Timeless Stack describes processes in a Formula.
  Communicating a Formula -- via email, gist, pastebin, whatever -- should be enough for anyone to repeat your work.
  Everything in the Timeless Stack is API-driven, easy to serialize, and easy to share.

- *Control over data flow*: Unlike other container systems, in the Timeless Stack
  you can compose filesystem trees how you want: multiple inputs, in any order; and
  explicitly declare sections of filesystem that are useful results to export
  (meaning just as importantly, you can choose what files to leave behind).
  Granular control lets you build pipelines that are clean, explicit, and fast.
  More importantly, it lets us reason about our processes, and thus
  scale up our ability to share.

- *Labeling instead of contamination*: The Timeless Stack configuration explicitly
  enforces a split between << data identity >> and << data naming >>.
  We work with hashes as primary identifiers, which it easy to decentralize
  any processing built with the Timeless Stack.

- *Variation builds on precision*: the Timeless Stack designs for systems like automatic
  updates and matrix tests on environmental variations by building them *on top*
  of the zero-ambiguity/deep-time-reproducible API layer of Formulas.
  This allows clear identification of each version/test/etc, making it possible to
  clearly report what's been covered and what needs to be finished.

The Timeless Stack is not a build tool, and it's not just a container image builder; think of it more as a workspace manager.
It's important to have a clean workspace, fill it with good tools, and keep the materials going both in and out of your workspace well-inventoried.
Like other container systems, you can use `make`, `cake`, `rake`, `bake`, or whatever's popular this month inside a Timeless Stack Formula;
*unlike* other container systems, with the Timeless Stack you can control the inputs separately, update them separately, and
perhaps most importantly of all actually produce results which are smaller than the whole fileset you started with.

All of these properties come together towards two big goals:

- Decentralization: things built with the Timeless Stack can be built again, anywhere, by anyone, and anywhen.
- Simplicity: shipping full system images is great, but with the Timeless Stack you can *also* choose to produce
  more granular products, which lets you keep individual parts simple even while building bigger systems.


Let's hear more...!
-------------------

You should see a table of contents on the left, and page-flip buttons just below.
(On mobile screens, you may need to click the "pancake stack" icon at the top of
the page to show/hide the table of contents.)

If you're evaluating the Timeless Stack to understand why the project exists
and what's unique about the ecosystem, you'll want to start with the
[Design](./design/README.md) chapters.

If you're a person of action: the [Quickstart](./quickstart.md) section has
examples of using the tools.  The quickstart examples start with the lowest
level tools, then work gradually up the stack to the more expressive layers --
so keep this in mind if you have limited patience or time to experiment; the
commands you'll use the most in practice are actually at the end of the
quickstart series.

If you just need to brush up on some reference material: head to the
[CLI docs](./cli/README.md).  (But keep in mind most of the tools will also
generate their own help text in response to the `-h` or `--help` commands!)

The [Glossary](./glossary.md) is also a good quick reference for core concepts.

To get to source code, jump to the [CLI docs](./cli/README.md), and each tool's
source repo will be linked from their individual reference pages.

For a new reader, we recommend giving the [Design](./design/README.md) chapters
a quick skim for highlights, but jump to the [Quickstart](./quickstart.md)
examples as soon as things get too abstract.  Go back and forth in whatever
order interests you!

Happy hacking!
