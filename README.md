gitodo
======

gitodo is a simple personal task manager. Note that this script is very
experimental and in an early stage.

You can do the following:

* Add, edit and list your tasks. Essentially, that's a todo list.
* Prioritize some tasks. Negative priorities mean a higher urgency.
* Set a deadline for tasks.
* Be able to synchronize your tasks with other machines because they're
  kept in a Git repository.

When listing tasks, they're first sorted by importance then by deadline.
Typical output from the script might look like this:

	Old Prio        Deadline          ID   Subject
	--- ----- --------------------- ------ -------
	    [-15] [                   ] [   1] Mail to jane: Dinner.
	    [ -3] [                   ] [   2] Christmas presents.
	[!] [  0] [           22:00:00] [   9] Remove garbage from your bed.
	    [  0] [           23:30:00] [   8] Go to sleep. Yes, it's important.
	    [  0] [2010-12-10 23:59:00] [  10] Still awake?
	    [  0] [2010-12-13         ] [   6] Prepare talk about Git.
	    [  0] [2010-12-24         ] [   7] Remove SVN from all computers.
	    [  0] [                   ] [   4] Wash dishes.
	    [  0] [                   ] [   5] Buy new milk.
	    [  5] [                   ] [   3] Wash the car.

Note the order: Items with a higher importance come first. If two items
have the same importance, they're sorted by their deadline. Deadlines
can be a date, a time (meaning "today") or both.

If the deadline for a task has already passed, it's marked with a `[!]`
at the beginning of the line.

Items are simple text files. They look like this:

	what: Subject of the task.
	when: 2010-12-10 08:30
	prio: 2

	Some other lines describing the task in detail.

Deadline and priority are optional. The default priority is 0 and no
deadline means 2038-01-01 00:00:00. ;-)


Task item files, the repo and synching
--------------------------------------

All your task items are kept in single directory. On the first start,
a Git repository will be created in this directory. Every change of your
task list will be automatically committed to that repository. By
default, this directory is `$XDG_DATA_HOME/gitodo.items`. If
`$XDG_DATA_HOME` is not set, the directory in which the `gitodo` script
resides will be used.

Common task items will be named like "i0123": That would be the file for
the 123rd item. Note that new items will get the next free ID. If 123
currently is the highest ID, a new item will get ID 124.

Add the items repo to your synching mechanism if you want them to be
synched.


Setup
-----

First, clone the code repository:

	$ cd ~/git
	$ git clone git://github.com/vain/gitodo.git

If you already have an existing repository for your task items, clone
that one as well:

	$ cd "$XDG_DATA_HOME"
	$ git clone ssh://.../gitodo.items

If you decide to use the Vim syntax files, you should link them into
your `~/.vim` directory:

	$ cd ~/.vim/ftdetect
	$ ln -s ~/git/gitodo/vim/ftdetect/gitodo.vim
	$ cd ../syntax/
	$ ln -s ~/git/gitodo/vim/syntax/gitodo.vim


Portability
-----------

The script is *meant* to be able to run in the
[msysgit](http://code.google.com/p/msysgit/) environment on Windows.
That's because I need that at work (sigh). I can't guarantee that every
revision will run on msysgit, but I'll do my very best, Ms. Sophie.

Of course, it runs on GNU/Linux as well.


Environment
-----------

* `$GITODO_FORCE_COLOR`: If this variable is set, color is used in any
  case, even if stdout is not a terminal.


Command line options
--------------------

See the output of `gitodo --help` for a detailed list of command line
options.
