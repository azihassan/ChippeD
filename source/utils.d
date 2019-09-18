import std.typetuple;
import std.range;
import std.stdio : File, writeln, write;

struct Logger
{
	File writer;
	bool enable = false;

	void write(S...)(S args)
	{
		if(enable)
			writer.write(args);
	}

	void writeln(S...)(S args)
	{
		if(enable)
			writer.writeln(args);
	}

	void writef(Char, A...)(in Char[] fmt, A args)
	{
		if(enable)
			writer.writef(fmt, args);
	}

	void writefln(Char, A...)(in Char[] fmt, A args)
	{
		if(enable)
			writer.writefln(fmt, args);
	}

}
