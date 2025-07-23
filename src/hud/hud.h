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


#define KILLMESSAGE_LIMIT 5i
#define KILLMESSAGE_TIME 4.0f

int g_killMsgCount;
float g_killMsgTime;

typedef struct
{
	string m_target;
	string m_attacker;
	string m_method;
} killmsg_t;

var killmsg_t g_killMsgRecord[KILLMESSAGE_LIMIT];