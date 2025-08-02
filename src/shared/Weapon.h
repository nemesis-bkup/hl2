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

/*! \brief Half-Life weapon base class. */
/*!QUAKED hl2Weapon (0 0.8 0.8) (-16 -16 0) (16 16 72) 
# OVERVIEW
Half-Life specific weapon based on ncWeapon.

# NEW KEYS
- "ammoIcon" - Which sprites/ image to use. See notes.
- "crosshair" - Which sprites/ image to use as a crosshair. See notes.
- "hudSlot" - In which weapon selection slot this weapon belongs to.
- "hudSlotPos" - The position of the weapon in the respective weapon selection slot.

# NOTES
Both `ammoIcon` and `crosshair` refer to sprite declarations inside the sprites/ directory. FreeHL scans the `sprites/hud.txt` file and and weapon specific files.
Since the weapon specific files only contain short names like `ammo` and `crosshair` you have to refer to them with a prefix separated by a `.` period symbol.

For example, `ammoIcon` being set to `weapon_foobar.ammo` will look up `ammo` inside `sprites/weapon_foobar.txt`.
*/
class
hl2Weapon:ncWeapon
{
public:
	void hl2Weapon(void);

	virtual void InputFrame(void);
	virtual void ReleasedWeaponAttack(string);
	virtual void FiredWeaponAttack(string);
	virtual void AddedToInventory(void);
	virtual void UpdateFireInfoCache(void);

	nonvirtual void PhyscannonPush(void);
	nonvirtual void PhyscannonPull(void);
	nonvirtual void ToolgunFire(bool);
	nonvirtual void PhysgunFire(void);
	nonvirtual void PhysgunFreeze(void);
#ifdef SERVER
	virtual void SpawnKey(string, string);
	nonvirtual void PhyscannonUngrab(void);
#endif

#ifdef CLIENT
	nonvirtual void DrawToolgunText(void);
	virtual void UpdateGUI(void);
	nonvirtual void DrawLaser(void);
#endif

private:
#ifdef CLIENT
	string m_ammoIcon;
	string m_ammo2Icon;
	string m_crossHair;
	ncWeapon m_nextWeapon;
#endif

#ifdef SERVER
	ncPhysicsEntity m_grabbedEntity;
#endif

	bool m_bAltModeLaser;
	bool m_bIsPhysCannon;
	bool m_physcannonAlt;
	float m_physcannonCenterForce;
	float m_physcannonForceOffset;
	float m_physcannonPushRange;
	float m_physcannonPullRange;
	float m_physcannonReflectMultiplier;
	float m_physcannonPullForce;

	float m_flPhysgunDistance;
	bool m_fiPhysgun;
	bool m_fiPhysgunAlt;
	bool m_fiToolgun;
	bool m_fiToolgunAlt;

	string m_toolModeLocalizedString;
	string m_toolDescLocalizedString;
	int m_toolLastSetting;
};

typedef enum
{
	GMTOOL_ROPE = 0,
	GMTOOL_ELASTIC = 1,
	GMTOOL_WELD = 2,
	GMTOOL_BALLSOCKET = 3,
	GMTOOL_PULLEY = 4,
	GMTOOL_EASYWELD = 5,
	GMTOOL_EASYBALL = 6,
	GMTOOL_AXIS = 7,
	GMTOOL_SLIDER = 8,
	GMTOOL_NAILGUN = 9,
	GMTOOL_FACEPOSER = 10,
	GMTOOL_EYESPOSER = 11,
	GMTOOL_REMOVER = 12,
	GMTOOL_IGNITE = 13,
	GMTOOL_PAINT = 14,
	GMTOOL_DUPLICATE = 15,
	GMTOOL_COLOR = 16,
	GMTOOL_MAGNETISE = 17,
	GMTOOL_NOCOLLIDE = 18,
	GMTOOL_DYNAMITE = 19,
	GMTOOL_MATERIAL = 20,
	GMTOOL_RTCAMERA = 21,
	GMTOOL_THRUSTERS = 23,
	GMTOOL_PHYSPROPS = 24,
	GMTOOL_STATUS = 25,
	GMTOOL_BALLOONS = 26,
	GMTOOL_EMITTER = 27,
	GMTOOL_SPRITES = 28,
	GMTOOL_WHEELS = 29,
} gm_toolmode_t;
