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
	SLAM_IDLE,
	SLAM_FIDGET,
	SLAM_DRAW,
	SLAM_THROW
};

enum
{
	RADIO_IDLE,
	RADIO_FIDGET,
	RADIO_DRAW,
	RADIO_USE,
	RADIO_HOLSTER
};

#ifdef SERVER
void
s_slam_detonate(entity master)
{
	for (entity b = world; (b = find(b, ::classname, "projectile_slam"));) {
		if (b.owner != master)
			continue;

		NSEntity slamEnt = (NSEntity)b;
		slamEnt.Trigger(master, TRIG_TOGGLE);
	}
}
#endif

void
w_slam_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.satchel_chg, pl.ammo_satchel, -1);
}

string
w_slam_wmodel(void)
{
	return "models/w_slam.mdl";
}

string
w_slam_pmodel(player pl)
{
	return "models/p_slam.mdl";
}

string
w_slam_deathmsg(void)
{
	return "";
}

void
w_slam_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_slam.bounce");
	precache_model("models/w_slam.mdl");
#else
	precache_model("models/weapons/v_slam.mdl");
	precache_model("models/v_slam_radio.mdl");
	precache_model("models/p_slam.mdl");
#endif
}

int
w_slam_pickup(player pl, int new, int startammo)
{
#ifdef SERVER
	int addAmmo = (startammo == -1) ? 1 : startammo;

	if (pl.ammo_satchel < MAX_A_SATCHEL) {
		pl.ammo_satchel = bound(0, pl.ammo_satchel + addAmmo, MAX_A_SATCHEL);
	} else {
		if (!new)
			return (0);
	}
#endif
	return (1);
}

void
w_slam_draw(player pl)
{
	if (pl.satchel_chg > 0) {
		Weapons_SetModel("models/v_slam_radio.mdl");
		Weapons_ViewAnimation(pl, RADIO_DRAW);
		
	} else {
		Weapons_SetModel("models/weapons/v_slam.mdl");
		Weapons_ViewAnimation(pl, SLAM_DRAW);
	}
}

void
w_slam_holster(player pl)
{
	
}

void
w_slam_primary(player pl)
{
	if (pl.w_attack_next) {
		return;
	}

	/* Ammo check */
	if (pl.satchel_chg <= 0 && pl.ammo_satchel <= 0) {
		return;
	}

	if (pl.satchel_chg <= 0) {
		Weapons_ViewAnimation(pl, RADIO_DRAW);
	} else {
		Weapons_ViewAnimation(pl, RADIO_USE);
	}

#ifdef SERVER
	/* if we don't have any slams placed yet, place one */
	if (!pl.satchel_chg) {
		NSProjectile_SpawnDef("projectile_slam", pl);
		pl.satchel_chg++;
		pl.ammo_satchel--;
		pl.mode_tempstate = 1; /* mark us as having deployed something */

		if (pl.flags & FL_CROUCHING)
			Animation_PlayerTop(pl, ANIM_CR_SHOOTSQUEAK, 0.41f);
		else
			Animation_PlayerTop(pl, ANIM_SHOOTSQUEAK, 0.5f);
	} else {
		/* detonate all we have */
		s_slam_detonate(pl);
		pl.satchel_chg = 0;

		/* no slams left to place? just get rid of this thing */
		if (pl.ammo_satchel <= 0) {
			Weapons_RemoveItem(pl, WEAPON_SLAM);
		}
	}
#else
	Weapons_SetModel("models/v_slam_radio.mdl");

	/* same thing as the SERVER ifdef above... */
	if (!pl.satchel_chg) {
		pl.satchel_chg++;
		pl.ammo_satchel--;
	} else {
		pl.satchel_chg = 0;
	}
#endif

	pl.w_attack_next = 1.0f;
	pl.w_idle_next = 1.0f;
}

void
w_slam_secondary(player pl)
{
	if (pl.w_attack_next) {
		return;
	}

	/* Ammo check */
	if (pl.ammo_satchel <= 0) {
		return;
	}

	Weapons_SetModel("models/v_slam_radio.mdl");
	Weapons_ViewAnimation(pl, RADIO_DRAW);

#ifdef SERVER
	NSProjectile_SpawnDef("projectile_slam", pl);
#endif

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CR_SHOOTSQUEAK, 0.41f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOTSQUEAK, 0.5f);

	pl.satchel_chg++;
	pl.ammo_satchel--;
	pl.mode_tempstate = 1; /* mark us as having deployed something */

	pl.w_attack_next = 1.0f;
	pl.w_idle_next = 0.5f;
}

void
w_slam_reload(player pl)
{
	
}

void
w_slam_release(player pl)
{
	if (pl.w_idle_next > 0.0) {
		return;
	}

	/* keep track of the model via tempstates */
	if (pl.satchel_chg < 1i && pl.mode_tempstate != 0) {
		pl.mode_tempstate = 0;
		Weapons_SetModel("models/v_slam.mdl");
		Weapons_ViewAnimation(pl, SLAM_DRAW);
		pl.w_idle_next = 15.0f;
		return;
	}

	if (pl.satchel_chg <= 0) {
		Weapons_ViewAnimation(pl, SLAM_FIDGET);
	} else {
		Weapons_ViewAnimation(pl, RADIO_FIDGET);
	}
	pl.w_idle_next = 15.0f;
}

float
w_slam_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CR_AIMSQUEAK : ANIM_AIMSQUEAK;
}

void
w_slam_hud(player pl)
{
#ifdef CLIENT
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [72/256,96/128], [24/256, 24/128], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_slam_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT

	if (selected) {
		drawsubpic(
			pos,
			[128,64],
			"materials/Sprites/w_icons2",
			[0.5, 0.25],
			[128/256,64/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[128,64],
			"materials/Sprites/w_icons2",
			[0.5, 0.25],
			[128/256,64/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_satchel, MAX_A_SATCHEL, a);
#endif
}

int
w_slam_isempty(player pl)
{
	if (pl.ammo_satchel <= 0)
		return 1;

	return 0;
}

weapontype_t
w_slam_type(player pl)
{
	return WPNTYPE_THROW;
}

weapon_t w_slam =
{
	.name		= "slam",
	.id		= ITEM_SLAM,
	.slot		= 4,
	.slot_pos	= 2,
	.weight		= -20,
	.draw		= w_slam_draw,
	.holster	= w_slam_holster,
	.primary	= w_slam_primary,
	.secondary	= w_slam_secondary,
	.reload		= w_slam_reload,
	.release	= w_slam_release,
	.postdraw	= w_slam_hud,
	.precache	= w_slam_precache,
	.pickup		= w_slam_pickup,
	.updateammo	= w_slam_updateammo,
	.wmodel		= w_slam_wmodel,
	.pmodel		= w_slam_pmodel,
	.deathmsg	= w_slam_deathmsg,
	.aimanim	= w_slam_aimanim,
	.isempty	= w_slam_isempty,
	.type		= w_slam_type,
	.hudpic		= w_slam_hudpic
};
