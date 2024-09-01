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

enum
{
	PYTHON_IDLE,
	PYTHON_FIRE,
	PYTHON_DRAW,
	PYTHON_RELOAD,
	PYTHON_HOLSTER,
	PYTHON_IDLE_TO_LOW,
	PYTHON_LOW_TO_IDLE,
	PYTHON_LOW_IDLE
};

void
w_357_precache(void)
{
#ifdef SERVER
	precache_model("models/w_357.mdl");
#else
	precache_model("models/weapons/v_357.mdl");
	precache_model("models/p_357.mdl");
#endif
}

int
w_357_pickup(player pl, int new, int startammo)
{
#ifdef SERVER
	int addAmmo = (startammo == -1) ? 6 : startammo;

	if (new) {
		pl.python_mag = addAmmo;
		return (1);
	}

	if (pl.ammo_357 < MAX_A_357) {
		pl.ammo_357 = bound(0, pl.ammo_357 + addAmmo, MAX_A_357);
	} else {
		if (!new)
			return (0);
	}
#endif
	return (1);
}

void
w_357_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.python_mag, pl.ammo_357, -1);
}

string
w_357_wmodel(void)
{
	return "models/w_357.mdl";
}

string
w_357_pmodel(player pl)
{
	return "models/p_357.mdl";
}

string
w_357_deathmsg(void)
{
	return "";
}

void
w_357_draw(player pl)
{
	Weapons_SetModel("models/weapons/v_357.mdl");

	/* singleplayer doesn't do scope */
	if (serverkeyfloat("sv_playerslots") == 1) {
		Weapons_SetGeomset("geomset 4 1\n");
	} else {
		Weapons_SetGeomset("geomset 4 2\n");
	}

	Weapons_ViewAnimation(pl, PYTHON_DRAW);
	pl.w_idle_next = 1.0f;
}

void
w_357_holster(player pl)
{
	Weapons_ViewAnimation(pl, PYTHON_HOLSTER);
	pl.w_idle_next = 0.3660f;
}

void
w_357_primary(player pl)
{
	if (pl.w_attack_next > 0.0)
		return;
	if (pl.gflags & GF_SEMI_TOGGLED)
		return;

	/* Ammo check */
	if ((pl.python_mag <= 0) || (pl.WaterLevel() >= WATERLEVEL_SUBMERGED)) {
#ifdef SERVER
		Sound_Play(pl, CHAN_AUTO, "weapon_357.empty");
#endif
		pl.gflags |= GF_SEMI_TOGGLED;
		return;
	}

	pl.python_mag--;

	/* Actual firing */
#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_SMALL);
#else
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, Skill_GetValue("plr_dmg_357", 40), [0.008, 0.008], WEAPON_357);
	Sound_Play(pl, CHAN_WEAPON, "Weapon_357.Single");
#endif

	Weapons_ViewPunchAngle(pl, [-10,0,0]);
	Weapons_ViewAnimation(pl, PYTHON_FIRE);

	if (pl.IsCrouching())
		Animation_PlayerTop(pl, ANIM_CR_SHOOTPYTHON, 0.43f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOTPYTHON, 0.43f);

	pl.w_attack_next = 0.833f;
	pl.w_idle_next = 0.833f;
}

void
w_357_secondary(player pl)
{

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* singleplayer doesn't do scope */
	if (serverkeyfloat("sv_playerslots") == 1) {
		return;
	}

	/* Simple toggle of fovs */
	if (pl.viewzoom == 1.0f) {
		pl.viewzoom = 0.5f;
	} else {
		pl.viewzoom = 1.0f;
	}

	pl.w_attack_next = 0.25f;
}

void
w_357_reload(player pl)
{

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
	if (pl.python_mag >= 6) {
		return;
	}
	if (pl.ammo_357 <= 0) {
		return;
	}

	/* undo our zoom */
	pl.viewzoom = 1.0f;

	/* Audio-Visual bit */
	Weapons_ViewAnimation(pl, PYTHON_RELOAD);

#ifdef SERVER
	static void w_357_reload_done(void) {
		player pl = (player)self;
		Weapons_ReloadWeapon(pl, player::python_mag, player::ammo_357, 6);
	}

	pl.think = w_357_reload_done;
	pl.nextthink = time + 3.15f;
	Sound_Play(pl, CHAN_WEAPON, "Weapon_357.Reload");
#endif

	pl.w_attack_next = 3.7f;
	pl.w_idle_next = 3.7f;
}

void
w_357_release(player pl)
{
	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.python_mag == 0 && pl.ammo_357 > 0) {
		Weapons_Reload(pl);
		return;
	}

	if (pl.w_idle_next > 0.0) {
		return;
	}

	Weapons_ViewAnimation(pl, PYTHON_IDLE);
	pl.w_idle_next = 4.0f;
}

void
w_357_crosshair(player pl)
{
#ifdef CLIENT
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector pos = g_hudmins + [g_hudres[0] / 2, g_hudres[1] / 2];
	Font_DrawText_RGBA(pos + [-7, -14], "Q", g_hud_color, 1.0, FONT_HUD_CROSS);
#endif
}

float
w_357_aimanim(player pl)
{
	return pl.IsCrouching() ? ANIM_CR_AIMPYTHON : ANIM_AIMPYTHON;
}

void
w_357_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (pl.python_mag == 0 && pl.ammo_357 == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	if (selected) {
		drawsubpic(
			pos,
			[128,64],
			"materials/Sprites/w_icons1",
			[0.5, 0.25],
			[128/256,64/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[128,64],
			"materials/Sprites/w_icons1",
			[0.5, 0.25],
			[128/256,64/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_357, MAX_A_357, a);
#endif
}

int
w_357_isempty(player pl)
{

	if (pl.python_mag <= 0 && pl.ammo_357 <= 0)
		return 1;

	return 0;
}

weapontype_t
w_357_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapon_t w_357 =
{
	.name		= "357",
	.id			= ITEM_357,
	.slot		= 1,
	.slot_pos	= 1,
	.weight		= 15,
	.draw		= w_357_draw,
	.holster	= w_357_holster,
	.primary	= w_357_primary,
	.secondary	= w_357_secondary,
	.reload		= w_357_reload,
	.release	= w_357_release,
	.postdraw	= w_357_crosshair,
	.precache	= w_357_precache,
	.pickup		= w_357_pickup,
	.updateammo	= w_357_updateammo,
	.wmodel		= w_357_wmodel,
	.pmodel		= w_357_pmodel,
	.deathmsg	= w_357_deathmsg,
	.aimanim	= w_357_aimanim,
	.isempty	= w_357_isempty,
	.type		= w_357_type,
	.hudpic		= w_357_hudpic
};