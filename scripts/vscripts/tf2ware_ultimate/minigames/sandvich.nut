minigame <- Ware_MinigameData
({
	name           = "Sandvich"
	author         = "ficool2"
	description    =
	[
		"Give Medic your Sandvich!"
		"Eat a Sandvich!"
	]
	duration       = 4.0
	music          = "actioninsilence"
	custom_overlay = 
	[
		"sandvich_heavy"
		"sandvich_medic"
	]
	min_players    = 2
	convars        =
	{
		mp_teams_unbalance_limit = 0
	}
})

function OnStart()
{
	local heavy_team = RandomInt(TF_TEAM_RED, TF_TEAM_BLUE)
	foreach (player in Ware_MinigamePlayers)
	{			
		if (player.GetTeam() == heavy_team)
		{
			Ware_SetPlayerMission(player, 0)
			Ware_SetPlayerClass(player, TF_CLASS_HEAVYWEAPONS)
			Ware_SetPlayerTeam(player, heavy_team)			
			Ware_GivePlayerWeapon(player, "Sandvich")
		}
		else
		{
			Ware_SetPlayerMission(player, 1)
			Ware_SetPlayerClass(player, TF_CLASS_MEDIC)
			player.SetHealth(1)
			Ware_SetPlayerTeam(player, heavy_team)		
		}
	}
}

function OnGameEvent_player_healed(params)
{
	local player = GetPlayerFromUserID(params.patient)
	local healer = GetPlayerFromUserID(params.healer)
	if (player && healer && player != healer && Ware_GetPlayerMission(healer) == 0)
	{
		Ware_PassPlayer(player, true)
		Ware_PassPlayer(healer, true)
	}
}
