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

Key mapping
-----------

The chip8 has a hexadecimal keyboard of 16 buttons, here are the mappings :


<table>
	<tr>
		<td>1 : A</td>
		<td>2 : Z</td>
		<td>3 : E</td>
		<td>C : O</td>
	</tr>

	<tr>
		<td>4 : Q</td>
		<td>5 : S</td>
		<td>6 : D</td>
		<td>D : J</td>
	</tr>

	<tr>
		<td>7 : W</td>
		<td>8 : X</td>
		<td>9 : C</td>
		<td>E : K</td>
	</tr>

	<tr>
		<td>A : U</td>
		<td>0 : Space bar</td>
		<td>B : I</td>
		<td>F : L</td>
	</tr>
</table>


In addition to these, the speed of the emulation can be controlled with the P and M buttons. P speeds it up while M slows it down.
