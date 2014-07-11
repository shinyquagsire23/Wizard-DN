#define u8 unsigned char
#define u16 unsigned short
#define u32 unsigned int


#define OBJ_PaletteMem        ((u16*)0x020373F8) // Sprite Palette(256/16 colors) (adjusted for FR callback)
#define BG_PaletteMem          ((u16*)0x020371F8) // Background Palette(256/16 colors) (adjusted for FR callback)
#define BG_PaletteMem2          ((u16*)0x020375F8) // Background Palette(256/16
#define OBJ_PaletteMem2        ((u16*)0x020377F8) // Sprite Palette(256/16 colors)

#define pal        		((u16*)offset) // Sprite Palette(256/16 colors)
#define palArr        	((u16*)palette) // Sprite Palette(256/16 colors)
#define palMask		((u16*)(palette+(maskLut[tehTimeByte])))
#define palMaskStart		(*(u16*)(palette+0x200-(type==0x70?0xE0:0)))
#define timeByte		((unsigned char*)0x0203C000)
#define customColor		(*(unsigned int*)0x0203C010)
#define bwFilter		((unsigned char*)0x02036E28)
#define blockset0Pal (*(u32*)((*(u32*)((*(u32*)(0x02036DFC))+16))+8))
#define mapType (*(u8*)(0x02036E13))
const unsigned int colors[144];
const unsigned int maskLut[4];
const unsigned int nonList[4];

//Hook in 080598CC
//Null out bytes 08059A28-08059A2F
//Null out bytes 08059A12-08059A13

void filter(unsigned int palette, unsigned int dest, unsigned int mode)
{
	int type = dest;
	if(palette == 0x08059A0F)
		palette = blockset0Pal;

	//Copy over old palette so we can start fresh with the mixer
	if(type == 0x70)
	{
		for(int i = 0; i < 6 * 0x10; i++)
			BG_PaletteMem[0x70 + (i)] = palArr[i];
	}

	int offset = 0x020371F8;
	int amount = 0x7;
	int thing = 0x0;
	int thing2 = 0x70;

	if(type == 0x70)
	{
		offset += 0xE0;
		amount = 0x6;
		thing = 0x70;
		thing2 = 0x60;
	}

	int time = timeByte[2];
	if(timeByte[4] != 0)
		time = timeByte[4];

	int returnYN = 0;
	for(int i = 0; i < 4; i++)
	{
		if(mapType == nonList[i])
			returnYN = 1;
	}

	if(returnYN && timeByte[4] == 0 && timeByte[5] == 0 && customColor == 0)
	{
		doMasking(palette, type, offset, amount);
		if(bwFilter[0] > 0 && bwFilter[0] < 4)
		{
			doBW(bwFilter[0], thing, thing2, offset, amount * 0x10);
		}
		return;
	}

	unsigned int mC = colors[time];//0xA02f3070
	if(customColor != 0)
		mC = customColor;

	for(int i = 0; i < amount*16; i++)
	{
		if(((mC & 0xFF000000) >> (24)) == 0)
			break;

		u16 color = pal[i]; 

		if(color == 0x0)
			continue;

		int r = (color & 0x1F);
		int g = (color & 0x3E0) >> (0x5);
		int b = (color & 0x7C00) >> (0xA);
		int a = 0x1F;
		//int gray = ((r+g+b)/3)>>3;

		//u16 grayscale = ((unsigned char)(gray & 0x1F) + ((unsigned char)(gray & 0x1F) << 5) + ((unsigned char)(gray & 0x1F) << 10));



		unsigned int mA = (mC & 0xFF000000) >> (24+3);
		unsigned int mR = (mC & 0x00FF0000) >> (16+3);
		unsigned int mG = (mC & 0x0000FF00) >> (8+3);
		unsigned int mB = (mC & 0x000000FF) >> (0+3);

		//Highlights+Shadows diff test
		/*unsigned int intensityLut[0x20] = { mA, (mA/18)*17, (mA/18)*16, (mA/18)*15, (mA/18)*14, (mA/18)*13, (mA/18)*12, (mA/18)*11, (mA/18)*10, (mA/18)*9, (mA/18)*8, (mA/18)*7, (mA/18)*6, (mA/18)*5, (mA/18)*4, (mA/18)*3, (mA/18)*2, (mA/18)*1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

		mA -= intensityLut[0x1F - gray];*/

		unsigned char rem = 0x1F - mA; // Remaining fraction

		short r1 = div((r*rem + mR*mA), 0x1F);
		short g1 = div((g*rem + mG*mA), 0x1F);
		short b1 = div((b*rem + mB*mA), 0x1F); 

		color = ((unsigned char)(r1 & 0x1F) + ((unsigned char)(g1 & 0x1F) << 5) + ((unsigned char)(b1 & 0x1F) << 10));
		pal[i] = color;
	}
	
	doMasking(palette, type, offset, amount);
	if(bwFilter[0] > 0 && bwFilter[0] < 4)
	{
		doBW(bwFilter[0], thing, thing2, offset, amount * 0x10);
		return;
	}
}

void doMasking(int palette, int type, int offset, int amount)
{
	int tehTimeByte = timeByte[0];
	if(timeByte[0] != 2 && palMaskStart == 0x8F8F) //We don't mask during the day, or if the map doesn't have masking
	{
		offset = 0x020371F8+(type==0x70?0xE0:0);
			
		for(int i = 0; i < (amount) * 0x10; i++)
		{
			if(palMask[i] != 0x8F8F)
				pal[i] = palMask[i];
		}
	}
}

int div(int a, int b)
{
	__asm("swi 0x6");
	return;
}

void doBW(unsigned char type, unsigned int thingy, unsigned int thingy2, unsigned int offset, unsigned int length)
{
	if(bwFilter[0] & 0x1 == 0x1)
	{
		if(bwFilter[0] == 0x3)
		{
			int (*func)(unsigned int, unsigned int) = (int (*)(void))0x08111F38+1;
			func(thingy,thingy2);
		}
		int (*func2)(unsigned int, unsigned int) = (int (*)(void))0x08071544+1;
		func2(offset,length);
	}
	else if(bwFilter[0] == 0x2)
	{
		int (*func2)(unsigned int, unsigned int) = (int (*)(void))0x080715F4+1;
		func2(offset,length);
	}
}

//Format is ARGB
const unsigned int colors[144] __attribute__((aligned(4)))={ 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x4D3102A4, 0x4B3805A0, 0x4940089C, 0x47470B98, 0x454E0E95, 0x43561191, 0x415D148D, 0x3F641789, 0x3D6C1A86, 0x3B731D82, 0x397A207E, 0x3782237A, 0x35892677, 0x33902973, 0x30982C6F, 0x2E9F2F6B, 0x2CA63268, 0x2AAE3564, 0x28B53860, 0x26BC3B5C, 0x24C43E59, 0x22CB4155, 0x20D24451, 0x1EDA474D, 0x1CE14A4A, 0x1AE84D46, 0x18F05042, 0x16F7533E, 0x14FF563B, 0x14FF563B, 0x13F75339, 0x12F05137, 0x12E94E35, 0x11E14C34, 0x11DA4932, 0x10D34730, 0x10CC442F, 0x0FC4422D, 0x0EBD3F2B, 0x0EB63D2A, 0x0DAE3A28, 0x0DA73826, 0x0CA03625, 0x0C993323, 0x0B913121, 0x0A8A2E20, 0x0A832C1E, 0x097B291C, 0x0974271A, 0x086D2419, 0x07652217, 0x075E1F15, 0x06571D14, 0x06501B12, 0x05481810, 0x0541160F, 0x043A130D, 0x0332110B, 0x032B0E0A, 0x02240C08, 0x021D0906, 0x01150705, 0x010E0403, 0x00070201, 0x00000000, 0x00000000, 0x01020000, 0x03040000, 0x05060000, 0x06080000, 0x080A0000, 0x0A0C0000, 0x0C0E0000, 0x0D100000, 0x0F120000, 0x11140000, 0x13160000, 0x14190100, 0x161B0100, 0x181D0100, 0x1A1F0100, 0x1B210100, 0x1D230100, 0x1F250100, 0x21270100, 0x22290100, 0x242B0100, 0x262D0100, 0x28300200, 0x28300200, 0x302E0121, 0x382D0143, 0x402C0064, 0x482B0086, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8, 0x502A00A8 };


const unsigned int nonList[4] ={ 0x4, 0x8, 0x9, 0xFF };
const unsigned int maskLut[4] __attribute__((aligned(4)))={ 0x600, 0x200, 0x0, 0x400 };

