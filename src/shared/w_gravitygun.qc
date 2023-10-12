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
	GRAVGUN_PADDING1,
	GRAVGUN_PADDING2,
	GRAVGUN_IDLE,
	GRAVGUN_HOLD_IDLE,
	GRAVGUN_DRAW,
	GRAVGUN_HOLSTER,
	GRAVGUN_FIRE,
	GRAVGUN_ALTFIRE,
};

void w_gravitygun_precache(void)
{
#ifdef CLIENT
	precache_model("models/weapons/v_physcannon.mdl");
#endif
}

void w_gravitygun_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.ammo_uranium, -1);
}

string w_gravitygun_wmodel(void)
{
	return "models/w_gravitygun.mdl";
}

string w_gravitygun_pmodel(player pl)
{
	return "models/p_egon.mdl";
}

string w_gravitygun_deathmsg(void)
{
	return "";
}

int w_gravitygun_pickup(player pl, int new, int startammo)
{
#ifdef SERVER
	int addAmmo = (startammo == -1) ? 20 : startammo;

	if (pl.ammo_uranium < MAX_A_URANIUM) {
		pl.ammo_uranium = bound(0, pl.ammo_uranium + addAmmo, MAX_A_URANIUM);
	} else {
		if (!new)
			return (0);
	}
#endif
	return (1);
}

void w_gravitygun_draw(player pl)
{
	pl.mode_tempstate = 0;

	Weapons_SetModel("models/weapons/v_physcannon.mdl");
	Weapons_ViewAnimation(pl, GRAVGUN_DRAW);
	pl.w_idle_next = 0.95f;
}

void w_gravitygun_holster(player pl)
{
	Weapons_ViewAnimation(pl, GRAVGUN_HOLSTER);
}

void w_gravitygun_release(player pl);

void w_gravitygun_primary(player pl)
{
	if (pl.w_attack_next > 0.0f) {
		w_gravitygun_release(pl);
		return;
	}

	Weapons_MakeVectors(pl);
	vector srcOrg, endOrg;
	srcOrg = pl.GetEyePos();
	endOrg = srcOrg + v_forward * 1024;

	traceline(srcOrg, endOrg, MOVE_NORMAL, pl);

	print(sprintf("%v %v: %f %s\n", srcOrg, endOrg, trace_fraction, trace_ent.classname));

	if (trace_fraction < 1.0) {
#ifdef SERVER
		if (trace_ent.isPhysics) {
			NSPhysicsEntity physEnt = (NSPhysicsEntity)trace_ent;

			physEnt.PhysicsEnable();
			physEnt.ApplyForceCenter(v_forward * 15000);
			physEnt.ApplyForceOffset(v_forward * 600, trace_endpos);

			physEnt.nextthink = time;
		}
#endif
		Weapons_ViewAnimation(pl, GRAVGUN_ALTFIRE);
		pl.w_attack_next = 0.6f;
		pl.w_idle_next = 0.1f;
	} else {
		Weapons_ViewAnimation(pl, GRAVGUN_FIRE);
		pl.w_attack_next = 0.6f;
		pl.w_idle_next = 0.6f;
	}

}
void w_gravitygun_secondary(player pl)
{
	if (pl.w_attack_next > 0.0f) {
		return;
	}

	Weapons_MakeVectors(pl);
	vector srcOrg, endOrg;
	srcOrg = pl.GetEyePos();
	endOrg = srcOrg + v_forward * 1024;

	traceline(srcOrg, endOrg, MOVE_NORMAL, pl);

	if (trace_fraction < 1.0) {
#ifdef SERVER
		if (trace_ent.isPhysics) {
			vector pullDirection;
			NSPhysicsEntity physEnt = (NSPhysicsEntity)trace_ent;
			physEnt.PhysicsEnable();

			pullDirection = normalize(srcOrg - physEnt.WorldSpaceCenter());
			//pullDirection *= (physEnt.mass + 0.5) * (1/50.0f);
			physEnt.ApplyForceCenter(pullDirection * 50.0);
			//physEnt.velocity = v_forward * -100.0f;
			physEnt.nextthink = time;
		}
#endif
	} else {

	}

	//Weapons_ViewAnimation(pl, GRAVGUN_FIRE);
	//pl.w_attack_next = 0.4f;
	//pl.w_idle_next = 0.4f;
}

void w_gravitygun_reload(player pl)
{
	
}

void w_gravitygun_release(player pl)
{
	if (pl.w_idle_next > 0.0)
		return;

	Weapons_ViewAnimation(pl, GRAVGUN_IDLE);
	pl.w_idle_next = 2.0f;
}

void w_gravitygun_crosshair(player pl)
{
#ifdef CLIENT
	vector pos = g_hudmins + [g_hudres[0] / 2, g_hudres[1] / 2];
	Font_DrawText_RGBA(pos + [-7, -14], "Q", g_hud_color, 1.0, FONT_HUD_CROSS);
	HUD_DrawAmmo2();
#endif
}

float w_gravitygun_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CR_AIMEGON : ANIM_AIMEGON;
}

void w_gravitygun_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (pl.ammo_uranium == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	if (selected) {
		drawsubpic(
			pos,
			[128,64],
			"materials/Sprites/w_icons2",
			[0.5, 0.75],
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
			[0.5, 0.75],
			[128/256,64/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_uranium, MAX_A_URANIUM, a);
#endif
}

int
w_gravitygun_isempty(player pl)
{
	if (pl.ammo_uranium <= 0)
		return 1;

	return 0;
}

weapontype_t
w_gravitygun_type(player pl)
{
	return WPNTYPE_FULLAUTO;
}

weapon_t w_gravitygun =
{
	.name		= "egon",
	.id			= ITEM_GRAVITYGUN,
	.slot		= 0,
	.slot_pos	= 2,
	.weight		= 15,
	.draw		= w_gravitygun_draw,
	.holster	= w_gravitygun_holster,
	.primary	= w_gravitygun_primary,
	.secondary	= w_gravitygun_secondary,
	.reload		= w_gravitygun_reload,
	.release	= w_gravitygun_release,
	.postdraw	= w_gravitygun_crosshair,
	.precache	= w_gravitygun_precache,
	.pickup		= w_gravitygun_pickup,
	.updateammo	= w_gravitygun_updateammo,
	.wmodel		= w_gravitygun_wmodel,
	.pmodel		= w_gravitygun_pmodel,
	.deathmsg	= w_gravitygun_deathmsg,
	.aimanim	= w_gravitygun_aimanim,
	.hudpic		= w_gravitygun_hudpic,
	.isempty	= w_gravitygun_isempty,
	.type		= w_gravitygun_type,
	.predraw	= __NULL__
};