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

#ifdef SERVER
.float nadeCookingTime;
#endif

enum
{
	BUGBAIT_DRAWBACK,
	BUGBAIT_THROW,
	BUGBAIT_IDLE,
	BUGBAIT_DRAW,
	BUGBAIT_HOLSTER,
	BUGBAIT_SQUEEZE
};

void w_bugbait_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_frag.bounce");
	precache_model("models/w_grenade.mdl");
	particleeffectnum("fx_explosion.main");
	precache_model("sprites/fexplo.spr");
#else
	precache_model("models/weapons/v_bugbait.mdl");
	precache_model("models/p_grenade.mdl");
#endif
}

void w_bugbait_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.ammo_handgrenade, -1);
}

string w_bugbait_wmodel(void)
{
	return "models/w_grenade.mdl";
}

string w_bugbait_pmodel(player pl)
{
	return "models/p_grenade.mdl";
}

string w_bugbait_deathmsg(void)
{
	return "";
}

int w_bugbait_pickup(player pl, int new, int startammo)
{
#ifdef SERVER
	int addAmmo = (startammo == -1) ? 1 : startammo;

	if (pl.ammo_handgrenade < MAX_A_HANDGRENADE) {
		pl.ammo_handgrenade = bound(0, pl.ammo_handgrenade + addAmmo, MAX_A_HANDGRENADE);
	} else {
		if (!new)
			return (0);
	}
#endif
	return (1);
}

void w_bugbait_draw(player pl)
{
	pl.mode_tempstate = 0;

	Weapons_SetModel("models/weapons/v_bugbait.mdl");
	Weapons_ViewAnimation(pl, BUGBAIT_DRAW);
	pl.w_idle_next = 0.9f;
}

void w_bugbait_holster(player pl)
{
	
}
void w_bugbait_primary(player pl)
{
	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	/* We're abusing this network variable for the holding check */
	if (pl.mode_tempstate > 0) {
		return;
	}

	/* Ammo check */
	if (pl.ammo_handgrenade <= 0) {
		return;
	}

	Weapons_ViewAnimation(pl, BUGBAIT_DRAWBACK);

	pl.mode_tempstate = 1;
	pl.w_attack_next = 0.5f;
	pl.w_idle_next = 0.5f;

#ifdef SERVER
	pl.nadeCookingTime = time;
#endif
}
void w_bugbait_secondary(player pl)
{
	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
	if (pl.ammo_handgrenade <= 0) {
		return;
	}

#ifdef SERVER
	Sound_Play(pl, CHAN_WEAPON, "Weapon_Bugbait.Splat");
#endif
	Weapons_ViewAnimation(pl, BUGBAIT_SQUEEZE);
	pl.w_attack_next = 0.5f;
	pl.w_idle_next = 0.6f;
}

void w_bugbait_hud(player pl)
{
#ifdef CLIENT
	HUD_DrawAmmo2();

	vector pos = g_hudmins + [g_hudres[0] / 2, g_hudres[1] / 2];
	Font_DrawText_RGBA(pos + [-7, -14], "Q", g_hud_color, 1.0, FONT_HUD_CROSS);
#endif
}

void w_bugbait_release(player pl)
{
	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.mode_tempstate == 1) {
		Weapons_ViewAnimation(pl, BUGBAIT_THROW);
#ifdef SERVER
		vector throwDirection;
		float throwingStrength;

		NSProjectile nade = (NSProjectile )EntityDef_CreateClassname("projectile_frag");
		nade.SetOwner(pl);

		throwDirection = pl.v_angle;
		throwDirection[0] = -10.0f; /* always aim a bit up */

		/* diminish when aiming up */
		if (pl.v_angle[0] < 0) {
			throwDirection[0] += (pl.v_angle[0] * 0.9f);
		} else { /* increase when aiming down */
			throwDirection[0] += (pl.v_angle[0] * 1.1f);
		}

		throwingStrength = bound(0, (90 - throwDirection[0]) * 5.0f, 1000);

		nade.Launch(pl.GetEyePos(), pl.v_angle, time - pl.nadeCookingTime, 0.0f, 0.0f);
		makevectors(throwDirection);
		nade.SetVelocity((v_forward * throwingStrength) + pl.GetVelocity());
#endif
		pl.ammo_handgrenade--;
		pl.mode_tempstate = 2;
		pl.w_attack_next = 1.0f;
		pl.w_idle_next = 0.5f;

		if (pl.flags & FL_CROUCHING)
			Animation_PlayerTop(pl, ANIM_CR_SHOOTCROWBAR, 0.41f);
		else
			Animation_PlayerTop(pl, ANIM_SHOOTCROWBAR, 0.5f);
	} else if (pl.mode_tempstate == 2) {
		Weapons_ViewAnimation(pl, BUGBAIT_DRAW);
#ifdef SERVER
		if (!pl.ammo_handgrenade) {
			Weapons_RemoveItem(pl, WEAPON_BUGBAIT);
		}
#endif
		pl.w_attack_next = 0.5f;
		pl.w_idle_next = 0.5f;
		pl.mode_tempstate = 0;
	} else {
		Weapons_ViewAnimation(pl, BUGBAIT_IDLE);
		pl.w_idle_next = 3.0f;
	}
}

float
w_bugbait_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_bugbait_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col = g_hud_color;

	if (selected) {
		drawsubpic(
			pos,
			[128,64],
			"materials/Sprites/w_icons3",
			[0, 0.5],
			[128/256,64/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[128,64],
			"materials/Sprites/w_icons3",
			[0, 0.5],
			[128/256,64/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_handgrenade, MAX_A_HANDGRENADE, a);
#endif
}

int
w_bugbait_isempty(player pl)
{

	if (pl.ammo_handgrenade <= 0)
		return 1;

	return 0;
}

weapontype_t
w_bugbait_type(player pl)
{
	return WPNTYPE_THROW;
}

weapon_t w_bugbait =
{
	.name		= "grenade",
	.id			= ITEM_HANDGRENADE,
	.slot		= 5,
	.slot_pos	= 0,
	.weight		= 5,
	.draw		= w_bugbait_draw,
	.holster	= w_bugbait_holster,
	.primary	= w_bugbait_primary,
	.secondary	= w_bugbait_secondary,
	.reload		= __NULL__,
	.release	= w_bugbait_release,
	.postdraw	= w_bugbait_hud,
	.precache	= w_bugbait_precache,
	.pickup		= w_bugbait_pickup,
	.updateammo	= w_bugbait_updateammo,
	.wmodel		= w_bugbait_wmodel,
	.pmodel		= w_bugbait_pmodel,
	.deathmsg	= w_bugbait_deathmsg,
	.aimanim	= w_bugbait_aimanim,
	.isempty	= w_bugbait_isempty,
	.type		= w_bugbait_type,
	.hudpic		= w_bugbait_hudpic
};