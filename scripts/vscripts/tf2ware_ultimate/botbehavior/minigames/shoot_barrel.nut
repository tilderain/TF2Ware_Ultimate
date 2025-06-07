function OnUpdate(bot)
{
    local prop = Ware_MinigameScope.barrel

	if (prop)
	{
    	local loco = bot.GetLocomotionInterface()
		if (prop) //may die midscript
        	local dest = prop.GetOrigin()
        
    	loco.FaceTowards(dest)
		BotLookAt(bot, dest, 99999.0, 99999.0)
    	loco.Approach(prop.GetCenter(), 999.0)
			bot.PressFireButton(-1)

		if(RandomInt(0,50) == 0)
			EntityEntFire(bot, "SpeakResponseConcept", "TLK_PLAYER_NICESHOT")
    	//if (RandomInt(0,50) == 0)
    	//    loco.Jump()
	}
}
