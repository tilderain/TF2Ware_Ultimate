//todo forward vector and before line

function OnUpdate(bot)
{
    local prop = FindByClassnameNearest("prop_soccer_ball", bot.GetOrigin(), 2000)

	if (prop)
	{
    	local loco = bot.GetLocomotionInterface()
        local dest = prop.GetOrigin()
        
    	loco.FaceTowards(dest)
		BotLookAt(bot, dest, 99999.0, 99999.0)
    	loco.Approach(prop.GetCenter(), 999.0)

		if (RandomInt(0,4) == 0)
			bot.PressFireButton(-1)
    	//if (RandomInt(0,50) == 0)
    	//    loco.Jump()
	}
}
