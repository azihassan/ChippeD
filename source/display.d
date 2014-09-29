import derelict.sdl2.sdl;
import std.string : toStringz;
import std.stdio;
import std.string;
import std.format : to;
import std.algorithm : map;


struct Pixel
{
	SDL_Rect pos;
	ushort zoom;
	bool lit;

	this(ushort zoom, ushort x, ushort y)
	{
		this.zoom = zoom;
		pos.x = x * zoom;
		pos.y = y * zoom;
		pos.w = zoom;
		pos.h = zoom;
	}
}

class Screen
{
	SDL_Window *win;
	SDL_Renderer *renderer;
	Pixel[32][64] grid;
	string title = "Chip-8 Emulator written by Hassan";

	this(ushort zoom)
	{
		win = SDL_CreateWindow(title.toStringz, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, zoom * 64, zoom * 32, 0);
		renderer = SDL_CreateRenderer(win, -1, 0);
		foreach(ushort y; 0 .. 32)
			foreach(ushort x; 0 .. 64)
				grid[x][y] = Pixel(zoom, x, y);
	}

	void setTitle(string title, bool overwrite = true)
	{
		if(overwrite)
			this.title = title;
		else
			this.title ~= title;
		SDL_SetWindowTitle(win, this.title.toStringz);
	}

	void clearScreen()
	{
		foreach(ushort y; 0 .. 32)
			foreach(ushort x; 0 .. 64)
				grid[x][y].lit = false;
	}

	bool drawSprite(ushort x, ushort y, ushort h, ubyte[] data)
	{
		bool collision, changed;
		foreach(y_offset; 0 .. h)
		{
			foreach(x_offset; 0 .. 8)
			{
				ushort _x, _y;
				_x = cast(ushort) ((x_offset + x) % 64);
				_y = cast(ushort) ((y_offset + y) % 32);
				
				bool status = grid[_x][_y].lit;
				ubyte mask = data[y_offset] & (0b10000000 >> x_offset);
				if(mask != 0) //as per Wikipedia's specs
				{
					changed = true;
					status = !status; //flip the pixel
					if(!status)
						collision = true;
					grid[_x][_y].lit = status;
				}
			}
		}
		return collision;
	}

	void render() nothrow
	{
		SDL_SetRenderDrawColor(renderer, 0, 0, 0, 0);
		SDL_RenderClear(renderer);
		SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
		foreach(x; 0 .. grid.length)
			foreach(y; 0 .. grid[0].length)
				if(grid[x][y].lit)
					SDL_RenderDrawRect(renderer, &grid[x][y].pos);
		SDL_RenderPresent(renderer);
	}

	void cleanup()
	{
		SDL_DestroyRenderer(renderer);
		SDL_DestroyWindow(win);
	}
}

ubyte[] fonts = [
	0Xf0,0X90,0X90,0X90,0Xf0, //0
	0X20,0X60,0X20,0X20,0X70, //1
	0Xf0,0X10,0Xf0,0X80,0Xf0, //2
	0Xf0,0X10,0Xf0,0X10,0Xf0, //3
	0X90,0X90,0Xf0,0X10,0X10, //4
	0Xf0,0X80,0Xf0,0X10,0Xf0, //5
	0Xf0,0X80,0Xf0,0X90,0Xf0, //6
	0Xf0,0X10,0X20,0X40,0X40, //7
	0Xf0,0X90,0Xf0,0X90,0Xf0, //8
	0Xf0,0X90,0Xf0,0X10,0Xf0, //9
	0Xf0,0X90,0Xf0,0X90,0X90, //a
	0Xe0,0X90,0Xe0,0X90,0Xe0, //b
	0Xf0,0X80,0X80,0X80,0Xf0, //c
	0Xe0,0X90,0X90,0X90,0Xe0, //d
	0Xf0,0X80,0Xf0,0X80,0Xf0, //e
	0Xf0,0X80,0Xf0,0X80,0X80  //f
];
