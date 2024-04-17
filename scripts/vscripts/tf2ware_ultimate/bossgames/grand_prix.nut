
minigame <- Ware_MinigameData();
minigame.name = "Grand Prix";
minigame.music = "grandprix";
minigame.description = "Grand Prix! Complete 5 laps to win!";
minigame.duration = 120.0;
minigame.location = "kart_containers";
minigame.allow_damage = true;
minigame.end_delay = 0.5;


endzone_vector <- Vector(-1250, 4450, -5960)
// NB: Adjust Z value here if people aren't getting the checkpoint or are getting it when they shouldn't be.
checkpoint_vector <- Vector(-1000, 4400, -5760)

function IsInEndZone(player)
{
	return (player.GetOrigin().x > endzone_vector.x &&
			player.GetOrigin().y > endzone_vector.y &&
			player.GetOrigin().z > endzone_vector.z);
}

function IsInCheckPoint(player)
{
	return (player.GetOrigin().x > checkpoint_vector.x &&
			player.GetOrigin().y < checkpoint_vector.y &&
			player.GetOrigin().z > checkpoint_vector.z);
}

function OnStart()
{
	// put everyone in karts and freeze them
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		local minidata = Ware_GetPlayerMiniData(player);
		player.AddCond(TF_COND_HALLOWEEN_KART);
		player.AddCond(TF_COND_HALLOWEEN_KART_CAGE);
		
		// scope lap variables
		minidata.in_endzone <- false
		minidata.lapcount <- 0
		minidata.passed_checkpoint <- true
	}
	
	// start a countdown
	local timer = 5;
	Ware_CreateTimer(function()
	{
		Ware_ShowGlobalScreenOverlay(format("hud/tf2ware_ultimate/countdown_%s", timer.tostring()));
		if (timer > 0)
		{
			PrecacheSound(format("vo/announcer_begins_%ssec.mp3", timer.tostring()));
			PlaySoundOnAllClients(format("vo/announcer_begins_%ssec.mp3", timer.tostring()), 1.0, 100 * Ware_GetPitchFactor());
		}
		
		timer--;
		
		if (timer >= 0)
			return 1.0;
		else
		{
			// when hits 0, unfreeze players
			foreach(data in Ware_MinigamePlayers)
				data.player.RemoveCond(TF_COND_HALLOWEEN_KART_CAGE);
			Ware_ShowGlobalScreenOverlay("hud/tf2ware_ultimate/minigames/grand_prix");
		}
	}, 0.0);
}

function OnUpdate()
{
	foreach(data in Ware_MinigamePlayers)
	{
		local player = data.player;
		local minidata = Ware_GetPlayerMiniData(player);
		
		if (Ware_IsPlayerPassed(player))
			continue;
		
		if (minidata.lapcount >= 5)
		{
			Ware_PassPlayer(player, true);
			continue;
		}
		
		if (IsInCheckPoint(player))
		{
			minidata.passed_checkpoint <- true
			continue;
		}
		
		if (!minidata.passed_checkpoint)
			continue;
		
		// func_endzone gets the player's actual current position. bool_endzone tracks whether we already know if they're in the endzone
		local func_endzone = IsInEndZone(player);
		local bool_endzone = minidata.in_endzone;
		
		// If both have the same state we don't need to do anything
		if (func_endzone == bool_endzone)
			continue;
		
		if (func_endzone && !bool_endzone)
		{
			// In this case we just entered the endzone
			minidata.in_endzone <- true
			Ware_ShowScreenOverlay(player, "hud/tf2ware_ultimate/minigames/grand_prix_turbo_boost");
			minidata.lapcount++;
			minidata.passed_checkpoint <- false
			continue;
		}
		
		if (!func_endzone && bool_endzone)
		{
			// In this case we just left the endzone
			minidata.in_endzone <- false
			Ware_ShowScreenOverlay(player, "hud/tf2ware_ultimate/minigames/grand_prix");
			continue;
		}
	}
}

function OnEnd()
{
	foreach(data in Ware_MinigamePlayers)
	{
		local player = data.player;
		player.RemoveCond(TF_COND_HALLOWEEN_KART);
		player.RemoveCond(TF_COND_HALLOWEEN_KART_CAGE);
	}
}
