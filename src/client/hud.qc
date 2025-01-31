void
HUD_Init(void)
{
	HUDProgs_Init();
}

void
HUD_Draw(void)
{
	ncPlayer pl = (ncPlayer)pSeat->m_ePlayer;
	g_hud_color = [1, 0.75f, 0.25];

	/* little point in not drawing these, even if you don't have a suit */
	if (pl.m_activeWeapon) {
		pl.m_activeWeapon.UpdateGUI();
	}

	HUDProgs_Draw();
//	pSeatLocal->weaponSelectionHUD.Draw();
}
