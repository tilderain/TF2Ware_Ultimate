local mode = RandomInt(0, 1);

minigame <- Ware_MinigameData();
minigame.name = "Move";
minigame.description = mode == 0 ? "Move!" : "Don't Move!";
minigame.duration = 4.0;
minigame.music = "actioninsilence";
minigame.start_pass = true;
minigame.fail_on_death = true;
minigame.custom_overlay = mode == 0 ? "move" : "dont_move";

function OnUpdate()
{
	if (Ware_GetMinigameTime() < 2.0)
		return;
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		if (!IsEntityAlive(player))
			continue;
		
		if (mode == 0)
		{
			if (player.GetAbsVelocity().Length() < 75.0)
				Ware_SuicidePlayer(player);
		}
		else if (mode == 1)
		{
			if (player.GetAbsVelocity().Length() > 5.0)
				Ware_SuicidePlayer(player);	
		}				
	}
}