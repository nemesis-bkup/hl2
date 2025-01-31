#pragma PROGS_DAT  "../../hud.dat"

#include "../../../src/client/api.h"

font_s FONT_HL2;
font_s FONT_WEAPONICON;
font_s FONT_WEAPONNUM;
font_s FONT_WEAPONNUMB;
font_s FONT_VERDANA;
font_s FONT_WEAPONTEXT;
font_s FONT_WEAPONICON_SEL;

var vector autocvar_hl2hud_fgColor  = [1.0, 0.86, 0.0];
var float autocvar_hl2hud_fgAlpha  = 0.39f;
var float autocvar_hl2hud_altBucket  = 0.0;
var float autocvar_hl2hud_bucketNumAlpha  = 0.5f;
var float autocvar_hl2hud_hideTime  = 3.0f;

#define g_fg_color autocvar_hl2hud_fgColor
#define g_fg_alpha autocvar_hl2hud_fgAlpha

#include "HL2WeaponSelect.h"
#include "HL2WeaponSelect.qc"

//var string g_ammoPic;
HL2WeaponSelect weaponSelectionHUD;


var float g_oldHealth;
var float g_oldArmor;
var float g_oldClip;
var float g_oldAmmo1;
var float g_oldAmmo2;

var float g_healthAlpha;
var float g_armorAlpha;
var float g_clipAlpha;
var float g_ammo1Alpha;
var float g_ammo2Alpha;
var float g_ammoDisplayAlpha;
var float g_damageAlpha;
var vector g_damageLocation;

var bool g_isGarry;

#include "hud_old.qc"

void
HL2HUD_UpdateTimers(float health, float armor, float clip, float ammo1, float ammo2)
{
	if (health != g_oldHealth) {
		g_healthAlpha = 1.0;
	}
	if (armor != g_oldArmor) {
		g_armorAlpha = 1.0;
	}
	if (clip != g_oldClip) {
		g_clipAlpha = 1.0;
	}
	if (ammo1 != g_oldAmmo1) {
		g_ammo1Alpha = 1.0;
	}
	if (ammo2 != g_oldAmmo2) {
		g_ammo2Alpha = 1.0;
	}

	g_oldHealth = health;
	g_oldArmor = armor;
	g_oldClip = clip;
	g_oldAmmo1 = ammo1;
	g_oldAmmo2 = ammo2;
}

void
HL2HUD_ClampTimers()
{
	g_healthAlpha = bound(g_fg_alpha, g_healthAlpha - (clframetime * 0.5), 1.0);
	g_armorAlpha = bound(g_fg_alpha, g_armorAlpha - (clframetime * 0.5), 1.0);
	g_clipAlpha = bound(g_fg_alpha, g_clipAlpha - (clframetime * 0.5), 1.0);
	g_ammo1Alpha = bound(g_fg_alpha, g_ammo1Alpha - (clframetime * 0.5), 1.0);
	g_ammo2Alpha = bound(g_fg_alpha, g_ammo2Alpha - (clframetime * 0.5), 1.0);
	g_ammoDisplayAlpha = bound(0.0, g_ammoDisplayAlpha - (clframetime * 5), 1.0);
	g_damageAlpha = bound(0.0, g_damageAlpha - (clframetime * 1), 1.0);
}

void
HL2HUD_BigNums(vector pos, string numString, float alpha)
{
	if (alpha > g_fg_alpha) {
		float backAlpha = bound(0.0f, alpha - g_fg_alpha, 1.0f);
		draw.Text_RGBA(pos + [random(-2,2), 0], numString, g_fg_color, backAlpha, FONT_WEAPONNUMB);
		draw.Text_RGBA(pos, numString, g_fg_color, alpha, FONT_HL2);
	} else
		draw.Text_RGBA(pos, numString, g_fg_color, alpha, FONT_HL2);
}


void
HUD_Init(void)
{
#if 0
	Sound_Precache("Player.DenyWeaponSelection");
	Sound_Precache("Player.WeaponSelected");
	Sound_Precache("Player.WeaponSelectionMoveSlot");
	Sound_Precache("Player.WeaponSelectionOpen");
	Sound_Precache("Player.WeaponSelectionClose");
#endif

	weaponSelectionHUD = spawn(HL2WeaponSelect);

	g_isGarry = (cvars.GetString("fs_game") == "gmod9") ? (true) : (false);
}

void
HUD_RendererRestarted(void)
{
	font.Load("fonts/hl2.font", FONT_HL2);
	font.Load("fonts/weaponicon.font", FONT_WEAPONICON);
	font.Load("fonts/weaponicon_sel.font", FONT_WEAPONICON_SEL);
	font.Load("fonts/verdana.font", FONT_VERDANA);
	font.Load("fonts/weapontext.font", FONT_WEAPONTEXT);
	font.Load("fonts/weaponnumbers.font", FONT_WEAPONNUM);
	font.Load("fonts/weaponnumbers_blurry.font", FONT_WEAPONNUMB);
}

var int autocvar_hl2hud_style = 0;

void
HUD_Draw(void)
{
	vector pos;
	vector hud_mins, hud_size;
	float armorValue  = player.GetArmor();
	float healthValue = player.GetHealth();
	int teamID = player.GetTeam();
	float clipValue = weapon.GetClip();
	float ammoValue = weapon.GetAmmo1();
	float ammoValue2 = weapon.GetAmmo2();
	float staminaValue = 1.0 - player.GetStamina();

	string healthString = ftos(healthValue);
	string armorString = ftos(armorValue);
	string clipString = ftos(clipValue);
	string ammoString = ftos(ammoValue);
	string ammoString2 = ftos(ammoValue2);

	hud_mins = screen.HUDMins();
	hud_size = screen.HUDSize();

	HL2HUD_UpdateTimers(healthValue, armorValue, clipValue, ammoValue, ammoValue2);

	if (g_damageAlpha > 0.0f) {
		vector finalColor = [1,0,0];
		vector rel_pos, center;
		float fw, rt, rt_alpha;
		vector screenSize = screen.Size();
		finalColor[0] = g_damageAlpha;
		draw.Pic(screen.Mins(), "fade_additive", screenSize, finalColor, 1.0);
		center = screen.Mins() + (screenSize / 2);

		/* the pos relative to the player + view_dir determines which
		 * and how bright each indicator is drawn. so first get the relative
		 * position between us and the attacker, then calculate the strength
		 * of each direction based on a dotproduct tested against our
		 * camera direction.
		 */
		rel_pos = normalize(g_damageLocation - player.GetCameraPosition());
		makevectors(player.GetCameraAngles());
		fw = dotproduct(rel_pos, v_forward);
		fw = -1.0f;

		if (fw < -0.25f) {
			draw.Pic(center + [70+128,-128], "textures/ui/m_lineleft",
				[96,256], [1,0,0], g_damageAlpha);
			draw.Pic(center + [-102-128,-128], "textures/ui/m_lineright",
				[96,256], [1,0,0], g_damageAlpha);
		} else {
			rt = dotproduct(rel_pos, v_right);
			rt_alpha = fabs(rt) * g_damageAlpha;

			if (rt > 0.25f) {
				draw.Pic(center + [70+128,-128], "textures/ui/m_lineleft",
					[96,256], [1,0,0], rt_alpha);
			} else if (rt < -0.25f) {
				draw.Pic(center + [-102-128,-128], "textures/ui/m_lineright",
					[96,256], [1,0,0], rt_alpha);
			}
		}
	}

	if (g_isGarry) {
		pos = hud_mins + [hud_size[0] - 16, 16];

		draw.RoundedBox(pos - [96-8,0], [96, 36], [0,0,0], 76/255);
		draw.RText_RGBA(pos + [0, 4], "FWill 1.0", [1,1,1], 1.0, FONT_VERDANA);
		draw.RText_RGBA(pos + [0, 20], "frag-net.com", [1,1,1], 1.0, FONT_VERDANA);
	}

	if (autocvar_hl2hud_style) {
		HL2OldHUD_DrawHealth(healthValue, hud_mins, hud_size);
		HL2OldHUD_DrawArmor(armorValue, hud_mins, hud_size);

		if (weapon.UsesSecondaryAmmo() == true) {
			HL2OldHUD_DrawAmmo3(ammoValue2, hud_mins, hud_size);
		}

		if (weapon.GetClipSize() > 0) {
			HL2OldHUD_DrawAmmo1(clipValue, hud_mins, hud_size);
			HL2OldHUD_DrawAmmo2(ammoValue, hud_mins, hud_size);
		} else {
			HL2OldHUD_DrawAmmo2(ammoValue, hud_mins, hud_size);
		}

		HL2HUD_ClampTimers();
		return;
	}

	/* sprinting overlay  */
	if (staminaValue < 1.0f) {

		pos = hud_mins + [16, hud_size[1] - 90];

		if (player.IsSprinting()) {
			pos = hud_mins + [16, hud_size[1] - 90];
			draw.RoundedBox(pos, [102, 36], [0,0,0], 76/255);
			draw.Text_RGBA(pos + [8, 24], "SPRINT", g_fg_color, 1.0f, FONT_VERDANA);
		} else {
			pos = hud_mins + [16, hud_size[1] - 80];
			draw.RoundedBox(pos, [102, 26], [0,0,0], 76/255);
		}

		draw.Text_RGBA(pos + [8, 5], "AUX POWER", g_fg_color, 1.0f, FONT_VERDANA);


		for (float f = 0.0f; f <= 1.0f; f += 0.1f) {
			if (f < staminaValue)
				draw.Rect(pos + [8,15], [6, 4], g_fg_color, 1.0f);
			else
				draw.Rect(pos + [8,15], [6, 4], g_fg_color, g_fg_alpha);

			pos[0] += 9;
		}

	} else {
		if (teams.TeamCount() > 0i) {
			pos = hud_mins + [16, hud_size[1] - 65];
			draw.RoundedBox(pos, [66, 16], [0,0,0], 76/255);
			draw.Text_RGBA(pos + [8, 5], strcat("Team ", teams.Name(teamID)), teams.Color(teamID), 1.0f, FONT_VERDANA);
		}
	}

	/* health pos */
	pos = hud_mins + [16, hud_size[1] - 48];
	draw.RoundedBox(pos, [102, 36], [0,0,0], 76/255);
	HL2HUD_BigNums(pos + [50, 9], healthString, g_healthAlpha);
	draw.Text_RGBA(pos + [8, 21], "HEALTH", g_fg_color, g_healthAlpha, FONT_VERDANA);

	if (armorValue > 0) {
		/* armor pos */
		pos[0] += 102 + 16;
		draw.RoundedBox(pos, [102, 36], [0,0,0], 76/255);
		HL2HUD_BigNums(pos + [50, 9], armorString, g_armorAlpha);
		draw.Text_RGBA(pos + [8, 21], "SUIT", g_fg_color, g_armorAlpha, FONT_VERDANA);
	}

	weaponSelectionHUD.Draw();

	if (weapon.AmmoRequired() == false) {
		HL2HUD_ClampTimers();
		return;
	}

	/* ammo displays */

	/* ammo 2 */
	if (weapon.UsesSecondaryAmmo() == true) {
		pos = hud_mins + [hud_size[0] - 76, hud_size[1] - 48];
		draw.RoundedBox(pos, [60, 36], [0,0,0], 76/255);

		if (g_ammoDisplayAlpha > 0.0f) {
			draw.RoundedBox(pos,  [60, 36], g_fg_color, g_ammoDisplayAlpha);
		}

		HL2HUD_BigNums(pos + [10, 9], ammoString2, g_ammo2Alpha);
		pos[0] -= 102 - 16;
	} else {
		pos = hud_mins + [hud_size[0] - 102 - 16, hud_size[1] - 48];
	}

	if (weapon.GetClipSize() > 0) {
		pos[0] -= 64;

		draw.RoundedBox(pos, [132, 36], [0,0,0], 76/255);

		if (g_ammoDisplayAlpha > 0.0f) {
			draw.RoundedBox(pos, [132, 36], g_fg_color, g_ammoDisplayAlpha);
		}

		HL2HUD_BigNums(pos + [40, 9], clipString, g_clipAlpha);
		draw.Text_RGBA(pos + [8, 21], "AMMO", g_fg_color, g_clipAlpha, FONT_VERDANA);
		draw.Text_RGBA(pos + [96, 18], ammoString, g_fg_color, g_ammo1Alpha, FONT_VERDANA);
	} else {
		draw.RoundedBox(pos, [102, 36], [0,0,0], 76/255);

		if (g_ammoDisplayAlpha > 0.0f) {
			draw.RoundedBox(pos, [102, 36], g_fg_color, g_ammoDisplayAlpha);
		}

		HL2HUD_BigNums(pos + [50, 9], ammoString, g_ammo1Alpha);
		draw.Text_RGBA(pos + [8, 21], "AMMO", g_fg_color, g_ammo1Alpha, FONT_VERDANA);
	}

	HL2HUD_ClampTimers();
}

void
HUD_DrawSpectator(vector hud_mins, vector hud_size)
{

}

void
HUD_WeaponSwitched(string weaponName)
{
	//g_ammoPic = entityDef.GetKeyValue(weaponName, "ammoIcon");
	g_ammoDisplayAlpha = 1.0f;
}

float
HUD_InputFrame(float inputButtons)
{
	if (weaponSelectionHUD.Active()) {
		if (inputButtons & INPUT_PRIMARY) {
			weaponSelectionHUD.Trigger();
		} else if (inputButtons & INPUT_SECONDARY) {
			weaponSelectionHUD.Deactivate();
		}

		return (0.2f);
	}

	return (0.0f);
}

bool
HUD_ConsoleCommand(string commandString)
{
	tokenize_console(commandString);

	switch (argv(0)) {
	case "invnext":
		weaponSelectionHUD.SelectNext(false);
		break;
	case "invprev":
		weaponSelectionHUD.SelectPrevious(false);
		break;
	default:
		return (false);
	}

	return (true);
}

void
HUD_DamageReceived(vector damageLocation, int damagePoints, int damageFlags)
{
	g_damageAlpha = 1.0;
	g_damageLocation = damageLocation;
}
