import std.conv: to;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import cpu;
import keyboard;
import std.stdio;
import std.getopt;
import display;
import utils;

int main(string[] args)
{
	DerelictSDL2.load();
	SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER);

	int delay = 12;
	bool debug_enable = false;
	string output = "stdout";
	File writer = stdout;
	ushort zoom = 5;
	getopt(args, std.getopt.config.passThrough,
		"z|zoom", &zoom,
		"o|out", &output,
		"d|debug", &debug_enable
	);
	if(args.length == 1)
	{
		writefln("Usage : %s game.ch8", args[0]);
		writeln();
		writeln("-z|--zoom N : multiply the 64x32 resolution N times");
		writeln("-d|--debug : display opcodes in real time");
		writeln("-o|--out FILE : redirect output to the given FILE");
		writeln();
		return 0;
	}

	if(output != "stdout")
		writer = File(output, "w");
	auto screen = new Screen(zoom);
	scope(exit) screen.cleanup();
	auto keyboard = new Keyboard;
	auto logger = Logger(writer);
	logger.enable = debug_enable;

	auto cpu = new Cpu(keyboard, logger, screen);
	cpu.loadGame(args[1]);
	
	bool running = true;
	bool pause = false;
	SDL_Event event;
	int i;
	int sleep_after = 5; //sleep after this many cycles

	auto timers_timer = SDL_AddTimer(16u, cast(SDL_TimerCallback) &decrementTimers, cast(void *) cpu);
	auto screen_timer = SDL_AddTimer(16u, cast(SDL_TimerCallback) &updateScreen, cast(void *) screen);
	scope(exit)
	{
		SDL_RemoveTimer(timers_timer);
		SDL_RemoveTimer(screen_timer);
	}
	
	while(running)
	{
		SDL_PollEvent(&event);
		switch(event.type)
		{
			case SDL_QUIT: running = false; break;
			case SDL_KEYDOWN:
				auto pressed = event.key.keysym.sym;
				if(pressed == SDLK_ESCAPE)
				{
					running = false;
				}
				else if(pressed == SDLK_p)
				{
					sleep_after = (sleep_after + 1) > 50 ? 50 : sleep_after + 1;
					screen.setTitle(sleep_after.to!string ~ " opcodes per cycle");
				}
				else if(pressed == SDLK_m)
				{
					sleep_after = (sleep_after - 1) < 1 ? 1 : sleep_after - 1;
					screen.setTitle(sleep_after.to!string ~ " opcodes per cycle");
				}
				else if(pressed == SDLK_RETURN)
				{
					pause = !pause;
					screen.setTitle("[Pause]");
				}
				else
				{
					keyboard.press(pressed);
				}
			break;
			case SDL_KEYUP:
				keyboard.unpress(event.key.keysym.sym);
			break;
			default:
			break;
		}
		try
		{
			if(!pause)
				cpu.runCycle();
		}
		catch(Exception e)
		{
			writeln(e.msg);
			break;
		}

		if(++i % sleep_after == 0)
			SDL_Delay(delay);
	}
	return 0;
}

//I'm not proud of these functions :^(
extern(C) uint decrementTimers(uint interval, void *param) nothrow 
{
	auto cpu = cast(Cpu) param;
	cpu.decrementTimers();
	return interval;
}

extern(C) uint updateScreen(uint interval, void *param) nothrow
{
	auto display = cast(Screen) param;
	display.render();
	return interval;
}
