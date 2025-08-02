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

class hlPlayer:ncPlayer
{
	void(void) hlPlayer;

	virtual void Physics_Jump(void);

#ifdef CLIENT
	virtual void UpdatePlayerAttachments(bool);
	virtual void ReceiveEntity(float,float);
	virtual void PredictPreFrame(void);
	virtual void PredictPostFrame(void);
	virtual void UpdateAliveCam(void);
	virtual void ClientInputFrame(void);
#else
	virtual void Death(entity, entity, int, vector, vector, int);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity, float);
	virtual void Save(float);
	virtual void Restore(string,string);
#endif
};

void
hlPlayer::hlPlayer(void)
{
}


#ifdef CLIENT
void
hlPlayer::ClientInputFrame(void)
{
	super::ClientInputFrame();
}

void Camera_RunPosBob(vector angles, __inout vector camera_pos);
void Camera_StrafeRoll(__inout vector camera_angle);
void Shake_Update(ncPlayer);

void
hlPlayer::UpdateAliveCam(void)
{
	vector cam_pos = GetEyePos();
	Camera_RunPosBob(view_angles, cam_pos);

	g_view.SetCameraOrigin(cam_pos);
	Camera_StrafeRoll(view_angles);
	g_view.SetCameraAngle(view_angles);

	if (vehicle) {
		ncVehicle veh = (ncVehicle)vehicle;

		if (veh.UpdateView)
			veh.UpdateView();
	} else if (health) {
		if (autocvar_pm_thirdPerson == TRUE) {
			makevectors(view_angles);
			vector vStart = [pSeat->m_vecPredictedOrigin[0], pSeat->m_vecPredictedOrigin[1], pSeat->m_vecPredictedOrigin[2] + maxs[2]] + (v_right * 4);
			vector vEnd = vStart + (v_forward * -48) + (v_right * 4);
			traceline(vStart, vEnd, FALSE, this);
			g_view.SetCameraOrigin(trace_endpos + (v_forward * 5));
		}
	}

	Shake_Update(this);
	g_view.AddPunchAngle(m_punchAngle);
}

.string oldmodel;
//string Weapons_GetPlayermodel(ncPlayer, int);

void
hlPlayer::UpdatePlayerAttachments(bool visible)
{
	/* draw the flashlight */
	if (gflags & GF_FLASHLIGHT) {
		vector src;
		vector ang;
		
		if (entnum != player_localentnum) {
			src = origin + view_ofs;
			ang = v_angle;
		} else {
			src = pSeat->m_vecPredictedOrigin + view_ofs;
			ang = view_angles;
		}

		makevectors(ang);
		traceline(src, src + (v_forward * 8096), MOVE_NORMAL, this);
		float p = dynamiclight_add(src + (v_forward * 16), 512, [1,1,1], 0, "lights/flashlight");
		dynamiclight_set(p, LFIELD_ANGLES, ang);
		dynamiclight_set(p, LFIELD_FLAGS, 3);
	}

	/* FIXME: this needs to be incorporated and simplified, now that we can handle it all in-class */
	if (!visible)
		return;

	/* what's the current weapon model supposed to be anyway? */
	p_model.oldmodel = 0;//Weapons_GetPlayermodel(this, activeweapon);

	/* we changed weapons, update skeletonindex */
	if (p_model.model != p_model.oldmodel) {
		/* free memory */
		if (p_model.skeletonindex)
			skel_delete(p_model.skeletonindex);

		/* set the new model and mark us updated */
		setmodel(p_model, p_model.oldmodel);
		p_model.model = p_model.oldmodel;
		
		/* set the new skeletonindex */
		p_model.skeletonindex = skel_create(p_model.modelindex);

		/* hack this thing in here FIXME: this should be done when popping in/out of a pvs */
		if (autocvar(cl_himodels, 1, "Use high-quality thisayer models over lower-definition ones"))
			setcustomskin(this, "", "geomset 0 2\n");
		else
			setcustomskin(this, "", "geomset 0 1\n");
	}

	/* follow thisayer at all times */
	setorigin(p_model, origin);
	p_model.angles = angles;
	skel_build(p_model.skeletonindex, p_model, p_model.modelindex,0, 0, -1);

	/* we have to loop through all valid bones of the weapon model and match them
	 * to the thisayer one */
	for (float i = 0; i < g_pbones.length; i++) {
		vector bpos;
		float pbone = gettagindex(this, g_pbones[i]);
		float wbone = gettagindex(p_model, g_pbones[i]);

		/* if the bone doesn't ignore in either skeletal mesh, ignore */
		if (wbone <= 0 || pbone <= 0)
			continue;

		bpos = gettaginfo(this, pbone);
		
		/* the most expensive bit */
		skel_set_bone_world(p_model, wbone, bpos, v_forward, v_right, v_up);
	}
}

/*
=================
hlPlayer::ReceiveEntity
=================
*/
void
hlPlayer::ReceiveEntity(float new, float flChanged)
{
	/* the generic client attributes */
	super::ReceiveEntity(new, flChanged);
}

/*
=================
hlPlayer::PredictPostFrame

Save the last valid server values away in the _net variants of each field
so we can roll them back later.
=================
*/
void
hlPlayer::PredictPreFrame(void)
{
	/* the generic client attributes */
	super::PredictPreFrame();
}

/*
=================
hlPlayer::PredictPostFrame

Where we roll back our values to the ones last sent/verified by the server.
=================
*/
void
hlPlayer::PredictPostFrame(void)
{
	/* the generic client attributes */
	super::PredictPostFrame();
}

#else
void
hlPlayer::Save(float handle)
{
	super::Save(handle);
}

void
hlPlayer::Restore(string strKey, string strValue)
{
	switch (strKey) {
	default:
		super::Restore(strKey, strValue);
	}
}

void
hlPlayer::EvaluateEntity(void)
{
	/* the generic client attributes */
	ncPlayer::EvaluateEntity();

}

void
hlPlayer::Death(entity inflictor, entity attacker, int damagePoints, vector dir, vector absImpactPos, int hitBody)
{
	float randomAnim = floor(random(18, 26));
	ncEntity newCorpse = MakeCorpse(randomAnim);

	super::Death(inflictor, attacker, damagePoints, dir, absImpactPos, hitBody);
	SpectatorDeathcam(newCorpse, (ncEntity)attacker, 3.0f);
}

/*
=================
hlPlayer::SendEntity
=================
*/
float
hlPlayer::SendEntity(entity ePEnt, float flChanged)
{
	/* just-in-case. */
	if (IsPlayer() == false)
		return (0);

	/* don't broadcast invisible hlPlayers */
	if (IsFakeSpectator() && ePEnt != this)
		return (0);
	if (!GetModelindex() && ePEnt != this)
		return (0);

	flChanged = OptimiseChangedFlags(ePEnt, flChanged);

	/* the generic client attributes */
	ncPlayer::SendEntity(ePEnt, flChanged);

	return (1);
}
#endif

void
hlPlayer::Physics_Jump(void)
{
	if (waterlevel >= 2) {
		if (watertype == CONTENT_WATER) {
			velocity[2] = 100;
		} else if (watertype == CONTENT_SLIME) {
			velocity[2] = 80;
		} else {
			velocity[2] = 50;
		}
	} else {
		/* Half-Life: Longjump module */
		if (IsCrouching() && HasItem("item_longjump")) {
			makevectors([0, v_angle[1], 0]);
			velocity = v_forward * 512;
			velocity[2] += 100;
		}
		if (flags & FL_ONGROUND)
			velocity[2] += 265;
	}
}
