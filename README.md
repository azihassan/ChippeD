Chipped, a Chip8 emulator written in D
======================================

Compiling
---------

To compile the project you'll need both [DMD](http://dlang.org/download.html) and [dub](http://code.dlang.org/download). You can then cd to the project's directory (where dub.json is located) and run the command "dub build".

Running
-------

The program takes a few arguments :

* -z or --zoom N : Changes the resolution to N times the initial resolution of 64x32
* -d or --debug : Activates the debug mode. This will print the opcodes as they get interpreted as well as the memory addresses.
* -o or --out FILE : If the debug mode is enabled, the data will be printed to stdout. Use this flag to redirect the output to the FILE of your choice.

A precompiled version for Windows can be downloaded [here](https://drive.google.com/file/d/0B0q6zR75es1eMWhhM2tvblF3UEE/edit?usp=sharing).

![Running tetris](https://github.com/azihassan/ChippeD/raw/master/tetris.png "Running tetris")


Key mapping
-----------

The chip8 has a hexadecimal keyboard of 16 buttons, here are the mappings :

|Chip8 | Keyboard |
|------|----------|
| 1 | A |
| 2 | Z |
| 3 | E |
| 4 | Q |
| 5 | S |
| 6 | D |
| 7 | W |
| 8 | X |
| 9 | C |
| 0 | Space bar |
| A | U |
| B | I |
| C | O |
| D | J |
| E | K |
| F | L |


In addition to these, the speed of the emulation can be controlled with the P and M buttons. P speeds it up while M slows it down.
