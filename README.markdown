Description
===========

This directory contains some scripts to make autocompleting your most actively used
directories and files cakewalk.

Install
=======

To make your own autocompleted command, you'll need to:

1. Make an entry in the config file, path\_completions.yml. This entry (or key)
should list a set of directories whose contents you want to autocomplete for your shell command.

2. Setup a shell function in a file which translates your autocompleted entry to a full path
your command can use. The translation is done with the ruby script, basename\_to\_full\_path.rb
See the my\_completions file for an example.
Notice that you'll need to include the full path to that script as well as pass a -k option
pointing to the key you used for step 1.

3. In the same file, you need to point your key to your bash function using the complete command
and the path\_completer.rb script. See the my\_completions file for an example.

4. Make sure the file you've created is sourced in your bashrc.

Example
=======

To help with creating your own completions, I'll explain one of mine.
In path\_completions.yml, I entered the key 'code' which lists my most active code-related directories
(step 1). Since I wanted to get to those directories quickly, I made a bash c() function which
cd's to them. In that function, I also call basename\_to\_full\_path.rb, passing the -k
option my config key (step 2). In the same file, I also write a complete statement making sure to pass my key
to the path\_completer.rb script (step 3) and my bash function c.

Todo
====

* Explore providing different completions for different arguments of a command.
Could come in handy for autocompleting methods for my gri() function.
* Allow for a basename occuring in multiple directories to be mapped to a specific directory.
* Add aliases in autocompletion.
* Allow for optional full path autocompletion.
