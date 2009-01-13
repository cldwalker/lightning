Description
===========

Auto-complete files and directories for paths and commands you use often simply
by referring to their basenames. Lightning maps the basenames to the correct full path.
So instead of 

  bash> cd /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/irb.rb

you simply type or complete

  bash> gcd irb.rb

Lightning autocompletes a command based on a list of globble paths in your config file.
Since these globs are interpreted by ruby's Dir.glob(), you can:

1. Autocomplete files and directories that don't start with specific letters.
   Dir.glob("[^ls]*") -> Matches anything not starting with l or s

2. Autocomplete files ending with specific file extensions for a given directory.
   Dir.glob("/painfully/long/path/*.{rb,erb}") -> Matches files ending with .rb or .erb

3. Autocomplete all directories however many levels deep under the current directory.
   Dir.glob("**/")

`ri Dir.glob` for more examples.

Install
=======

To make your own commands, you'll need to:

1. Create your own ~/.lightning.yml, using lightning.yml.example as an example.

2. lightning-install in your shell to generate your lightning_completions file from your config.

3. Source the generated file in your bashrc ie 'source [INSERT CURRENT DIRECTORY]/lightning_completions'.


Configuration Options
=====================

TODO

Todo
====

* Tests!
* Handle duplicate basenames ie same basename but in multiple directories.
* Aliases for common autocompletions.
