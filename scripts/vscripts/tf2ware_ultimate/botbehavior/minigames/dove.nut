//TODO: shoot at random birds

local arrow_speed = 1800    // hammer units/s

function OnUpdate(bot)
{
    local prop = FindByClassnameNearest("base_boss", bot.GetOrigin(), 2500)
	if (prop)
	{
    	local loco = bot.GetLocomotionInterface()
        local dest = BotCalculateAimPosition(bot.GetOrigin(), prop.GetCenter(), prop.GetAbsVelocity(), 1800)
    	loco.FaceTowards(dest)
		BotLookAt(bot, dest, 9999.0, 9999.0)
    	loco.Approach(prop.GetCenter(), 999.0)
		if (RandomInt(0,4) == 0)
			bot.PressFireButton(-1)
    	//if (RandomInt(0,50) == 0)
    	//    loco.Jump()
	}
}
