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


/* MONSTER_TRIPMINE SEGMENT 
 * 
 * Because not being able to place it around levels would be boring.
 * Some maps, such as subtransit and a few singleplayer chapters have this. */

#ifdef SERVER
class monster_tripmine:ncMonster
{
	int m_iDist;
	void(void) monster_tripmine;

	virtual float(entity, float) SendEntity;
	virtual void(int) Trip;
	virtual void(void) Damaged;
	virtual void(void) Ready;
	virtual void(void) Respawn;
};

float
monster_tripmine::SendEntity(entity pvsent, float flags)
{
	WriteByte(MSG_ENTITY, ENT_TRIPMINE);
	WriteCoord(MSG_ENTITY, origin[0]);
	WriteCoord(MSG_ENTITY, origin[1]);
	WriteCoord(MSG_ENTITY, origin[2]);
	WriteCoord(MSG_ENTITY, angles[0]);
	WriteCoord(MSG_ENTITY, angles[1]);
	WriteCoord(MSG_ENTITY, angles[2]);
	WriteByte(MSG_ENTITY, health);
	WriteShort(MSG_ENTITY, modelindex);
	return (1);
}

void
monster_tripmine::Trip(int walkthrough)
{
	float dmg;
	if (!walkthrough) {
		real_owner = g_dmg_eAttacker;
	}

	/* This is to prevent infinite loops in Damage_Radius */
	Death =
	Pain = __NULL__;
	takedamage = DAMAGE_NO;
	dmg = Skill_GetValue("plr_tripmine", 150);

	pointparticles(particleeffectnum("fx_explosion.main"), origin, [0,0,0], 1);
	Damage_Radius(origin, real_owner, dmg, dmg * 2.5f, TRUE, WEAPON_SLAM);
	Sound_Play(self, CHAN_VOICE, "fx.explosion");
	Destroy();
}

void
monster_tripmine::Damaged(void)
{
	Trip(0);
}

void
monster_tripmine::Ready(void)
{
	makevectors(angles);
	traceline(origin, origin + v_forward * 2048, FALSE, this);
	SetSolid(SOLID_BBOX);

	/* first time we're marked as ready, we play a sound and set the distance */
	if (!health) {
		SendFlags = -1;
		health = 1;
		Death =
		Pain = Damaged;
		takedamage = DAMAGE_YES;
		m_iDist = (int)trace_plane_dist;
		Sound_Play(this, CHAN_WEAPON, "weapon_tripmine.activate");
	}

	if ((int)trace_plane_dist != m_iDist) {
		Trip(1);
	}
	nextthink = time;
}

void
monster_tripmine::Respawn(void)
{
	SetModel("models/weapons/w_slam.mdl");
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_NONE);
	SetSize([-8,-8,-8], [8,8,8]);
	SetOrigin(origin);
	SendFlags = 1; /* force update */

	/* ready in 4 seconds flat */
	think = Ready;

	/* fast beam */
	if (spawnflags & 1) {
		nextthink = time;
	} else {
		nextthink = time + 4.0f;
	}
}

void
monster_tripmine::monster_tripmine(void)
{
	Respawn();
}
#else
class csitem_tripmine
{
	int m_iActive;

	void(void) csitem_tripmine;
	virtual float(void) predraw;
};

float csitem_tripmine::predraw(void)
{
	if (m_iActive) {
		makevectors(angles);
		traceline(origin, origin + v_forward * 8196, FALSE, this);
		trailparticles(BEAM_TRIPMINE, this, origin, trace_endpos);
	}

	addentity(this);
	return PREDRAW_NEXT;
}

void
csitem_tripmine::csitem_tripmine(void)
{
	solid = SOLID_BBOX;
	movetype = MOVETYPE_NONE;
	drawmask = MASK_ENGINE;
	m_iActive = FALSE;
}

void w_tripmine_parse(void)
{
	csitem_tripmine tm = (csitem_tripmine)self;
	spawnfunc_csitem_tripmine();

	tm.origin[0] = readcoord();
	tm.origin[1] = readcoord();
	tm.origin[2] = readcoord();
	tm.angles[0] = readcoord();
	tm.angles[1] = readcoord();
	tm.angles[2] = readcoord();
	tm.m_iActive = readbyte();
	tm.modelindex = readshort();

	setorigin(tm, tm.origin);
	setsize(tm, [-8,-8,-8], [8,8,8]);
}
#endif





enum
{
	SLAM_IDLE,						// 3.36
	SLAM_IDLE_NOHAND,				// 3.36
	SLAM_THROW,						// 0.50
	SLAM_DRAWHAND,					// 0.83
	SLAM_THROW_NOHAND,				// 0.50
	SLAM_WAVE,						// 0.83
	SLAM_DRAW,						// 1.00
	SLAM_DRAW_NOHAND,				// 1.00
	SLAM_PLACE,						// 1.36
	SLAM_DETONATE,					// 1.36
	SLAM_PLACE_ONEHAND,				// 1.36
	SLAM_PLACE_NOHAND,				// 1.36
	SLAM_DETONATOR_DRAW,			// 1.00
	SLAM_DETONATOR_IDLE,			// 3.36
	SLAM_DETONATOR_BOOM,			// 0.70
	SLAM_DETONATOR_THROWDRAW,		// 1.00
	SLAM_DETONATOR_HOLSTER,			// 0.43
	SLAM_TRIPMINE_IDLE,				// 3.36
	SLAM_TRIPMINE_DRAW,				// 0.86
	SLAM_TRIPMINE_TOTHROW,			// 1.70
	SLAM_TRIPMINE_STARTATTACH,		// 0.26
	SLAM_TRIPMINE_ENDATTACH,		// 0.63
	/* hopefully unused */
	SLAM_STICKWALL_IDLE,			// 1.36
	SLAM_STICKWALL_IDLE_NOHAND,		// 1.36
	SLAM_STICKWALL_STARTATTACH,		// 0.20
	SLAM_STICKWALL_ENDATTACH,		// 0.63
	SLAM_STICKWALL_TOTHROW,			// 1.00
	SLAM_STICKWALL_TOTHROW_NOHAND,	// 1.00
};

enum
{
	SLAMSTATE_NONE,
	SLAMSTATE_RAISEDETONATOR,
	SLAMSTATE_LOWERDETONATOR,
	SLAMSTATE_GOTOTRIPMINE,
	SLAMSTATE_TRIPMINE,
	SLAMSTATE_LEAVETRIPMINE,
	SLAMSTATE_ENDATTACH,
	SLAMSTATE_GOTOTRIPDRAW
};

#ifdef SERVER
void
s_slam_detonate(entity master)
{
	for (entity b = world; (b = find(b, ::classname, "projectile_slam"));) {
		if (b.owner != master)
			continue;

		ncEntity slamEnt = (ncEntity)b;
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
	Weapons_SetModel("models/weapons/v_slam.mdl");

	if (pl.mode_tempstate == SLAMSTATE_TRIPMINE) {
		Weapons_ViewAnimation(pl, SLAM_TRIPMINE_DRAW);
	} else {

		if (pl.satchel_chg) {
			if (pl.ammo_satchel)
				Weapons_ViewAnimation(pl, SLAM_DETONATOR_THROWDRAW);
			else
				Weapons_ViewAnimation(pl, SLAM_DETONATOR_DRAW);
		} else {
			if (pl.ammo_satchel)
				Weapons_ViewAnimation(pl, SLAM_DRAW_NOHAND);
			else
				Weapons_ViewAnimation(pl, SLAM_DRAWHAND);
		}
	}

	pl.w_idle_next = 0.9f;
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
	if (pl.ammo_satchel <= 0) {
		return;
	}

	if (pl.mode_tempstate == SLAMSTATE_TRIPMINE) {
#ifdef SERVER
		vector src = Weapons_GetCameraPos(pl);
		Weapons_MakeVectors(pl);
		traceline(src, src + v_forward * 64, FALSE, pl);
		vector ang = vectoangles(trace_plane_normal);
		monster_tripmine mine = spawn(monster_tripmine, real_owner: pl, angles: ang, spawnflags: MSF_MULTIPLAYER);
		mine.health = 0;
		mine.SetOrigin(trace_endpos + (trace_plane_normal * 8));

		Sound_Play(pl, CHAN_WEAPON, "weapon_tripmine.deploy");
		Sound_Play(mine, CHAN_WEAPON, "weapon_tripmine.charge");
#endif
		Weapons_ViewAnimation(pl, SLAM_TRIPMINE_STARTATTACH);
		pl.mode_tempstate = SLAMSTATE_ENDATTACH;
		pl.w_attack_next = 
		pl.w_idle_next = 0.20f;
		pl.ammo_satchel--;

		if (pl.ammo_satchel <= 0 && pl.satchel_chg <= 0) {
#ifdef SERVER
			Weapons_RemoveItem(pl, WEAPON_SLAM);
#endif
		}
	} else {
		if (pl.satchel_chg)
			Weapons_ViewAnimation(pl, SLAM_THROW);
		else {
			Weapons_ViewAnimation(pl, SLAM_THROW_NOHAND);
			pl.mode_tempstate = SLAMSTATE_RAISEDETONATOR;
		}

	#ifdef SERVER
		ncProjectile_SpawnDef("projectile_slam", pl);
	#endif
		pl.satchel_chg++;
		pl.ammo_satchel--;
		pl.w_attack_next = 
		pl.w_idle_next = 0.50f;
	}


}

void
w_slam_secondary(player pl)
{
	if (pl.satchel_chg <= 0)
		return;

	if (pl.ammo_satchel <= 0) {
		Weapons_ViewAnimation(pl, SLAM_DETONATOR_BOOM);
		pl.w_attack_next = 
		pl.w_idle_next = 0.7f;
	} else {
		Weapons_ViewAnimation(pl, SLAM_DETONATE);
		pl.w_attack_next = 
		pl.w_idle_next = 1.36f;
	}

#ifdef SERVER
	s_slam_detonate(pl);
#endif

	pl.mode_tempstate = 0;
	pl.satchel_chg = 0;

}

void
w_slam_reload(player pl)
{
	
}

void
w_slam_release(player pl)
{
	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* we're in either slam or tripmine mode */
	if (pl.mode_tempstate == SLAMSTATE_NONE || pl.mode_tempstate == SLAMSTATE_TRIPMINE) {
		Weapons_MakeVectors(pl);
		vector src = pl.origin + pl.view_ofs;
		traceline(src, src + (v_forward * 64), FALSE, pl);

		if (trace_fraction >= 1.0 && pl.mode_tempstate == SLAMSTATE_TRIPMINE) {
			pl.mode_tempstate = SLAMSTATE_LEAVETRIPMINE;
		} else if (trace_fraction < 1.0 && pl.mode_tempstate == SLAMSTATE_NONE) {
			pl.mode_tempstate = SLAMSTATE_GOTOTRIPMINE;
		}
	}

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.mode_tempstate == SLAMSTATE_RAISEDETONATOR) {
		w_slam_draw(pl);
		pl.mode_tempstate = SLAMSTATE_NONE;
	} else if (pl.mode_tempstate == SLAMSTATE_GOTOTRIPMINE) {
		Weapons_ViewAnimation(pl, SLAM_PLACE);
		pl.w_idle_next = 1.30;
		pl.mode_tempstate = SLAMSTATE_TRIPMINE;
	} else if (pl.mode_tempstate == SLAMSTATE_LEAVETRIPMINE) {
		Weapons_ViewAnimation(pl, SLAM_TRIPMINE_TOTHROW);
		pl.w_idle_next = 1.68;
		pl.mode_tempstate = SLAMSTATE_NONE;
	} else if (pl.mode_tempstate == SLAMSTATE_ENDATTACH ) {
		Weapons_ViewAnimation(pl, SLAM_TRIPMINE_ENDATTACH);
		pl.w_idle_next = 0.6f;
		pl.mode_tempstate = SLAMSTATE_GOTOTRIPDRAW;
	} else if (pl.mode_tempstate == SLAMSTATE_TRIPMINE) {
		Weapons_ViewAnimation(pl, SLAM_TRIPMINE_IDLE);
	} else if (pl.mode_tempstate == SLAMSTATE_GOTOTRIPDRAW ) {
		pl.mode_tempstate = SLAMSTATE_TRIPMINE;
		w_slam_draw(pl);
	} else {
		if (pl.satchel_chg) {
			if (pl.ammo_satchel)
				Weapons_ViewAnimation(pl, SLAM_IDLE);
			else
				Weapons_ViewAnimation(pl, SLAM_DETONATOR_IDLE);
		} else {
			if (pl.ammo_satchel) {
				Weapons_ViewAnimation(pl, SLAM_IDLE_NOHAND);
			} else {
#ifdef SERVER
				Weapons_RemoveItem(pl, WEAPON_SLAM);
#endif
			}
		}

		//pl.w_idle_next = 3.36f;
	}
}

float
w_slam_aimanim(player pl)
{
	return pl.IsCrouching() ? ANIM_CR_AIMSQUEAK : ANIM_AIMSQUEAK;
}

void
w_slam_hud(player pl)
{
#ifdef CLIENT
	HUD_DrawAmmo2();
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
