Defaults in Formulas
====================

Repeatr goes through a fairly great length of work to make sure
the default behavior for formulas is always roughly what you mean.

We also commit to a fairly stable definition of that, because
implicit changes to what the blank spaces in a formula mean over
time would cause majorly problematic behavior throughout the ecosystem
(formula hashes would not change, but while semantics did -- not good).

So, here are some very -- even overly, boringly -- specific docs
of what we mean by "good defaults", and why.


Opting Out
----------

We'd be monsters if you couldn't disable these "helpful" defaults if
you disagree with them.

Set `formula.action.cradle` to `"disable"` to skip out on anything that
can be skipped.
(What does that mean?  Well, you can't have a UID set to null, so that
default will still be computed.  But all changes to the env var map
will be skipped, all filesystem tweaks skipped, and the default cwd
becomes plain '/'.)


Policy Levels
-------------

Before getting into command enviornment defaults, we need to talk
briefly about Policy levels.

Policy settings are a short enum:

- `routine`
- `governor`
- `sysad`

This list goes from lowest to highest privilege levels.
(The "routine" policy is extremely safe.  The "sysad" policy
explicitly means giving the contained process enough privilege
that it may be able to escalate to root on your host, reboot
your machine, etc.  You probably don't want to use the higher
Policy settings if you can help it, and certainly not on any
untrusted code or containers.)

FIXME you uh actually *don't* have to talk about this because
we're splitting out the UID thing.


Default Action & Command Environment
------------------------------------

All of the optional fields in the `formula.action` declaration have
defaults:

### Working Directory (`cwd`)

The current working directory when the process is launched defaults
to `/task`.

(This path will be created if it does not exist, and set to reasonable
permissions if necessary -- skip on to the "Default Filesystem Setup"
section of this doc for more detail.)

### UID

The default UID is 1000.

Note that the UID has nothing to do with privilege levels
(you may wish to read the [Policy](./formula-policy.md) doc
for more information about privilege levels).

### GID

The default GID is 1000.

### Username

The default username is "`reuser`", unless your UID is zero;
if your UID is zero, the username defaults to `"root"` instead,
which is probably what you expected.

The `$USER` environment variable will be set to this value,
unless already explicitly set in the `formula.action.env` map.

### Homedir

The default homedir is "`/home/$USER`" (as defined by the Username
section, above -- e.g. the `formula.action.env` is not considered),
unless your UID is zero;
if your UID is zero, the homedir defaults to `"/root"` instead,
which is probably what you expected.

The `$HOME` environment variable will be set to this value,
unless already explicitly set in the `formula.action.env` map.

### Path

The $PATH environment variable, unless otherwise specified, will
always be set to:

```
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

(This is a conservative choice, given that most distros are moving towards
a unified "/bin"; but here, being conservative has no downside.)

### Hostname

The hostname (on executor engines that support setting hostname) will
default to the execution ID, which is *a random value*.


Default Filesystem Setup
------------------------

After stitching up your input filesets, Repeatr will also perform some
small (but fairly essential) tweaks to the filesystem right before
launching your commands.  These are meant to make sure you have a
minimum-viable / minimum-sane environment (even if your input filesystems
shifted radically).

(All of these mutations, if made, will still preserve the mtimes of
parent dirs, for your convenience and sanity if you intend to scan
parts of the parent files into an output which preserves those properties.)

(As an edge case, these mutations will be skipped if the paths they
would affect would end up outside of any mounts through to the host.)

### Homedir

The homedir will be made, if it doesn't exist,
and it will be readable and writable to the owner (e.g. bitwise `|0700`).
The owner UID and GID will be set to the formula's UID and GID.
All of the parent dirs will be made traversable to "everyone"
(e.g. bitwise `|0001`) if they aren't already.

tl;dr: Your process should always be free to write in its own homedir.

### Tempdir

The `/tmp` dir will be made, if it doesn't exist.
The permissions will be forced to bitwise `01777` unconditionally.
If the dir was made, the owner UID and GID will be `0` and `0`.

tl;dr: Any process should be free to write the tempdir, and it should
generally behave exactly how you expect a tempdir to behave. 

### `/dev` and `/proc`

Here be dragons.

Some container executors will force the creation and mounting of
the `/dev` and `/proc` filesystems, and populate it with all of
the magical wonderful interfaces to the kernel you might expect.

We make very little guarantees about what you may find under
these paths.  They are implementation (and host kernel...!) specific.
