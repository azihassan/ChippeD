import std.typetuple;
import std.range;
import std.stdio : File, writeln, write;

/* to use in a compile-time foreach
 * copy/pasted from : https://issues.dlang.org/show_bug.cgi?id=4085
 */
template Iota(int start, int stop) {
	static if (stop <= start)
		alias TypeTuple!() Iota;
	else
		alias TypeTuple!(Iota!(start, stop-1), stop-1) Iota;
}

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
