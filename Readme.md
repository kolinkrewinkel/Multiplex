#Multiplex
Simultaneous editing for Xcode, inspired by Sublime Text.
![Screenshot of Xcode with plugin installed.](https://raw.githubusercontent.com/kolinkrewinkel/Multiplex/develop/Meta/Demo.gif?token=AAIySPhzw5iiBXC8SolkmLXckB_BXhujks5WLxWCwA%3D%3D)

##Features
- Quickly edit specific instances of a variable being used.
- Consistent insertion of closing characters
  - Quotes
  - Angle brackets
  - Curly braces
  - Brackets
- No more of Xcode inserting the leading braces (it's always in the wrong place!)
- No more annoying animation when showing the autocomplete dialog.
- More flexible "Edit All in Scope" functionality using proper simulataneous editing.
- Smarter auto-indenting

##Installation

**Alcatraz**  
Pending addition to the Alcatraz specs repo...for now, please use the installer or copy the file manually.

**Installer**  
Run the latest installer from [Releases](https://github.com/kolinkrewinkel/Multiplex/releases).

**Manual Copy**  
Move the `Multiplex.xcplugin` file from [Releases](https://github.com/kolinkrewinkel/Multiplex/releases) into `~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/`. Create any intermediate directories if necessary.

Addtionally, you can clone the project and build/run it. It will automatically launch a debugger session on Xcode itself, copying the plugin into the correct folder.

##Usage

- Insert a new cursor using *Command-Click*.
- Add the next occurrence of the word currently selected (or the word a single cursor falls within) using *Command-D*.
- "Edit All in Scope" (*Control-Command-E*) uses multiple selections rather than the original implementation which only shows a single cursor and propogates the changes.
- Jump to Definition is now accessed using *Alt-Click*.
- The info popover for a symbol is now shown by holding Alt-Click, or Force Touching.

##Bug Reports & Feature Requests
I'm certain there are bugs in this that will cause Xcode to crash. As a result, you should always edit documents that are tracked with version control so you're not out of luck if Autosave doesn't catch the most recent change.

Please file bugs on [GitHub Issues](http://github.com/kolinkrewinkel/Multiplex/issues) detailing how to reproduce it. If it's consistent and interrupting your work, temporarily uninstall until it's resolved.

The best feature requests are actually Pull Requests...but if the idea's cool, I (and hopefully others) will gladly work on it. :)


##Miscellaneous
Thanks to Jon Skinner for making the **excellent** Sublime Text editor.

The syntax highlighting in the demo gif is from my other plugin, [Polychromatic](http://github.com/kolinkrewinkel/Polychromatic/).

You can follow me on Twitter: [@kkrewink](http://twitter.com/kkrewink).

##License
MIT License
