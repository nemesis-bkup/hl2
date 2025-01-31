/* Use first frame for drawing (needs precache) */
#define NUMSIZE_X 20/256
#define NUMSIZE_Y 28/64
#define HUD_ALPHA 0.75

// primary: 255 208 64
// secondary 255 48 0
// tertiary 255 160 0

float spr_hudnum[10] = {
	2 / 256,
	22 / 256,
	42 / 256,
	62 / 256,
	82 / 256,
	102 / 256,
	122 / 256,
	142 / 256,
	162 / 256,
	182 / 256
};

float spr_hudnum_small[12] = {
	0 / 256,
	10 / 256,
	20 / 256,
	30 / 256,
	40 / 256,
	50 / 256,
	60 / 256,
	70 / 256,
	80 / 256,
	90 / 256,
	100 / 256,
	110 / 256
};

/* pre-calculated sprite definitions */
float spr_health[4] = {
	163 / 256, // pos x
	29 / 64, // pos u
	48 / 256, // size x
	16 / 64 // size y
};

float spr_armor[4] = {
	223 / 256, // pos x
	28 / 64, // pos u
	32 / 256, // size x
	16 / 64 // size y
};

float spr_ammo[4] = {
	120 / 256, // pos x
	28 / 64, // pos u
	32 / 256, // size x
	16 / 64 // size y
};

float spr_flash1[4] = {
	160 / 256, // pos x
	24 / 128, // pos u
	32 / 256, // size x
	32 / 128 // size y
};

float spr_flash2[4] = {
	112 / 256, // pos x
	24 / 128, // pos u
	48 / 256, // size x
	32 / 128 // size y
};

void
OldHUD_Init(void)
{

}

#define OLDHUD_SHEET "materials/Sprites/hud1"

void
OldHUD_RendererRestarted(void)
{
	precache_pic(OLDHUD_SHEET);
}

/* seperator for mainly ammo */
void
HUD_DrawSeperator(vector pos)
{
	drawsubpic(pos,
		[10,28],
		OLDHUD_SHEET,
		[240/256, 0.0],
		[10/256, 28/64],
		g_fg_color,
		1.0,
		DRAWFLAG_ADDITIVE
	);
}

/* handle single/multiple digits */
void
HUD_DrawNumber(int iNumber, vector vecPos, float fAlpha, vector vColor)
{
	drawsubpic(vecPos,
		[20,28],
		OLDHUD_SHEET,
		[spr_hudnum[iNumber], 0],
		[NUMSIZE_X, NUMSIZE_Y],
		vColor,
		fAlpha,
		DRAWFLAG_ADDITIVE
	);
}

void
HUD_DrawNumberS(int iNumber, vector vecPos, float fAlpha, vector vColor)
{
	drawsubpic(vecPos,
		[10,12],
		OLDHUD_SHEET,
		[spr_hudnum_small[iNumber], 29/64],
		[10/256, 12/64],
		vColor,
		fAlpha,
		DRAWFLAG_ADDITIVE
	);
}

void
HUD_DrawAmmoSeparator(vector vecPos)
{
	drawsubpic(vecPos,
		[10,28],
		OLDHUD_SHEET,
		[240/256, 0.0],
		[10/256, 28/256],
		g_fg_color,
		1.0,
		DRAWFLAG_ADDITIVE
	);
}

void
HUD_DrawNums(float fNumber, vector vecPos, float fAlpha, vector vColor)
{
	int i = fNumber;

	/* always draw 3 digits */
	for (int x = 0; x < 3; x++) {
		int b = (float)i % 10;

		/* don't allow anything below 0 */
		if (b < 0)
			b = 0;

		/* if we're a zero, but a leading one... */
		if (b == 0)
			if ((fNumber < 100 && x == 2) || (fNumber < 10 && x == 1))
				fAlpha = 0.25f;

		if (x == 1) {
			drawsubpic(vecPos,
				[20,28],
				OLDHUD_SHEET,
				[220/256, 0.0],
				[NUMSIZE_X, NUMSIZE_Y],
				vColor,
				fAlpha,
				DRAWFLAG_ADDITIVE
			);
		} else if (x == 2) {
			drawsubpic(vecPos,
				[20,28],
				OLDHUD_SHEET,
				[200/256, 0.0],
				[NUMSIZE_X, NUMSIZE_Y],
				vColor,
				fAlpha,
				DRAWFLAG_ADDITIVE
			);
		} else {
			drawsubpic(vecPos,
				[20,28],
				OLDHUD_SHEET,
				[200/256, 0.0],
				[NUMSIZE_X, NUMSIZE_Y],
				vColor,
				fAlpha,
				DRAWFLAG_ADDITIVE
			);
		}

		HUD_DrawNumber(b, vecPos, fAlpha, vColor);

		i = i / 10;
		vecPos[0] -= 20;
	}
}

void
HUD_DrawNumsS(float fNumber, vector vecPos, float fAlpha, vector vColor)
{
	int i = fNumber;

	/* always draw 3 digits */
	for (int x = 0; x < 3; x++) {
		int b = (float)i % 10;

		/* don't allow anything below 0 */
		if (b < 0)
			b = 0;

		/* if we're a zero, but a leading one... */
		if (b == 0)
			if ((fNumber < 100 && x == 2) || (fNumber < 10 && x == 1))
				fAlpha = 0.25f;

		if (x == 1) {
			drawsubpic(vecPos,
				[10,12],
				OLDHUD_SHEET,
				[spr_hudnum_small[11], 29/64],
				[10/256, 12/64],
				vColor,
				fAlpha,
				DRAWFLAG_ADDITIVE
			);
		} else if (x == 2) {
			drawsubpic(vecPos,
				[10,12],
				OLDHUD_SHEET,
				[spr_hudnum_small[10], 29/64],
				[10/256, 12/64],
				vColor,
				fAlpha,
				DRAWFLAG_ADDITIVE
			);
		} else {
			drawsubpic(vecPos,
				[10,12],
				OLDHUD_SHEET,
				[spr_hudnum_small[10], 29/64],
				[10/256, 12/64],
				vColor,
				fAlpha,
				DRAWFLAG_ADDITIVE
			);
		}

		HUD_DrawNumberS(b, vecPos, fAlpha, vColor);

		i = i / 10;
		vecPos[0] -= 10;
	}
}

/* health */
void
HL2OldHUD_DrawHealth(float value, vector hudMins, vector hudSize)
{
	vector pos;
	pos = hudMins + [16, hudSize[1] - 42];

	if (value > 25) {
		drawsubpic(
			pos + [0,-14],
			[48,16],
			OLDHUD_SHEET,
			[spr_health[0], spr_health[1]],
			[spr_health[2], spr_health[3]],
			g_fg_color,
			g_healthAlpha,
			DRAWFLAG_ADDITIVE
		);
		HUD_DrawNums(value, pos + [40, 0], g_healthAlpha, g_fg_color);
	} else {
		drawsubpic(
			pos + [0,-14],
			[48,16],
			OLDHUD_SHEET,
			[spr_health[0], spr_health[1]],
			[spr_health[2], spr_health[3]],
			[1,0.627450980392,0],
			g_healthAlpha,
			DRAWFLAG_ADDITIVE
		);
		HUD_DrawNums(value, pos + [40, 0], g_healthAlpha, [1,0,0]);
	}
}

/* armor/suit charge */
void
HL2OldHUD_DrawArmor(float value, vector hudMins, vector hudSize)
{
	vector pos;

	pos = hudMins + [16+96, hudSize[1] - 42];
	if (value > 25) {
		drawsubpic(
			pos + [0,-14],
			[32,16],
			OLDHUD_SHEET,
			[spr_armor[0], spr_armor[1]],
			[spr_armor[2], spr_armor[3]],
			g_fg_color,
			g_armorAlpha,
			DRAWFLAG_ADDITIVE
		);
		HUD_DrawNums(value, pos + [40, 0], g_armorAlpha, g_fg_color);
	} else {
		drawsubpic(
			pos + [0,-14],
			[32,16],
			OLDHUD_SHEET,
			[spr_armor[0], spr_armor[1]],
			[spr_armor[2], spr_armor[3]],
			[1,0.627450980392,0],
			g_armorAlpha,
			DRAWFLAG_ADDITIVE
		);
		HUD_DrawNums(value, pos + [40, 0], g_armorAlpha, [1,0,0]);
	}
}

/* magazine/clip ammo */
void
HL2OldHUD_DrawAmmo1(int value, vector hudMins, vector hudSize)
{
	vector pos;
	pos = hudMins + [hudSize[0] - 152, hudSize[1] - 42];

		drawsubpic(
			pos + [-38,-14],
			[32,16],
			OLDHUD_SHEET,
			[spr_ammo[0], spr_ammo[1]],
			[spr_ammo[2], spr_ammo[3]],
			g_fg_color,
			g_armorAlpha,
			DRAWFLAG_ADDITIVE
		);

	HUD_DrawNums(value, pos, g_clipAlpha, g_fg_color);
	HUD_DrawSeperator(pos + [30,0]);
}

/* leftover type ammo */
void
HL2OldHUD_DrawAmmo2(int value, vector hudMins, vector hudSize)
{
	vector pos;
	pos = hudMins + [hudSize[0] - 80, hudSize[1] - 42 + 5];
	HUD_DrawNumsS(value, pos, g_ammo1Alpha, g_fg_color);
}

/* special ammo */
void
HL2OldHUD_DrawAmmo3(int value, vector hudMins, vector hudSize)
{
	vector pos;
	pos = hudMins + [hudSize[0] - 42, hudSize[1] - 42 + 5];
	HUD_DrawNumsS(value, pos, g_ammo2Alpha, g_fg_color);
}
