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

	int delay = 6;
	bool debug_enable = false;
	string output = "stdout";
	File writer = stdout;
	ushort zoom = 5;
	getopt(args, std.getopt.config.passThrough,
		"zoom", &zoom,
		"out", &output,
		"d|debug", &debug_enable
	);

	if(output != "stdout")
		writer = File(output, "w");
	auto cpu = new Cpu();
	auto scr = new Screen(zoom);
	scope(exit) scr.cleanup();
	auto kbd = new Keyboard;
	auto logger = Logger(writer);
	logger.enable = debug_enable;

	cpu.scr = scr;
	cpu.kbd = kbd;
	cpu.logger = logger;
	cpu.loadGame(args[1]);
	
	bool running = true;
	bool pause = false;
	SDL_Event event;
	int i;
	int sleep_after = 2; //delay after this many cycles

	auto timers_timer = SDL_AddTimer(16u, cast(SDL_TimerCallback) &decrementTimers, cast(void *) cpu);
	auto screen_timer = SDL_AddTimer(16u, cast(SDL_TimerCallback) &updateScreen, cast(void *) scr);
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
					scr.setTitle(sleep_after.to!string ~ " instructions before sleep");
				}
				else if(pressed == SDLK_m)
				{
					sleep_after = (sleep_after - 1) < 1 ? 1 : sleep_after - 1;
					scr.setTitle(sleep_after.to!string ~ " instructions before sleep");
				}
				else if(pressed == SDLK_RETURN)
				{
					pause = !pause;
					scr.setTitle("[Pause]", false);
				}
				else
				{
					cpu.kbd.press(pressed);
				}
			break;
			case SDL_KEYUP:
				cpu.kbd.unpress(event.key.keysym.sym);
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
