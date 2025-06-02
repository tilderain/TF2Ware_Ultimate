function OnUpdate(bot)
{
	local prop

	for (prop; prop = Entities.FindByClassname(prop, "player");)
	{
		if (prop && prop.IsPlayer())
		{
			local dest = prop.GetCenter() + Vector(RandomFloat(-33,33), RandomFloat(-33,33), 1000)

			BotLookAt(bot, prop.GetCenter(), 350.0, 600.0)
        	local loco = bot.GetLocomotionInterface()
        	loco.FaceTowards(prop.GetCenter())
        	loco.Approach(dest, 999.0)
			//if (RandomInt(0,4) == 0)
				bot.PressFireButton(-1)
        	//if (RandomInt(0,1) == 0)
        		loco.Jump()

			break
		}
	}
}
