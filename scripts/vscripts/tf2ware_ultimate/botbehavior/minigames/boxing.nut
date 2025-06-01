
//TODO: bots miss because they're stuck in each other

function OnUpdate(bot)
{
	local prop
	//local data = bot.GetScriptScope().bot_data
	for (prop; prop = Entities.FindByClassname(prop, "player");)
	{
		if (prop && prop.IsPlayer() && (prop.GetTeam() != bot.GetTeam()))
		{
			local dest = prop.GetCenter() + Vector(RandomFloat(-100,100), RandomFloat(-100,100), RandomFloat(-100,100))
			//if (!("dest" in data))
			//	data.dest = dest
			
			BotLookAt(bot, prop.GetCenter(), 350.0, 600.0)
        	local loco = bot.GetLocomotionInterface()
        	loco.FaceTowards(prop.GetCenter())
        	loco.Approach(dest, 999.0)
			if (RandomInt(0,4) == 0)
				bot.PressFireButton(-1)
        	//if (RandomInt(0,50) == 0)
        	//    loco.Jump()

			break
		}
	}
}
