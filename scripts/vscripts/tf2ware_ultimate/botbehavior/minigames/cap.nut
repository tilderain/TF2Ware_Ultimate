
//TODO: actually target players??

function OnUpdate(bot)
{
    local prop = FindByClassnameNearest("trigger_capture_area", bot.GetOrigin(), 3000)
	local dest = Vector()
    if (prop)
        dest = prop.GetCenter()

	BotLookAt(bot, dest, 9999.0, 9999.0)
    local loco = bot.GetLocomotionInterface()
    loco.FaceTowards(dest)
    loco.Approach(dest, 999.0)
	if (RandomInt(0,2) == 0)
		bot.PressSpecialFireButton(-1)
    //if (RandomInt(0,50) == 0)
    //    loco.Jump()
}

