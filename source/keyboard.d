import derelict.sdl2.sdl;

static this()
{
	DerelictSDL2.load();
}

class Keyboard
{
	ubyte[SDL_Keycode] keymap;
	bool[ubyte] status;

	this()
	{
		keymap = [
			SDLK_SPACE : 0x0,
			SDLK_a : 0x1,
			SDLK_z : 0x2,
			SDLK_e : 0x3,
			SDLK_q : 0x4,
			SDLK_s : 0x5,
			SDLK_d : 0x6,
			SDLK_w : 0x7,
			SDLK_x : 0x8,
			SDLK_c : 0x9,
			SDLK_u : 0xa,
			SDLK_i : 0xb,
			SDLK_o : 0xc,
			SDLK_j : 0xd,
			SDLK_k : 0xe,
			SDLK_l : 0xf
		];
		foreach(code, value; keymap)
			status[value] = false;
	}

	void reset()
	{
		foreach(ref key; status)
			key = false;
	}

	bool isPressed(ubyte key)
	{
		return status[key];
	}

	void press(SDL_Keycode code)
	{
		if(code in keymap)
			status[keymap[code]] = true;
	}

	void unpress(SDL_Keycode code)
	{
		if(code in keymap)
			status[keymap[code]] = false;
	}

	ubyte getPressed()
	{
		foreach(code, value; status)
			if(value)
				return code;
		return 0x10;
	}
}
