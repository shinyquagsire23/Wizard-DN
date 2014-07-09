#define u8 unsigned byte
#define u16 unsigned short
#define u32 usigned int


#define OBJ_PaletteMem        ((u16*)0x020373F8) // Sprite Palette(256/16 colors) (adjusted for FR callback)
#define BG_PaletteMem          ((u16*)0x020371F8) // Background Palette(256/16 colors) (adjusted for FR callback)
#define BG_PaletteMem2          ((u16*)0x020375F8) // Background Palette(256/16
#define OBJ_PaletteMem2        ((u16*)0x020377F8) // Sprite Palette(256/16 colors)

#define pal        ((u16*)offset) // Sprite Palette(256/16 colors)
#define timeByte	((unsigned char*)0x0203C000)
const unsigned char filters[4];

void filter(unsigned int derp, unsigned int offset)
{
	offset -= 0x400;
	
	for(int i = 0; i < 16; i++)
	{
		u16 color = pal[i];
		int r = color & 0x1F;
		int g = (color & 0x3E0) >> 0x5;
		int b = (color & 0x7C00) >> 0xA;

		//r *= 2.1;

		int time = timeByte[0];
		int filter = filters[time];

		if(filter & 1)
			r = (r >> 1);
		if((filter & 2) >> 1)
			g = (g >> 1);
		if((filter & 4) >> 2)
			b = (b >> 1);
		color = (r + (g << 5) + (b << 10));
		pal[i] = color;
	}

	for(int i = 0; i < 0x200; i++)
		BG_PaletteMem2[i] = BG_PaletteMem[i];
}

const unsigned char filters[4] __attribute__((aligned(4)))={ 0b011, 0b100, 0b000, 0b110 };
