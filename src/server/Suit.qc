class
hl2Suit:ncItem
{
	void hl2Suit(void);

	virtual void OnUse(entity usingEntity);
};


void
hl2Suit:: hl2Suit(void)
{

}

void
hl2Suit::OnUse(entity userEntity)
{
	if (userEntity.gflags & GF_FLASHLIGHT) {
		userEntity.gflags &= ~GF_FLASHLIGHT;
		StartSoundDef("HL2Player.FlashLightOff", CHAN_ITEM, true);
	} else {
		userEntity.gflags |= GF_FLASHLIGHT;
		StartSoundDef("HL2Player.FlashLightOn", CHAN_ITEM, true);
	}
}
