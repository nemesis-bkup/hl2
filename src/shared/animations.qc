/*
 * Copyright (c) 2015-2021 Vera Visions L.L.C.
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

/* this is a terrible hack file that'll persist until we got our *act* together */
#define BIP01_SPINE3 2

#define ANIM_IDLE 1
#define ANIM_IDLE_CROUCH 5
#define ANIM_WALK 14
#define ANIM_WALK_CROUCH 30
#define ANIM_RUN 22
#define ANIM_RUN_CROUCH 30

void Animation_Print(string sWow) {
#ifdef CLIENT
	print(sprintf("[DEBUG] %s", sWow));
#else 
	bprint(PRINT_HIGH, sprintf("SSQC: %s", sWow) );
#endif	
}

void
Animation_Init(void)
{
#if 0
	g_flFemalePlayerSkeleton = getmodelindex("models/player/female_anims.mdl");
	g_flMalePlayerSkeleton = getmodelindex("models/player/male_anims.mdl");
#else
	g_flFemalePlayerSkeleton = getmodelindex("models/humans/group01/male_cheaple.mdl");
	g_flMalePlayerSkeleton = g_flFemalePlayerSkeleton;
#endif

	//printf("Female skeleton: %d\n", g_flFemalePlayerSkeleton);
	//printf("Male skeleton: %d\n", g_flMalePlayerSkeleton);
}

float
Animation_GetTopTime(HLPlayer pl)
{
	return pl.anim_top_time;
}

void
Animation_TimerUpdate(HLPlayer pl, float ftime)
{
	makevectors([0, pl.v_angle[1], 0]);

	/* top animation is always just being incremented */
	pl.anim_top_time += ftime;
	pl.anim_top_delay -= ftime;

	/* we may be walking backwards, thus decrement bottom */
	if (dotproduct(pl.velocity, v_forward) < 0) {
		pl.anim_bottom_time -= ftime;
	} else {
		pl.anim_bottom_time += ftime;
	}
}

/*
=================
Animation_PlayerUpdate

Called every frame to update the animation sequences
depending on what the player is doing
=================
*/
void
Animation_PlayerUpdate(HLPlayer pl)
{
	if (!pl.skeletonindex) {
		pl.skeletonindex = skel_create(g_flMalePlayerSkeleton);
	}

	if (vlen(pl.velocity) < 1) {
		if (pl.IsCrouching()) {
			pl.anim_bottom = ANIM_IDLE_CROUCH;
		} else {
			pl.anim_bottom = ANIM_IDLE;
		}
	} else if (vlen(pl.velocity) < 150) {
		if (pl.IsCrouching()) {
			pl.anim_bottom = ANIM_WALK_CROUCH;
		} else {
			pl.anim_bottom = ANIM_WALK;
		}
	} else if (vlen(pl.velocity) > 200) {
		if (pl.IsCrouching()) {
			pl.anim_bottom = ANIM_RUN_CROUCH;
		} else {
			pl.anim_bottom = ANIM_RUN;
		}
	}

	/* hack, we can't play the animations in reverse the normal way */
	if (pl.frame1time < 0.0f) {
		pl.frame1time = 10.0f;
	}

	pl.angles[0] = 0.0f;
	pl.angles[1] = pl.v_angle[1];
	pl.angles[2] = 0.0f;

	makevectors([0, pl.v_angle[1], 0]);
	float fCorrect = dotproduct(pl.velocity, v_right) * 0.25f;

	pl.anim_top = pl.anim_bottom;

	/* Correct the legs */
	pl.angles[1] -= fCorrect;

	if (pl.HasVFlags(VFL_INVEHICLE)) {
		float rq = -1;
		ncVehicle veh = (ncVehicle)pl.vehicle;

		if (veh)
			rq = veh.DriverAnimation();

		if (rq == -1) {
			pl.anim_top = ANIMATION_CAR_SIT_IDLE;
			pl.anim_bottom = ANIMATION_CAR_SIT_IDLE;
			pl.angles = pl.vehicle.angles;
		} else {
			pl.anim_top = rq;
			pl.anim_bottom = rq;
			pl.angles = pl.vehicle.angles;
		}
	}

	/* TODO: Needs interpolation */
	/* lower body */
	pl.frame = pl.anim_bottom;
// 	self.frame2 = pl.anim_bottom;
	pl.frame1time = pl.anim_bottom_time;
// 	self.frame2time = pl.anim_bottom_time;
//  	pl.lerpfrac = 1.0f;
	skel_build(pl.skeletonindex, pl, g_flMalePlayerSkeleton, 0, 1, BIP01_SPINE3, 1 );
	
	// Build the top body
	pl.frame = pl.anim_top;
// 	self.frame2 = pl.anim_top;
	pl.frame1time = pl.anim_top_time;
// 	self.frame2time = pl.anim_top_time;
//  	pl.lerpfrac = 1.0f;
	skel_build(pl.skeletonindex, pl, g_flMalePlayerSkeleton, 0, BIP01_SPINE3, 0, 1 ); // The 0.0001 comes from a stupid bug?

	makevectors( [ 0, -fCorrect, 0 ] );
	skel_postmul_bone( pl.skeletonindex, autocvar(skel_bone, 5), [0,0,0], v_forward );

	/* counter act our crouching spine animation */
	if (pl.IsCrouching())
		makevectors( [ 0, -25, fCorrect ] );
	else
		makevectors( [ 0, pl.v_angle[0] * 0.5f, fCorrect ] );

	skel_postmul_bone( pl.skeletonindex, BIP01_SPINE3, [0,0,0], v_forward );
}

void
Animation_PlayerTop(HLPlayer pl, float topanim, float timer)
{
	if (timer == -1)
		timer = frameduration(g_flMalePlayerSkeleton, topanim);

	pl.anim_top = topanim;
	pl.anim_top_time = 0.0f;
	pl.anim_top_delay = timer;
}

void
Animation_PlayerBottom(HLPlayer pl, float botanim, float timer)
{
	pl.anim_bottom = botanim;
}
