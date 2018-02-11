Timeless Stack Design
=====================

As we covered in the intro, the Timeless Stack is three things:
a philosophy, some tooling, and an ecosystem that plays nicely together.
Thus, the design documentation also has a major split:
some things are very literal tool and API design subjects,
and some are recommendations and guidelines for good ecosystem integration
in the things you generate with the tools.

- [Timeless Stack API Layers](./API), the next section, covers where
  the core APIs begin and end.  It's important to understand where these
  API layers are separated in order to understand how the Timeless Stack
  facilitates building reusable components *without* going the typical
  road of building a new walled garden of a distro.
- [Release Schema](./releasing) then covers how the Timeless Stack standardizes
  publishing both build instructions and artifact identifiers so that both data
  and all the mechanisms to regenerate that data can be shared.
  This standardization makes it possible for many different projects with many
  different authors to all effectively collaborate, publishing releases and
  maintaining dependency trees even without a centralized online authority.
- [Responsible Packaging](./packaging) takes the next step and describes
  how we recommend building and packaging software for end users
  so that it works well in not just the Timeless Stack ecosystem, but
  also will be trivially exportable to *any* other distro and environment.
  (Note that this section is guidelines and recommendations -- *not* code,
  structures, or requirements.  You can start building software and processing
  data with the Timeless Stack *without* reading this section.)
