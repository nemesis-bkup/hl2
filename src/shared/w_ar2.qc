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
	AR2_IDLE,
	AR2_FIRE1,
	AR2_FIRE2,
	AR2_FIRE3,
	AR2_FIRE4,
	AR2_ALTFIRE,
	AR2_RELOAD,
	AR2_DRAW,
	AR2_HOLSTER,
	AR2_IDLE_TO_LOW,
	AR2_LOW_TO_IDLE,
	AR2_SHAKE,
	AR2_VENT_NEUTRAL,
	AR2_VENT_OPEN,
	AR2_VENT_CLOSED
};

void
w_ar2_precache(void)
{
#ifdef SERVER
	precache_model("models/w_hgun.mdl");
	precache_model("models/hornet.mdl");
#else
	precache_model("models/weapons/v_irifle.mdl");
	precache_model("models/p_hgun.mdl");
#endif
}

int
w_ar2_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	/* only pick it up once */
	if (new) {
		pl.ammo_hornet = MAX_A_HORNET;
		return (1);
	}
#endif
	return (0);
}

void
w_ar2_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.ammo_hornet, -1);
}
string w_ar2_wmodel(void)
{
	return "models/w_hgun.mdl";
}
string w_ar2_pmodel(player pl)
{
	return "models/p_hgun.mdl";
}
string w_ar2_deathmsg(void)
{
	return "";
}

void
w_ar2_draw(player pl)
{
	Weapons_SetModel("models/weapons/v_irifle.mdl");
	Weapons_ViewAnimation(pl, AR2_DRAW);
	pl.w_idle_next = 0.8f;
}

void
w_ar2_holster(player pl)
{
	Weapons_ViewAnimation(pl, AR2_HOLSTER);
	
}

#ifdef SERVER
void
w_ar2_shoothornet(player pl)
{

}
#endif

void
w_ar2_release(player pl)
{
	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.w_idle_next > 0.0) {
		return;
	}

	Weapons_ViewAnimation(pl, AR2_IDLE);
	pl.w_idle_next = 1.0f;
}

void
w_ar2_primary(player pl)
{
	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
	if (pl.ammo_hornet <= 0) {
	//	w_ar2_release(pl);
		//return;
	}

#ifdef SERVER
	w_ar2_shoothornet(pl);
	Sound_Play(pl, CHAN_WEAPON, "Weapon_AR2.Single");
#endif

//	pl.ammo_hornet--;
	int r = floor(pseudorandom() * 4.0);
	Weapons_ViewAnimation(pl, AR2_FIRE1 + r);

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CR_SHOOTHIVE, 0.43f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOTHIVE, 0.43f);

	pl.w_attack_next = 0.1f;
	pl.w_idle_next = 0.2f;
}

void
w_ar2_secondary(player pl)
{
	if (pl.w_attack_next) {
		return;
	}

    /* Ammo check */
	if (pl.ammo_hornet <= 0) {
		w_ar2_release(pl);
		return;
	}

#ifdef SERVER
//	w_ar2_shoothornet(pl);
	Sound_Play(pl, CHAN_WEAPON, "Weapon_AR2.Double");
#endif

	pl.ammo_hornet--;
	Weapons_ViewAnimation(pl, AR2_ALTFIRE);

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CR_SHOOTHIVE, 0.43f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOTHIVE, 0.43f);

	pl.w_attack_next = 0.7f;
	pl.w_idle_next = 0.7f;
}

void
w_ar2_reload(player pl)
{
	if (pl.w_attack_next) {
		return;
	}

#ifdef SERVER
//	w_ar2_shoothornet(pl);
	Sound_Play(pl, CHAN_WEAPON, "Weapon_AR2.Reload");
#endif

	Weapons_ViewAnimation(pl, AR2_RELOAD);

	pl.w_attack_next = 1f;
	pl.w_idle_next = 1f;
}

void
w_ar2_crosshair(player pl)
{
#ifdef CLIENT
	HUD_DrawAmmo2();

	vector pos = g_hudmins + [g_hudres[0] / 2, g_hudres[1] / 2];
	Font_DrawText_RGBA(pos + [-7, -14], "Q", g_hud_color, 1.0, FONT_HUD_CROSS);
#endif
}

float
w_ar2_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CR_AIMHIVE : ANIM_AIMHIVE;
}

void
w_ar2_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col = g_hud_color;

	if (selected) {
		drawsubpic(
			pos,
			[128,64],
			"materials/Sprites/w_icons2",
			[0.0, 0.25],
			[128/256,64/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[128,64],
			"materials/Sprites/w_icons2",
			[0.0, 0.25],
			[128/256,64/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_hornet, MAX_A_HORNET, a);
#endif
}

int
w_ar2_isempty(player pl)
{
	return 0;
}

weapontype_t
w_ar2_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapon_t w_ar2 =
{
	.name		= "hornet",
	.id			= ITEM_AR2,
	.slot		= 2,
	.slot_pos	= 1,
	.weight		= 10,
	.draw		= w_ar2_draw,
	.holster	= w_ar2_holster,
	.primary	= w_ar2_primary,
	.secondary	= w_ar2_secondary,
	.reload		= w_ar2_reload,
	.release	= w_ar2_release,
	.postdraw	= w_ar2_crosshair,
	.precache	= w_ar2_precache,
	.pickup		= w_ar2_pickup,
	.updateammo	= w_ar2_updateammo,
	.wmodel		= w_ar2_wmodel,
	.pmodel		= w_ar2_pmodel,
	.deathmsg	= w_ar2_deathmsg,
	.aimanim	= w_ar2_aimanim,
	.isempty	= w_ar2_isempty,
	.type		= w_ar2_type,
	.hudpic		= w_ar2_hudpic
};

#ifdef CLIENT
void w_tripmine_parse(void)
{

}
#endif