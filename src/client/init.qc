/*
 * Copyright (c) 2016-2025 Marco Cawthorne <marco@icculus.org>
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
ClientGame_Init(float apilevel, string enginename, float engineversion)
{
	registercommand("printSpawnList");

	registercommand("lastinv");
	registercommand("invnext");
	registercommand("invprev");
	registercommand("showSpawnMenu");
}

void
ClientGame_InitDone(void)
{
	bool gameTitle = serverkeyfloat("gametitle");

	if (gameTitle == true) {
		pSeatLocal->m_flTitleAlpha = 4.0f;
	}
}

void
ClientGame_RendererRestart(string rstr)
{
	BEAM_TRIPMINE = particleeffectnum("weapon_slam.beam");

	font.Load("fonts/scoreboard.font", FONT_SCOREBOARD);
	font.Load("fonts/tool.font", FONT_TOOL);
	font.Load("fonts/scores_norm.font", FONT_SCORES_NORMAL);
	font.Load("fonts/scores_bold.font", FONT_SCORES_BOLD);
}
