/*
 * Copyright (c) 2025 Marco Cawthorne <marco@icculus.org>
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

void
hl2Weapon::hl2Weapon(void)
{
#ifdef CLIENT
	m_toolLastSetting = -1;
	m_ammoIcon = __NULL__;
	m_ammo2Icon = __NULL__;
	m_crossHair = __NULL__;
	m_nextWeapon = __NULL__;
#endif
	m_bIsPhysCannon = false;
	m_bAltModeLaser = false;

	m_fiPhysgun = false;
	m_fiPhysgunAlt = false;
}

#ifdef SERVER
void
hl2Weapon::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	default:
		super::SpawnKey(keyName, setValue);
	}
}
#endif

void
hl2Weapon::UpdateFireInfoCache(void)
{
	super::UpdateFireInfoCache();

	m_physcannonAlt = GetSubDefBool(m_weaponLastFireInfo, "physcannonAlt");
	m_physcannonCenterForce = GetSubDefFloat(m_weaponLastFireInfo, "physcannonCenterForce");
	m_physcannonForceOffset = GetSubDefFloat(m_weaponLastFireInfo, "physcannonForceOffset");
	m_physcannonPushRange = GetSubDefFloat(m_weaponLastFireInfo, "physcannonPushRange");
	m_physcannonPullRange = GetSubDefFloat(m_weaponLastFireInfo, "physcannonPullRange");
	m_physcannonPullForce = GetSubDefFloat(m_weaponLastFireInfo, "physcannonPullForce");
	m_physcannonReflectMultiplier = GetSubDefFloat(m_weaponLastFireInfo, "physcannonReflectMultiplier");
	m_fiPhysgun = GetSubDefBool(m_weaponLastFireInfo, "physgun");
	m_fiPhysgunAlt = GetSubDefBool(m_weaponLastFireInfo, "physgunAlt");
	m_fiToolgun = GetSubDefBool(m_weaponLastFireInfo, "toolgun");
	m_fiToolgunAlt = GetSubDefBool(m_weaponLastFireInfo, "toolgunAlt");
}

#ifdef SERVER
void
hl2Weapon::PhyscannonUngrab(void)
{
	if (!m_grabbedEntity) {
		return;
	}

	m_grabbedEntity.owner = __NULL__;
	m_grabbedEntity.nextthink = 0.0f;
	m_grabbedEntity.think = 0;
	m_grabbedEntity = __NULL__;
}
#endif

void
hl2Weapon::PhyscannonPush(void)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();
	vector forwardDir = anglesToForward(ourOwner.v_angle);

#ifdef SERVER
	if (m_grabbedEntity) {
		m_grabbedEntity.ApplyForceCenter(forwardDir * m_physcannonCenterForce);
		m_grabbedEntity.ApplyForceOffset(forwardDir * m_physcannonForceOffset, trace_endpos);
		PhyscannonUngrab();
		return;
	}

	vector srcOrg, endOrg;
	srcOrg = ourOwner.GetEyePos();
	endOrg = srcOrg + forwardDir * m_physcannonPushRange;

	int oldhitcontents = ourOwner.hitcontentsmaski;
	ourOwner.hitcontentsmaski = CONTENTBITS_POINTSOLID | CONTENTBIT_CORPSE | CONTENTBIT_WATER | CONTENTBIT_SLIME | CONTENTBIT_LAVA | CONTENTBIT_PROJECTILE;
	traceline(srcOrg, endOrg, MOVE_NORMAL, ourOwner);
	ourOwner.hitcontentsmaski = oldhitcontents;

	if (!trace_ent || trace_ent.classname == "player") {
		return;
	}

	//print(sprintf("%v %v: %f %s\n", srcOrg, endOrg, trace_fraction, trace_ent.classname));

	/* player is looking downwards, so we should ensure the entity travels upward
	   or else it's just trying to hug the floor too much */
	if (ourOwner.v_angle[0] > 0) {
		vector newAngle = ourOwner.v_angle;
		newAngle[0] *= m_physcannonReflectMultiplier;
		forwardDir = anglesToForward(newAngle);
	}

	if (trace_fraction < 1.0) {
		if (trace_ent.isPhysics) {
			ncPhysicsEntity physEnt = (ncPhysicsEntity)trace_ent;

			physEnt.ApplyForceCenter(forwardDir * m_physcannonCenterForce);
			physEnt.ApplyForceOffset(forwardDir * m_physcannonForceOffset, trace_endpos);

			//physEnt.nextthink = time;
		}
	}
#endif
}

void
UpdatePos(void)
{
	ncPlayer ourOwner = (ncPlayer)self.owner;

	if (ourOwner.health <= 0) {
		self.think = __NULL__;
		self.nextthink = 0.0f;
		return;
	}

	hl2Weapon physCannon = (hl2Weapon)ourOwner.m_activeWeapon;
	vector forwardDir = anglesToForward(ourOwner.v_angle);
	vector targetOrg = ourOwner.GetEyePos() + forwardDir * physCannon.m_flPhysgunDistance;
	self.velocity = (targetOrg - self.origin) * 10.0;
	self.nextthink = time;
	self.think = UpdatePos;
}

void
hl2Weapon::PhyscannonPull(void)
{
#ifdef SERVER
	ncPlayer ourOwner = (ncPlayer)GetOwner();

	if (m_grabbedEntity) {
		PhyscannonUngrab();
		m_fiFireRate = 0.5f;
		return;
	}

	vector srcOrg, endOrg;
	srcOrg = ourOwner.GetEyePos();
	endOrg = srcOrg + anglesToForward(ourOwner.v_angle) * m_physcannonPullRange;

	int oldhitcontents = ourOwner.hitcontentsmaski;
	ourOwner.hitcontentsmaski = CONTENTBITS_POINTSOLID | CONTENTBIT_CORPSE | CONTENTBIT_WATER | CONTENTBIT_SLIME | CONTENTBIT_LAVA | CONTENTBIT_PROJECTILE;
	traceline(srcOrg, endOrg, MOVE_NORMAL, ourOwner);
	ourOwner.hitcontentsmaski = oldhitcontents;

	if (trace_fraction < 1.0) {
		if (!trace_ent.isPhysics) {
			return;
		}

		if (distance(srcOrg, trace_ent.origin) < 192.0f) {
			m_grabbedEntity = (ncPhysicsEntity)trace_ent;
			m_grabbedEntity.owner = ourOwner;
			m_grabbedEntity.Wake();
			m_grabbedEntity.ScheduleThink(UpdatePos, 0.0f);
			m_fiFireRate = 0.25f;
			ourOwner.gflags |= GF_SEMI_TOGGLED;
			m_flPhysgunDistance = 128.0f;
		} else {
			vector pullDirection;
			ncPhysicsEntity physEnt = (ncPhysicsEntity)trace_ent;

			if (physEnt.GetMass() > 250.0) {
				return;
			}

			pullDirection = vectorNormalize(srcOrg - physEnt.WorldSpaceCenter());
			pullDirection *= m_physcannonPullForce;

			physEnt.ApplyForceCenter(pullDirection);
		}
	}
#endif
	
}

void
hl2Weapon::PhysgunFire(void)
{
#ifdef SERVER
	ncPlayer ourOwner = (ncPlayer)GetOwner();

	if (m_grabbedEntity) {
		if (input_buttons & INPUT_SECONDARY) {
			PhysgunFreeze();
			Release();
		}
		return;
	}


	vector srcOrg, endOrg;
	srcOrg = ourOwner.GetEyePos();
	endOrg = srcOrg + anglesToForward(ourOwner.v_angle) * 4096;

	int oldhitcontents = ourOwner.hitcontentsmaski;
	ourOwner.hitcontentsmaski = CONTENTBITS_POINTSOLID | CONTENTBIT_CORPSE | CONTENTBIT_WATER | CONTENTBIT_SLIME | CONTENTBIT_LAVA | CONTENTBIT_PROJECTILE;
	//traceline(srcOrg, endOrg, MOVE_NORMAL, ourOwner);
	tracebox(srcOrg, [-8,-8,-8], [8,8,8], endOrg, MOVE_NORMAL, ourOwner);
	ourOwner.hitcontentsmaski = oldhitcontents;

	if (trace_fraction < 1.0) {
		if (!trace_ent.isPhysics) {
			return;
		}

		m_grabbedEntity = (ncPhysicsEntity)trace_ent;
		m_grabbedEntity.owner = ourOwner;
		m_grabbedEntity.Wake();
		m_grabbedEntity.ScheduleThink(UpdatePos, 0.0f);
		m_fiFireRate = 0.25f;
		m_flPhysgunDistance = distance(trace_ent.origin, ourOwner.GetOrigin());
		ourOwner.StartSoundDef(m_fiSndFireStop, CHAN_WEAPON, true);
	}
#endif
}

void
hl2Weapon::PhysgunFreeze(void)
{
#ifdef SERVER
	if (!m_grabbedEntity) {
		return;
	}

	m_grabbedEntity.Sleep();
	PhyscannonUngrab();
#endif
	m_flPhysgunDistance = 0.0f;
}

void
hl2Weapon::ReleasedWeaponAttack(string fireInfo)
{
	if (m_fiPhysgun) {
#ifdef SERVER
		PhyscannonUngrab();
#endif
		m_flPhysgunDistance = 0.0f;
		return;
	}

	super::ReleasedWeaponAttack(fireInfo);
}

void
hl2Weapon::InputFrame(void)
{
	if (!m_fiPhysgun) {
		return;
	}

#ifdef SERVER
	if (!m_grabbedEntity) {
		return;
	}
#endif
	ncPlayer ourOwner = (ncPlayer)GetOwner();

	if (input_buttons & INPUT_USE) {
#ifdef SERVER
		m_grabbedEntity.avelocity = g_vec_null;
#endif
		if (input_movevalues[1] > 0) {
#ifdef SERVER
			m_grabbedEntity.angles[1] += frametime * 360.0;
#endif
		} else if (input_movevalues[1] < 0) {
#ifdef SERVER
			m_grabbedEntity.angles[1] -= frametime * 360.0;
#endif
		}
		if (input_movevalues[0] > 0) {
#ifdef SERVER
			m_grabbedEntity.angles[0] += frametime * 360.0;
#endif
		} else if (input_movevalues[0] < 0) {
#ifdef SERVER
			m_grabbedEntity.angles[0] -= frametime * 360.0;
#endif
		}
		input_movevalues = g_vec_null;
		ourOwner.m_nuclideFlags |= VFL_FROZEN;
	} else {
		ourOwner.m_nuclideFlags &= ~VFL_FROZEN;
	}
}

.entity first_ent;
.vector first_pos;

void
hl2Weapon::ToolgunFire(bool altFire)
{
#ifdef SERVER
	ncPlayer ourOwner = (ncPlayer)GetOwner();
	ncEntity targetEntity;
	float forceLimit;
	bool noCollide;

	vector srcOrg, endOrg;
	srcOrg = ourOwner.GetEyePos();
	endOrg = srcOrg + anglesToForward(ourOwner.v_angle) * 4096;

	int oldhitcontents = ourOwner.hitcontentsmaski;
	ourOwner.hitcontentsmaski = CONTENTBITS_POINTSOLID | CONTENTBIT_CORPSE | CONTENTBIT_WATER | CONTENTBIT_SLIME | CONTENTBIT_LAVA | CONTENTBIT_PROJECTILE;
	traceline(srcOrg, endOrg, MOVE_NORMAL, ourOwner);
	ourOwner.hitcontentsmaski = oldhitcontents;

	if (trace_fraction >= 1.0f) {
		return;
	}

	targetEntity = (ncEntity)trace_ent;

	switch (cvar("gm_toolmode")) {
	case GMTOOL_ROPE:
		if (!targetEntity) {
			return;
		}

		if (!ourOwner.first_ent) {
			ourOwner.first_ent = targetEntity;
			ourOwner.first_pos = trace_endpos;
		} else {
			ncPhysicsConstraint::Rope(ourOwner.first_ent, targetEntity, first_pos, trace_endpos);
			ourOwner.first_ent = 0;
			ourOwner.first_pos = g_vec_null;
		}
		break;
	case GMTOOL_WELD:
		if (!targetEntity) {
			return;
		}

		if (!ourOwner.first_ent) {
			ourOwner.first_ent = targetEntity;
			ourOwner.first_pos = trace_endpos;
		} else {
			forceLimit = autocvar(gm_weld_weld_forcelimit, 5000);
			noCollide = autocvar(gm_weld_weld_nocollide, 0);
			ncPhysicsConstraint::Weld(ourOwner.first_ent, targetEntity, 0, 0, forceLimit, noCollide, 0);
			ourOwner.first_ent = 0;
			ourOwner.first_pos = g_vec_null;
		}
		break;
	case GMTOOL_BALLSOCKET:
		if (!targetEntity) {
			return;
		}

		if (!ourOwner.first_ent) {
			ourOwner.first_ent = targetEntity;
			ourOwner.first_pos = trace_endpos;
		} else {
			forceLimit = autocvar(gm_weld_ball_forcelimit, 5000);
			noCollide = autocvar(gm_weld_ball_nocollide, 0);
			ncPhysicsConstraint::Ballsocket(ourOwner.first_ent, targetEntity, 0, 0, forceLimit, noCollide);
			ourOwner.first_ent = 0;
			ourOwner.first_pos = g_vec_null;
		}
		break;
	case GMTOOL_REMOVER:
		if (!targetEntity) {
			return;
		}

		targetEntity.Destroy();
		break;
	case GMTOOL_IGNITE:
		if (!targetEntity) {
			return;
		}

		if (altFire) {
			targetEntity.Input(owner, "Extinguish", "");
		} else {
			targetEntity.Input(owner, "Ignite", "");
		}
		break;
	case GMTOOL_PAINT:
		break;
	case GMTOOL_DUPLICATE:
		if (altFire) {
			if (targetEntity) {
				ourOwner.first_ent = targetEntity;
			}
		} else {
			if (ourOwner.first_ent) {
				ncEntity newDupe = (ncEntity)spawn();
				copyentity(ourOwner.first_ent, newDupe);
				newDupe.SetOriginUnstick(trace_endpos);
			}
		}
		break;
	case GMTOOL_COLOR:
		if (!targetEntity) {
			return;
		}
		ncRenderableEntity renderEnt = (ncRenderableEntity)targetEntity;
		vector newColor;
		float newAlpha, newRenderMode, newRederFX;
		newColor[0] = cvar("gm_colourset_r");
		newColor[1] = cvar("gm_colourset_g");
		newColor[2] = cvar("gm_colourset_b");
		newAlpha = cvar("gm_colourset_a");
		newRenderMode = cvar("gm_colourset_rm");
		newRederFX = cvar("gm_colourset_fx");
		renderEnt.SetRenderColor(newColor);
		renderEnt.SetRenderAmt(newAlpha);
		renderEnt.SetRenderMode(newRenderMode);
		renderEnt.SetRenderFX(newRederFX);
		break;
	case GMTOOL_ELASTIC:
	case GMTOOL_PULLEY:
	case GMTOOL_EASYWELD:
	case GMTOOL_EASYBALL:
	case GMTOOL_AXIS:
	case GMTOOL_SLIDER:
	case GMTOOL_NAILGUN:
	case GMTOOL_FACEPOSER:
	case GMTOOL_EYESPOSER:
	case GMTOOL_MAGNETISE:
	case GMTOOL_NOCOLLIDE:
	case GMTOOL_DYNAMITE:
	case GMTOOL_MATERIAL:
	case GMTOOL_RTCAMERA:
	case GMTOOL_THRUSTERS:
	case GMTOOL_PHYSPROPS:
	case GMTOOL_STATUS:
	case GMTOOL_BALLOONS:
	case GMTOOL_EMITTER:
	case GMTOOL_SPRITES:
	case GMTOOL_WHEELS:
		ncError("Unimplemented");
		break;
	}
#endif
}

void
hl2Weapon::FiredWeaponAttack(string fireInfo)
{
	if (m_fiToolgun) {
		ToolgunFire(m_fiToolgunAlt ? true : false);
		return;
	} else if (m_fiPhysgun) {
		PhysgunFire();
		return;
	} else if (m_bIsPhysCannon) {
		if (m_physcannonAlt == true) {
			PhyscannonPull();
		} else {
			PhyscannonPush();
		}
		return;
	}

	super::FiredWeaponAttack(fireInfo);
}

void
hl2Weapon::AddedToInventory(void)
{
	super::AddedToInventory();

	m_bIsPhysCannon = GetDefBool("physcannon");

#ifdef CLIENT
	m_ammoIcon = GetDefString("ammoIcon");

	if (m_ammoIcon == "") {
		m_ammoIcon = sprintf("%s.ammo", strtolower(classname));
	}

	m_ammo2Icon = GetDefString("ammoIcon");

	if (m_ammo2Icon == "") {
		m_ammo2Icon = sprintf("%s.ammo2", strtolower(classname));
	}

	m_crossHair = GetDefString("crosshair");

	if (m_crossHair == "") {
		m_crossHair = sprintf("%s.crosshair", strtolower(classname));
	}

	m_weaponHUDIcon = GetDefString("hl2hud_icon");

	if (m_weaponHUDIcon == "") {
		m_weaponHUDIcon = "V";
	}

	m_weaponHUDIconSel = GetDefString("hl2hud_iconSelected");

	if (m_weaponHUDIconSel == "") {
		m_weaponHUDIconSel = m_weaponHUDIcon;
	}

	if (m_ammoIcon == "none") {
		m_ammoIcon = __NULL__;
	}

	if (m_ammo2Icon == "none") {
		m_ammo2Icon = __NULL__;
	}

	if (m_crossHair == "none") {
		m_crossHair = __NULL__;
	}

	if (m_weaponHUDIcon == "none") {
		m_weaponHUDIcon = __NULL__;
	}

	if (m_weaponHUDIconSel == "none") {
		m_weaponHUDIconSel = __NULL__;
	}

#endif

	m_bAltModeLaser = GetDefBool("laser");
}

#ifdef CLIENT
void
hl2Weapon::DrawToolgunText(void)
{
	int toolMode = cvar("gm_toolmode");

	if (toolMode > 28) {
		return;
	}

	if (toolMode != m_toolLastSetting) {
		m_toolLastSetting = toolMode;
		m_toolModeLocalizedString = localize(sprintf("#TOOL_NAME_%i", toolMode));
		m_toolDescLocalizedString = localize(sprintf("#TOOL_DESC_%i", toolMode));
	}
	
	drawfill(g_hudmins + [0, g_hudres[1]-32], [g_hudres[0], 32], [0,0,0], 0.75f, DRAWFLAG_NORMAL);
	Font_DrawField(g_hudmins + [0, g_hudres[1]-26], [g_hudres[0], 16], m_toolModeLocalizedString, FONT_TOOL, 0);
	Font_DrawField(g_hudmins + [0, g_hudres[1]-16], [g_hudres[0], 16], m_toolDescLocalizedString, FONT_TOOL, 0);
}

void
hl2Weapon::UpdateGUI(void)
{
	ncPlayer ourOwner = __NULL__;

	if (m_fiToolgun) {
		DrawToolgunText();
	}

#if 0
	/* draw crosshair */
	//HLSprite_DrawCrosshair(m_crossHair);

	if (m_bAltModeLaser) {
		DrawLaser();
	}

	vector crossPos = Cross_GetPos(g_vec_null);

#if 1
	vector vSize = [540,16];
	vector vMainPos;
	float progress;

	progress = (m_flOverheating / m_fiOverheatLength);

	if (progress > 1.0) {
		progress = 1.0f;
	}

	if (m_fiOverheatLength && progress > 0) {
		vMainPos = g_hudmins;
		vMainPos[0] += (g_hudres[0] / 2) - (vSize[0] / 2);
		vMainPos[1] += (g_hudres[1] / 2) - (vSize[1] / 2);

		vector vBar = vSize;
		vBar[0] = 538 * progress;
		vBar[1] = 14;
		drawfill(vMainPos + [1,1], vBar, g_hud_color, 1.0, DRAWFLAG_ADDITIVE);
		drawfill(vMainPos, [vSize[0], 1], g_hud_color, 1.0f); // Top
		drawfill([vMainPos[0], vMainPos[1] + vSize[1]], [vSize[0], 1], g_hud_color, 1.0f); // Bottom
		drawfill(vMainPos, [1, vSize[1]], g_hud_color, 1.0f); // Left
		drawfill([vMainPos[0] + vSize[0], vMainPos[1]], [1, vSize[1] + 1], g_hud_color, 1.0f); // Right
	}
#endif

	if (m_bAmmoRequired == false)
		return;

	ourOwner = (ncPlayer)GetOwner();

	if (m_iClipSize > 0i) {
		ourOwner.a_ammo1 = m_iClip;
		//HUD_DrawAmmo1();
	}

	ourOwner.a_ammo2 = ourOwner.GetReserveAmmo(m_primaryAmmoType);
	//HUD_DrawAmmo2();

	if (m_secondaryAmmoType && m_primaryAmmoType != m_secondaryAmmoType) {
		ourOwner.a_ammo3 = ourOwner.GetReserveAmmo(m_secondaryAmmoType);
		//HUD_DrawAmmo3();
	}
#endif
}

void
hl2Weapon::DrawLaser(void)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();
	float lerpValue;
	vector laser_pos = g_vec_null;
	vector jitter = [0.0f, 0.0f, 0.0f];

	vector src = ourOwner.GetEyePos();
	traceline(src, src + (anglesToForward(ourOwner.v_angle) * 256), FALSE, ourOwner);
	lerpValue = lerp(18,6, trace_fraction);
	jitter[0] = (random(0,2) - 2) * (1 - trace_fraction);
	jitter[1] = (random(0,2) - 2) * (1 - trace_fraction);
	laser_pos = g_hudmins + (g_hudres / 2) + ([-lerpValue,-lerpValue] / 2);

	drawsubpic(
		laser_pos + jitter,
		[lerpValue,lerpValue],
		"materials/Sprites/redglow1",
		[0,0],
		[1.0, 1.0],
		[1,1,1],
		1.0f,
		DRAWFLAG_ADDITIVE
	);
}
#endif
