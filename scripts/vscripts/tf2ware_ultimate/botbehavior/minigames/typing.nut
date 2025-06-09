function OnStart(bot)
{
	// TODO scale by difficulty
	local chance = 0.3
	local delay = RandomFloat(0.5, 1.5)
	
	Ware_BotCreateMinigameTimer(bot, function()
	{	
		local minidata = Ware_GetPlayerMiniData(bot)
		if(Ware_MinigameScope.word_typing && "score" in minidata)
		{
			local w = Ware_MinigameScope.word_rotation[minidata.score]
			local word = Ware_BotTryWordTypo(bot, w.tostring(), chance)

			//todo disable visibility
			Say(bot, word, false)
		}
		if(bot.IsAlive())
			return delay
	}, delay)
}