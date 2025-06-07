function OnUpdate(bot)
{
	local prop
	if (Ware_MinigameScope.gifts_active.len())
    	prop = RandomElement(Ware_MinigameScope.gifts_active)

	if (prop)
	{
    	local loco = bot.GetLocomotionInterface()
        local dest = prop.gift.GetOrigin()
        
    	loco.FaceTowards(dest)
		BotLookAt(bot, dest, 99999.0, 99999.0)
    	loco.Approach(prop.gift.GetCenter(), 999.0)
			bot.PressFireButton(-1)

		if(RandomInt(0,50) == 0)
			EntityEntFire(bot, "SpeakResponseConcept", "TLK_PLAYER_NICESHOT")

    	//if (RandomInt(0,50) == 0)
    	//    loco.Jump()
	}
}
