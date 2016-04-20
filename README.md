# HxLine

Haxe readline function for VT220 terminals.
This library has been design to mock as much as possible the behave of bash and readline.

It is highly configurable, but it also comes with functions and helpers to use it directly out of the box without setup (see the examples folder).

Weight: 700LoC

Features:
* Cursor movement, including begin of line and end of line
* Kill and yank text, including from the cursor to the begin or end.
* Autocompletion of commands.
* History in memory or in a file
* Backwards and forwards history search
* Very easy to extend the functionality and add other terminals such as windows.
* Logic decoupled from terminal class: possible to port it to non-text terminals.


# Status
Status: beta (only tested it on my machine).

# Platforms
Tested on C++ and Neko for OSX. Should work seamlessly on Linux.
All sys platforms should work out of the box except Java (getChar is not implemented there.)
