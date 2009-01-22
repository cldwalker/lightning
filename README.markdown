Description
===========

Autocomplete a group of files and directories simply by listing their globbable paths
in a config file. Generate completions from your config, source them into your shell
and you're ready to rock.

So instead of carpal-typing

    bash> vim /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/irb.rb

you type or complete

    bash> rvim irb.rb

Uneasy about what lightning will execute? Test/print it out with a -test flag

    bash> rvim -test irb.rb
    rvim '/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/irb.rb'

Want to autocomplete but don't remember how the basename starts? Just use a ruby regular expression:

    # *'s are converted to .*'s for convience sakes
    bash> rvim *dialog [TAB TAB]
    canvasprintdialog.rb
    extfileselectiondialog.rb
    dialog.rb//System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/tk
    fileselectiondialog.rb
    dialog.rb//System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/tkextlib/bwidget
    finddialog.rb

    #re-edit your line to narrow down your completion to one entry
    bash> rvim ca*dialog [TAB TAB]

    #once the basename completes, you can execute your command
    bash> rvim canvasprintdialog.rb

As you can see, you only need to autocomplete the basenames of paths and lightning will resolve their
full paths.  In these examples, rvim is a lightning command configured to autocomplete a certain group of paths for vim.
In my case, rvim is configured to complete my ruby core and standard library files.


Install
=======

For newcomers to github, install this gem with: `gem install cldwalker-lightning -s http://gems.github.com`

To make your own commands, you'll need to:

1. Create ~/.lightning.yml or a lightning.yml in the current directory.
   Use the Configuration section below and the provided lightning.yml.example as guides.

2. Execute `lightning-install` to generate ~/.lightning\_completions from your config.
   There is a config option for changing the location of the generated file. See Configuration
   below. See lightning\_completions.example for what would be generated for the enclosed example
   config.

3. Source the generated file in your bashrc ie `source ~/.lightning_completions`.


Globbable paths
===============

Since the globbable paths are interpreted by ruby's Dir.glob(), you can:

1. Autocomplete files and directories that don't start with specific letters.

   Dir.glob("[^ls]*") -> Matches anything not starting with l or s

2. Autocomplete files ending with specific file extensions for a given directory.

   Dir.glob("/painfully/long/path/*.{rb,erb}") -> Matches files ending with .rb or .erb

3. Autocomplete all directories however many levels deep under the current directory.

   Dir.glob("**/")

`ri Dir.glob` for more examples.

Configuration
=====================

It helps to look at lightning.yml.example while reading this.

Configuration options are:

* generated\_file: Location of shell script file generated from config. Defaults to
  ~/.lightning\_completions.
* ignore\_paths: List of paths to globally ignore when listing completions.
* complete\_regex: true or false (default is true)
  Turns on/off Ruby regular expression matching when completing. One convience
  is that a '*' is converted to '.*' ie glob-like behavior.

  Note: Realize your regular expression normally just match the basename. However, since duplicates
  list their full paths, their full paths are subject to regex matching.
* shell: Specifies shell script generator used for generating completions. Defaults to bash.
* commands: A list of lightning commands. A lightning command is just a shell function
  which executes a specified shell function with a defined set of paths to autocomplete on.
  A command consists of the following options/keys:
  
  * name (required): Name of the lightning command you'll be typing.
  * map\_to (required): Shell command which the lightning command passes arguments to.
  * description: Description which is placed as a comment in the generated shell script.
  * paths (required): A list of globbable paths, whose basenames are autocompleted. You can also
    pass this a path name that has been defined in the paths option. 

* paths: This takes a hash (pairs) of path names and globbable paths. This should be used when
  you have a group of paths that are used in multiple commands. When doing that, you would specify
  the path name defined here in the command's paths key.
  Note: path names should only be alphanumeric

* post\_path: Text to add immediately after a resolved path. lightning.yml.example contains
  an example used for opening gem documentation in your browser.

Duplicate Basenames
===================

So what happens when their are multiple matches for the same basename?
Lightning appends a '/' + the full directory to each of the basenames.

For example, if I autocomplete button.rb for my ruby standard libraries I get:

      bash> rvim button.rb
      button.rb//System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/tk
      button.rb//System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/tkextlib/bwidget
      button.rb//System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/tkextlib/blt/tile

This isn't the prettiest completion but it resolves duplicates, displays the path differences
between each and easily autocompletes. I'm open to suggestions on this syntax.

Limitations
===========

* The generated shell scripts default to bash but could easily be extended for other shell languages. Patches welcome.
* All arguments passed to a lightning command are considered part of the basename to resolve. So
  it's not yet possible to resolve some arguments and not others.
* When regular expression completing, I've noticed bash doesn't handle '^' well if it's the first of
  a couple of characters in a completion.

Motivation
==========

I've seen dotfiles on github and on blogs which accomplish this kind of autocompletion for gem
documentation. There's even a gem just for gem editing: http://gemedit.rubyforge.org/.
But once I saw how easy it was to manipulate completion through ruby,
http://github.com/ryanb/dotfiles/blob/master/bash/completion\_scripts/project\_completion,
I had to do something.

Todo/Ideas
==========

* Aliases for common autocompletions.
* Allow lightning commands to only path-resolve one of multiple arguments given.
* Command interface to easily add/remove current directory or globs from a command
