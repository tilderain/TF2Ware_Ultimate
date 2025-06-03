
//TODO: actually target players??

function OnUpdate(bot)
{
	local dest = Ware_MinigameLocation.center

	BotLookAt(bot, dest, 9999.0, 9999.0)
    local loco = bot.GetLocomotionInterface()
    loco.FaceTowards(dest)
    loco.Approach(dest, 999.0)
	if (RandomInt(0,2) == 0)
		bot.PressSpecialFireButton(-1)
    //if (RandomInt(0,50) == 0)
    //    loco.Jump()
}

