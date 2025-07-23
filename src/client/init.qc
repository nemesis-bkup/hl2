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

/*
=================
ClientGame_Init

Comparable to worldspawn in SSQC in that it's mostly used for precaches
=================
*/
void
ClientGame_Init(float apilevel, string enginename, float engineversion)
{
	registercommand("chooseteam");
	registercommand("printSpawnList");

	registercommand("lastinv");
	registercommand("invnext");
	registercommand("invprev");
}

void VGUI_ShowMOTD();

void
ClientGame_InitDone(void)
{
	VGUI_ShowMOTD();

	Font_Load("fonts/tool.font", FONT_TOOL);

	bool gameTitle = serverkeyfloat("gametitle");

	if (gameTitle == true) {
		pSeatLocal->m_flTitleAlpha = 4.0f;
	}
}

void
ClientGame_RendererRestart(string rstr)
{
	HUD_Init();
	Animation_Init();

	BEAM_TRIPMINE = particleeffectnum("weapon_slam.beam");
}
