class
HL2Suit:ncItem
{
	void HL2Suit(void);

	virtual void OnUse(entity usingEntity);
};


void
HL2Suit::HL2Suit(void)
{

}

void
HL2Suit::OnUse(entity userEntity)
{
	if (userEntity.gflags & GF_FLASHLIGHT) {
		userEntity.gflags &= ~GF_FLASHLIGHT;
		StartSoundDef("HL2Player.FlashLightOff", CHAN_ITEM, true);
	} else {
		userEntity.gflags |= GF_FLASHLIGHT;
		StartSoundDef("HL2Player.FlashLightOn", CHAN_ITEM, true);
	}
}
