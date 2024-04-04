minigame <- Ware_MinigameData();
minigame.name = "Goomba";
minigame.description = "Don't get jumped on!"
minigame.description2 = "Jump on a Heavy's head!"
minigame.duration = 4.0;
minigame.music = "clumsy";
minigame.min_players = 2;
minigame.start_pass = false;
minigame.allow_damage = true;
minigame.fail_on_death = true;
minigame.custom_overlay = "dont_jumped";
minigame.custom_overlay2 = "jump_heavy";

local jump_team;

function OnStart()
{
	jump_team = RandomInt(TF_TEAM_RED, TF_TEAM_BLUE);
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
					
		if (data.team == jump_team)
		{
			Ware_SetPlayerMission(player, 2);
			Ware_SetPlayerClass(player, TF_CLASS_SCOUT);
		}
		else
		{
			Ware_SetPlayerMission(player, 1);
			Ware_SetPlayerClass(player, TF_CLASS_HEAVYWEAPONS);
			Ware_PassPlayer(player, true); // TODO: this wont play nicely with vfx
		}
	}	
}

function OnUpdate()
{
	foreach (data in Ware_MinigamePlayers)
	{
		if (data.team == jump_team)
		{
			local player = data.player;
			if (IsEntityAlive(player))
			{
				local ground = GetPropEntity(player, "m_hGroundEntity");
				if (ground != null && ground.IsPlayer() && ground.GetTeam() != jump_team)
				{
					Ware_PassPlayer(player, true);

					ground.TakeDamageCustom(
						player, player, null, Vector(), Vector(), 
						1000.0, DMG_FALL, TF_DMG_CUSTOM_BOOTS_STOMP);
					ScreenShake(ground.GetCenter(), 15.0, 150.0, 1.0, 500, 0, true);
				}
			}
		}
	}
}

function OnTakeDamage(params)
{
	return params.damage_stats == TF_DMG_CUSTOM_BOOTS_STOMP;
}