Policies for Formula Execution
==============================

`Policy` settings are how Formulas describe privilege levels.
Internally, they translate to linux kernel "capabilities", but the
formula policies concept is intentionally much less rich, and
designed around the concept of safe and minimal defaults.

By default, executing a Formula will try to use at least as much isolation as a
regular posix user account would provide: a non-zero UID and GID are assigned.
Operating on files with other owners is a permissions error; etcetera.
You can configure other policies to give your contained process more privileges.


Policy Levels
-------------

Policy settings are a short enum:

- `routine`
- `governor`
- `sysad`

This list goes from lowest to highest privilege levels.

Roughly:

The **"routine"** policy is extremely safe; it has no
escalated privileges; if files aren't owned by your UID you're
not getting any special treatment; etc.
This is the default if not overridden, and it should be enough
for most daily work.

The **"governor"** policy is a bit like root on your host -- the process can
read and write to any files, change its UID and GID, etc, as if superuser --
but it's still in containers, locked in a chroot, and reasonably safe.
(Notably, you still cannot create device files.)
If you can get away with "routine" mode, do so!  If you need
"governor", it's fairly safe.
(Running a legacy distro package manager often requires more privileges
than well-designed container-era tools should need, for example.
Sometimes you can get away with merely `action.uid=0`, but
in practice `policy=governor` is also often required.)

The **"sysad"** policy explicitly means giving the contained process
enough privilege that it may be able to escalate to root on your
host, reboot your machine, create and manipulate device files, etc.
You could conceivably want to use this if you want containers for
organizational purposes, but use tools in them which really do run
administrative operations on your host.

Long story short: As always in security, use the lowest privilege
levels you can get the job done with; and we've made those the default.
You probably don't want to use the higher Policy settings if you can
help it, and *certainly* under no circumstances should one ever use the
"sysad" policy level when handling any untrusted filesets or executable
content retrieved from the network.
