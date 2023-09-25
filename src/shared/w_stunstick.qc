/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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
	CBAR_IDLE,
	CBAR_DRAW,
	CBAR_ATTACK1MISS,
	CBAR_ATTACK2MISS,
	CBAR_ATTACK1HIT,
	CBAR_ATTACK2HIT,
	CBAR_ATTACK3HIT,
	CBAR_ATTACK3MISS,
	CBAR_HOLSTER
};

void
w_stunstick_precache(void)
{
#ifdef SERVER
	precache_model("models/w_stunstick.mdl");
#else
	precache_model("models/weapons/v_stunstick.mdl");
	precache_model("models/p_stunstick.mdl");
#endif
}

void
w_stunstick_updateammo(player pl)
{

}

string
w_stunstick_wmodel(void)
{
	return "models/w_stunstick.mdl";
}
string
w_stunstick_pmodel(player pl)
{
	return "models/p_stunstick.mdl";
}

string
w_stunstick_deathmsg(void)
{
	return "%s was assaulted by %s's Stunstick.";
}

void
w_stunstick_draw(player pl)
{
	Weapons_SetModel("models/weapons/v_stunstick.mdl");
	Weapons_ViewAnimation(pl, CBAR_DRAW);
	pl.w_idle_next = 0.8f;
}

void
w_stunstick_holster(player pl)
{
	Weapons_ViewAnimation(pl, CBAR_HOLSTER);
}

void
w_stunstick_primary(player pl)
{
	int anim = 0;
	vector src;

	if (pl.w_attack_next) {
		return;
	}

	Weapons_MakeVectors(pl);
	src = pl.origin + pl.view_ofs;

	/* make sure we can gib corpses */
	int oldhitcontents = pl.hitcontentsmaski;
	pl.hitcontentsmaski = CONTENTBITS_POINTSOLID | CONTENTBIT_CORPSE;
	traceline(src, src + (v_forward * 64), FALSE, pl);
	pl.hitcontentsmaski = oldhitcontents;

	if (trace_fraction >= 1.0) {
		pl.w_attack_next = 0.5f;
		pl.w_idle_next = 0.65f;
	} else {
		pl.w_attack_next = 0.45f;
		pl.w_idle_next = 0.5f;
	}

	int r = (float)input_sequence % 3.0f;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, trace_fraction >= 1 ? CBAR_ATTACK1MISS:CBAR_ATTACK1HIT);
		break;
	case 1:
		Weapons_ViewAnimation(pl, trace_fraction >= 1 ? CBAR_ATTACK2MISS:CBAR_ATTACK2HIT);
		break;
	default:
		Weapons_ViewAnimation(pl, trace_fraction >= 1 ? CBAR_ATTACK2MISS:CBAR_ATTACK3HIT);
	}

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CR_SHOOTCROWBAR, 0.41f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOTCROWBAR, 0.5f);

#ifdef SERVER
	Sound_Play(pl, CHAN_WEAPON, "Weapon_StunStick.Swing");

	if (trace_fraction >= 1.0) {
		return;
	}

	/* don't bother with decals, we got squibs */
	if (trace_ent.iBleeds) {
		FX_Blood(trace_endpos, [1,0,0]);
	} else {
		SurfData_Impact(trace_ent, trace_endpos, trace_plane_normal);
	}

	if (trace_ent.takedamage) {
		Damage_Apply(trace_ent, pl, Skill_GetValue("plr_stunstick", 10), WEAPON_STUNSTICK, DMG_BLUNT);
		if (trace_ent.iBleeds) {
			Sound_Play(pl, CHAN_WEAPON, "Weapon_StunStick.Melee_Hit");
		}
	} else {
		Sound_Play(pl, CHAN_WEAPON, "Weapon_StunStick.Melee_HitWorld");
	}
#endif
}

void
w_stunstick_release(player pl)
{
	if (pl.w_idle_next > 0.0) {
		return;
	}

	Weapons_ViewAnimation(pl, CBAR_IDLE);
	pl.w_idle_next = 15.0f;
}

float
w_stunstick_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_stunstick_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col = g_hud_color;

	if (selected) {
		drawsubpic(
			pos,
			[128,64],
			"materials/Sprites/w_icons1",
			[0, 0.75],
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
			[0, 0.75],
			[128/256,64/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

int
w_stunstick_isempty(player pl)
{
	return 0;
}

weapontype_t w_stunstick_type(player pl)
{
	return WPNTYPE_CLOSE;
}

weapon_t w_stunstick =
{
	.name		= "stunstick",
	.id			= ITEM_STUNSTICK,
	.slot		= 0,
	.slot_pos	= 1,
	.weight		= 0,
	.draw		= w_stunstick_draw,
	.holster	= w_stunstick_holster,
	.primary	= w_stunstick_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_stunstick_release,
	.postdraw	= __NULL__,
	.precache	= w_stunstick_precache,
	.pickup		= __NULL__,
	.updateammo	= w_stunstick_updateammo,
	.wmodel		= w_stunstick_wmodel,
	.pmodel		= w_stunstick_pmodel,
	.deathmsg	= w_stunstick_deathmsg,
	.aimanim	= w_stunstick_aimanim,
	.isempty	= w_stunstick_isempty,
	.type		= w_stunstick_type,
	.hudpic		= w_stunstick_hudpic
};
