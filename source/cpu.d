import std.file : read;
import std.path : baseName;
import std.random : uniform;
import std.string;
import utils;
import keyboard;
import display;
import std.datetime : StopWatch;

struct OpCode
{
	ushort value;
	ushort mask;
	ubyte x;
	ubyte y;
	ubyte z;
	ubyte kk;
	ushort nnn;

	this(ushort op)
	{
		value = op;
		mask = op & 0xf000;
		x = (op & 0x0f00) >> 8;
		y = (op & 0x00f0) >> 4;
		z = op & 0x000f;
		kk = op & 0x00ff;
		nnn = op & 0x0fff;
	}
}

unittest
{
	auto op = OpCode(0xd123);
	assert(op.mask == 0xd000);
	assert(op.x == 0x1);
	assert(op.y == 0x2);
	assert(op.z == 0x3);
	assert(op.kk == 0x23);
	assert(op.nnn == 0x123);
}

class Cpu
{
	protected:
	bool wait_for_keypress;
	ubyte[4096] memory;
	ushort pc;
	ubyte[16] V;
	ushort I;
	ubyte delay_timer;
	ubyte sound_timer;
	ubyte sp;
	ushort[16] stack;
	void delegate(OpCode op)[ushort] callbacks;

	public:
	Logger logger;
	Screen scr;
	Keyboard kbd;

	this()
	{
		pc = 0x200;
		memory[0 .. display.fonts.length] = display.fonts;

		foreach(x; Iota!(0, 16))
			mixin("callbacks[0x%x000] = &_%xxxx;".format(x, x));
	}

	void loadGame(string game)
	{
		auto rom = cast(ubyte[]) game.read();
		memory[pc .. pc + rom.length] = rom;
		scr.setTitle("Running : " ~ game.baseName);
	}

	void runCycle()
	{
		auto op = OpCode(memory[pc] << 8 | memory[pc + 1]);
		logger.writef("[%x @ %x] ", op.value, pc);
		if(wait_for_keypress)
		{
			_fx0a(op);
			return;
		}
		if((op.mask) !in callbacks)
		{
			logger.writefln("Opcode %x not implemented yet.", op.value);
			pc += 2;
			return;
		}	
		callbacks[op.mask](op);
	}

	void decrementTimers() nothrow
	{
		delay_timer -= delay_timer == 0 ? 0 : 1;
		sound_timer -= sound_timer == 0 ? 0 : 1;
	}

	protected:
	void _0xxx(OpCode op)
	{
		switch(op.nnn)
		{
			case 0xe0: _00e0(op); break;
			case 0xee: _00ee(op); break;
			default:
				logger.writefln("Unknown op : %x", op.value);
				pc += 2;
			break;
		}
	}

	void _00e0(OpCode op)
	{
		logger.writeln("CLS");
		scr.clearScreen();
		pc += 2;
	}

	void _00ee(OpCode op)
	{
		logger.writeln("RET");
		pc = stack[sp--];
		pc += 2; // forgetting this caused a major headache and an unfinite loop
	}

	void _1xxx(OpCode op)
	{
		logger.writefln("JP %x", op.nnn);
		pc = op.nnn;
	}
	
	void _2xxx(OpCode op)
	{
		logger.writefln("CALL %x", op.nnn);
		stack[++sp] = pc;
		pc = op.nnn;
	}
	
	void _3xxx(OpCode op)
	{
		logger.writefln("SE V%x, %x", op.x, op.kk);
		pc += V[op.x] == (op.kk) ? 4 : 2;
	}
	
	void _4xxx(OpCode op)
	{
		logger.writefln("SNE V%x, %x", op.x, op.kk);
		pc += V[op.x] != (op.kk) ? 4 : 2;
	}
	
	void _5xxx(OpCode op)
	{
		logger.writefln("SE V%x, V%x", op.x, op.y);
		pc += V[op.x] == V[op.y] ? 4 : 2;
	}
	
	void _6xxx(OpCode op)
	{
		logger.writefln("LD V%x, %x", op.x, op.kk);
		V[op.x] = op.kk;
		pc += 2;
	}
	
	void _7xxx(OpCode op)
	{
		logger.writefln("ADD V%x, %x", op.x, op.kk);
		V[op.x] += op.kk;
		pc += 2;
	}
	
	void _8xxx(OpCode op)
	{
		switch(op.z)
		{
			case 0x0: _8xx0(op); break;
			case 0x1: _8xx1(op); break;
			case 0x2: _8xx2(op); break;
			case 0x3: _8xx3(op); break;
			case 0x4: _8xx4(op); break;
			case 0x5: _8xx5(op); break;
			case 0x6: _8xx6(op); break;
			case 0x7: _8xx7(op); break;
			case 0xe: _8xxe(op); break;
			default:
				logger.writefln("Unknown op %x", op.value);
				pc += 2;
			break;
		}
	}
	
	void _8xx0(OpCode op)
	{
		logger.writefln("LD V%x, V%x", op.x, op.y);
		V[op.x] = V[op.y];
		pc += 2;
	}
	
	void _8xx1(OpCode op)
	{
		logger.writefln("OR V%x, V%x", op.x, op.y);
		V[op.x] |= V[op.y];
		pc += 2;
	}
	
	void _8xx2(OpCode op)
	{
		logger.writefln("AND V%x, V%x", op.x, op.y);
		V[op.x] &= V[op.y];
		pc += 2;
	}
	
	void _8xx3(OpCode op)
	{
		logger.writefln("XOR V%x, V%x", op.x, op.y);
		V[op.x] ^= V[op.y];
		pc += 2;
	}
	
	void _8xx4(OpCode op)
	{
		logger.writefln("ADD V%x, V%x", op.x, op.y);
		V[0xf] = V[op.x] + V[op.y] > 255;
		V[op.x] += V[op.y];
		pc += 2;
	}
	
	void _8xx5(OpCode op)
	{
		logger.writefln("SUB V%x, V%x", op.x, op.y);
		V[0xf] = V[op.x] > V[op.y];
		V[op.x] -= V[op.y];
		pc += 2;
	}
	
	void _8xx6(OpCode op)
	{
		logger.writefln("SHR V%x{, V%x}", op.x, op.y);
		V[0xf] = V[op.x] & 0b1;
		//V[0xf] = (V[x] & 0xf) & 0x1;
		V[op.x] >>= 1;
		pc += 2;
	}
	
	void _8xx7(OpCode op)
	{
		logger.writefln("SUBN V%x, V%x", op.x, op.y);
		V[0xf] = V[op.y] > V[op.x];
		V[op.x] = cast(ubyte) (V[op.y] - V[op.x]);
		pc += 2;
	}
	
	void _8xxe(OpCode op)
	{
		logger.writefln("SHL V%x{, V%x}", op.x, op.y);
		V[0xf] = (V[op.x] & 0x80) ? 1 : 0;
		/*V[0xf] = V[y] >> 7;
		V[0xf] = (V[y] >> 8) >> 7;*/
		V[op.x]  = (V[op.x] << 1) & 0b11111111;
		pc += 2;
	}
	
	void _9xxx(OpCode op)
	{
		logger.writefln("SNE V%x, V%x", op.x, op.y);
		pc += V[op.x] != V[op.y] ? 4 : 2;
	}
	
	void _axxx(OpCode op)
	{
		logger.writefln("LD I, %x", op.nnn);
		I = op.nnn;
		pc += 2;
	}
	
	void _bxxx(OpCode op)
	{
		logger.writefln("JP V0, %x", op.nnn);
		pc = cast(ushort) (V[0] + op.nnn);
	}
	
	void _cxxx(OpCode op)
	{
		logger.writefln("RND V%x, %x", op.x, op.kk);
		V[op.x] = uniform(0, 255) & (op.kk);
		pc += 2;
	}
	
	void _dxxx(OpCode op)
	{
		logger.writefln("DRW V%x, V%x, %x", op.x, op.y, op.z);
		V[0xf] = scr.drawSprite(V[op.x], V[op.y], op.z, memory[I .. I + op.z + 1]);
		pc += 2;
	}
	
	void _exxx(OpCode op)
	{
		switch(op.kk)
		{
			case 0x9e: _ex9e(op); break;
			case 0xa1: _exa1(op); break;
			default:
				logger.writefln("Unknown op : %x", op.value);
				pc += 2;
			break;
		}
	}
	
	void _ex9e(OpCode op)
	{
		logger.writefln("SKP V%x", op.x);
		pc += kbd.isPressed(V[op.x]) ? 4 : 2;
	}
	
	void _exa1(OpCode op)
	{
		logger.writefln("SKNP V%x", op.x);
		pc += kbd.isPressed(V[op.x]) ? 2 : 4;
	}
	
	void _fxxx(OpCode op)
	{
		switch(op.kk)
		{
			case 0x0007: _fx07(op); break;
			case 0x000a: _fx0a(op); break;
			case 0x0015: _fx15(op); break;
			case 0x0018: _fx18(op); break;
			case 0x001e: _fx1e(op); break;
			case 0x0029: _fx29(op); break;
			case 0x0033: _fx33(op); break;
			case 0x0055: _fx55(op); break;
			case 0x0065: _fx65(op); break;
			default:
				logger.writefln("Unknown op : %x", op.value);
				pc += 2;
			break;
		}
	}
	
	void _fx07(OpCode op)
	{
		logger.writefln("LD V%x, DT", op.x);
		V[op.x] = delay_timer;
		pc += 2;
	}
	
	void _fx0a(OpCode op)
	{
		logger.writefln("LD V%x, K", op.x);
		wait_for_keypress = true;
		ubyte pressed = kbd.getPressed();
		if(pressed != 0x10)
		{
			V[op.x] = pressed;
			wait_for_keypress = false;
			pc += 2;
		}
	}
	
	void _fx15(OpCode op)
	{
		logger.writefln("LD DT, V%x", op.x);
		delay_timer = V[op.x];
		pc += 2;
	}
	
	void _fx18(OpCode op)
	{
		logger.writefln("LD ST, V%x", op.x);
		sound_timer = V[op.x];
		pc += 2;
	}
	
	void _fx1e(OpCode op)
	{
		logger.writefln("ADD I, V%x", op.x);
		I += V[op.x];
		pc += 2;
	}
	
	void _fx29(OpCode op)
	{
		logger.writefln("LD F, V%x", op.x);
		I = V[op.x] * 5;
		pc += 2;
	}
	
	void _fx33(OpCode op)
	{
		logger.writefln("LD B, V%x", op.x);
		memory[I] = V[op.x] / 100;
		memory[I + 1] = (V[op.x] / 10) % 10;
		memory[I + 2] = V[op.x] % 10;
		//memory[I + 2] = (V[x] % 100) / 10;
		pc += 2;
	}
	
	void _fx55(OpCode op)
	{
		logger.writefln("LD [I], V%x", op.x);
		memory[I .. I + op.x + 1] = V[0 .. op.x + 1];
		pc += 2;
	}
	
	void _fx65(OpCode op)
	{
		logger.writefln("LD V%x, [I]", op.x);
		V[0 .. op.x + 1] = memory[I .. I + op.x + 1];
		pc += 2;
	}
	
}
