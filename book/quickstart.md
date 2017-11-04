Getting Started with Repeatr and the Timeless Stack
===================================================

In this getting started doc, we'll show working examples
You should be able to copy the snippets in this file directly,
and they should work without modification.
You should be able to modify them afterwards to build in the
directions you wish to explore.


prerequisites
-------------

- a linux kernel (we're about to use linux containers).
- either the timeless stack tool binaries, OR a go compiler to build them.

The host system requirements for running the core Timeless Stack tools
is intentionally very, very small.



installing
----------

First things first: we'll need a
[`repeatr`](./tools-repeatr.md)
(and [`rio`](./tools-rio.md)) binary on our `$PATH`.

To build the latest versions: clone and follow the instructions in
https://github.com/polydawn/repeatr .  This will require a [go compiler](https://golang.org/dl/), bash, git, and not much else.



computing with repeatr
----------------------

The first piece of the Timeless Stack we'll use is [Repeatr](./tools-repeatr.md).
Repeatr computes things -- and you guessed it, hopefully repeatedly.
To do this, Repeatr uses [containers](./glossary.md#containers) to isolate environments,
we will need to explicitly identify all of our raw materials so Repeatr can set up that isolated environment.

### hello-world formula

```json
{"formula": {
	"inputs": {
		"/": "tar:6q7G4hWr283FpTa5Lf8heVqw9t97b5VoMU6AGszuBYAz9EzQdeHVFAou7c4W9vFcQ6"
	},
	"action": {
		"exec": ["/bin/echo", "hello world!"]
	}
},
"context": {
	"fetchUrls": {
		"/": [
			"ca+https://repeatr.s3.amazonaws.com/warehouse/"
		]
	}
}}
```

This snippet is a formula (and some "context" configuration).
Copy and paste this into a file called `example.formula`, and we can run it!

```bash
repeatr run example.formula
```

You should see a couple lines of logs scroll by, then the "hello" output, and finally, a json object.
The logs as repeatr sets up the environemnt are routed to stderr,
as is the "hello" print from the commands run in the container.
The json object comes out on stdout -- and is the only thing on stdout, so you can easily pipe this to other tools (e.g. [`jq`](https://stedolan.github.io/jq/)).

```text
log: lvl=info msg=read for ware "tar:6q7G4hW...vFcQ6" opened from warehouse "ca+https://repeatr.s3.amazonaws.com/warehouse/"
hello world!
{
  "guid": "by356nem-e0trxfw4-mt4xk1m9",
  "formulaID": "VvzXuRSogyW7JXvt49JWSfbJoAhpovCRPM69bd8xnDXyU8L5TMhrUmKGodWffysmK",
  "results": {},
  "exitCode": 0,
  // ...additional metadata elided...
}
```

This json object is called a [Run Record](./glossary#runrecord).
You get one from every `repeatr run` invocation, and they describe
both the setup (the `formulaID` property is a hash describing the formula we just ran!  This will be very useful, later), and the results... this time, we have an empty `results` field, but we'll see that used in just a moment; also, you can see the command in the container exited successfully by the `"exitCode": 0` line.

This is a reliable, repeatable way to distribute software and run it regardless of host environment.
But it's actually pretty boring!  Let's *build something* with it, next.


### producing outputs

// TODO another formula example add an output

As with the fetchURLs for inputs, we now have saveURLs for the output.
These are optional; you can list an output but no matching saveURL if you want to hash it, but discard the data.
But typically of course you do want to save the output, so you can either
pass it on to more formulas, or use `rio unpack` to extract it on your host.


### other things to try

There are lots of different options you can configure in formulas,
such as setting environment variables, setting the user IDs to run as, and many other knobs to twiddle.
We'll skip over those in this quickstart.

One thing you may have wondered already is why the "context" is separate from the "formula".
You can answer that question by changing some of the "context" fields
-- say, adding or removing more URLs to the fetchUrls list --
and then calling `repeatr run` again.
Notice anything?
The `formulaID` doesn't change ;)
