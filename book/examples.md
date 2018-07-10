Examples
========

These are the examples you are looking for :)

- The simplest, single formula (single container):
	- [polydawn/repeatr/example_03_output.formula](https://github.com/polydawn/repeatr/blob/c87a4d705ed42a401c7f1a82604ab8ab226955e8/example_03_output.formula)
	- Note that this is a dummy example with only one input; you can add more input paths and output paths.
	- If you run this, you'll get a JSON object on stdout with the output filesystem hashes.

- What if we piped those together with bash:
	- [polydawn/timeless/omnibus/build.sh](https://github.com/polydawn/timeless/blob/df9c431880fdebaafb86436ef7d5c8f38f2dcc01/omnibus/build.sh)
	- This is horrible -- "updating" hashes by bash vars, using `jq` to extract outputs -- but it works and you can see all the moving parts (not many).
	- This script builds the binary releases of the Timeless stack tools.  It is reproducible and self-hosting.
	- If you download the release binaries on github, then run the script, **it will reproduce the same tarball**.  Try it!

- Okay, now let's move beyond the bash.
	- We'll start using locally scoped names here -- but it still generates the purely hashy documents as earlier.
	- 1) Spec actions like this:
		- [polydawn/stellar/examples/hellomodule/.timeless/module.tl](https://github.com/polydawn/stellar/blob/8dc00ed104b2f60a974ba8aedfaca6cee0177594/examples/hellomodule/.timeless/module.tl)
	- 2) You can refer to releases like this:
		- [polydawn/stellar/examples/hellomodule/.timeless/catalog/froob.org/base/catalog.tl](https://github.com/polydawn/stellar/blob/8dc00ed104b2f60a974ba8aedfaca6cee0177594/examples/hellomodule/.timeless/catalog/froob.org/base/catalog.tl)
	- 3) You'll get output like this:
		- [polydawn/stellar/examples/hellomodule/helloModule_test.go#L16-L24](https://github.com/polydawn/stellar/blob/8dc00ed104b2f60a974ba8aedfaca6cee0177594/examples/hellomodule/helloModule_test.go#L16-L24)
	- 4) Cool.
	- This was still one step.  Let's get cooler.

- Now let's do multi-step pipelines.
	- 1) Spec actions like this:
		- [polydawn/stellar/examples/recursivemodule/.timeless/module.tl](https://github.com/polydawn/stellar/blob/8dc00ed104b2f60a974ba8aedfaca6cee0177594/examples/recursivemodule/.timeless/module.tl)
		- Notice you can add more "modules" recursively -- this gives you locally scoped references; composable++
	- 2) You can refer to releases the same as above.
	- 3) You'll get output like this:
		- [polydawn/stellar/examples/recursivemodule/recursiveModule_test.go#L16-L29](https://github.com/polydawn/stellar/blob/8dc00ed104b2f60a974ba8aedfaca6cee0177594/examples/recursivemodule/recursiveModule_test.go#L16-L29)
	- 4) Cool!
	- This did a topological sort, executed all the containers in order, pipelined the hashes of filesystem snapshots between them, and all that jazz.
	- Let's get cooler.

- I heard you like CI but hate cloud
	- Why *wouldn't* CI work on localhost?
	- Use a git "ingest" -- it looks up a git hash from the HEAD in your local repo.
	- [polydawn/stellar-demo/.timeless/module.tl#L4](https://github.com/polydawn/stellar-demo/blob/26cb507ca02a04b9eb5435fe486d6d8d0e0cfd65/.timeless/module.tl#L4)
	- run it every time you commit
	- tada
