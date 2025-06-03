
function OnUpdate(bot)
{
    local prop = FindByClassnameNearest("prop_dynamic", bot.GetOrigin(), 1000)
    local prop2 = FindByClassnameNearest("prop_physics", bot.GetOrigin(), 2000)
    if (prop)
    {
        local dest = prop.GetOrigin()
        if (prop2)
            dest = prop2.GetOrigin()
        BotLookAt(bot, dest, 888.0, 888.0)
        local loco = bot.GetLocomotionInterface()
        loco.FaceTowards(dest)
        loco.Approach(dest, 999.0)
		if (RandomInt(0,4) == 0)
			bot.PressFireButton(-1)
        if (RandomInt(0,50) == 0)
            loco.Jump()
    }
}
