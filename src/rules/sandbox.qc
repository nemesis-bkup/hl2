/*
 * Copyright (c) 2024 Marco Cawthorne <marco@icculus.org>
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

#if 0
string g_stockHL2MPPlayerModels[] = {
	"models/humans/group03/female_01.mdl",
	"models/humans/group03/female_02.mdl",
	"models/humans/group03/female_03.mdl",
	"models/humans/group03/female_04.mdl",
	"models/humans/group03/female_06.mdl",
	"models/humans/group03/female_07.mdl",
	"models/humans/group03/male_01.mdl",
	"models/humans/group03/male_02.mdl",
	"models/humans/group03/male_03.mdl",
	"models/humans/group03/male_04.mdl",
	"models/humans/group03/male_05.mdl",
	"models/humans/group03/male_06.mdl",
	"models/humans/group03/male_07.mdl",
	"models/humans/group03/male_08.mdl",
	"models/humans/group03/male_09.mdl",
	"models/police.mdl",
	"models/combine_soldier.mdl",
	"models/combine_soldier_prisonguard.mdl",
	"models/combine_super_soldier.mdl",
};
#else
string g_stockHL2MPPlayerModels[] = {
	"models/humans/group01/male_cheaple.mdl",
};
#endif

bool
IsTeamplay(void)
{
	return cvars.GetBool("mp_teamplay");
}

bool
AllowFlashlight(void)
{
	return cvars.GetBool("mp_flashlight");
}

void
CodeCallback_Precache(void)
{
	precache.Entity("player_sandbox");

	for (int i = 0; i < g_stockHL2MPPlayerModels.length; i++) {
		precache.Model(g_stockHL2MPPlayerModels[i]);
	}
}

void
CodeCallback_StartGameType(void)
{
	motd.LoadDefault();
	game.SetSpawnPoint("info_player_deathmatch");
}

void
CodeCallback_PlayerSpawn(entity playerEntity)
{
	string playerModel;
	ents.ChangeToClass(playerEntity, "player_sandbox");
	playerModel = g_stockHL2MPPlayerModels[floor(random(0,g_stockHL2MPPlayerModels.length))];
	playerEntity.modelindex = getmodelindex(playerModel); /* keep OG size */
	game.TeleportToSpawn(playerEntity);
}

void
CodeCallback_PlayerDisconnect(entity playerEntity)
{

}

bool
CodeCallback_PlayerRequestRespawn(entity playerEntity)
{
	CodeCallback_PlayerSpawn(playerEntity);
	return (true);
}

void
CodeCallback_PlayerDamage(entity playerEntity, entity inflictor, entity attacker)
{

}

void
CodeCallback_PlayerKilled(entity playerEntity, entity inflictor, entity attacker, string weapon)
{
	combat.Obituary(playerEntity.netname, attacker.netname, weapon, "");

	/* death-counter */
	playerEntity.deaths++;

	/* update score-counter */
	if (is.Player(attacker)) {
		if (playerEntity == attacker) {
			attacker.frags--;
		} else {
			attacker.frags++;
		}
	}
}

bool
CodeCallback_ClientCommand(entity playerEntity, string command)
{
	float commandArgs = tokenize(command);

	switch (argv(0)) {

	default:
		return (false);
	}

	return (true);
}

bool
CodeCallback_ImpulseCommand(entity playerEntity, float impulseNum)
{
	switch (impulseNum) {
	case 100:
		if (AllowFlashlight() == true) {
			ents.Input(playerEntity, "UseItem", "item_suit", playerEntity);
		}
		break;
	default:
		return (false);
	}

	return (true);
}
