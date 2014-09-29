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
		<td>1</td>
		<td>a</td>
	</tr>

	<tr>
		<td>2</td>
		<td>z</td>
	</tr>

	<tr>
		<td>3</td>
		<td>e</td>
	</tr>

	<tr>
		<td>4</td>
		<td>q</td>
	</tr>

	<tr>
		<td>5</td>
		<td>s</td>
	</tr>

	<tr>
		<td>6</td>
		<td>d</td>
	</tr>

	<tr>
		<td>7</td>
		<td>w</td>
	</tr>

	<tr>
		<td>8</td>
		<td>x</td>
	</tr>

	<tr>
		<td>9</td>
		<td>c</td>
	</tr>

	<tr>
		<td>0</td>
		<td>Space bar</td>
	</tr>

	<tr>
		<td>A</td>
		<td>u</td>
	</tr>

	<tr>
		<td>B</td>
		<td>i</td>
	</tr>

	<tr>
		<td>C</td>
		<td>o</td>
	</tr>

	<tr>
		<td>D</td>
		<td>j</td>
	</tr>

	<tr>
		<td>E</td>
		<td>k</td>
	</tr>

	<tr>
		<td>F</td>
		<td>l</td>
	</tr>
</table>


In addition to these, the speed of the emulation can be controlled with the P and M buttons. P speeds it up while M slows it down.
