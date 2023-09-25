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

#ifdef CLIENT
var float TRAIL_EGONBEAM;

string w_gravitygun_sparkframes[11];

void
w_gravitygun_beamfx(vector vecPos, vector vecEndPos, entity eOwner)
{
	trailparticles(TRAIL_EGONBEAM, eOwner, vecPos, vecEndPos);
}
#endif

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
#ifdef SERVER
	precache_sound("weapons/egon_windup2.wav");
	precache_sound("weapons/egon_run3.wav");
	precache_sound("weapons/egon_off1.wav");
	precache_model("models/w_gravitygun.mdl");
	Sound_Precache("weapon_egon.empty");
#else
	TRAIL_EGONBEAM = particleeffectnum("weapon_egon.beam");
	precache_model("models/weapons/v_physcannon.mdl");
	precache_model("models/p_egon.mdl");
	precache_model("sprites/xspark1.spr");

	for (int i = 0; i < 11; i++)
		w_gravitygun_sparkframes[i] = spriteframe("sprites/xspark1.spr", i, 0.0f);
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
		return;
	}

	Weapons_ViewAnimation(pl, GRAVGUN_FIRE);
	pl.w_attack_next = 0.6f;
	pl.w_idle_next = 0.6f;
}
void w_gravitygun_secondary(player pl)
{
	if (pl.w_attack_next > 0.0f) {
		return;
	}


	Weapons_ViewAnimation(pl, GRAVGUN_FIRE);
	pl.w_attack_next = 0.4f;
	pl.w_idle_next = 0.4f;
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

void
w_gravitygun_postdraw(player pl, int thirdperson)
{
#ifdef CLIENT
	if (!(pl.gflags & GF_EGONBEAM))
		return;

	vector src;
	vector endpos;

	if (thirdperson) {
		makevectors(pl.v_angle);
		src = pl.origin;
		endpos = pl.origin + (v_forward * 1024);
		traceline(src, endpos, MOVE_NORMAL, pl);
		w_gravitygun_beamfx(gettaginfo(pl.p_model, 10), trace_endpos, pl);
	} else {
		vector gunpos = gettaginfo(pSeat->m_eViewModel, 33);
		src = gettaginfo(pSeat->m_eViewModel, 0);
		makevectors(view_angles);
		endpos = src + v_forward * 1024;
		traceline(src, endpos, FALSE, pl);
		w_gravitygun_beamfx(gunpos, endpos, pl);
	}

	int i = (cltime*10.0f) % 11.0f;
	vector fsize = [32,32];
	makevectors(view_angles);
	trace_endpos += v_forward * -16; /* nudge towards our camera */
	dynamiclight_add(trace_endpos, 128, [0.5, 0.5, 1.0]);

	R_BeginPolygon(w_gravitygun_sparkframes[i], 1, 0);
	R_PolygonVertex(trace_endpos + v_right * fsize[0] - v_up * fsize[1],
		[1,1], [1,1,1], 1.0f);
	R_PolygonVertex(trace_endpos - v_right * fsize[0] - v_up * fsize[1],
		[0,1], [1,1,1], 1.0f);
	R_PolygonVertex(trace_endpos - v_right * fsize[0] + v_up * fsize[1],
		[0,0], [1,1,1], 1.0f);
	R_PolygonVertex(trace_endpos + v_right * fsize[0] + v_up * fsize[1],
		[1,0], [1,1,1], 1.0f);
	R_EndPolygon();
#endif
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
	.slot_pos	= 1,
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
	.predraw	= w_gravitygun_postdraw
};