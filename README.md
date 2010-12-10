gitodo
======

gitodo is a simple personal task manager. Note that this script is very
experimental and in an early stage.

You can do the following:

* Add, edit and list your tasks. Essentially, that's a todo list.
* Prioritize some tasks. Negative priorities mean a higher urgency.
* Set a deadline for tasks.
* Synchronize your tasks with other machines.

When listing tasks, they're first sorted by importance then by deadline.
Typical output from the script might look like this:

	Old Prio        Deadline          ID    Subject
	--- ----- --------------------- ------  -------
	    [-15] [                   ] [   1]: Mail to jane: Dinner.
	    [ -3] [                   ] [   2]: Christmas presents.
	[!] [  0] [           22:00:00] [   9]: Remove garbage from your bed.
	    [  0] [           23:30:00] [   8]: Go to sleep. Yes, it's important.
	    [  0] [2010-12-10 23:59:00] [  10]: Still awake?
	    [  0] [2010-12-13         ] [   6]: Prepare talk about Git.
	    [  0] [2010-12-24         ] [   7]: Remove SVN from all computers.
	    [  0] [                   ] [   4]: Wash dishes.
	    [  0] [                   ] [   5]: Buy new milk.
	    [  5] [                   ] [   3]: Wash the car.

Note the order: Items with a higher importance come first. If two items
have the same importance, they're sorted by their deadline. Deadlines
can be a date, a time (meaning "today") or both.

Items are simple text files. They look like this:

	what: Subject of the task.
	when: 2010-12-10 08:30
	prio: 2

	Some other lines describing the task in detail.

Deadline and priority are optional. The default priority is 0 and no
deadline means 2038-01-01 00:00:00. ;-)


Task item files, the repo and synching
--------------------------------------

All your tasks are kept in the subdirectory "items". On the first start,
a Git repository will be created in this directory. Every change of your
task list will be automatically committed to that repository.

Common task items will be named like "i0123": That would be the file for
the 123rd item. Note that new items will get the next free ID. If 123
currently is the highest ID, a new item will get ID 124.

There's a special file in the items directory called "remotes". It lists
all your peers:

	pinguin /home/void/git/gitodo/items
	pinguin /tmp/tmp/gitodo/items
	mobiltux /home/void/git/gitodo/items
	worklaptop /home/jane/gitodo/items

The first field is a host name, the second field a path on that host. If
it's a foreign host, SSH will be used to fetch from their Git repo. If
it's the same host that you're currently logged in to, then a local
fetch will take place.

* Q: Why not use the native "remotes" mechanism of Git?
* A: Native Git remotes would have to be maintained on every single
  clone. But I'm lazy and I don't want to do that. I want to define a
  single list will *all* repositories and the script has to find out
  if it can pull from them.

Doing a `gitodo --pull` will pull the current task items from all your
remotes.


Portability
-----------

The script is *meant* to be able to run in the
[msysgit](http://code.google.com/p/msysgit/) environment on Windows.
That's because I need that at work (sigh). I can't guarantee that every
revision will run on msysgit, but I'll do my very best, Ms. Sophie.

Of course, it runs on GNU/Linux as well.


Command line options
--------------------

See the output of `gitodo --help` for a detailed list of command line
options.
