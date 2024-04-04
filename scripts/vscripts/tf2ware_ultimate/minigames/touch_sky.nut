minigame <- Ware_MinigameData();
minigame.name = "Touch Sky";
minigame.description = "Touch the Sky!";
minigame.duration = 10.0;
minigame.end_delay = 0.2;
minigame.music = "golden";

highest_player <- null;
highest_height <- 0.0;

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SCOUT, null, { "air dash count" : 9999 });
}

function OnUpdate()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		if (!IsEntityAlive(player))
			continue;		
			
		// fix pitch going out of bounds
		if (GetPropInt(player, "m_Shared.m_iAirDash") > 9)
			SetPropInt(player, "m_Shared.m_iAirDash", 9);
		
		local height = Ware_GetPlayerHeight(player);
		if (height > highest_height)
		{
			highest_player = player;
			highest_height = height;
		}
		
		if (height > 1500.0)
			Ware_PassPlayer(player, true);		
	}
}

function OnEnd()
{
	if (highest_height > 512.0 && highest_player.IsValid())
	{
		Ware_ChatPrint(null, "{player} {color}reached the highest point at {str} HU!",
							highest_player, TF_COLOR_DEFAULT, format("%.1f", highest_height));
	}
}