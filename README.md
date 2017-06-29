% Gomiko
% Ippei Kishida
% Last-modified:2017/06/29 11:08:02.
<!-- vim:syntax=markdown
<u> ■■■■ HERE ■■■■ </u>

TODO 用語統一
-->

(→ [Japanese version](index-ja.html))

# Overview

Gomiko provides a mechanism to temporarily store files rather than delete them, such as the Windows snap box.
[Implement UNIX Technique / Shell](http://www.q-eng.imat.eng.osaka-cu.ac.jp/~ippei/html/unixtodaystips/shell.html#)
As you have done in the past,
I installed the dust box on the shell.
That's 99% of my requirements,
If you have been using it for a long time, you may have felt a shortage as follows.

* I want to hand lightly.
* If you delete a file in the program, you also want to enter the dust box.

Gomiko provides the gomiko command.
The gomiko command has the ability to move files to ~/.trash with changes in rm.
It also displays the history of deletion and undo.
Gomiko as a Gem provides the Gomiko library.
The Ruby program is designed to handle the dust box as well.

## before the name

The name "gomiko" was named as "Japanese box" in Japanese.
If you think that it is "a shrine maiden who plays go", is it cute?

# Install

Rubygems is used.
You can use Rubygems to install it as follows:

    gem install gomiko

## Settings (you like)

The setting is basically unnecessary.
Also generates ~/.trash automatically.
If ~/.trash is present before gomiko and the file is there,
I think that at least a few of them will not work,
It would be more difficult to leave it empty.

If you decide to use gomiko in earnest,
I think you should make rm an alias for gomiko rm.
I have set the following in ~/.zshrc:

    alias rm='gomiko rm'

I think that undo and empty subcommands should be typed like gomiko undo,
I have not created any aliases in particular.


# Command

The gomiko command is available.
Various functions are provided as this subcommand.

## gomiko help

If you do not specify an argument, or if you specify the subcommand help, a helper is displayed.

    % gomiko

    % gomiko help

If you specify a subcommand name after help, as in the following example, the help for the subcommand rm is:

    % gomiko help rm


## gomiko rm

    % gomiko rm foo.txt

It is replaced with the normal rm command.
To change the deletion
Move to the ~/.trash directory.
The moved file name is
"~/.trash/date-time/original full path"
It is becoming more and more common.
This
"Date-time" is the timing when gomiko was started,
It is not the time when the movement was performed internally.
For example, if `gomiko rm *` "deletes a large number of files and takes more than a second,
It can be entered in one "date-time".

You can specify more than one file at a time, as follows:

    % gomiko rm foo.txt bar.txt */*.txt

You can also move the directory to the dust box without options, as shown below.

    % gomiko rm dir1/ dir2/

When multiple gomiko rms are performed at the same time,
The first is
It will be the directory name `` ~/.trash/date - time ``,
From now on,
It is created in serial number after time like "~/.trash/date-time-1".
It is a mechanism that is similar to the Locked Directory of Exclusive Control,
Because only the process that generated the directory is in the directory,
It is also safe for file systems that share NFS over multiple machines.

After that, the file directory under ~/.trash/ will be called "trash ID directory"
The directory name is called the "ID".
Even if it was created manually rather than via gomiko rm,
It can be used as a trash ID directory, trash ID.
(Whether undo or other commands are intended to work is another matter.)


## gomiko undo

The subcommand undo provides the un-delete function for file deletion.
If you run it without arguments as in the following, you will undo the most recent contents of the trash ID directory.

    % gomiko undo

Because undo removes the appropriate discovery ID directory,
If you run gomiko undo, you will then unhide the new Discovery ID directory.
In other words, running gomiko undo will continue to remove the deletion.

If the file exists in the original path that you deleted,
It does not issue a warning about the file in question and does not perform the move.
Other files are returned.

    % gomiko undo
    Normal file already exist: /home /ippei /tmp /gomiko /0
    Can not undo: /home/ippei/.trash/20170623-133644

You can specify a false ID to execute undo on the argument.

    % gomiko undo 20170623-133644

(In this case, the expansion of the memory card can not be normal.)

    % gomiko undo 20170623-133644 20170623-123456

You can also specify the path

    % gomiko undo ~/.trash/20170623-*

## gomiko empty

Empty the contents of the ~/.trash directory.
If the argument is omitted, all file directories in ~/.trash are considered.
Gomiko empty is also a file directory that is in ~/.trash without gomiko rm
It is targeted.

You can specify a false ID in the argument.

    % gomiko empty 20170628-112425-2

It can be specified with a path instead of a false ID.

    % gomiko empty ~/.trash/20170628-112425-2

### --mtime option

It is recommended that you periodically delete the contents of ~/.trash.
At that point, if you empty the file at some stage, the file you moved to ~/.trash
It is also possible to delete it.
If you look at the timestamp, for example, delete the file after seven days,
It is a routine method.
The --mtime option does this.

    % gomiko empty --mtime=-7

, Delete the item that has passed 7 days or more.
Because we decided on the notation using the -mtime option of find,
Normally you will specify a negative number.
The default value of the - mtime option argument is 0,
All previously created trash ID directories are considered.
This time stan- dard,
We are looking at the time stamp (update time) of the geo ID directory.
Because you did not get the date from the file name,
Changing the file name does not change the date judgment.

If you use the --mtime option with the argument id of the argument,
Select an AND condition that matches both.
(Note: Even if it is considered to be an OR condition,
 If you do OR, you only need to issue the command twice,
 Because the AND condition is between the hand and the hand, the value is still.
 I do not think that it should be used together.)

### --quiet option

You will not need to log the standard output when running with cron.
In such cases, the --quiet option can suppress the standard output.

    % gomiko empty --quiet

When you run the empty subcommand manually
It is more pleasant to see something, and by default, --quiet is off.

## gomiko ls

Displays the contents of ~/.trash.

    % gomiko ls
    size date-time-id    typical-path[ ...]
    20K  20170623-125159 /home/ippei/tmp/gomiko/0
    20K  20170623-125810 /home/ippei/tmp/gomiko/5 ...
    84K  20170627-084500 /home/ippei/git/gomiko/test/gomiko/tmp/
    24K  20170627-091649 /home/ippei/git/gomiko/a/
    32K  20170627-091712 /home/ippei/git/gomiko/test/gomiko/b (exist in original path)
    100K 20170627-092407 /home/ippei/git/gomiko/test/gomiko/tmp/

The first line is the title line of information.
The second and third lines are data.
The size of the first column is the size that can be acquired by du.
The second column is representative of the path that is assumed to be deleted.
This inference is based on the recursive search of the trash ID directory,
And it presents a file directory that does not exist on the actual full path.
Following the second column, "..." means that there is an assumed path other than the representative,
In other words, it is assumed that you have moved multiple files into a single box with a single command.

If the original path that you deleted contains a file that already exists,
It outputs (may exist newer file) as follows.

    20K  20170623-125810 /home/ippei/tmp/gomiko/5 ...(may exist newer file)

You can specify a false ID for the argument.

    % gomiko ls 20170623-125159 20170623-125810
    size date-time-id    typical-path[ ...]
    20K  20170623-125159 /home/ippei/tmp/gomiko/0
    20K  20170623-125810 /home/ippei/tmp/gomiko/5 ...


The path is OK even if it is a bad ID.

    % gomiko ls ~/.trash/20170623-125*
    size date-time-id    typical-path[ ...]
    20K  20170623-125159 /home/ippei/tmp/gomiko/0
    20K  20170623-125810 /home/ippei/tmp/gomiko/5 ...

### --long, -l option

The --long (-l) option prints more information.

    % gomiko ls --long
    ------------------------------------------------------------
    size      : 20K
    id        : 20170628-112425
    guess path: /home/ippei/tmp/gomiko/0
    +----- filetype in trash
    | +--- filetype in original path
    | | +- original path
    / / /home
    / / /home/ippei
    / / /home/ippei/tmp
    / / /home/ippei/tmp/gomiko
    .   /home/ippei/tmp/gomiko/0

    ------------------------------------------------------------
    size      : 20K
    id        : 20170628-112425-1
    guess path: /home/ippei/tmp/gomiko/1
    +----- filetype in trash
    | +--- filetype in original path
    | | +- original path
    / / /home
    / / /home/ippei
    / / /home/ippei/tmp
    / / /home/ippei/tmp/gomiko
    .   /home/ippei/tmp/gomiko/1

    ------------------------------------------------------------
    size      : 20K
    id        : 20170628-112425-3
    guess path: /home/ippei/tmp/gomiko/3
    +----- filetype in trash
    | +--- filetype in original path
    | | +- original path
    / / /home
    / / /home/ippei
    / / /home/ippei/tmp
    / / /home/ippei/tmp/gomiko
    .   /home/ippei/tmp/gomiko/3

It is divided by a horizontal line for each gummy ID.
Capacity (size),
The ID (id)
The guessed path (guess path)
Below is the information for all the directory files stored in the trash ID directory,
The first element of each line is the file type in the geo ID directory,
The next element is the file type of the original path on the current file tree.
The meaning of the letter that indicates the file type is as follows.

* "/" Directory
* "." Normal file
* " "(Blank) indicates that the file does not exist


# Library

Gomiko.new generates a Gomiko object,
By using Gomiko#throw,
You can use the dust box from the program.


# Rejected features

## It takes a long time to move to a local folder when deleting an NFS share file

Solutions to this need are difficult.
The problem is how to place the dust box directory equivalent to ~/.trash.
The df command provides information about the file system,
It is difficult to determine automatically due to various factors such as sym- bolic links and permutations.
For example, if you followed the expanded path of a symlink,
To the top-level directory that has the same file system or permission to write to itself
Let's imagine a policy of creating a gummy box directory.
If you delete it in /tmp, you will create a directory called /tmp/.trash.
I can not say that it is an amiable good.
In addition, there are multiple dust box directories,
It becomes difficult to know where the target file is stored.
The benefits are far less complex and complex, and there are fewer demerits.
It is possible to create an option to specify the location of the glove box directory,
There is no plan to make such an option at this time.


## mkdir and directory specification

Every time you run gomiko (or whenever you throw Gomiko#throw internally), a new gomi ID directory is created,
The granularity of gomiko undo is in that unit.
When you delete a file from a program,
There is a request that "we want to go to a common false ID directory in one process".
To solve this problem, create a gomi ID directory with gomiko mkdir,
You can specify gomiko rm or Gomiko#throw with that directory.
Although technological difficulties are not difficult,
This will cause problems as a program's log- ics.
The problem is that multiple file deletions can be the same path in a single trash ID directory.
Assuming that you have implemented the - id option in gomiko mkdir and gomiko rm,
Let's consider it in a shell script.

    DIR=`gomiko mkdir`#Creates a new ID directory and returns its ID
    touch a
    gomiko rm --id=$ DIR a # Specify the id ID directory and drag it there.
    touch a
    gomiko rm --id=$ DIR a # It should be loaded into the same path of the same god ID directory.

The second gomiko rm causes duplication.
Because the file trees at different points in time are grouped together,
Such problems may arise.
As a program, you should position the geo-ID directory as a snapshot of the file tree at the time of the deletion.

From these, there is no plan to add this function.

## redo function

Currently, gomiko uses the data in ~/.trash files as its data
Processing is being performed.
By not having the history as a separate file,
And preserves the uniqueness of the information.
To do a redo, you need to remove the undo file from ~/.trash,
It is necessary to place a record somewhere.
As a result, the place of information becomes less centralized,
You have to be careful about maintaining consistency.
Even if gomiko itself does not have the redo function,
The same can be done by using the shell's histories.
Because I think that it is a function with a lot of effort in terms of work,
There is no plan to add this function.

## Using the Directory Creation Time

And the directory in the trash ID directory.
If we can compare the generation time of the source directories,
It will be possible to deduce more accurate delete targets.
For example, if you have a file called /a /b /c.txt,
Suppose you deleted it with /a /b.
The ending file directory is
/A and ~/.trash/ID/a/b.
If you then generate /a/b,
The /a/b should be later than the creation time by ~/.trash /false ID /a /b.
On the other hand, if you look at a, the ~/.trash/false ID /a generated by deletion should be later than the /a that was already present at the time of deletion.
You should be able to determine whether this is the directory generated after the deletion,
On Linux mainstream ext4 file systems
The file directory creation time is not recorded in the timestamp.
Therefore, this can not be used.
We will also consider when the file system that can be used at creation time is mainstream.


# Contributing to gomiko
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

# Copyright

Copyright (c) 2017 ippei94da. See LICENSE.txt for
further details.

