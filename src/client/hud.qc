/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

void HUD_DrawWeaponSelect(void);

/* Use first frame for drawing (needs precache) */
#define NUMSIZE_X 20/256
#define NUMSIZE_Y 28/64
#define HUD_ALPHA 0.75

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

/* precaches */
void
HUD_Init(void)
{
	Font_Load("fonts/hud_cross.font", FONT_HUD_CROSS);
	g_cross_spr = spriteframe("sprites/crosshairs.spr", 0, 0.0f);
	g_laser_spr = spriteframe("sprites/laserdot.spr", 0, 0.0f);
	g_hud1_spr = "materials/Sprites/hud1";
	g_hud2_spr =  "materials/Sprites/hud1";
	g_hud3_spr =  "materials/Sprites/hud1";
	g_hud4_spr =  "materials/Sprites/hud1";
	g_hud5_spr = "materials/Sprites/hud1";
	g_hud6_spr =  "materials/Sprites/hud1";
	g_hud7_spr =  "materials/Sprites/hud1";
	HUD_AmmoNotify_Init();
	HUD_DamageNotify_Init();
	HUD_ItemNotify_Init();
}

/* seperator for mainly ammo */
void
HUD_DrawSeperator(vector pos)
{
	drawsubpic(pos,
		[10,28],
		g_hud7_spr,
		[240/256, 0.0],
		[10/256, 28/64],
		g_hud_color,
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
		g_hud7_spr,
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
		g_hud7_spr,
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
		g_hud7_spr,
		[240/256, 0.0],
		[10/256, 28/256],
		g_hud_color,
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
				g_hud7_spr,
				[220/256, 0.0],
				[NUMSIZE_X, NUMSIZE_Y],
				vColor,
				fAlpha,
				DRAWFLAG_ADDITIVE
			);
		} else if (x == 2) {
			drawsubpic(vecPos,
				[20,28],
				g_hud7_spr,
				[200/256, 0.0],
				[NUMSIZE_X, NUMSIZE_Y],
				vColor,
				fAlpha,
				DRAWFLAG_ADDITIVE
			);
		} else {
			drawsubpic(vecPos,
				[20,28],
				g_hud7_spr,
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
				g_hud7_spr,
				[spr_hudnum_small[11], 29/64],
		[10/256, 12/64],
				vColor,
				fAlpha,
				DRAWFLAG_ADDITIVE
			);
		} else if (x == 2) {
			drawsubpic(vecPos,
				[10,12],
				g_hud7_spr,
				[spr_hudnum_small[10], 29/64],
		[10/256, 12/64],
				vColor,
				fAlpha,
				DRAWFLAG_ADDITIVE
			);
		} else {
			drawsubpic(vecPos,
				[10,12],
				g_hud7_spr,
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
HUD_DrawHealth(void)
{
	vector pos;
	player pl = (player)pSeat->m_ePlayer;

	if (pl.health != pSeatLocal->m_iHealthOld) {
		pSeatLocal->m_flHealthAlpha = 1.0;
	}

	if (pSeatLocal->m_flHealthAlpha >= HUD_ALPHA) {
		pSeatLocal->m_flHealthAlpha -= clframetime * 0.5;
	} else {
		pSeatLocal->m_flHealthAlpha = HUD_ALPHA;
	}

	pos = g_hudmins + [16, g_hudres[1] - 42];
	if (pl.health > 25) {
		drawsubpic(
			pos + [0,-14],
			[48,16],
			g_hud7_spr,
			[spr_health[0], spr_health[1]],
			[spr_health[2], spr_health[3]],
			g_hud_color,
			pSeatLocal->m_flHealthAlpha,
			DRAWFLAG_ADDITIVE
		);
		HUD_DrawNums(pl.health, pos + [40, 0], pSeatLocal->m_flHealthAlpha, g_hud_color);
	} else {
		drawsubpic(
			pos + [0,-14],
			[48,16],
			g_hud7_spr,
			[spr_health[0], spr_health[1]],
			[spr_health[2], spr_health[3]],
			[1,0,0],
			pSeatLocal->m_flHealthAlpha,
			DRAWFLAG_ADDITIVE
		);
		HUD_DrawNums(pl.health, pos + [40, 0], pSeatLocal->m_flHealthAlpha, [1,0,0]);
	}

	pSeatLocal->m_iHealthOld = pl.health;
}

/* armor/suit charge */
void
HUD_DrawArmor(void)
{
	vector pos;
	player pl = (player)pSeat->m_ePlayer;

	if (pl.armor != pSeatLocal->m_iArmorOld) {
		pSeatLocal->m_flArmorAlpha = 1.0;
	}

	if (pSeatLocal->m_flArmorAlpha >= HUD_ALPHA) {
		pSeatLocal->m_flArmorAlpha -= clframetime * 0.5;
	} else {
		pSeatLocal->m_flArmorAlpha = HUD_ALPHA;
	}

	pos = g_hudmins + [16+96, g_hudres[1] - 42];
	if (pl.armor > 25) {
		drawsubpic(
			pos + [0,-14],
			[32,16],
			g_hud7_spr,
			[spr_armor[0], spr_armor[1]],
			[spr_armor[2], spr_armor[3]],
			g_hud_color,
			pSeatLocal->m_flArmorAlpha,
			DRAWFLAG_ADDITIVE
		);
		HUD_DrawNums(pl.armor, pos + [40, 0], pSeatLocal->m_flArmorAlpha, g_hud_color);
	} else {
		drawsubpic(
			pos + [0,-14],
			[32,16],
			g_hud7_spr,
			[spr_armor[0], spr_armor[1]],
			[spr_armor[2], spr_armor[3]],
			[1,0,0],
			pSeatLocal->m_flArmorAlpha,
			DRAWFLAG_ADDITIVE
		);
		HUD_DrawNums(pl.armor, pos + [40, 0], pSeatLocal->m_flArmorAlpha, [1,0,0]);
	}

	pSeatLocal->m_iArmorOld = pl.armor;
}

/* magazine/clip ammo */
void
HUD_DrawAmmo1(void)
{
	player pl = (player)pSeat->m_ePlayer;
	vector pos;

	if (pl.a_ammo1 != pSeatLocal->m_iAmmo1Old) {
		pSeatLocal->m_flAmmo1Alpha = 1.0;
		pSeatLocal->m_iAmmo1Old = pl.a_ammo1;
	}

	if (pSeatLocal->m_flAmmo1Alpha >= HUD_ALPHA) {
		pSeatLocal->m_flAmmo1Alpha -= clframetime * 0.5;
	} else {
		pSeatLocal->m_flAmmo1Alpha = HUD_ALPHA;
	}

	pos = g_hudmins + [g_hudres[0] - 152, g_hudres[1] - 42];

		drawsubpic(
			pos + [-38,-14],
			[32,16],
			g_hud7_spr,
			[spr_ammo[0], spr_ammo[1]],
			[spr_ammo[2], spr_ammo[3]],
			g_hud_color,
			pSeatLocal->m_flArmorAlpha,
			DRAWFLAG_ADDITIVE
		);

	HUD_DrawNums(pl.a_ammo1, pos, pSeatLocal->m_flAmmo1Alpha, g_hud_color);
	HUD_DrawSeperator(pos + [30,0]);
}

/* leftover type ammo */
void
HUD_DrawAmmo2(void)
{
	player pl = (player)pSeat->m_ePlayer;
	vector pos;

	if (pl.a_ammo2 != pSeatLocal->m_iAmmo2Old) {
		pSeatLocal->m_flAmmo2Alpha = 1.0;
		pSeatLocal->m_iAmmo2Old = pl.a_ammo2;
	}

	if (pSeatLocal->m_flAmmo2Alpha >= HUD_ALPHA) {
		pSeatLocal->m_flAmmo2Alpha -= clframetime * 0.5;
	} else {
		pSeatLocal->m_flAmmo2Alpha = HUD_ALPHA;
	}

	pos = g_hudmins + [g_hudres[0] - 80, g_hudres[1] - 42 + 5];
	HUD_DrawNumsS(pl.a_ammo2, pos, pSeatLocal->m_flAmmo2Alpha, g_hud_color);
}

/* special ammo */
void
HUD_DrawAmmo3(void)
{
	player pl = (player)pSeat->m_ePlayer;
	vector pos;

	if (pl.a_ammo3 != pSeatLocal->m_iAmmo3Old) {
		pSeatLocal->m_flAmmo3Alpha = 1.0;
		pSeatLocal->m_iAmmo3Old = pl.a_ammo3;
	}

	if (pSeatLocal->m_flAmmo3Alpha >= HUD_ALPHA) {
		pSeatLocal->m_flAmmo3Alpha -= clframetime * 0.5;
	} else {
		pSeatLocal->m_flAmmo3Alpha = HUD_ALPHA;
	}

	pos = g_hudmins + [g_hudres[0] - 42, g_hudres[1] - 42 + 5];
	HUD_DrawNumsS(pl.a_ammo3, pos, pSeatLocal->m_flAmmo3Alpha, g_hud_color);
}

/* ammo bar */
void
HUD_DrawAmmoBar(vector pos, float val, float max, float a)
{
	if (val <= 0)
		return;

	float perc;
	perc = val / max;
	//drawfill(pos + [10,0], [20,4], g_hud_color, a, DRAWFLAG_NORMAL);
	//drawfill(pos + [10,0], [20 * perc,4], [0,1,0], a, DRAWFLAG_NORMAL);
}

/* weapon/ammo pickup notifications */
void
HUD_DrawNotify(void)
{
	player pl = (player)self;
	vector pos;
	float a;

	pos = g_hudmins + [g_hudres[0] - 150, g_hudres[1] - 128];

	if (pSeatLocal->m_flPickupAlpha <= 0.0f) {
		pos[1] += 48;
		//HUD_ItemNotify_Draw(pos);
		//HUD_AmmoNotify_Draw(pos);
		return;
	}

	a = bound(0.0, pSeatLocal->m_flPickupAlpha, 1.0);
	pos[1] += 48 * (1.0 - a);
	Weapons_HUDPic(pl, pSeatLocal->m_iPickupWeapon, 1, pos, a);
	//HUD_ItemNotify_Draw(pos);
	//HUD_AmmoNotify_Draw(pos);
	pSeatLocal->m_flPickupAlpha -= (clframetime * 0.5);
}

void
HUD_WeaponPickupNotify(int w)
{
#if defined (VALVE) || defined (GEARBOX)
	switch (w) {
		case WEAPON_SNARK:
		case WEAPON_SATCHEL:
		case WEAPON_HANDGRENADE:
		case WEAPON_TRIPMINE:
#if defined(GEARBOX)
		case WEAPON_PENGUIN:
#endif
		return;
		default:
	}
#endif

	pSeatLocal->m_iPickupWeapon = w;
	pSeatLocal->m_flPickupAlpha = 2.5f;
}

void
HUD_DrawDamageIndicator(void)
{
	vector cross_pos;

	if (pSeatLocal->m_flDamageIndicator <= 0.0)
		return;

	cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];

	/*drawsubpic(
		cross_pos,
		[24,24],
		g_cross_spr,
		[0.0, 72/128],
		[0.1875, 0.1875],
		[1,1,1] * pSeatLocal->m_flDamageIndicator,
		1.0f,
		DRAWFLAG_ADDITIVE
	);*/

	pSeatLocal->m_flDamageIndicator -= clframetime;
}

void
HUD_TimeRemaining(void)
{
	vector iconPos = g_hudmins + [16, g_hudres[1] - 64];

	/* display time if timelimit is being hit */
	if (serverkeyfloat("timelimit")) {
		string tempstr = strcat("Time Remaining: ", Util_GetTime());
		Font_DrawText_RGB(iconPos, tempstr, g_hud_color, FONT_20);
	}
}

/* main entry */
void
HUD_Draw(void)
{
	player pl = (player)pSeat->m_ePlayer;

	g_hud_color = [1, 0.75f, 0.25];

	/* little point in not drawing these, even if you don't have a suit */
	Weapons_DrawCrosshair(pl);

	{
		
	}

	HUD_DrawDamageIndicator();
	HUD_DrawWeaponSelect();
	Obituary_Draw();
	Textmenu_Draw();

	HUD_TimeRemaining();

	if (!(pl.g_items & ITEM_SUIT)) {
		return;
	}

	HUD_DamageNotify_Draw();
	HUD_DrawHealth();
	HUD_DrawArmor();
	HUD_DrawNotify();
	Damage_Draw();
}

/* specatator main entry */
void
HUD_DrawSpectator(void)
{
	Textmenu_Draw();

	NSClientSpectator spec = (NSClientSpectator)pSeat->m_ePlayer;

	drawfont = Font_GetID(FONT_20);
	vector vecPos = [0.0f, 0.0f, 0.0f];
	string strText = __NULL__;
	float palpha = 1.0f;

	if (spec.spec_mode == SPECMODE_FREE) {
		palpha = 0.5f;
	}

	strText = sprintf("Tracking: %s", getplayerkeyvalue(spec.spec_ent - 1, "name"));
	vecPos[0] = g_hudmins[0] + (g_hudres[0] / 2) - (stringwidth(strText, TRUE, [20,20]) / 2);
	vecPos[1] = g_hudmins[1] + g_hudres[1] - 60;
	drawstring(vecPos, strText, [20,20], [1,1,1], palpha, DRAWFLAG_ADDITIVE);

	strText = sprintf("Mode: %s", g_specmodes[spec.spec_mode]);
	vecPos[0] = g_hudmins[0] + (g_hudres[0] / 2) - (stringwidth(strText, TRUE, [20,20]) / 2);
	vecPos[1] = g_hudmins[1] + g_hudres[1] - 40;
	drawstring(vecPos, strText, [20,20], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);
}
