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
	PISTOL_IDLE, // 0
	PISTOL_IDLE_EMPTY, // 1
	PISTOL_FIRE1, // 2
	PISTOL_FIRE2, // 3
	PISTOL_FIRE3, // 4
	PISTOL_FIRE4, // 5
	PISTOL_FIRE_EMPTY, // 6
	PISTOL_DRAW, //7
	PISTOL_DRAW_EMPTY, // 8
	PISTOL_RELOAD, // 9
	PISTOL_HOLSTER,
	PISTOL_HOLSTER_EMPTY,
	PISTOL_IDLE_TO_LOW,
	PISTOL_LOW_TO_IDLE,
	PISTOL_LOW_IDLE
};

#ifdef CLIENT
void w_pistol_ejectshell(void)
{
	static void w_pistol_ejectshell_death(void) {
		remove(self);
	}
	static void w_pistol_ejectshell_touch(void) {
		if (other == world)
			Sound_Play(self, CHAN_BODY, "Bounce.Shell");
	}
	entity eShell = spawn();
	setmodel(eShell, "models/weapons/shell.mdl");
	eShell.solid = SOLID_BBOX;
	eShell.movetype = MOVETYPE_BOUNCE;
	eShell.drawmask = MASK_ENGINE;
	eShell.angles = [pSeat->m_eViewModel.angles[0], pSeat->m_eViewModel.angles[1], 0];
	eShell.velocity = pSeat->m_vecPredictedVelocity;

	makevectors(pSeat->m_eViewModel.angles);
	eShell.velocity += (v_forward * 0);
	eShell.velocity += (v_right * 80);
	eShell.velocity += (v_up * 100);
	eShell.touch = w_pistol_ejectshell_touch;

	eShell.avelocity = [0,45,900];
	eShell.think = w_pistol_ejectshell_death;
	eShell.nextthink = time + 2.5f;
	setsize(eShell, [0,0,0], [0,0,0]);
	setorigin(eShell, pSeat->m_eViewModel.origin + (v_forward * 26) + (v_right * 8) + (v_up * -4));
}
#endif

void
w_pistol_precache(void)
{
#ifdef SERVER
	precache_model("models/w_9mmhandgun.mdl");
	precache_model("models/weapons/shell.mdl");
#else
	precache_model("models/weapons/v_pistol.mdl");
	precache_model("models/p_9mmhandgun.mdl");
	precache_model("models/weapons/shell.mdl");
#endif
}

void
w_pistol_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.glock_mag, pl.ammo_9mm, -1);
}

string
w_pistol_wmodel(void)
{
	return "models/w_9mmhandgun.mdl";
}

string
w_pistol_pmodel(player pl)
{
	return "models/p_9mmhandgun.mdl";
}

string
w_pistol_deathmsg(void)
{
	return "";
}

int
w_pistol_pickup(player pl, int new, int startammo)
{
#ifdef SERVER
	int addAmmo = (startammo == -1) ? 18 : startammo;

	if (new) {
		pl.glock_mag = addAmmo;
		return (1);
	}

	if (pl.ammo_9mm < MAX_A_9MM) {
		pl.ammo_9mm = bound(0, pl.ammo_9mm + addAmmo, MAX_A_9MM);
	} else {
		if (!new)
			return (0);
	}
#endif
	return (1);
}

void
w_pistol_draw(player pl)
{
	Weapons_SetModel("models/weapons/v_pistol.mdl");

	if (pl.glock_mag)
		Weapons_ViewAnimation(pl, PISTOL_DRAW);
	else
		Weapons_ViewAnimation(pl, PISTOL_DRAW_EMPTY);

	pl.w_idle_next = 0.8f;
}

void
w_pistol_holster(player pl)
{
	if (pl.glock_mag)
		Weapons_ViewAnimation(pl, PISTOL_HOLSTER);
	else
		Weapons_ViewAnimation(pl, PISTOL_HOLSTER_EMPTY);
}

int
w_pistol_isempty(player pl)
{
	if (pl.glock_mag <= 0 && pl.ammo_9mm <= 0)
		return 1;

	return 0;
}

void
w_pistol_primary(player pl)
{
	if (pl.w_attack_next > 0.0)
		return;
	if (pl.gflags & GF_SEMI_TOGGLED)
		return;

	/* ammo check */
	if ((pl.glock_mag <= 0i) ? true : false) {
#ifdef SERVER
		Sound_Play(pl, CHAN_AUTO, "Weapon_Pistol.Empty");
#endif
		pl.gflags |= GF_SEMI_TOGGLED;
		return;
	}

	/* actual firing */
	pl.glock_mag--;

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_pistol_ejectshell, 0.0f);
#else
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, Skill_GetValue("plr_9mm_bullet", 8), [0.01,0.01], WEAPON_PISTOL);
	Sound_Play(pl, CHAN_WEAPON, "Weapon_Pistol.Single");
#endif

	Weapons_ViewPunchAngle(pl, [-2,0,0]);

	if (pl.glock_mag) {
		int r = floor(pseudorandom() * 3.0f);
		Weapons_ViewAnimation(pl, PISTOL_FIRE2 + r);
	} else {
		Weapons_ViewAnimation(pl, PISTOL_FIRE_EMPTY);
	}

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);

	pl.w_attack_next = 0.1f;
	pl.w_idle_next = 0.4f;
	pl.gflags |= GF_SEMI_TOGGLED;
}

void
w_pistol_secondary(player pl)
{

}

void
w_pistol_reload(player pl)
{
	if (pl.w_attack_next > 0.0) {
		return;
	}

	if (pl.glock_mag >= 18) {
		return;
	}
	if (pl.ammo_9mm <= 0) {
		return;
	}

	Weapons_ViewAnimation(pl, PISTOL_RELOAD);

#ifdef SERVER
	static void w_pistol_reload_done(void) {
		player pl = (player)self;
		Weapons_ReloadWeapon(pl, player::glock_mag, player::ammo_9mm, 18);
	}

	pl.think = w_pistol_reload_done;
	pl.nextthink = time + 1.38f;
	Sound_Play(pl, CHAN_WEAPON, "Weapon_Pistol.Reload");
#endif

	pl.w_attack_next = 1.40f;
	pl.w_idle_next = 1.40f;
}

void
w_pistol_release(player pl)
{
	int r;

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.glock_mag == 0 && pl.ammo_9mm > 0) {
		Weapons_ViewAnimation(pl, PISTOL_IDLE);
		Weapons_Reload(pl);
		return;
	}

	if (pl.w_idle_next > 0.0)
		return;

	if (pl.glock_mag)
		Weapons_ViewAnimation(pl, PISTOL_IDLE);
	else
		Weapons_ViewAnimation(pl, PISTOL_IDLE_EMPTY);
}

float
w_pistol_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_pistol_hud(player pl)
{
#ifdef CLIENT
	vector pos = g_hudmins + [g_hudres[0] / 2, g_hudres[1] / 2];
	Font_DrawText_RGBA(pos + [-7, -14], "Q", g_hud_color, 1.0, FONT_HUD_CROSS);

#if 0
		drawsubpic(
			pos + [-28, -28],
			[56,56],
			"materials/Sprites/qi_center",
			[0,36/128],
			[56/128, 56/128],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
#endif


	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
#endif
}

void
w_pistol_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (pl.glock_mag == 0 && pl.ammo_9mm == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	if (selected) {
		drawsubpic(
			pos,
			[128,64],
			"materials/Sprites/w_icons1",
			[0.5, 0.0],
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
			[0.5, 0.0],
			[128/256,64/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_9mm, MAX_A_9MM, a);
#endif
}

weapontype_t
w_pistol_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapon_t w_pistol =
{
	.name		= "9mmhandgun",
	.id			= ITEM_PISTOL,
	.slot		= 1,
	.slot_pos	= 0,
	.weight		= 10,
	.draw		= w_pistol_draw,
	.holster	= w_pistol_holster,
	.primary	= w_pistol_primary,
	.secondary	= w_pistol_secondary,
	.reload		= w_pistol_reload,
	.release	= w_pistol_release,
	.postdraw	= w_pistol_hud,
	.precache	= w_pistol_precache,
	.pickup		= w_pistol_pickup,
	.updateammo	= w_pistol_updateammo,
	.wmodel		= w_pistol_wmodel,
	.pmodel		= w_pistol_pmodel,
	.deathmsg	= w_pistol_deathmsg,
	.aimanim	= w_pistol_aimanim,
	.isempty	= w_pistol_isempty,
	.type		= w_pistol_type,
	.hudpic		= w_pistol_hudpic
};
