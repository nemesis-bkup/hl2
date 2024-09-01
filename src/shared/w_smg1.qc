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
	SMG1_IDLE,
	SMG1_FIRE1,
	SMG1_FIRE2,
	SMG1_FIRE3,
	SMG1_FIRE4,
	SMG1_ALTFIRE,
	SMG1_DRAW,
	SMG1_RELOAD,
	SMG1_DRYFIRE,
	SMG1_IDLE_TO_LOW,
	SMG1_LOW_TO_IDLE,
	SMG1_LOW
};

#ifdef CLIENT
void w_smg1_ejectshell(void)
{
	static void w_smg1_ejectshell_death(void) {
		remove(self);
	}
	static void w_smg1_ejectshell_touch(void) {
		if (other == world)
			Sound_Play(self, CHAN_BODY, "Bounce.Shell");
	}
	entity eShell = spawn();
	setmodel(eShell, "models/weapons/rifleshell.mdl");
	eShell.solid = SOLID_BBOX;
	eShell.movetype = MOVETYPE_BOUNCE;
	eShell.drawmask = MASK_ENGINE;
	eShell.angles = [pSeat->m_eViewModel.angles[0], pSeat->m_eViewModel.angles[1], 0];
	eShell.velocity = pSeat->m_vecPredictedVelocity;

	float r = random(0.0, 50.0);
	makevectors(pSeat->m_eViewModel.angles);
	eShell.velocity += (v_forward * 0);
	eShell.velocity += (v_right * 45);
	eShell.velocity += (v_up * (145 + r));
	eShell.touch = w_smg1_ejectshell_touch;

	eShell.avelocity = [0,45,900];
	eShell.think = w_smg1_ejectshell_death;
	eShell.nextthink = time + 2.5f;
	setsize(eShell, [0,0,0], [0,0,0]);
	setorigin(eShell, pSeat->m_eViewModel.origin + (v_forward * 30) + (v_right * 8) + (v_up * -15));
}
#endif

void
w_smg1_precache(void)
{
#ifdef SERVER
	precache_model("models/w_9mmar.mdl");
	precache_model("models/grenade.mdl");
#else
	precache_model("models/weapons/v_smg1.mdl");
	precache_model("models/p_9mmar.mdl");
	precache_model("models/weapons/rifleshell.mdl");
#endif
}

int
w_smg1_pickup(player pl, int new, int startammo)
{
#ifdef SERVER
#ifdef GEARBOX
	int addAmmo = (startammo == -1) ? 50 : startammo;
#else
	int addAmmo = (startammo == -1) ? 25 : startammo;
#endif

	if (new) {
		pl.mp5_mag = addAmmo;
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
w_smg1_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.mp5_mag, pl.ammo_9mm, pl.ammo_m203_grenade);
}

string
w_smg1_wmodel(void)
{
	return "models/w_9mmar.mdl";
}

string
w_smg1_pmodel(player pl)
{
	return "models/p_9mmar.mdl";
}

string
w_smg1_deathmsg(void)
{
	return "";
}

void
w_smg1_draw(player pl)
{
	Weapons_SetModel("models/weapons/v_smg1.mdl");
	Weapons_ViewAnimation(pl, SMG1_DRAW);
	pl.w_idle_next = 0.8f;
}

void
w_smg1_holster(player pl)
{
	Weapons_ViewAnimation(pl, SMG1_LOW);
}

void
w_smg1_primary(player pl)
{
	if (pl.w_attack_next > 0.0f)
		return;
	if (pl.gflags & GF_SEMI_TOGGLED)
		return;

	/* Ammo check */
	bool out_of_ammo = (pl.mp5_mag <= 0i) ? true : false;
	if (out_of_ammo || (pl.WaterLevel() >= WATERLEVEL_SUBMERGED)) {
#ifdef SERVER
		Sound_Play(pl, CHAN_AUTO, "Weapon_SMG1.Empty");
#endif
		pl.gflags |= GF_SEMI_TOGGLED;
		return;
	}

	pl.mp5_mag--;

	/* Actual firing */
	int r = floor(pseudorandom() * 4.0f);
	switch (r) {
	case 1:
		Weapons_ViewAnimation(pl, SMG1_FIRE1);
		break;
	case 2:
		Weapons_ViewAnimation(pl, SMG1_FIRE2);
		break;
	case 3:
		Weapons_ViewAnimation(pl, SMG1_FIRE2);
		break;
	default:
		Weapons_ViewAnimation(pl, SMG1_FIRE3);
		break;
	}

	Weapons_ViewPunchAngle(pl, [-2,0,0]);

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);
	View_AddEvent(w_smg1_ejectshell, 0.0f);
#else
	/* singleplayer is more accurate */
	if (cvar("sv_playerslots") == 1) {
		TraceAttack_FireBullets(1, Weapons_GetCameraPos(pl), Skill_GetValue("plr_dmg_smg1", 4), [0.025,0.025], WEAPON_SMG1);
	} else {
		TraceAttack_FireBullets(1, Weapons_GetCameraPos(pl), Skill_GetValue("plr_dmg_smg1", 4), [0.05,0.05], WEAPON_SMG1);
	}

	Sound_Play(pl, CHAN_WEAPON, "Weapon_SMG1.Single");
#endif

	if (pl.IsCrouching())
		Animation_PlayerTop(pl, ANIM_CR_SHOOTMP5, 0.1f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOTMP5, 0.1f);

	pl.w_attack_next = 0.085f;
	pl.w_idle_next = 0.233f;
}

void
w_smg1_secondary(player pl)
{
	if (pl.w_attack_next > 0.0f)
		return;
	if (pl.gflags & GF_SEMI_TOGGLED)
		return;

	/* Ammo check */
	bool out_of_ammo = (pl.ammo_m203_grenade <= 0i) ? true : false;
	if (out_of_ammo || pl.WaterLevel() >= WATERLEVEL_SUBMERGED) {
#ifdef SERVER
		Sound_Play(pl, CHAN_AUTO, "Weapon_SMG1.Empty");
#endif
		pl.gflags |= GF_SEMI_TOGGLED;
		return;
	}

	pl.ammo_m203_grenade--;

#ifdef SERVER
	NSProjectile_SpawnDef("projectile_ARgrenade", pl);
	Sound_Play(pl, CHAN_WEAPON, "Weapon_SMG1.Double");
#endif

	Weapons_ViewPunchAngle(pl, [-10.0f, 0.0f, 0.0f]);
	Weapons_ViewAnimation(pl, SMG1_ALTFIRE);

	if (pl.IsCrouching())
		Animation_PlayerTop(pl, ANIM_CR_SHOOTMP5, 0.45f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOTMP5, 0.45f);

	pl.w_attack_next = 0.5f;
	pl.w_idle_next = 0.5f;
}

void
w_smg1_reload(player pl)
{
	if (pl.w_attack_next) {
		return;
	}

	/* Ammo check */
	if (pl.mp5_mag >= 50) {
		return;
	}
	if (pl.ammo_9mm <= 0) {
		return;
	}

	Weapons_ViewAnimation(pl, SMG1_RELOAD);

#ifdef SERVER
	static void w_smg1_reload_done(void) {
		player pl = (player)self;
		Weapons_ReloadWeapon(pl, player::mp5_mag, player::ammo_9mm, 50);
	}

	pl.think = w_smg1_reload_done;
	pl.nextthink = time + 1.4f;
#endif

	pl.w_attack_next = 1.5f;
	pl.w_idle_next = 1.5f;
}

void
w_smg1_release(player pl)
{
	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.mp5_mag == 0 && pl.ammo_9mm > 0) {
		Weapons_Reload(pl);
		return;
	}
	if (pl.w_idle_next > 0.0) {
		return;
	}

	Weapons_ViewAnimation(pl, SMG1_IDLE);
	pl.w_idle_next = 15.0f;
}

void
w_smg1_crosshair(player pl)
{
#ifdef CLIENT
	vector pos = g_hudmins + [g_hudres[0] / 2, g_hudres[1] / 2];
	Font_DrawText_RGBA(pos + [-7, -14], "Q", g_hud_color, 1.0, FONT_HUD_CROSS);

	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	HUD_DrawAmmo3();

#endif
}

float
w_smg1_aimanim(player pl)
{
	return pl.flags & ANIM_CR_AIMMP5 ? ANIM_CR_AIMCROWBAR : ANIM_AIMMP5;
}

void
w_smg1_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (pl.mp5_mag == 0 && pl.ammo_9mm == 0 && pl.ammo_m203_grenade == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	if (selected) {
		drawsubpic(
			pos,
			[128,64],
			"materials/Sprites/w_icons1",
			[0.5, 0.5],
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
			[0.5, 0.5],
			[128/256,64/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_9mm, MAX_A_9MM, a);
	HUD_DrawAmmoBar(pos + [25, 0], pl.ammo_m203_grenade, MAX_A_M203_GRENADE, a);
#endif
}

int
w_smg1_isempty(player pl)
{

	if (pl.mp5_mag <= 0 && pl.ammo_9mm <= 0 && pl.ammo_m203_grenade <= 0)
		return 1;

	return 0;
}

weapontype_t
w_smg1_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapon_t w_smg1 =
{
	.name		= "9mmAR",
	.id			= ITEM_SMG1,
	.slot		= 2,
	.slot_pos	= 0,
	.weight		= 15,
	.draw		= w_smg1_draw,
	.holster	= w_smg1_holster,
	.primary	= w_smg1_primary,
	.secondary	= w_smg1_secondary,
	.reload		= w_smg1_reload,
	.release	= w_smg1_release,
	.postdraw	= w_smg1_crosshair,
	.precache	= w_smg1_precache,
	.pickup		= w_smg1_pickup,
	.updateammo	= w_smg1_updateammo,
	.wmodel		= w_smg1_wmodel,
	.pmodel		= w_smg1_pmodel,
	.deathmsg	= w_smg1_deathmsg,
	.aimanim	= w_smg1_aimanim,
	.isempty	= w_smg1_isempty,
	.type		= w_smg1_type,
	.hudpic		= w_smg1_hudpic
};