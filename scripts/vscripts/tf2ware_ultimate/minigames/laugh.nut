
// NB: In microtf2, the game checks just for if the scout
// has been hit, not whether or not they actually laughed.
// This is not desirable as it is uninituitive for scout team.
// It is perhaps more fair for heavy team.
// For now, this minigame will only fail a scout if they laugh.
// However, this minigame will eventually either make scouts
// laugh even if mid-air, or disallow jumping altogether (or
// something else).
// - pokemonpasta

local heavy_team = RandomInt(TF_TEAM_RED, TF_TEAM_BLUE);

minigame <- Ware_MinigameData();
minigame.name = "Don't Laugh";
minigame.duration = 4.0;
minigame.music = "brassy";
minigame.min_players = 2;
minigame.allow_damage = true;
minigame.friendly_fire = false;
minigame.start_pass = true;

// Mission 1: Scout Team
minigame.description = "Don't Laugh!";
minigame.custom_overlay = "laugh_scout";

// Mission 2: Heavy Team
minigame.description2 = "Make the Scouts Laugh!";
minigame.custom_overlay2 = "laugh_heavy";

function OnStart()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		
		// prevent taunting
		player.AddCond(TF_COND_GRAPPLED_TO_PLAYER);
		
		if (data.team == heavy_team)
		{
			Ware_SetPlayerMission(player, 2);
			Ware_SetPlayerClass(player, TF_CLASS_HEAVYWEAPONS);
			Ware_GivePlayerWeapon(player, "Holiday Punch");
			// give crits so holiday punch always makes laugh
			player.AddCond(TF_COND_CRITBOOSTED);
			// default to fail unless they make a scout laugh
			Ware_PassPlayer(player, false);
		}
		else
		{
			Ware_SetPlayerMission(player, 1);
			Ware_SetPlayerClass(player, TF_CLASS_SCOUT);
		}
	}
}

function OnTakeDamage(params)
{
	local victim = params.const_entity;
	local attacker = params.attacker;
	if (victim.IsPlayer() && attacker.IsPlayer())
	{
		params.damage = 0.0;
		victim.RemoveCond(TF_COND_GRAPPLED_TO_PLAYER);
		Ware_CreateTimer(@() CheckTaunt(victim, attacker), 0.0);
	}
}

function CheckTaunt(victim, attacker)
{
	victim.AddCond(TF_COND_GRAPPLED_TO_PLAYER);
	if (victim.GetTeam() != heavy_team &&
		attacker.GetTeam() == heavy_team &&
		victim.IsTaunting()
		)
	{
		Ware_PassPlayer(victim, false);
		Ware_PassPlayer(attacker, true);
	}
}

function OnEnd()
{
	foreach(data in Ware_MinigamePlayers)
	{
		local player = data.player;
		player.RemoveCond(TF_COND_CRITBOOSTED);
		player.RemoveCond(TF_COND_GRAPPLED_TO_PLAYER);
	}
}
